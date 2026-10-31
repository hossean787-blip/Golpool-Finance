import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:golpool/expense_chart.dart';
import 'package:golpool/backup_service.dart';
import 'package:golpool/financial_reminders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:golpool/finance.dart';
import 'package:golpool/visual_system.dart';
import 'package:golpool/secure_finance_store.dart';
void main()=>runApp(const Golpool());
class Golpool extends StatelessWidget {
 final SecureFinanceStore? store;
 const Golpool({super.key,this.store});
 @override Widget build(BuildContext context)=>MaterialApp(debugShowCheckedModeBanner:false,title:'گل‌پول',theme:GolpoolStyle.theme,home:Home(store:store));
}
class Home extends StatefulWidget {final SecureFinanceStore? store; const Home({super.key,this.store});@override State<Home> createState()=>_HomeState();}
class _HomeState extends State<Home>{
 int tab=0;
 String txSearch='';
 String txFilter='all';
 final List<Map<String,dynamic>> items=[];
 late final SecureFinanceStore secureStore=widget.store??SecureFinanceStore();
 bool dataReady=false;
 bool secureError=false;
 bool remindersEnabled=false;
 bool biometricLock=false;
 bool unlocked=true;
 final FinancialReminders reminders=FinancialReminders();
 Future<void> _writeTail=Future<void>.value();
 @override void initState(){super.initState();_load();}
 Future<void> _load() async {try {final data=await secureStore.load();if(data!=null){final stored=data['items'];if(stored is List){items..clear()..addAll(stored.map((e)=>Map<String,dynamic>.from(e as Map)));}
    final savedCards=data['cards']; if(savedCards is List){cards..clear()..addAll(savedCards.map((x)=>x.toString()));}
    final savedRecurring=data['recurring'];if(savedRecurring is List){recurring..clear()..addAll(savedRecurring.map((e)=>Map<String,dynamic>.from(e as Map)));}
    final savedOpenings=data['openingBalances'];if(savedOpenings is Map){openingBalances..clear()..addAll(savedOpenings.map((k,v)=>MapEntry(k.toString(),(v as num).round())));}
    final savedBudgets=data['budgets']; if(savedBudgets is Map){budgets..clear()..addAll(savedBudgets.map((k,v)=>MapEntry(k.toString(),(v as num).round())));}
    final savedGoals=data['goals']; if(savedGoals is List){goals..clear()..addAll(savedGoals.map((x)=>Map<String,dynamic>.from(x as Map)));}
    remindersEnabled=data['remindersEnabled']==true;
    biometricLock=data['biometricLock']==true;
    final savedDebts=data['debts']; if(savedDebts is List){debts..clear()..addAll(savedDebts.map((x)=>Map<String,dynamic>.from(x as Map)));}}}catch(_){secureError=true;}if(widget.store==null){try{await reminders.initialize();await _refreshReminders();}catch(_){/* not available on this device */}}
   if(biometricLock&&widget.store==null){unlocked=false;}
   if(mounted)setState(()=>dataReady=true);
   if(!unlocked)await unlockDevice();}
 Future<void> _persist() async {
   final state=snapshot();
   final task=_writeTail.then((_)=>secureStore.save(state));
   _writeTail=task.catchError((Object _){});
   try{await task;}catch(_){if(mounted)setState(()=>secureError=true);}
 }
 Future<void> changed() async {if(mounted)setState((){});await _persist();if(!secureError)await _refreshReminders();}
 Future<void> _refreshReminders() async {try{await reminders.update(enabled:remindersEnabled,pendingCount:MoneyMath.pending(items).length);await reminders.updateRecurring(recurring);}catch(_){if(mounted&&widget.store==null)info('زمان‌بندی اعلان‌ها روی این دستگاه ممکن نشد.');}}
 Future<void> toggleReminders(bool value)async{if(value){try{if(!await reminders.enable()){info('مجوز اعلان داده نشد.');return;}}catch(_){info('اعلان روی این دستگاه در دسترس نیست.');return;}}setState(()=>remindersEnabled=value);await _persist();await _refreshReminders();}

 final cards=<String>[];
 final openingBalances=<String,int>{};
 final recurring=<Map<String,dynamic>>[];
 final budgets=<String,int>{};
 final goals=<Map<String,dynamic>>[];
 final debts=<Map<String,dynamic>>[];
 String date(){final d=DateTime.now();return [d.year,d.month.toString().padLeft(2,'0'),d.day.toString().padLeft(2,'0')].join('-');}
 String money(num n)=>GolpoolStyle.money(n);
 Widget tile(String title,String subtitle,{VoidCallback? action})=>GolpoolStyle.panel(child:ListTile(
  contentPadding:const EdgeInsets.symmetric(horizontal:8,vertical:3),
  leading:GolpoolStyle.bubble(title.contains('خرج')?Icons.shopping_bag_outlined:Icons.auto_awesome_rounded),
  title:Text(title,style:const TextStyle(fontWeight:FontWeight.w700,fontSize:14)),
  subtitle:Text(subtitle,style:const TextStyle(color:GolpoolStyle.muted,fontSize:12)),
  trailing:action==null?null:IconButton(onPressed:action,icon:const Icon(Icons.edit_outlined,color:GolpoolStyle.rose))));
 Widget screen(){
  switch(tab){
   case 0:
    final todayAmount=MoneyMath.spentToday(items,date());
    final total=budgets.values.fold<int>(0,(s,n)=>s+n);
    final used=budgets.keys.fold<int>(0,(s,c)=>s+MoneyMath.categorySpent(items,c,date().substring(0,7)));
    return ListView(children:[
      GolpoolStyle.welcomeBanner().animate().fadeIn(duration:500.ms).slideY(begin:-.08,end:0),
      GolpoolStyle.summary(today:money(todayAmount),remaining:money(total-used)),
      GolpoolStyle.section('خرج‌ها به تفکیک دسته'),ExpenseChart(items:items,budgets:budgets),
      GolpoolStyle.section('حساب‌های من'),GolpoolStyle.panel(child:Column(children:cards.map((c)=>ListTile(leading:GolpoolStyle.bubble(Icons.credit_card),title:Text(c),subtitle:Text(MoneyMath.accountBalance(c,openingBalances,items)==null?'مانده اولیه ثبت نشده':money(MoneyMath.accountBalance(c,openingBalances,items)!)))).toList())),
      GolpoolStyle.section('خرج‌های بدون توضیح'),GolpoolStyle.pending(MoneyMath.pending(items).length,()=>setState(()=>tab=1)),GolpoolStyle.section('آخرین تراکنش‌ها'),
      ...items.reversed.take(4).map((t)=>tile(t['note'].toString().isEmpty?'خرج بدون توضیح':t['note'].toString(),money(t['amount'] as num)))]);
   case 1:
    final matching=items.reversed.where((t)=>(txFilter=='all'||t['type']==txFilter)&&
      (txSearch.trim().isEmpty||t['note'].toString().contains(txSearch.trim())||t['category'].toString().contains(txSearch.trim()))).toList();
    return ListView(children:[
    GolpoolStyle.panel(child:TextField(onChanged:(v)=>setState(()=>txSearch=v),
      decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'جست‌وجوی تراکنش‌ها',border:InputBorder.none))),
    Wrap(spacing:8,children:[for(final entry in {'all':'همه','expense':'برداشت','income':'واریز','transfer':'انتقال'}.entries)
      ChoiceChip(label:Text(entry.value),selected:txFilter==entry.key,onSelected:(_)=>setState(()=>txFilter=entry.key))]),
    const SizedBox(height:9),
    ...matching.map((t)=>GolpoolStyle.panel(child:Column(children:[
      ListTile(title:Text(t['note'].toString().isEmpty?'بدون توضیح':t['note'].toString()),
        subtitle:Text(money(t['amount'] as num)),trailing:PopupMenuButton<String>(onSelected:(v){if(v=='edit'){editTx(t);}else if(v=='split'){splitTx(t);}else{deleteTx(t);}},itemBuilder:(_)=>[
        if(t['type']=='expense')const PopupMenuItem(value:'split',child:Text('تقسیم هزینه بین دسته‌ها')),
        if(t['type']!='transfer')const PopupMenuItem(value:'edit',child:Text('ویرایش و دسته‌بندی')),
        const PopupMenuItem(value:'delete',child:Text('حذف تراکنش'))])),
      if(t['receipt'] is String) GestureDetector(onTap:()=>showReceipt(t),child:ClipRRect(
        borderRadius:BorderRadius.circular(14),child:Image.memory(base64Decode(t['receipt'] as String),
        height:110,fit:BoxFit.cover))),
      TextButton.icon(onPressed:()=>attachReceipt(t),icon:const Icon(Icons.add_a_photo_outlined),
        label:Text(t['receipt'] is String?'تعویض تصویر رسید':'افزودن تصویر رسید'))]))),
    if(matching.isEmpty)tile('تراکنشی پیدا نشد','از جست‌وجو یا فیلتر دیگری استفاده کن')]);
   case 2:return ListView(children:[
    GolpoolStyle.section('بودجه‌بندی ماهانه'),
    GolpoolStyle.budgetGauge(spent:MoneyMath.expensesForMonth(items,date().substring(0,7)),limit:budgets.values.fold<int>(0,(a,b)=>a+b)),
    GolpoolStyle.panel(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Text('درآمد ماه: ${money(MoneyMath.incomeForMonth(items,date().substring(0,7)))}'),
      Text('هزینه ماه: ${money(MoneyMath.expensesForMonth(items,date().substring(0,7)))}'),
      Text('خالص ماه: ${money(MoneyMath.incomeForMonth(items,date().substring(0,7))-MoneyMath.expensesForMonth(items,date().substring(0,7)))}')])),
    if(budgets.isEmpty)tile('بودجه‌ای تعریف نشده','در این نسخه بودجه پیش‌فرض ساختگی نمایش داده نمی‌شود.'),
    ...budgets.entries.map((e){
      final used=MoneyMath.categorySpent(items,e.key,date().substring(0,7));
      return InkWell(onTap:()=>editBudget(e.key),child:GolpoolStyle.categoryBudget(e.key,money(used),money(e.value),e.value==0?0:used/e.value));
    })]);
   case 3:return ListView(children:[
    GolpoolStyle.section('هدف‌های پس‌انداز'),
    ...goals.map((g)=>Column(children:[
      if(g['image'] is String)GolpoolStyle.panel(child:ClipRRect(
        borderRadius:BorderRadius.circular(18),child:Image.memory(base64Decode(g['image'] as String),
          height:135,width:double.infinity,fit:BoxFit.cover))),
      GolpoolStyle.goalCard(g['name'].toString(),money(g['saved'] as int),
        money(g['target'] as int),MoneyMath.progress(g['saved'] as int,g['target'] as int)/100,
        ()=>saveGoal(g)),
      TextButton.icon(onPressed:()=>attachGoalPhoto(g),icon:const Icon(Icons.add_photo_alternate_outlined),
        label:const Text('تصویر هدف'))
    ])),
    ...goals.map((g)=>Row(children:[Expanded(child:OutlinedButton.icon(onPressed:()=>editGoal(g),icon:const Icon(Icons.tune),label:Text('مدیریت ${g['name']}'))),const SizedBox(width:9),IconButton(onPressed:()=>goalHistory(g),icon:const Icon(Icons.history),tooltip:'تاریخچه هدف')])),
    FilledButton.icon(onPressed:addGoal,icon:const Icon(Icons.add),label:const Text('هدف جدید'))]);
   default:return ListView(children:[
    tile('کارت‌های بانکی',cards.join('، ')),
    FilledButton(onPressed:addCard,child:const Text('افزودن کارت')),
    OutlinedButton.icon(onPressed:transferMoney,icon:const Icon(Icons.swap_horiz),label:const Text('انتقال بین حساب‌ها')),
    OutlinedButton.icon(onPressed:editOpeningBalance,icon:const Icon(Icons.account_balance_wallet_outlined),label:const Text('تنظیم مانده اولیه حساب')),

    FilledButton.tonal(onPressed:addBudget,child:const Text('تعریف بودجه ماهانه')),
    GolpoolStyle.panel(child:SwitchListTile(
      title:const Text('یادآوری شبانه'),
      subtitle:const Text('۲۱:۰۰ و ۲۲:۳۰، فقط وقتی خرج نامشخص باقی مانده باشد؛ ساعت تقریبی'),
      value:remindersEnabled,onChanged:toggleReminders)),
    GolpoolStyle.panel(child:SwitchListTile(title:const Text('قفل ورود دستگاه'),subtitle:const Text('استفاده از اثر انگشت، چهره یا رمز دستگاه در صورت پشتیبانی'),value:biometricLock,onChanged:toggleBiometrics)),
    GolpoolStyle.section('پشتیبان‌گیری امن'),
    GolpoolStyle.panel(child:Column(children:[
      const Text('فایل پشتیبان با رمز انتخابی شما رمزگذاری می‌شود. رمز را فراموش نکنید.'),
      const SizedBox(height:12),
      FilledButton.icon(onPressed:exportBackup,icon:const Icon(Icons.lock_outline),label:const Text('خروجی رمزگذاری‌شده')),
      OutlinedButton.icon(onPressed:importBackup,icon:const Icon(Icons.restore),label:const Text('بازیابی از فایل'))])),
    GolpoolStyle.section('هزینه‌های تکراری'),
    ...recurring.map(recurringTile),
    FilledButton.tonalIcon(onPressed:addRecurring,icon:const Icon(Icons.add),label:const Text('هزینه تکراری جدید')),
    ...debts.map((d)=>GolpoolStyle.panel(child:ListTile(title:Text(d['person'].toString()),subtitle:Text(money(d['amount'] as num)),trailing:Switch(value:d['settled']==true,onChanged:(v){d['settled']=v;changed();})))),
    FilledButton(onPressed:addDebt,child:const Text('ثبت قرض'))]);
  }
 }
 Future<void> unlockDevice()async {
   final success=await DeviceUnlock().unlock();
   if(mounted)setState(()=>unlocked=success);
 }
 Future<void> toggleBiometrics(bool enabled)async {
   if(enabled){
     final ok=await DeviceUnlock().unlock();
     if(!ok){info('احراز هویت دستگاه موفق نشد؛ قفل فعال نشد.');return;}
   }
   setState(()=>biometricLock=enabled);
   await _persist();
 }
 Map<String,dynamic> snapshot()=>{'items':items,'cards':cards,'openingBalances':openingBalances,'recurring':recurring,'budgets':budgets,'goals':goals,'debts':debts,'remindersEnabled':remindersEnabled,'biometricLock':biometricLock};
 Future<String?> passwordPrompt(String title) async {
   final c=TextEditingController();
   final value=await showDialog<String>(context:context,builder:(ctx)=>AlertDialog(
     title:Text(title),content:TextField(controller:c,obscureText:true,
       decoration:const InputDecoration(hintText:'حداقل ۱۲ نویسه')),
     actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('انصراف')),
       FilledButton(onPressed:()=>Navigator.pop(ctx,c.text),child:const Text('تأیید'))]));
   c.dispose();return value;
 }
 void info(String message){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(message)));}
 Future<void> attachReceipt(Map<String,dynamic> transaction) async {
   try{
     final image=await ImagePicker().pickImage(source:ImageSource.gallery,imageQuality:50,maxWidth:1100);
     if(image==null)return;
     final bytes=await image.readAsBytes();
     if(bytes.length>280000){info('حجم تصویر زیاد است؛ تصویر کوچک‌تری انتخاب کنید.');return;}
     final previous=transaction['receipt'];
     transaction['receipt']=base64Encode(bytes);
     await _persist();if(secureError){if(previous==null){transaction.remove('receipt');}else{transaction['receipt']=previous;}return;}
     if(mounted)setState((){});
     info('رسید ذخیره شد.');
   }catch(_){info('دسترسی به تصویر یا ذخیره آن ممکن نشد.');}
 }
 Future<void> attachGoalPhoto(Map<String,dynamic> goal)async{
   try{
     final picked=await ImagePicker().pickImage(source:ImageSource.gallery,
       maxWidth:900,imageQuality:48);
     if(picked==null)return;
     final bytes=await picked.readAsBytes();
     if(bytes.length>220000){info('تصویر هدف بیش از حد بزرگ است.');return;}
     final old=goal['image'];
     goal['image']=base64Encode(bytes);
     await _persist();
     if(secureError){goal['image']=old;return;}
     if(mounted)setState((){});
   }catch(_){info('انتخاب تصویر هدف انجام نشد.');}
 }
 Future<void> showReceipt(Map<String,dynamic> transaction)async{
   final b=transaction['receipt'];
   if(b is! String)return;
   try {await showDialog<void>(context:context,builder:(ctx)=>Dialog(
     child:InteractiveViewer(child:Image.memory(base64Decode(b),fit:BoxFit.contain))));}
   catch(_){info('تصویر رسید آسیب دیده است.');}
 }
 Future<void> exportBackup()async{
   final pass=await passwordPrompt('رمز جدید پشتیبان');
   if(pass==null)return;
   if(pass.length<12){info('رمز باید حداقل ۱۲ نویسه باشد.');return;}
   try{
     final payload=await GolpoolBackup.encrypt(snapshot(),pass);
     final file=File('${Directory.systemTemp.path}/golpool-backup-${DateTime.now().millisecondsSinceEpoch}.golpool');
     await file.writeAsString(payload,flush:true);
     await SharePlus.instance.share(ShareParams(files:[XFile(file.path)],
       subject:'پشتیبان رمزگذاری‌شده گل‌پول'));
     // Temporary shared files can remain in the OS cache; never use public cloud links by default.
   }catch(_){info('ساخت یا اشتراک‌گذاری پشتیبان انجام نشد.');}
 }
 Future<void> importBackup()async{
   final selected=await FilePicker.pickFiles();
   if(selected.isEmpty)return;
   final f=selected.single;
   if((f.lengthSync()??await f.length()??20000001)>20000000){info('فایل بزرگ‌تر از حد مجاز است.');return;}
   final pass=await passwordPrompt('رمز پشتیبان');
   if(pass==null)return;
   try{
     final raw=await f.readAsBytes();
     final result=await GolpoolBackup.decrypt(utf8.decode(raw),pass);
     if(!mounted)return;
     final confirm=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
       title:const Text('جایگزینی اطلاعات'),
       content:const Text('تمام اطلاعات فعلی با داده‌های پشتیبان جایگزین می‌شود. ادامه می‌دهید؟'),
       actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('انصراف')),
         FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('بازیابی'))]));
     if(confirm!=true)return;
     // Backup files may not silently enable or disable the device lock.
     result['biometricLock']=biometricLock;
     await _writeTail;
     await secureStore.save(result);
     if(!mounted)return;
     setState((){items..clear()..addAll((result['items'] as List).map((x)=>Map<String,dynamic>.from(x as Map)));
       cards..clear()..addAll((result['cards'] as List).map((x)=>x.toString()));
       openingBalances..clear()..addAll((result['openingBalances'] is Map ? (result['openingBalances'] as Map) : <String,int>{}).map((k,v)=>MapEntry(k.toString(),(v as num).round())));
       recurring..clear()..addAll((result['recurring'] is List ? (result['recurring'] as List) : <dynamic>[]).map((e)=>Map<String,dynamic>.from(e as Map)));
       budgets..clear()..addAll((result['budgets'] as Map).map((k,v)=>MapEntry(k.toString(),(v as num).round())));
       goals..clear()..addAll((result['goals'] as List).map((x)=>Map<String,dynamic>.from(x as Map)));
       debts..clear()..addAll((result['debts'] as List).map((x)=>Map<String,dynamic>.from(x as Map)));
       remindersEnabled=result['remindersEnabled']==true;
       biometricLock=result['biometricLock']==true;});
     await _refreshReminders();
     info('بازیابی موفق بود.');
   }catch(_){info('رمز نادرست یا فایل نامعتبر است؛ اطلاعات تغییر نکرد.');}
 }
 Future<String?> ask(String title)async{
  final controller=TextEditingController();
  final result=await showDialog<String>(context:context,builder:(ctx)=>AlertDialog(title:Text(title),content:TextField(controller:controller,keyboardType:TextInputType.text),actions:[
    TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('لغو')),
    FilledButton(onPressed:()=>Navigator.pop(ctx,controller.text),child:const Text('ثبت'))]));
  controller.dispose();return result;
 }
 Future<void> addTx()async{
  final kind=await showDialog<String>(context:context,builder:(ctx)=>SimpleDialog(title:const Text('ثبت تراکنش'),children:[SimpleDialogOption(onPressed:()=>Navigator.pop(ctx,'expense'),child:const Text('هزینه')),SimpleDialogOption(onPressed:()=>Navigator.pop(ctx,'income'),child:const Text('درآمد'))]));
  if(kind==null)return;
  final sum=int.tryParse(await ask('مبلغ (تومان)')??'');
  if(sum==null||sum<=0)return;
  final note=await ask('توضیح هزینه (اختیاری)');
  if(note==null)return;
  final category=await ask('دسته‌بندی (مثلاً خوراک یا حقوق)');if(category==null)return;
  String? account;
  if(cards.isNotEmpty){if(!mounted)return;account=await chooseAccount('حساب مرتبط');if(account==null)return;}
  if(kind=='expense'&&account!=null){
    final bal=MoneyMath.accountBalance(account,openingBalances,items);
    if(bal!=null&&sum>bal){info('مبلغ بیشتر از مانده حساب است.');return;}
  }
  items.add({'type':kind,'date':date(),'amount':sum,'note':note,
    'category':category.trim().isEmpty?'سایر':category.trim(),'account':account});await changed();
 }
 Future<void> explain(Map<String,dynamic> t)async{final s=await ask('توضیح تراکنش');if(s!=null&&s.trim().isNotEmpty){t['note']=s.trim();changed();}}
 Future<void> splitTx(Map<String,dynamic> transaction)async{
   if(transaction['type']!='expense')return;
   final total=(transaction['amount'] as num).round();
   final first=await ask('دسته بخش اول');if(first==null||first.trim().isEmpty)return;
   final firstAmount=int.tryParse(await ask('مبلغ بخش اول')??'');
   if(firstAmount==null||firstAmount<=0||firstAmount>=total){info('مبلغ بخش اول نامعتبر است.');return;}
   final second=await ask('دسته بخش دوم');if(second==null||second.trim().isEmpty)return;
   final parts=<Map<String,dynamic>>[
     {'category':first.trim(),'amount':firstAmount},
     {'category':second.trim(),'amount':total-firstAmount}
   ];
   if(!MoneyMath.validateParts(total,parts)){info('مجموع مبالغ باید برابر تراکنش باشد.');return;}
   transaction['parts']=parts;transaction['category']='چندبخشی';await changed();
 }
 Future<void> editTx(Map<String,dynamic> tx)async{
   if(tx['type']=='transfer'){info('برای اصلاح انتقال، آن را حذف و دوباره ثبت کن.');return;}
   final amount=int.tryParse(await ask('مبلغ جدید (تومان)')??'');
   if(amount==null||amount<=0)return;
   final note=await ask('توضیح جدید');if(note==null)return;
   final category=await ask('دسته هزینه یا درآمد');if(category==null||category.trim().isEmpty)return;
   if(!mounted)return;
   final kind=await showDialog<String>(context:context,builder:(ctx)=>SimpleDialog(title:const Text('نوع تراکنش'),
      children:[SimpleDialogOption(onPressed:()=>Navigator.pop(ctx,'expense'),child:const Text('هزینه')),
                SimpleDialogOption(onPressed:()=>Navigator.pop(ctx,'income'),child:const Text('درآمد'))]));
   if(kind==null)return;
   tx.remove('parts');
   tx..['amount']=amount..['note']=note.trim()..['category']=category.trim()..['type']=kind;
   await changed();
 }
 Future<void> deleteTx(Map<String,dynamic> tx)async{
   final yes=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
     title:const Text('حذف تراکنش'),content:const Text('این تراکنش و تصویر رسید آن حذف می‌شود.'),
     actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('انصراف')),
       FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('حذف'))]));
   if(yes==true){items.remove(tx);await changed();}
 }
 Future<void> editBudget(String category)async{
   final value=int.tryParse(await ask('سقف جدید $category (تومان)')??'');
   if(value==null||value<0)return;
   if(value==0){budgets.remove(category);}else{budgets[category]=value;}
   await changed();
 }
 Future<void> goalHistory(Map<String,dynamic> goal)async{
   final rows=goal['history'];
   if(!mounted)return;
   await showDialog<void>(context:context,builder:(ctx)=>AlertDialog(
     title:Text('تاریخچه ${goal['name']}'),
     content:SizedBox(width:300,child:rows is List&&rows.isNotEmpty?
       ListView(shrinkWrap:true,children:rows.reversed.map((r)=>ListTile(
         title:Text(money((r['amount'] as num).abs())),
         subtitle:Text(r['date'].toString()),
         leading:Icon((r['amount'] as num)<0?Icons.remove_circle_outline:Icons.add_circle_outline,
           color:(r['amount'] as num)<0?GolpoolStyle.rose:GolpoolStyle.mint))).toList()):
       const Text('هنوز تراکنشی برای این هدف ثبت نشده است.')),
     actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('بستن'))]));
 }
 Future<void> editGoal(Map<String,dynamic> goal)async{
   final action=await showDialog<String>(context:context,builder:(ctx)=>SimpleDialog(title:Text(goal['name'].toString()),
     children:[SimpleDialogOption(onPressed:()=>Navigator.pop(ctx,'rename'),child:const Text('ویرایش نام و مبلغ هدف')),
       SimpleDialogOption(onPressed:()=>Navigator.pop(ctx,'withdraw'),child:const Text('برداشت از پس‌انداز')),
       SimpleDialogOption(onPressed:()=>Navigator.pop(ctx,'delete'),child:const Text('حذف هدف'))]));
   if(action=='rename'){
     final name=await ask('نام جدید هدف');if(name==null||name.trim().isEmpty)return;
     final target=int.tryParse(await ask('مبلغ جدید هدف')??'');if(target==null||target<=0)return;
     goal['name']=name.trim();goal['target']=target;await changed();
   }else if(action=='withdraw'){
     final value=int.tryParse(await ask('مبلغ برداشت از پس‌انداز')??'');
     if(value==null||value<=0||value>(goal['saved'] as num))return;
     goal['saved']=(goal['saved'] as num).round()-value;
     (goal['history']??=<Map<String,dynamic>>[]).add({'date':date(),'amount':-value});await changed();
   }else if(action=='delete'){
     if(!mounted)return;
     final confirmed=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
       title:const Text('حذف هدف'),content:const Text('پس‌انداز ثبت‌شده در این هدف از سوابق حذف می‌شود.'),
       actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('انصراف')),
         FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('حذف'))]));
     if(confirmed==true){goals.remove(goal);await changed();}
   }
 }
 Future<void> addGoal()async{
  final name=await ask('نام هدف');if(name==null||name.isEmpty)return;
  final sum=int.tryParse(await ask('مبلغ هدف')??'');if(sum!=null&&sum>0){goals.add({'name':name,'saved':0,'target':sum});changed();}
 }
 Future<void> saveGoal(Map<String,dynamic> g)async{
  final sum=int.tryParse(await ask('مبلغ پس‌انداز')??'');if(sum!=null&&sum>0){g['saved']=(g['saved'] as int)+sum;
    (g['history']??=<Map<String,dynamic>>[]).add({'date':date(),'amount':sum});await changed();}
 }
 Future<void> addCard()async{
  final name=await ask('نام کارت یا بانک');
  if(name==null||name.trim().isEmpty||cards.contains(name.trim()))return;
  final opening=int.tryParse(await ask('مانده اولیه به تومان (صفر هم مجاز است)')??'');
  if(opening==null||opening<0)return;
  cards.add(name.trim());openingBalances[name.trim()]=opening;await changed();
 }
 Future<void> editOpeningBalance()async{
  if(cards.isEmpty){info('ابتدا یک حساب ثبت کن.');return;}
  final name=await chooseAccount('حساب موردنظر');
  if(name==null)return;
  final amount=int.tryParse(await ask('مانده اولیه حساب $name')??'');
  if(amount==null||amount<0)return;
  openingBalances[name]=amount;await changed();
 }
 Future<String?> chooseAccount(String title)async{
  if(cards.isEmpty)return null;
  return showDialog<String>(context:context,builder:(ctx)=>SimpleDialog(title:Text(title),
    children:cards.map((c)=>SimpleDialogOption(onPressed:()=>Navigator.pop(ctx,c),
    child:Text(c))).toList()));
 }
 Future<void> transferMoney()async{
  if(cards.length<2){info('برای انتقال، دو حساب نیاز است.');return;}
  final source=await chooseAccount('حساب مبدأ');if(source==null||!mounted)return;
  final destination=await chooseAccount('حساب مقصد');if(destination==null||destination==source)return;
  final amount=int.tryParse(await ask('مبلغ انتقال (تومان)')??'');
  if(amount==null||amount<=0)return;
  final balance=MoneyMath.accountBalance(source,openingBalances,items);
  if(balance!=null&&amount>balance){info('مبلغ از مانده حساب مبدأ بیشتر است.');return;}
  items.add({'type':'transfer','date':date(),'amount':amount,'note':'انتقال از $source به $destination',
    'category':'انتقال','from':source,'to':destination});
  await changed();
 }

 Future<void> addBudget()async{
  final name=await ask('دسته بودجه (مثلاً خوراک)');
  if(name==null||name.trim().isEmpty)return;
  final amount=int.tryParse(await ask('سقف بودجه (تومان)')??'');
  if(amount==null||amount<=0)return;
  budgets[name.trim()]=amount;changed();
 }
 Widget recurringTile(Map<String,dynamic> entry) {
   final name=entry['name']?.toString()??'هزینه';
   final amount=entry['amount'] is num ? (entry['amount'] as num) : 0;
   final day=entry['day']?.toString()??'-';
   return GolpoolStyle.panel(child:Column(children:[
     SwitchListTile(title:Text(name),subtitle:Text('${money(amount)} · روز $day هر ماه'),
       value:entry['active']==true,onChanged:(v){entry['active']=v;changed();}),
     Row(children:[
       TextButton.icon(onPressed:()=>recordRecurring(entry),
         icon:const Icon(Icons.check_circle_outline),label:const Text('ثبت پرداخت')),
       const Spacer(),
       IconButton(onPressed:()=>removeRecurring(entry),icon:const Icon(Icons.delete_outline))
     ])
   ]));
 }
 Future<void> addRecurring()async{
  if(recurring.length>=100){info('حداکثر ۱۰۰ هزینه تکراری قابل ثبت است.');return;}
  final name=await ask('نام هزینه تکراری');if(name==null||name.trim().isEmpty)return;
  final amount=int.tryParse(await ask('مبلغ ماهانه به تومان')??'');
  if(amount==null||amount<=0)return;
  final day=int.tryParse(await ask('روز پرداخت هر ماه (۱ تا ۲۸)')??'');
  if(day==null||day<1||day>28)return;
  recurring.add({'id':DateTime.now().microsecondsSinceEpoch%100000000,'name':name.trim(),
    'amount':amount,'day':day,'active':true,'lastPaidMonth':''});
  await changed();
  try{if(!await reminders.enable())info('یادآوری این پرداخت نیازمند مجوز اعلان است.');}catch(_){info('مجوز اعلان در دسترس نیست.');}
 }
 Future<void> recordRecurring(Map<String,dynamic> entry)async{
   final month=date().substring(0,7);
   if(entry['lastPaidMonth']==month){info('پرداخت این ماه قبلاً ثبت شده است.');return;}
   String? account;
   if(cards.isNotEmpty){account=await chooseAccount('حساب پرداخت');if(account==null)return;}
   final amount=(entry['amount'] as num).round();
   if(account!=null){
     final available=MoneyMath.accountBalance(account,openingBalances,items);
     if(available!=null&&amount>available){info('مانده حساب کافی نیست.');return;}
   }
   items.add({'type':'expense','date':date(),'amount':amount,'note':entry['name'],
     'category':'هزینه تکراری','account':account});
   entry['lastPaidMonth']=month;await changed();
 }
 Future<void> removeRecurring(Map<String,dynamic> entry)async{
   final yes=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
     title:const Text('حذف هزینه تکراری'),content:const Text('سوابق پرداخت قبلی حذف نمی‌شود.'),
     actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('انصراف')),
       FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('حذف'))]));
   if(yes==true){try{await reminders.cancelRecurring(entry['id'] as int);}catch(_){}recurring.remove(entry);await changed();}
 }
 Future<void> addDebt()async{
  final who=await ask('نام شخص');if(who==null||who.isEmpty)return;
  final sum=int.tryParse(await ask('مبلغ قرض')??'');
  if(sum!=null&&sum>0){debts.add({'person':who,'amount':sum,'settled':false});changed();}
 }
 @override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(
  appBar:AppBar(toolbarHeight:83,title:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('یه همراه کوچولو برای پول‌هات 🌸',style:TextStyle(fontSize:12,color:GolpoolStyle.muted)),const SizedBox(height:4),Text(['خانه','تراکنش‌ها','بودجه ماهانه','هدف‌های من','بیشتر'][tab],style:const TextStyle(fontSize:24,fontWeight:FontWeight.w800,color:GolpoolStyle.ink))]),actions:[Padding(padding:const EdgeInsets.only(left:14),child:GolpoolStyle.bubble(Icons.notifications_none_rounded))]),
  body:!dataReady?const Center(child:CircularProgressIndicator()):!unlocked?Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[const Icon(Icons.lock_outline,size:55,color:GolpoolStyle.rose),const SizedBox(height:15),const Text('ورود امن به گل‌پول'),const SizedBox(height:14),FilledButton.icon(onPressed:unlockDevice,icon:const Icon(Icons.fingerprint),label:const Text('بازکردن قفل دستگاه'))])):secureError?const Center(child:Text('خطای ذخیره‌سازی امن؛ برای حفاظت از داده‌ها ثبت اطلاعات متوقف شد.')):Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:screen()),
  floatingActionButton:tab==1&&dataReady&&!secureError&&unlocked?FloatingActionButton(backgroundColor:GolpoolStyle.rose,foregroundColor:Colors.white,onPressed:addTx,child:const Icon(Icons.add)):null,
  bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:unlocked?(v)=>setState(()=>tab=v):null,destinations:const [
   NavigationDestination(icon:Icon(Icons.home_outlined),label:'خانه'),
   NavigationDestination(icon:Icon(Icons.receipt_long_outlined),label:'تراکنش‌ها'),
   NavigationDestination(icon:Icon(Icons.pie_chart_outline),label:'بودجه'),
   NavigationDestination(icon:Icon(Icons.favorite_outline),label:'هدف‌ها'),
   NavigationDestination(icon:Icon(Icons.menu),label:'بیشتر')])
 ));
}

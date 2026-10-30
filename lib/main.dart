import 'package:flutter/material.dart';
import 'package:golpool/finance.dart';
void main()=>runApp(const Golpool());
class Golpool extends StatelessWidget {
 const Golpool({super.key});
 @override Widget build(BuildContext context)=>MaterialApp(debugShowCheckedModeBanner:false,title:'گل‌پول',theme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xffdb5a8f)),scaffoldBackgroundColor:const Color(0xfffcf3f6)),home:const Home());
}
class Home extends StatefulWidget {const Home({super.key});@override State<Home> createState()=>_HomeState();}
class _HomeState extends State<Home>{
 int tab=0;
 final List<Map<String,dynamic>> items=[];
 final cards=['بانک اول','بانک دوم'];
 final budgets={'خوراک':4000000,'پوشاک':5000000,'زیبایی':2500000,'خانه':3000000,'رفت‌وآمد':1500000,'تفریح':2000000};
 final goals=<Map<String,dynamic>>[{'name':'خرید گوشی','saved':18000000,'target':60000000}];
 final debts=<Map<String,dynamic>>[];
 String date(){final d=DateTime.now();return [d.year,d.month.toString().padLeft(2,'0'),d.day.toString().padLeft(2,'0')].join('-');}
 String money(num n)=>n.round().toString()+' تومان';
 Widget tile(String title,String subtitle,{VoidCallback? action})=>Card(color:Colors.white,child:ListTile(title:Text(title),subtitle:Text(subtitle),trailing:action==null?null:IconButton(onPressed:action,icon:const Icon(Icons.edit_outlined))));
 Widget screen(){
  switch(tab){
   case 0:
    final todayAmount=MoneyMath.spentToday(items,date());
    final total=budgets.values.fold<int>(0,(s,n)=>s+n);
    final used=budgets.keys.fold<int>(0,(s,c)=>s+MoneyMath.categorySpent(items,c,date().substring(0,7)));
    return ListView(children:[
      tile('خرج امروز 🌸',money(todayAmount)),tile('مانده بودجه ماه 💚',money(total-used)),
      tile('حساب‌های من',cards.join(' · ')),
      tile('این پول کجا رفت؟',MoneyMath.pending(items).length.toString()+' خرج بدون توضیح',action:()=>setState(()=>tab=1)),
      ...items.reversed.take(4).map((t)=>tile(t['note'].toString().isEmpty?'خرج بدون توضیح':t['note'].toString(),money(t['amount'] as num)))]);
   case 1:return ListView(children:[
    ...items.reversed.map((t)=>tile(t['note'].toString().isEmpty?'بدون توضیح':t['note'].toString(),money(t['amount'] as num),action:()=>explain(t))),
    if(items.isEmpty)tile('هنوز تراکنشی ثبت نشده','با دکمه + شروع کن')]);
   case 2:return ListView(children:budgets.entries.map((e){
    final used=MoneyMath.categorySpent(items,e.key,date().substring(0,7));
    final percent=used/e.value;
    return Card(color:Colors.white,child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Text(e.key,style:const TextStyle(fontWeight:FontWeight.bold)),
      const SizedBox(height:8),LinearProgressIndicator(value:percent.clamp(0.0,1.0)),
      Text(money(used)+' از '+money(e.value)),
      if(percent>=0.7)const Text('یه یادآوری کوچولو: داری به سقف بودجه نزدیک می‌شی 💗',style:TextStyle(color:Colors.pink))
    ])));
   }).toList());
   case 3:return ListView(children:[
    ...goals.map((g)=>Card(color:Colors.white,child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
      Text(g['name'].toString()),const SizedBox(height:8),
      LinearProgressIndicator(value:MoneyMath.progress(g['saved'] as int,g['target'] as int)/100),
      Text(money(g['saved'] as int)+' از '+money(g['target'] as int)),
      TextButton(onPressed:()=>saveGoal(g),child:const Text('افزودن پس‌انداز'))]))),
    FilledButton(onPressed:addGoal,child:const Text('هدف جدید'))]);
   default:return ListView(children:[
    tile('کارت‌های بانکی',cards.join('، ')),
    FilledButton(onPressed:addCard,child:const Text('افزودن کارت')),
    tile('یادآوری شبانه','۲۱:۰۰ و در صورت عدم تکمیل ۲۲:۳۰ (فعلاً غیرفعال)'),
    tile('امنیت و پشتیبان‌گیری','نسخه آزمایشی؛ اطلاعات واقعی وارد نکنید'),
    ...debts.map((d)=>tile(d['person'].toString(),money(d['amount'] as num)+' · '+(d['settled']==true?'تسویه شده':'باز'))),
    FilledButton(onPressed:addDebt,child:const Text('ثبت قرض'))]);
  }
 }
 Future<String?> ask(String title)async{
  final controller=TextEditingController();
  final result=await showDialog<String>(context:context,builder:(ctx)=>AlertDialog(title:Text(title),content:TextField(controller:controller,keyboardType:TextInputType.text),actions:[
    TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('لغو')),
    FilledButton(onPressed:()=>Navigator.pop(ctx,controller.text),child:const Text('ثبت'))]));
  controller.dispose();return result;
 }
 Future<void> addTx()async{
  final sum=int.tryParse(await ask('مبلغ برداشت (تومان)')??'');
  if(sum==null||sum<=0)return;
  final note=await ask('توضیح هزینه (اختیاری)');
  if(note==null)return;
  setState(()=>items.add({'type':'expense','date':date(),'amount':sum,'note':note,'category':'سایر'}));
 }
 Future<void> explain(Map<String,dynamic> t)async{final s=await ask('توضیح تراکنش');if(s!=null&&s.trim().isNotEmpty)setState(()=>t['note']=s.trim());}
 Future<void> addGoal()async{
  final name=await ask('نام هدف');if(name==null||name.isEmpty)return;
  final sum=int.tryParse(await ask('مبلغ هدف')??'');if(sum!=null&&sum>0)setState(()=>goals.add({'name':name,'saved':0,'target':sum}));
 }
 Future<void> saveGoal(Map<String,dynamic> g)async{
  final sum=int.tryParse(await ask('مبلغ پس‌انداز')??'');if(sum!=null&&sum>0)setState(()=>g['saved']=(g['saved'] as int)+sum);
 }
 Future<void> addCard()async{final name=await ask('نام کارت یا بانک');if(name!=null&&name.isNotEmpty)setState(()=>cards.add(name));}
 Future<void> addDebt()async{
  final who=await ask('نام شخص');if(who==null||who.isEmpty)return;
  final sum=int.tryParse(await ask('مبلغ قرض')??'');
  if(sum!=null&&sum>0)setState(()=>debts.add({'person':who,'amount':sum,'settled':false}));
 }
 @override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(
  appBar:AppBar(title:const Text('گل‌پول 🌸')),
  body:Padding(padding:const EdgeInsets.symmetric(horizontal:12),child:screen()),
  floatingActionButton:tab==1?FloatingActionButton(onPressed:addTx,child:const Icon(Icons.add)):null,
  bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),destinations:const [
   NavigationDestination(icon:Icon(Icons.home_outlined),label:'خانه'),
   NavigationDestination(icon:Icon(Icons.receipt_long_outlined),label:'تراکنش‌ها'),
   NavigationDestination(icon:Icon(Icons.pie_chart_outline),label:'بودجه'),
   NavigationDestination(icon:Icon(Icons.favorite_outline),label:'هدف‌ها'),
   NavigationDestination(icon:Icon(Icons.menu),label:'بیشتر')])
 ));
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Shared design tokens based on the approved Golpool pastel mockup.
class GolpoolStyle {
 static const rose=Color(0xffdb5a8f);
 static const pink=Color(0xffef6e9d);
 static const ink=Color(0xff392c3a);
 static const muted=Color(0xff8e8190);
 static const mint=Color(0xff31b795);
 static const line=Color(0xfff1e3ea);
 static const background=Color(0xfffcf3f6);
 static final formatter=NumberFormat.decimalPattern('fa');
 static String money(num value)=>'${formatter.format(value.round())} تومان';
 static ThemeData get theme=>ThemeData(
  useMaterial3:true,scaffoldBackgroundColor:background,
  colorScheme:ColorScheme.fromSeed(seedColor:rose,brightness:Brightness.light,surface:Colors.white),
  visualDensity:VisualDensity.standard,
  splashFactory:InkRipple.splashFactory,
  pageTransitionsTheme:const PageTransitionsTheme(builders:{TargetPlatform.android:ZoomPageTransitionsBuilder(),TargetPlatform.iOS:CupertinoPageTransitionsBuilder()}),
  inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:Colors.white,contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:15),border:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:const BorderSide(color:line)),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:const BorderSide(color:line)),focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:const BorderSide(color:rose,width:1.6))),
  cardTheme:CardThemeData(color:Colors.white,elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(23))),
  dividerTheme:const DividerThemeData(color:line,thickness:1),
  appBarTheme:const AppBarTheme(backgroundColor:background,foregroundColor:ink,scrolledUnderElevation:0),
  navigationBarTheme:NavigationBarThemeData(backgroundColor:Colors.white,elevation:0,height:75,
   indicatorColor:const Color(0xffffe5ee),labelTextStyle:WidgetStateProperty.all(const TextStyle(fontSize:11,color:ink))),
  filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(backgroundColor:rose,foregroundColor:Colors.white,
    padding:const EdgeInsets.symmetric(horizontal:22,vertical:14),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(17)))),
  textTheme:const TextTheme(bodyMedium:TextStyle(color:ink,fontSize:14,height:1.6),bodyLarge:TextStyle(color:ink,fontSize:16,height:1.55),titleMedium:TextStyle(color:ink,fontWeight:FontWeight.w800,fontSize:17)));
 static Widget bubble(IconData icon)=>Container(width:43,height:43,decoration:BoxDecoration(
  color:const Color(0xffffe9f0),borderRadius:BorderRadius.circular(15)),
  child:Icon(icon,color:rose,size:22));
 static Widget panel({required Widget child,Color color=Colors.white})=>Container(
  margin:const EdgeInsets.only(bottom:14),padding:const EdgeInsets.all(15),
  decoration:BoxDecoration(color:color,border:Border.all(color:line),borderRadius:BorderRadius.circular(25),
  boxShadow:[BoxShadow(color:rose.withValues(alpha:.09),blurRadius:23,offset:const Offset(0,8))]),child:child);
 static Widget section(String title)=>Padding(padding:const EdgeInsets.only(top:17,bottom:11,right:3),
  child:Text(title,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:18,color:ink)));
 static Widget progress(double ratio,{Color color=rose})=>Padding(padding:const EdgeInsets.symmetric(vertical:10),
  child:ClipRRect(borderRadius:BorderRadius.circular(99),child:LinearProgressIndicator(
   value:ratio.clamp(0.0,1.0),minHeight:10,backgroundColor:const Color(0xfff6e8ee),color:color)));
 static Widget summary({required String today,required String remaining})=>Padding(
  padding:const EdgeInsets.only(top:10,bottom:3),child:Row(children:[
   Expanded(child:_stat('خرج امروز',today,Icons.shopping_bag_outlined,const Color(0xffffeaf1))),
   const SizedBox(width:11),
   Expanded(child:_stat('مانده بودجه ماه',remaining,Icons.favorite_outline,const Color(0xffeaf9f2)))]));
 static Widget _stat(String label,String value,IconData icon,Color color)=>Container(
  padding:const EdgeInsets.all(14),constraints:const BoxConstraints(minHeight:124),
  decoration:BoxDecoration(color:color,borderRadius:BorderRadius.circular(23),border:Border.all(color:line)),
  child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   Row(children:[Expanded(child:Text(label,style:const TextStyle(fontSize:12,color:muted))),
    Icon(icon,color:rose,size:20)]),const SizedBox(height:18),
   FittedBox(fit:BoxFit.scaleDown,alignment:Alignment.centerRight,child:Text(value,
    style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900,color:ink)))]));
 static Widget welcomeBanner()=>Container(
   margin:const EdgeInsets.only(top:12,bottom:10),padding:const EdgeInsets.all(21),
   decoration:BoxDecoration(
     gradient:const LinearGradient(begin:Alignment.topRight,end:Alignment.bottomLeft,
       colors:[Color(0xfff8cada),Color(0xffffe9df),Color(0xfff1ddf7)]),
     borderRadius:BorderRadius.circular(29),
     boxShadow:[BoxShadow(color:rose.withValues(alpha:.12),blurRadius:23,offset:const Offset(0,10))]),
   child:Row(children:[
     const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
       Text('گل‌پولِ من 🌷',style:TextStyle(color:ink,fontSize:23,fontWeight:FontWeight.w900)),
       SizedBox(height:9),
       Text('برای آرزوهای قشنگ و تصمیم‌های هوشمندانه',style:TextStyle(color:ink,fontSize:12,height:1.65))])),
     Container(width:65,height:65,alignment:Alignment.center,
       decoration:BoxDecoration(color:Colors.white.withValues(alpha:.65),shape:BoxShape.circle),
       child:const Icon(Icons.local_florist_rounded,color:rose,size:38))]));
 static Widget goalCard(String name,String saved,String target,double percent,VoidCallback onAdd)=>panel(
  color:const Color(0xfffffbfd),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
   Row(children:[bubble(Icons.favorite_outline_rounded),const SizedBox(width:12),
    Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(name,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:17)),
      const SizedBox(height:4),Text('$saved از $target',style:const TextStyle(color:muted,fontSize:12))])),
    Text('${(percent*100).round()}٪',style:const TextStyle(fontWeight:FontWeight.bold,color:mint,fontSize:18))]),
   progress(percent,color:mint),
   Align(alignment:Alignment.centerLeft,child:FilledButton.tonalIcon(
    onPressed:onAdd,icon:const Icon(Icons.add),label:const Text('افزودن پس‌انداز')))]));
 static Widget categoryBudget(String title,String used,String limit,double percent)=>panel(
  child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
   Row(children:[bubble(Icons.spa_outlined),const SizedBox(width:10),
    Expanded(child:Text(title,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:15))),
    Text('${(percent*100).round()}٪',style:const TextStyle(color:rose,fontWeight:FontWeight.bold))]),
   progress(percent),Text('$used از $limit',style:const TextStyle(color:muted,fontSize:12)),
   if(percent>=1)const Padding(padding:EdgeInsets.only(top:8),child:Text('بودجه این دسته مصرف شده است؛ هزینه‌های بعدی را با دقت بررسی کن.',style:TextStyle(color:rose,fontSize:12))),
   if(percent>=.7 && percent<1)const Padding(padding:EdgeInsets.only(top:8),child:Text(
    'یه یادآوری کوچولو؛ داری به سقف بودجه نزدیک می‌شی 💗',style:TextStyle(color:rose,fontSize:12)))]));
 static Widget pending(int count,VoidCallback open)=>panel(color:const Color(0xfffff7fa),
  child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
   Text(count==0?'همه تراکنش‌ها توضیح دارند 🌷':'$count تراکنش منتظرند بگی بابت چی بودن.',
    style:const TextStyle(fontSize:13,color:muted)),
   if(count>0)...[const SizedBox(height:12),FilledButton(onPressed:open,child:const Text('تکمیل خرج‌ها'))]]));
 static Widget budgetGauge({required int spent,required int limit}) {
   final fraction=limit<=0?0.0:(spent/limit).clamp(0.0,1.0).toDouble();
   return panel(color:const Color(0xfffff8fb),child:Column(children:[
     const Text('نمای کلی بودجه ماه',style:TextStyle(fontSize:17,fontWeight:FontWeight.w800,color:ink)),
     const SizedBox(height:18),
     SizedBox(width:170,height:170,child:Stack(alignment:Alignment.center,children:[
       SizedBox(width:166,height:166,child:CircularProgressIndicator(
         value:fraction,strokeWidth:14,strokeCap:StrokeCap.round,
         backgroundColor:const Color(0xfff5d8e3),color:rose)),
       Column(mainAxisSize:MainAxisSize.min,children:[
         Text('${(fraction*100).round()}٪',style:const TextStyle(fontSize:35,fontWeight:FontWeight.w900,color:ink)),
         const Text('مصرف‌شده',style:TextStyle(color:muted,fontSize:12))
       ])
     ])),
     const SizedBox(height:15),
     Row(children:[
       Expanded(child:_stat('هزینه این ماه',money(spent),Icons.trending_up_rounded,const Color(0xffffe8ef))),
       const SizedBox(width:10),
       Expanded(child:_stat('بودجه باقی‌مانده',money((limit-spent).clamp(0,limit)),Icons.savings_outlined,const Color(0xffe8f8f2)))
     ])
   ]));
 }

}
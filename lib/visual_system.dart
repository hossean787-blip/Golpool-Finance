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
  colorScheme:ColorScheme.fromSeed(seedColor:rose),
  appBarTheme:const AppBarTheme(backgroundColor:background,foregroundColor:ink,scrolledUnderElevation:0),
  navigationBarTheme:NavigationBarThemeData(backgroundColor:Colors.white,
   indicatorColor:const Color(0xffffe5ee),labelTextStyle:WidgetStateProperty.all(const TextStyle(fontSize:11,color:ink))),
  filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(backgroundColor:rose,foregroundColor:Colors.white,
    padding:const EdgeInsets.symmetric(horizontal:22,vertical:14),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(17)))),
  textTheme:const TextTheme(bodyMedium:TextStyle(color:ink),bodyLarge:TextStyle(color:ink)));
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
 static Widget pending(int count,VoidCallback open)=>panel(color:const Color(0xfffff7fa),
  child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
   Text(count==0?'همه تراکنش‌ها توضیح دارند 🌷':'$count تراکنش منتظرند بگی بابت چی بودن.',
    style:const TextStyle(fontSize:13,color:muted)),
   const SizedBox(height:12),FilledButton(onPressed:open,child:const Text('تکمیل خرج‌ها'))]));
}
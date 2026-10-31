import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'visual_system.dart';

class ExpenseChart extends StatelessWidget {
  final List<Map<String,dynamic>> items;
  final Map<String,int> budgets;
  const ExpenseChart({super.key,required this.items,required this.budgets});

  @override Widget build(BuildContext context) {
    final month=DateTime.now().toIso8601String().substring(0,7);
    final values=<String,double>{};
    for(final entry in items){
      if(entry['type']!='expense'||!(entry['date']?.toString().startsWith(month)??false))continue;
      final parts=entry['parts'];
      if(parts is List){
        for(final part in parts){
          if(part is! Map)continue;
          final amount=part['amount'];
          if(amount is! num||amount<=0)continue;
          final category=part['category']?.toString()??'سایر';
          values.update(category,(v)=>v+amount.toDouble(),ifAbsent:()=>amount.toDouble());
        }
      }else{
        final category=entry['category']?.toString()??'سایر';
        final amount=entry['amount'];
        if(amount is num && amount>0) { values.update(category,(v)=>v+amount.toDouble(),ifAbsent:()=>amount.toDouble()); }
      }
    }
    final entries=values.entries.where((e)=>e.value>0).toList()..sort((a,b)=>b.value.compareTo(a.value));
    const palette=[Color(0xffda5f91),Color(0xff9a84d1),Color(0xff60c5a6),Color(0xffffbc86),Color(0xff82afdb),Color(0xffd89ab6)];
    if(entries.isEmpty) { return GolpoolStyle.panel(child:const Padding(padding:EdgeInsets.all(12),
      child:Text('پس از ثبت هزینه، نمودار دسته‌بندی اینجا نمایش داده می‌شود.'))); }
    final total=entries.fold<double>(0,(s,e)=>s+e.value);
    return GolpoolStyle.panel(child:Column(children:[
      SizedBox(height:195,child:PieChart(PieChartData(centerSpaceRadius:54,sectionsSpace:3,
        sections:List.generate(entries.length,(i)=>PieChartSectionData(
          value:entries[i].value,color:palette[i%palette.length],radius:36,
          showTitle:false)),))),
      const SizedBox(height:10),
      ...List.generate(entries.length,(i)=>Padding(padding:const EdgeInsets.symmetric(vertical:6),
        child:Row(children:[Container(width:11,height:11,decoration:BoxDecoration(color:palette[i%palette.length],shape:BoxShape.circle)),
          const SizedBox(width:9),Expanded(child:Text(entries[i].key)),
          Text('${(100*entries[i].value/total).round()}٪',style:const TextStyle(fontWeight:FontWeight.w700))])))
    ]));
  }
}

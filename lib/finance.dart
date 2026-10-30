class MoneyMath {
  static int spentToday(List<Map<String,dynamic>> rows, String date) =>
    rows.where((x)=>x['type']=='expense' && x['date']==date)
      .fold(0,(int s,x)=>s+(x['amount'] as num).round());

  static int categorySpent(List<Map<String,dynamic>> rows, String category, String month) {
    var total=0;
    for(final x in rows){
      if(x['type']!='expense' || !(x['date'] as String).startsWith(month))continue;
      final parts=x['parts'];
      if(parts is List){
        for(final p in parts){
          if(p['category']==category)total+=(p['amount'] as num).round();
        }
      }else if(x['category']==category){total+=(x['amount'] as num).round();}
    }
    return total;
  }

  static bool validateParts(int amount,List<Map<String,dynamic>> parts)=>
      amount>0 && parts.isNotEmpty &&
      parts.every((x)=>(x['amount'] as num)>0 && (x['category'] as String).isNotEmpty) &&
      parts.fold(0,(int s,x)=>s+(x['amount'] as num).round())==amount;

  static int progress(int saved,int target)=>target<=0?0:((saved/target*100).round()).clamp(0,100);
  static List<Map<String,dynamic>> pending(List<Map<String,dynamic>> rows)=>rows
      .where((x)=>x['type']=='expense' && ((x['note']??'') as String).trim().isEmpty).toList();
}
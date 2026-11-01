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
  /// Returns null when an account has no known opening balance.
  static int? accountBalance(String name, Map<String,int> openings,List<Map<String,dynamic>> rows){
    final opening=openings[name];
    if(opening==null)return null;
    var current=opening;
    for(final row in rows){
      final amount=row['amount'];
      if(amount is! num)continue;
      final n=amount.round();
      if(row['type']=='income' && row['account']==name)current+=n;
      if(row['type']=='expense' && row['account']==name)current-=n;
      if(row['type']=='transfer'){
        if(row['from']==name)current-=n;
        if(row['to']==name)current+=n;
      }
    }
    return current;
  }

  static int incomeForMonth(List<Map<String,dynamic>> rows,String month)=>rows
    .where((x)=>x['type']=='income' && x['date'] is String && (x['date'] as String).startsWith(month))
    .fold<int>(0,(sum,x)=>sum+(x['amount'] as num).round());

  static int expensesForMonth(List<Map<String,dynamic>> rows,String month)=>rows
    .where((x)=>x['type']=='expense' && x['date'] is String && (x['date'] as String).startsWith(month))
    .fold<int>(0,(sum,x)=>sum+(x['amount'] as num).round());

  /// Validate a proposed ledger mutation, excluding the original row for edits.
  static bool canPost(List<Map<String,dynamic>> rows,Map<String,int> openings,
      Map<String,dynamic> proposed,{Map<String,dynamic>? original}) {
    final amount=proposed['amount'];
    if(amount is! int || amount<=0)return false;
    final type=proposed['type'];
    if(type!='expense' && type!='income' && type!='transfer')return false;
    final remainder=rows.where((row)=>!identical(row,original)).toList();
    remainder.add(proposed);
    if(type=='transfer'){
      final from=proposed['from'];
      final to=proposed['to'];
      if(from is! String||to is! String||from==to||
         !openings.containsKey(from)||!openings.containsKey(to))return false;
    }
    for(final name in openings.keys){
      final balance=accountBalance(name,openings,remainder);
      if(balance!=null&&balance<0)return false;
    }
    return true;
  }

  static int debtRemaining(Map<String,dynamic> debt){
    final amount=debt['amount'];
    final settled=debt['paid'];
    if(amount is! num)return 0;
    if(settled is num)return (amount.round()-settled.round()).clamp(0,amount.round()).toInt();
    return debt['settled']==true?0:amount.round();
  }

}
/// A cautious parser for bank SMS text supplied with explicit user consent.
/// A message is *never* assumed authentic just because it contains bank words.
class BankSmsCandidate {
  final int amount;
  final String direction;
  final String? cardLast4;
  final String sourceText;
  const BankSmsCandidate(this.amount,this.direction,this.cardLast4,this.sourceText);
}

class BankSmsParser {
  static BankSmsCandidate? parse(String message) {
    final clean = message
       .replaceAll(RegExp(r'[۰-۹]'), (m) => String.fromCharCode(m.group(0)!.codeUnitAt(0)-0x06F0+0x30))
       .replaceAll(RegExp(r'[٠-٩]'), (m) => String.fromCharCode(m.group(0)!.codeUnitAt(0)-0x0660+0x30));
    final debit=RegExp(r'برداشت|خرید|کسر از حساب').hasMatch(clean);
    final credit=RegExp(r'واریز|افزایش موجودی|بستانکار').hasMatch(clean);
    if(debit==credit) return null;
    final match=RegExp(r'(?:مبلغ|مقدار)\s*[:：]?\s*([0-9,٬،]+)\s*(ریال|تومان)?').firstMatch(clean);
    if(match==null)return null;
    final value=int.tryParse(match.group(1)!.replaceAll(RegExp(r'[^0-9]'),''));
    if(value==null || value<=0)return null;
    final currency=match.group(2);
    // Unspecified currency is unsafe: avoid 10x misclassification.
    if(currency==null)return null;
    final tomans=currency=='ریال'?value~/10:value;
    if(tomans<=0 || (currency=='ریال' && value%10!=0))return null;
    final card=RegExp(r'(?:کارت|حساب)\s*[:：]?\s*(?:\*+|x+|X+)?\s*([0-9]{4})').firstMatch(clean);
    return BankSmsCandidate(tomans,debit?'expense':'income',card?.group(1),message);
  }
}

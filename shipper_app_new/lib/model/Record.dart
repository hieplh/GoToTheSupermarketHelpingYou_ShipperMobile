class StatisticMonth {
  String ofMonthYear;
  String fromDate;
  NumberOrders numberOrders;
  Amount amount;
  List<Record> record;

  StatisticMonth(
      {this.ofMonthYear,
      this.fromDate,
      this.numberOrders,
      this.amount,
      this.record});

  factory StatisticMonth.fromJson(Map<String, dynamic> json) {
    return StatisticMonth(
        ofMonthYear: json['ofMonthYear'],
        fromDate: json['fromDate'],
        numberOrders: NumberOrders.fromJson(json['numberOfOrders']),
        amount: Amount.fromJson(json['amount']),
        record: json["weeks"] != null
            ? List<Record>.from(json["weeks"].map((x) => Record.fromJson(x)))
            : List<Record>());
  }
}

class NumberOrders {
  int numOrders;
  int numRejected;
  int numCanceled;
  int numDone;

  NumberOrders(
      {this.numOrders, this.numRejected, this.numCanceled, this.numDone});

  factory NumberOrders.fromJson(Map<String, dynamic> json) {
    return NumberOrders(
        numOrders: json['numOrders'],
        numRejected: json['numRejected'],
        numCanceled: json['numCanceled'],
        numDone: json['numDone']);
  }
}

class Amount {
  double amountRefund;
  double amountTotal;
  double amountCharged;
  double amountEarned;
  Amount(
      {this.amountRefund,
      this.amountTotal,
      this.amountCharged,
      this.amountEarned});

  factory Amount.fromJson(Map<String, dynamic> json) {
    return Amount(
        amountRefund: json['amountRefund'],
        amountTotal: json['amountTotal'],
        amountCharged: json['amountCharged'],
        amountEarned: json['amountEarned']);
  }
}

class Record {
  String week;
  String fromdate;
  double amountEarned;
  double amountCharged;

  Record({this.week, this.fromdate, this.amountEarned, this.amountCharged});

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
        week: json['week'],
        fromdate: json['fromdate'],
        amountEarned: json['amountEarned'],
        amountCharged: json['amountCharged']);
  }
}

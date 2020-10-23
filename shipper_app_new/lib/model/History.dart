class History {
  String id;
  String addressDelivery;
  String marketName;
  String note;
  String shipper;
  String createDate;
  String createTime;
  double costShopping;
  double costDelivery;
  double totalCost;

  History(
      {this.id,
      this.addressDelivery,
      this.marketName,
      this.note,
      this.shipper,
      this.createDate,
      this.createTime,
      this.costShopping,
      this.costDelivery,
      this.totalCost});

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id'],
      addressDelivery: json['addressDelivery'],
      marketName: json['marketName'],
      note: json['note'],
      shipper: json['shipper'],
      createDate: json['createDate'],
      createTime: json['createTime'],
      costShopping: json['costShopping'],
      costDelivery: json['costDelivery'],
      totalCost: json['totalCost'],
    );
  }
}

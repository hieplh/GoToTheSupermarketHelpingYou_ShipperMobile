class History {
  String id;
  String addressDelivery;
  String marketName;
  String note;
  String shipper;
  int status;
  String createDate;
  String createTime;
  String receiveTime;
  String deliveryTime;
  double costShopping;
  double costDelivery;
  double totalCost;

  History(
      {this.id,
      this.addressDelivery,
      this.marketName,
      this.note,
      this.shipper,
      this.status,
      this.createDate,
      this.createTime,
      this.receiveTime,
      this.deliveryTime,
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
      status: json['status'],
      createDate: json['createDate'],
      createTime: json['createTime'],
      receiveTime: json['receiveTime'],
      deliveryTime: json['deliveryTime'],
      costShopping: json['costShopping'],
      costDelivery: json['costDelivery'],
      totalCost: json['totalCost'],
    );
  }
}

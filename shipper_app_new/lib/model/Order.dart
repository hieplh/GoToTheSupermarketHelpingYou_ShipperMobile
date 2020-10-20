class Order {
  String id;
  String cust;
  String note;
  double costShopping;
  double costDelivery;
  double totalCost;
  String dateDelivery;
  String timeDelivery;

  Order(
      {this.id,
      this.cust,
      this.note,
      this.costShopping,
      this.costDelivery,
      this.totalCost,
      this.dateDelivery,
      this.timeDelivery});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      cust: json['cust'],
      note: json['note'],
      costShopping: json['costShopping'],
      costDelivery: json['costDelivery'],
      totalCost: json['totalCost'],
      dateDelivery: json['dateDelivery'],
      timeDelivery: json['timeDelivery'],
    );
  }
}

class OrderDetail {
  String id;
  String food;
  String image;
  double priceOriginal;
  double pricePaid;
  double weight;
  int saleOff;

  OrderDetail({
    this.id,
    this.food,
    this.image,
    this.priceOriginal,
    this.pricePaid,
    this.weight,
    this.saleOff,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'],
      food: json['food'],
      image: json['image'],
      priceOriginal: json['priceOriginal'],
      pricePaid: json['pricePaid'],
      weight: json['weight'],
      saleOff: json['saleOff'],
    );
  }
}

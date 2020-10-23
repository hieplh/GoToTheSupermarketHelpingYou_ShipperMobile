class Orders {
  String distance;
  int value;
  Order order;

  Orders({this.distance, this.value, this.order});

  factory Orders.fromJson(Map<String, dynamic> json) {
    return Orders(
        distance: json['distance'],
        value: json['value'],
        order: Order.fromJson(json['order']));
  }
}

class Order {
  String id;
  String cust;
  String note;
  double costShopping;
  double costDelivery;
  String addressDelivery;
  double totalCost;
  String dateDelivery;
  String timeDelivery;
  Market market;
  List<OrderDetail> detail;

  Order(
      {this.id,
      this.cust,
      this.market,
      this.detail,
      this.note,
      this.costShopping,
      this.costDelivery,
      this.totalCost,
      this.dateDelivery,
      this.timeDelivery,
      this.addressDelivery});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
        id: json['id'],
        cust: json['cust'],
        market: Market.fromJson(json['market']),
        note: json['note'],
        costShopping: json['costShopping'],
        costDelivery: json['costDelivery'],
        totalCost: json['totalCost'],
        dateDelivery: json['dateDelivery'],
        timeDelivery: json['timeDelivery'],
        addressDelivery: json['addressDelivery'],
        detail: List<OrderDetail>.from(
            json["details"].map((x) => OrderDetail.fromJson(x))));
  }
}

class Market {
  String id;
  String name;
  String addr1;
  String addr2;
  String addr3;
  String addr4;
  String lat;
  String lng;

  Market(
      {this.id,
      this.name,
      this.addr1,
      this.addr2,
      this.addr3,
      this.addr4,
      this.lat,
      this.lng});

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: json['id'],
      name: json['name'],
      addr1: json['addr1'],
      addr2: json['addr2'],
      addr3: json['addr3'],
      addr4: json['addr4'],
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}

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

  Map toJson() => {
        "id": id,
        "food": food,
        "image": image,
        "priceOriginal": priceOriginal,
        "pricePaid": pricePaid,
        "weight": weight,
        "saleOff": saleOff,
      };
}

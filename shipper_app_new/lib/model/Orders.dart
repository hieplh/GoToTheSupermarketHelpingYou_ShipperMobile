class Orders {
  String destination;
  int value;
  Order order;

  Orders({this.destination, this.value, this.order});

  factory Orders.fromJson(Map<String, dynamic> json) {
    return Orders(
        destination: json['destination'],
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
  AddressDelivery addressDelivery;
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
        addressDelivery: AddressDelivery.fromJson(json['addressDelivery']),
        market: Market.fromJson(json['market']),
        note: json['note'],
        costShopping: json['costShopping'],
        costDelivery: json['costDelivery'],
        totalCost: json['totalCost'],
        dateDelivery: json['dateDelivery'],
        timeDelivery: json['timeDelivery'],
        detail: json["details"] != null
            ? List<OrderDetail>.from(
                json["details"].map((x) => OrderDetail.fromJson(x)))
            : List<OrderDetail>());
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

class AddressDelivery {
  String address;
  String lat;
  String lng;

  AddressDelivery({this.address, this.lat, this.lng});

  factory AddressDelivery.fromJson(Map<String, dynamic> json) {
    return AddressDelivery(
      address: json['address'],
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}

class Food {
  String description;
  String id;
  String image;
  String name;
  double price;
  SaleOff saleOff;

  Food(
      {this.description,
      this.id,
      this.image,
      this.name,
      this.price,
      this.saleOff});

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      description: json['description'],
      id: json['id'],
      image: json['image'],
      name: json['name'],
      price: json['price'],
      saleOff: SaleOff.fromJson(json['saleOff']),
    );
  }
}

class SaleOff {
  String endDate;
  String endTime;
  int saleOff;
  String startDate;
  String startTime;

  SaleOff({
    this.endDate,
    this.endTime,
    this.saleOff,
    this.startDate,
    this.startTime,
  });
  factory SaleOff.fromJson(Map<String, dynamic> json) {
    return SaleOff(
      endDate: json['endDate'],
      endTime: json['endTime'],
      saleOff: json['saleOff'],
      startDate: json['startDate'],
      startTime: json['startTime'],
    );
  }
}

class OrderDetail {
  String id;
  Food food;
  double priceOriginal;
  double pricePaid;
  int saleOff;
  double weight;

  OrderDetail({
    this.id,
    this.food,
    this.priceOriginal,
    this.pricePaid,
    this.weight,
    this.saleOff,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'],
      food: Food.fromJson(json['food']),
      priceOriginal: json['priceOriginal'],
      pricePaid: json['pricePaid'],
      weight: json['weight'],
      saleOff: json['saleOff'],
    );
  }

  Map toJson() => {
        "id": id,
        "food": food,
        "priceOriginal": priceOriginal,
        "pricePaid": pricePaid,
        "weight": weight,
        "saleOff": saleOff,
      };
}

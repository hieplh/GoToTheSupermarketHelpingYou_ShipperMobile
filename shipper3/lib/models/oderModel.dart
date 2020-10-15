class Orders {
  String distance;
  int value;
  Order order;

  Orders({this.distance, this.value, this.order});

  Orders.fromJson(Map<String, dynamic> json) {
    distance = json['distance'];
    value = json['value'];
    order = json['order'] != null ? new Order.fromJson(json['order']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['distance'] = this.distance;
    data['value'] = this.value;
    if (this.order != null) {
      data['order'] = this.order.toJson();
    }
    return data;
  }
}

class Order {
  String id;
  String cust;
  Market market;
  String note;
  int costShopping;
  int costDelivery;
  int totalCost;
  String dateDelivery;
  String timeDelivery;
  List<Details> details;
  String lat;
  String lng;

  Order(
      {this.id,
        this.cust,
        this.market,
        this.note,
        this.costShopping,
        this.costDelivery,
        this.totalCost,
        this.dateDelivery,
        this.timeDelivery,
        this.details,
        this.lat,
        this.lng});

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cust = json['cust'];
    market =
    json['market'] != null ? new Market.fromJson(json['market']) : null;
    note = json['note'];
    costShopping = json['costShopping'];
    costDelivery = json['costDelivery'];
    totalCost = json['totalCost'];
    dateDelivery = json['dateDelivery'];
    timeDelivery = json['timeDelivery'];
    if (json['details'] != null) {
      details = new List<Details>();
      json['details'].forEach((v) {
        details.add(new Details.fromJson(v));
      });
    }
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['cust'] = this.cust;
    if (this.market != null) {
      data['market'] = this.market.toJson();
    }
    data['note'] = this.note;
    data['costShopping'] = this.costShopping;
    data['costDelivery'] = this.costDelivery;
    data['totalCost'] = this.totalCost;
    data['dateDelivery'] = this.dateDelivery;
    data['timeDelivery'] = this.timeDelivery;
    if (this.details != null) {
      data['details'] = this.details.map((v) => v.toJson()).toList();
    }
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    return data;
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

  Market.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    addr1 = json['addr1'];
    addr2 = json['addr2'];
    addr3 = json['addr3'];
    addr4 = json['addr4'];
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['addr1'] = this.addr1;
    data['addr2'] = this.addr2;
    data['addr3'] = this.addr3;
    data['addr4'] = this.addr4;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    return data;
  }
}

class Details {
  String id;
  String food;
  String image;
  int priceOriginal;
  int pricePaid;
  double weight;
  int saleOff;

  Details(
      {this.id,
        this.food,
        this.image,
        this.priceOriginal,
        this.pricePaid,
        this.weight,
        this.saleOff});

  Details.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    food = json['food'];
    image = json['image'];
    priceOriginal = json['priceOriginal'];
    pricePaid = json['pricePaid'];
    weight = json['weight'];
    saleOff = json['saleOff'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['food'] = this.food;
    data['image'] = this.image;
    data['priceOriginal'] = this.priceOriginal;
    data['pricePaid'] = this.pricePaid;
    data['weight'] = this.weight;
    data['saleOff'] = this.saleOff;
    return data;
  }
}
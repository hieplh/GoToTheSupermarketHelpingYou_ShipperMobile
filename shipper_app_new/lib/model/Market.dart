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

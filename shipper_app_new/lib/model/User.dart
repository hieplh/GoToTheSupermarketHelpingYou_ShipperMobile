class User {
  String username;
  String fullname;
  String dob;
  String role;
  int numDelivery;
  int numCancel;
  double wallet;
  int maxOrder;
  double lat;
  double lng;
  double rating;
  String vin;

  User({
    this.username,
    this.fullname,
    this.dob,
    this.role,
    this.numDelivery,
    this.numCancel,
    this.wallet,
    this.maxOrder,
    this.lat,
    this.lng,
    this.rating,
    this.vin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      fullname: json['fullname'],
      dob: json['dob'],
      role: json['role'],
      numDelivery: json['numDelivery'],
      numCancel: json['numCancel'],
      wallet: json['wallet'],
      maxOrder: json['maxOrder'],
      lat: json['lat'],
      lng: json['lng'],
      rating: json['rating'],
      vin: json['vin'],
    );
  }
}

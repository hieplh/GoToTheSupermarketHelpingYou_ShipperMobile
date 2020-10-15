import 'dart:convert';

class shipperLocation {
  String lat;
  String lng;
  String shipperId;
  shipperLocation({this.lat, this.lng, this.shipperId});
  factory shipperLocation.fromJson(Map<String, dynamic> json) {
    return shipperLocation(
      lat: json['lat'],
      lng: json['lng'],
      shipperId: json['shipperId'],
    );
  }
  Map<String, dynamic> toJson() =>
      {"lat": lat, "lng": lng, "shipperId": shipperId};
}

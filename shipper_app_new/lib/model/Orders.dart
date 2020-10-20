class Orders {
  String distance;
  int value;

  Orders({this.distance, this.value});

  factory Orders.fromJson(Map<String, dynamic> json) {
    return Orders(
      distance: json['distance'],
      value: json['value'],
    );
  }
}

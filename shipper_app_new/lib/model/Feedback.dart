class FeedbackOrder {
  String id;
  String customer;
  String shipper;
  String order;
  String feedback;
  int rating;

  FeedbackOrder(
      {this.id,
      this.customer,
      this.shipper,
      this.order,
      this.feedback,
      this.rating});

  factory FeedbackOrder.fromJson(Map<String, dynamic> json) {
    return FeedbackOrder(
      id: json['id'],
      customer: json['customer'],
      shipper: json['shipper'],
      order: json['order'],
      feedback: json['feedback'],
      rating: json['rating'],
    );
  }
}

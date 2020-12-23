import 'package:shipper_app_new/model/Orders.dart';
import 'package:shipper_app_new/model/User.dart';

class History {
  String id;
  String addressDelivery;
  Market market;
  String note;
  User shipper;
  int status;
  String createDate;
  String createTime;
  String receiveTime;
  String deliveryTime;
  double costShopping;
  double costDelivery;
  double totalCost;

  History(
      {this.id,
      this.addressDelivery,
      this.market,
      this.note,
      this.shipper,
      this.status,
      this.createDate,
      this.createTime,
      this.receiveTime,
      this.deliveryTime,
      this.costShopping,
      this.costDelivery,
      this.totalCost});

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id'],
      addressDelivery: json['addressDelivery'],
      market: Market.fromJson(json['market']),
      note: json['note'],
      shipper: User.fromJson(json['shipper']),
      status: json['status'],
      createDate: json['createDate'],
      createTime: json['createTime'],
      receiveTime: json['receiveTime'],
      deliveryTime: json['deliveryTime'],
      costShopping: json['costShopping'],
      costDelivery: json['costDelivery'],
      totalCost: json['totalCost'],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shipper_app_new/model/Orders.dart';
import 'package:shipper_app_new/model/User.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:convert';
import 'package:shipper_app_new/components/RouteSupermarket.dart';
import 'package:shipper_app_new/constant/constant.dart';
import 'package:meet_network_image/meet_network_image.dart';

import 'CustomerDetail.dart';

class DetailScreen extends StatefulWidget {
  final User userData;
  final List<Order> list;
  final oCcy = new NumberFormat("#,##0", "en_US");

  DetailScreen({Key key, this.list, this.userData}) : super(key: key);

  @override
  DetailScreenState createState() => DetailScreenState();
}

class DetailScreenState extends State<DetailScreen> {
  _getNameFood(String foodId) {
    switch (foodId) {
      case "BACHIHEO":
        {
          // statements;
          return 'Thịt Ba Chỉ Heo';
        }
        break;

      case "BIHATDAU":
        {
          // statements;
          return 'Bí Hạt Đậu';
        }
        break;

      case "BONGCAIXANH":
        {
          // statements;
          return 'Bông Cải Xanh';
        }
        break;
      case "CAIDUNHUUCO":
        {
          // statements;
          return 'Cải Dún Hữu Cơ';
        }
        break;
      case "CUCAITRANG_1":
        {
          // statements;
          return 'Củ Cái Trắng';
        }
        break;
      case "DAUCOVE":
        {
          // statements;
          return 'Đậu cove Đà Lạt';
        }
        break;
      case "DAUHUCHIEN":
        {
          // statements;
          return 'Đậu Hũ Chiên';
        }
        break;
      case "DAUHUTRANG":
        {
          // statements;
          return 'Đậu Hũ Trắng';
        }
        break;
      case "DUIGA":
        {
          // statements;
          return 'Đùi Gà';
        }
        break;
      case "NAMBAONGUXAM":
        {
          // statements;
          return 'Nấm Bào Ngư Xám';
        }
        break;
      case "THANBO":
        {
          // statements;
          return 'Thăn Bò';
        }
        break;
      case "THITBAROI":
        {
          // statements;
          return 'Thịt Ba Rọi';
        }
        break;
      case "UCGATA":
        {
          // statements;
          return 'Ức Gà Ta';
        }
        break;
      case "UCGATAGACONG":
        {
          // statements;
          return 'Ức Gà Ta Gò Công';
        }
        break;
      case "XALACH_1":
        {
          // statements;
          return 'Xà Lách';
        }
        break;
      default:
        {
          return foodId;
        }
        break;
    }
  }

  updateOrders() async {
    List<Map<String, dynamic>> data = new List<Map<String, dynamic>>();
    for (Order orderInList in widget.list) {
      Map<String, dynamic> order = {
        "costDelivery": orderInList.costDelivery,
        "addressDelivery": {
          "address": '${orderInList.addressDelivery.address}',
          "lng": '${orderInList.addressDelivery.lng}',
          "lat": '${orderInList.addressDelivery.lat}',
        },
        "costShopping": orderInList.costShopping,
        "cust": '${orderInList.cust}',
        "dateDelivery": "${orderInList.dateDelivery}",
        "details": [
          for (OrderDetail detail in orderInList.detail)
            {
              "id": "${detail.id}",
              "food": {
                "id": "${detail.food.id}",
                "name": "${detail.food.name}",
                "image": "${detail.food.image}",
                "description": "${detail.food.description}",
                "price": detail.food.price,
                "saleOff": {
                  "startDate": detail.food.saleOff.startDate,
                  "endDate": detail.food.saleOff.endDate,
                  "startTime": detail.food.saleOff.startTime,
                  "endTime": detail.food.saleOff.endTime,
                  "saleOff": detail.food.saleOff.saleOff
                }
              },
              "priceOriginal": detail.priceOriginal,
              "pricePaid": detail.pricePaid,
              "saleOff": detail.saleOff,
              "weight": detail.weight
            },
        ],
        "id": "${orderInList.id}",
        "market": {
          "addr1": utf8.decode(latin1.encode("${orderInList.market.addr1}"),
              allowMalformed: true),
          "addr2": utf8.decode(latin1.encode("${orderInList.market.addr2}"),
              allowMalformed: true),
          "addr3": utf8.decode(latin1.encode("${orderInList.market.addr3}"),
              allowMalformed: true),
          "addr4": utf8.decode(latin1.encode("${orderInList.market.addr4}"),
              allowMalformed: true),
          "id": "${orderInList.market.id}",
          "lat": "${orderInList.market.lat}",
          "lng": "${orderInList.market.lng}",
          "name": utf8.decode(latin1.encode("${orderInList.market.name}"),
              allowMalformed: true),
        },
        "note": "phuong nguyen",
        "shipper": widget.userData.username,
        "status": 21,
        "timeDelivery": "12:12:12",
        "totalCost": orderInList.totalCost
      };
      data.add(order);
    }
    // print(jsonEncode(data));
    //
    // var url = GlobalVariable.API_ENDPOINT + 'orders/update';
    // var response = await http.put(
    //   Uri.encodeFull(url),
    //   headers: {
    //     'Content-type': 'application/json',
    //     "Accept": "application/json",
    //   },
    //   encoding: Encoding.getByName("utf-8"),
    //   body: jsonEncode(data),
    // );

    List<OrderDetail> oD = new List<OrderDetail>();
    for (Order orders in widget.list) {
      for (OrderDetail detail in orders.detail) {
        oD.add(detail);
      }
    }

    // If the server did return a 200 OK response,
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => RouteSupermarket(
                orderDetails: oD, data: data, userData: widget.userData)),
        (Route<dynamic> route) => false);
  }

  final oCcy = new NumberFormat("#,##0", "en_US");

  @override
  Widget build(BuildContext context) {
    List<double> listTotalWeight = new List<double>();
    for (Order orders in widget.list) {
      double total = 0;
      for (OrderDetail details in orders.detail) {
        total += details.weight;
      }
      listTotalWeight.add(total);
    }

    // List<double> listTotalWeight = listOrderDetails.map((e.weight) => e.weight);
    return new Scaffold(
      appBar: new AppBar(
          title: new Text("Chi tiết đơn hàng"), backgroundColor: Colors.green),
      body: new Swiper(
          itemBuilder: (BuildContext context, int index) {
            return new SafeArea(
              child: SingleChildScrollView(
                physics: ScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.list[index].detail.length,
                      itemBuilder: (context, indexList) {
                        return ListTile(
                          leading:
                              widget.list[index].detail[indexList].food.image !=
                                      null
                                  ? Image.network(widget
                                      .list[index].detail[indexList].food.image)
                                  : Image.network(GlobalVariable.LAZY_IMAGE),
                          title: Text(_getNameFood(
                              widget.list[index].detail[indexList].food.id)),
                          trailing: Text(widget
                                  .list[index].detail[indexList].weight
                                  .toString() +
                              " kg"),
                          subtitle: Text(
                              oCcy.format(widget.list[index].detail[indexList]
                                      .priceOriginal) +
                                  " vnd/1kg",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                        );
                      },
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.supervised_user_circle),
                        title: Text('Thông tin khách hàng '),
                        trailing: Text(
                          "Xem chi tiết",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CustomerPage(
                                    orderID: widget.list[index].id)),
                          );
                        },
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.settings_applications),
                        title: Text('Mã đơn hàng '),
                        trailing: Text(widget.list[index].id),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.money),
                        title: Text('Tổng tiền Sản Phẩm '),
                        trailing: Text(
                              '10,000 vnd'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.local_shipping),
                        title: Text('Tiền vận chuyển '),
                        trailing: Text(
                            oCcy.format(widget.list[index].costDelivery) +
                                ' vnd'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.book_outlined),
                        title: Text('Tiền công mua đồ '),
                        trailing: Text(
                            oCcy.format(widget.list[index].costShopping) +
                                ' vnd'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.receipt),
                        title: Text('Tiền được nhận '),
                        trailing: Text(oCcy.format(
                                ((widget.list[index].costShopping +
                                        widget.list[index].costDelivery) /
                                    2)) +
                            ' vnd'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.shop),
                        title: Text('Tổng khối lượng '),
                        trailing:
                            Text(oCcy.format(listTotalWeight[index]) + " kg"),
                      ),
                    ),
                    // Card(
                    //   child: ListTile(
                    //     leading: Icon(Icons.directions_train),
                    //     title: Text('Khoảng cách '),
                    //     trailing: Text("" + ' km'),
                    //   ),
                    // ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.album),
                        title: Text('Đi Từ'),
                        subtitle: Text(utf8.decode(
                            latin1.encode(widget.list[index].market.name +
                                " " +
                                widget.list[index].market.addr1),
                            allowMalformed: true)),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.home),
                        title: Text('Đến'),
                        subtitle: Text(utf8.decode(
                            latin1.encode(
                                widget.list[index].addressDelivery.address),
                            allowMalformed: true)),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.access_alarm),
                        title: Text('Giao trước lúc'),
                        subtitle: Text(widget.list[index].timeDelivery),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: widget.list.length,
          pagination: new SwiperPagination(
              alignment: Alignment.bottomLeft,
              builder: new DotSwiperPaginationBuilder(
                color: Colors.grey,
                activeColor: Colors.green,
                size: 20,
                activeSize: 20,
              )),
          viewportFraction: widget.list.length == 1 ? 0.9 : 0.8,
          control: new SwiperControl(color: Colors.green),
          scale: 0.9),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          updateOrders();
        },
        label: Text('Tiến hành giao hàng'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

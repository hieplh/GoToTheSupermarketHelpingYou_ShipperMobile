import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shipper_app_new/constant/constant.dart';
import 'package:shipper_app_new/model/Customer.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerPage extends StatefulWidget {
  final orderID;
  const CustomerPage({Key key, this.orderID}) : super(key: key);

  @override
  CustomerPageState createState() => CustomerPageState();
}

class CustomerPageState extends State<CustomerPage> {
  Future<Customer> futureCustomer;
  String addressDelivery = "";
  @override
  void initState() {
    super.initState();
    futureCustomer = getCustomerDetail();
  }

  _makingPhoneCall(number) async {
    var url = 'tel:${number}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<Customer> getCustomerDetail() async {
    final response = await http
        .get(GlobalVariable.API_ENDPOINT + 'order/staff/' + widget.orderID);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      setState(() {
        addressDelivery = jsonDecode(response.body)['addressDelivery'];
      });
      // then parse the JSON.
      return Customer.fromJson(jsonDecode(response.body)["customer"]);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load customer');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text('Thông tin khách hàng'),
            backgroundColor: Colors.green),
        body: FutureBuilder<Customer>(
          future: futureCustomer,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                padding: const EdgeInsets.all(8),
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                          "https://toppng.com/uploads/preview/roger-berry-avatar-placeholder-11562991561rbrfzlng6h.png"),
                    ),
                    title: Text(
                      utf8.decode(
                          latin1.encode(
                              '${snapshot.data.firstName} ${snapshot.data.middleName} ${snapshot.data.lastName}'),
                          allowMalformed: true),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${snapshot.data.email}',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15.0,
                      ),
                    ),
                    onTap: () {
                      //Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.phone,
                      color: const Color.fromRGBO(0, 175, 82, 1),
                    ),
                    title: Text(
                      'Số điện thoại',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    trailing: Text("${snapshot.data.phone}"),
                    onTap: () {
                      _makingPhoneCall("${snapshot.data.phone}");
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.assignment,
                      color: const Color.fromRGBO(0, 175, 82, 1),
                    ),
                    title: Text(
                      'Mã đơn hàng đã đặt',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    trailing: Text("${widget.orderID}"),
                    onTap: () {
                   
                    },
                  ),

                ],
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
           Navigator.pop(context);
          },
          tooltip: 'Quay lại',
          child: const Icon(Icons.arrow_back),
          backgroundColor: Colors.green,
        ));
  }
}

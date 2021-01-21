import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shipper_app_new/components/RestarApp.dart';
import 'package:shipper_app_new/model/History.dart';
import 'package:shipper_app_new/model/Orders.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:shipper_app_new/constant/constant.dart';
import 'package:shipper_app_new/model/User.dart';
import 'HistoryDetail.dart';
import 'OrderDetail.dart';
import 'package:intl/intl.dart';
import 'package:sweetalert/sweetalert.dart';
import 'package:badges/badges.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:numberpicker/numberpicker.dart';
import 'RouteCustomer.dart';
import 'RouteSupermarket.dart';
import 'Step.dart';

class MyHomeWidget extends StatefulWidget {
  final User userData;
  MyHomeWidget({Key key, this.userData}) : super(key: key);

  @override
  _MyHomeWidgetState createState() => _MyHomeWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyHomeWidgetState extends State<MyHomeWidget> {
  TextEditingController _c;
  String oldPass;
  String newPass;
  String validatePass;
  TextEditingController oldController = TextEditingController();
  TextEditingController newController = TextEditingController();
  TextEditingController validController = TextEditingController();
  int _counter = 0;

  int countbadges = 0;
  final oCcy = new NumberFormat("#,##0", "en_US");
  StreamController<int> _events;
  String token_app;
  Location location;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  Future<List<Orders>> futureOrders;
  int _selectedIndex = 0;
  var listOrders = new List<Order>();
  var listOrdersFirst = new List<Order>();
  var currentList = new List<Order>();
  var listHistory = new List<History>();
  List<Map<String, dynamic>> data = new List<Map<String, dynamic>>();
  List<OrderDetail> oD = new List<OrderDetail>();
  Completer<GoogleMapController> _controller = Completer();
  final _formKey = GlobalKey<FormState>();
  Set<Marker> markers = Set();
  // Position _currentPosition;
  LocationData currentLocation;
  Timer _clockTimer;
  int maxOrderAccept;

  var listOrderDetails = new List();
  _getCurrentLocation() async {
    currentLocation = await location.getLocation();
  }

  Future<String> _calculation = Future<String>.delayed(
    Duration(seconds: 1),
    () => 'Data Loaded',
  );

  setOrderToMove(List<Order> listOrderstmp) async {
    for (Order orderInList in listOrderstmp) {
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

    for (Order orders in listOrderstmp) {
      for (OrderDetail detail in orders.detail) {
        oD.add(detail);
      }
    }

    // If the server did return a 200 OK response,
  }

  Future<String> _getLastSreens() async {
    await http
        .get(GlobalVariable.API_ENDPOINT +
            "shipper/" +
            '${widget.userData.username}')
        .then((response) {
      if (response.body.isNotEmpty) {
        List mapRes = new List();
        mapRes = json.decode(response.body);

        switch (mapRes[0]['status']) {
          case 21:
            Iterable listTmp = json.decode(response.body);
            currentList =
                listTmp.map((model) => Order.fromJson(model)).toList();
            setOrderToMove(currentList);
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => RouteSupermarket(
                        orderDetails: oD,
                        data: data,
                        userData: widget.userData)),
                (Route<dynamic> route) => false);
            break;

          case 22:
            {
              Iterable listTmp = json.decode(response.body);
              currentList =
                  listTmp.map((model) => Order.fromJson(model)).toList();
              setOrderToMove(currentList);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Steps(
                          item: oD,
                          data: data,
                          userData: widget.userData,
                        )),
              );
            }
            break;
          case 23:
            {
              Iterable listTmp = json.decode(response.body);
              currentList =
                  listTmp.map((model) => Order.fromJson(model)).toList();
              setOrderToMove(currentList);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        RouteCustomer(data: data, userData: widget.userData)),
              );
            }
            break;

          default:
            {
              //statements;
            }
            break;
        }
      } else {}
    });
    return 'Success';
  }

  Future<String> _getOrders() async {
    await http
        .get(GlobalVariable.API_ENDPOINT +
            "shipper/" +
            '${widget.userData.username}')
        .then((response) {
      print("Response don hang " + response.body);
      setState(() {
        Iterable list = json.decode(response.body);
        listOrders = list.map((model) => Order.fromJson(model)).toList();
        countbadges = listOrders.length;
      });
    });
    return 'Success';
  }

  Future<String> _getOrdersFirst() async {
    await http
        .get(GlobalVariable.API_ENDPOINT +
            "shipper/" +
            '${widget.userData.username}')
        .then((response) {
      print("Response don hang " + response.body);
      setState(() {
        Iterable list = json.decode(response.body);
        listOrdersFirst = list.map((model) => Order.fromJson(model)).toList();
      });
    });
    return 'Success';
  }

  updateOrders() async {
    List<Map<String, dynamic>> data = new List<Map<String, dynamic>>();
    for (Order orderInList in listOrders) {
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

    var url = GlobalVariable.API_ENDPOINT + 'orders/update';
    var response = await http.put(
      Uri.encodeFull(url),
      headers: {
        'Content-type': 'application/json',
        "Accept": "application/json",
      },
      encoding: Encoding.getByName("utf-8"),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print("Updater thanh cong");
    } else {
      throw Exception('Loi update dau tien ' +
          utf8.decode(latin1.encode(response.body), allowMalformed: true));
    }
  }

  _getHistory() async {
    var response = await http.get(GlobalVariable.API_ENDPOINT +
        "histories/shipper/" +
        '${widget.userData.username}' +
        "/page/1");

    if (response.body.isNotEmpty) {
      setState(() {
        Iterable list = json.decode(response.body);
        listHistory = list.map((model) => History.fromJson(model)).toList();
      });
    }
    ;
  }

  void showMarker() {
    var pinPosition =
        LatLng(currentLocation.latitude, currentLocation.longitude);
    markers.add(Marker(
        markerId: MarkerId('currentLocation'),
        position: pinPosition,
        icon: BitmapDescriptor.defaultMarker));
  }

  void updateMarkerOnMap() async {
    CameraPosition cPosition = CameraPosition(
      zoom: 16,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    setState(() {
      var pinPosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);

      markers.removeWhere((m) => m.markerId.value == 'currentLocation');
      markers.add(Marker(
          markerId: MarkerId('currentLocation'),
          position: pinPosition, // updated position
          icon: BitmapDescriptor.defaultMarker));
    });
  }

  Timer _timer;
  void _startTimer() {
    _counter = 10;
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      //setState(() {
      (_counter > 0) ? _counter-- : _timer.cancel();
      //});
      print(_counter);
      _events.add(_counter);
    });
  }

  @override
  void initState() {
    super.initState();
    _getLastSreens();
    maxOrderAccept = widget.userData.maxOrder;
    _c = new TextEditingController();
    location = new Location();
    _getCurrentLocation();
    location.onLocationChanged().listen((LocationData cLoc) async {
      currentLocation = cLoc;

      updateMarkerOnMap();
    });

    _firebaseMessaging.getToken().then((token) {
      token_app = token.substring(2);
    });

    _firebaseMessaging.configure(
      onMessage: (message) async {
        print(message);
        _getOrdersFirst();
        if (message['data']['compulsory'] == 'false') {
          _events = new StreamController<int>();
          _events.add(10);
          _startTimer();
          Timer _timer;
          BuildContext dialogContext;
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext builderContext) {
                dialogContext = context;
                _timer = Timer(Duration(seconds: 10), () {
                  // rejectOrder();
                  Navigator.of(context).pop();
                });

                return AlertDialog(
                  title: Text("Thông báo"),
                  content: StreamBuilder<int>(
                      stream: _events.stream,
                      builder:
                          (BuildContext context, AsyncSnapshot<int> snapshot) {
                        return Container(
                            height: MediaQuery.of(context)
                                .size
                                .height, // Change as per your requirement
                            width: MediaQuery.of(context)
                                .size
                                .width, // Change as per your requirement
                            child: SingleChildScrollView(
                              physics: ScrollPhysics(),
                              child: Column(
                                children: [
                                  Card(
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                        ListTile(
                                            leading: Icon(Icons.home),
                                            title: Text(
                                                utf8.decode(
                                                    latin1.encode(
                                                        listOrdersFirst
                                                            .first.market.name),
                                                    allowMalformed: true),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                )),
                                            subtitle: RichText(
                                              text: TextSpan(
                                                text: 'Số lượng đơn hàng :  ',
                                                style:
                                                    DefaultTextStyle.of(context)
                                                        .style,
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text:
                                                          '${listOrdersFirst.length}',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ],
                                              ),
                                            )),
                                      ])),
                                  ListTile(
                                      leading: Text('Thời gian chấp nhận : '),
                                      trailing: Text(
                                          '${snapshot.data.toString()}',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 20))),
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: listOrdersFirst.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return OrderInfo(
                                          data: listOrdersFirst[index]);
                                    },
                                  ),
                                ],
                              ),
                            ));
                      }),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Chấp nhận'),
                      onPressed: () async {
                        await _getOrders().then((value) {
                          updateOrders();
                        });
                        await Navigator.pop(dialogContext);
                      },
                    ),
                    TextButton(
                      child: Text('Từ chối '),
                      onPressed: () {
                        // rejectOrder();
                        Navigator.pop(dialogContext);
                      },
                    ),
                  ],
                );
              }).then((val) {
            if (_timer.isActive) {
              _timer.cancel();
            }
          });
        } else if (message['data']['isCancel'] == 'true') {
          setState(() {
            listOrders
                .removeWhere((item) => item.id == message['data']['orderId']);
          });
          showDialog(
              context: context,
              builder: (_) => new AlertDialog(
                    title: new Text("Thông báo"),
                    content: new Text(
                        'Đơn hàng ${message['data']['orderId']} đã bị hủy'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('OK'),
                        onPressed: () async {
                          await Navigator.of(context).pop();
                        },
                      )
                    ],
                  ));
        }
      },
      onResume: (message) async {
        // setState(() {
        //   title = message["data"]["title"];
        //   helper = "You have open the application from notification";
        // });
      },
    );

    _clockTimer = Timer.periodic(new Duration(seconds: 5), (timer) {
      if (GlobalVariable.IS_LOG_OUT == true) {
        _clockTimer.cancel();
      } else {
        _updatePos();
      }
    });
  }

  _updatePos() {
    print(GlobalVariable.API_ENDPOINT +
        "shipper/" +
        '${widget.userData.username}' +
        "/lat/" +
        '${currentLocation.latitude}' +
        "/lng/" +
        '${currentLocation.longitude}' +
        '/' +
        '${token_app}');
    http
        .get(GlobalVariable.API_ENDPOINT +
            "shipper/" +
            '${widget.userData.username}' +
            "/lat/" +
            '${currentLocation.latitude}' +
            "/lng/" +
            '${currentLocation.longitude}' +
            '/' +
            '${token_app}')
        .then((response) {});
  }

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      if (index == 1) {
        countbadges = 0;
      }
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        body: FutureBuilder<String>(
            future: _calculation,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                List<Widget> _widgetOptions = <Widget>[
                  _buildMap(),
                  _buildOrderReceive(),
                  _buildHistoryList(),
                  _buildInfo(),
                ];
                return Center(
                  child: _widgetOptions.elementAt(_selectedIndex),
                );
              }
            }),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.location_on,
              ),
              title: Text('Bản Đồ'),
            ),
            BottomNavigationBarItem(
              icon: countbadges > 0
                  ? Badge(
                      badgeContent: Text(
                        '${countbadges}',
                        style: TextStyle(color: Colors.white),
                      ),
                      child: Icon(Icons.assignment),
                    )
                  : Icon(Icons.assignment),
              title: Text('Đơn hàng'),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.lock_clock,
              ),
              title: Text('Lịch Sử'),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
              ),
              title: Text('Cài Đặt'),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromRGBO(0, 141, 177, 1),
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  rejectOrder() async {
    var response = await http.get(GlobalVariable.API_ENDPOINT +
        "shipper/${widget.userData.username}/reject");
    if (response.statusCode == 200) {
      print("Reject done");
    }
  }

  Widget _buildMap() {
    CameraPosition initialCameraPosition =
        CameraPosition(zoom: 16, target: LatLng(10.8414, 106.7462));
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: 16);
    }

    return Container(
        child: Stack(
      children: [
        GoogleMap(
          initialCameraPosition: initialCameraPosition,

          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            showMarker();
          },
          markers: markers,
          // myLocationEnabled: true,
        ),
      ],
    ));
  }

  // Widget _buildNotify() {
  //   return Scaffold(
  //     appBar: AppBar(
  //         automaticallyImplyLeading: false,
  //         title: Text("Thông báo"),
  //         centerTitle: true,
  //         backgroundColor: Colors.green),
  //     body: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildOrderReceive() {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Đơn hàng hiện tại'),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.green),
      body: listOrders.length > 0
          ? Column(
              children: <Widget>[
                Card(
                  child: ListTile(
                      title: Text(
                        utf8.decode(latin1.encode(listOrders[0].market.name),
                            allowMalformed: true),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      subtitle: Text(
                        utf8.decode(latin1.encode(listOrders[0].market.addr1),
                                allowMalformed: true) +
                            " " +
                            utf8.decode(
                                latin1.encode(listOrders[0].market.addr2),
                                allowMalformed: true) +
                            " " +
                            utf8.decode(
                                latin1.encode(listOrders[0].market.addr3),
                                allowMalformed: true) +
                            " " +
                            utf8.decode(
                                latin1.encode(listOrders[0].market.addr4),
                                allowMalformed: true),
                        style: TextStyle(fontSize: 17),
                      )),
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: listOrders.length,
                  itemBuilder: (context, indexList) {
                    return Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Image.asset("assets/order.jpg"),
                            title: Text(listOrders[indexList].id),
                            trailing: Text(
                                oCcy.format(listOrders[indexList].totalCost) +
                                    " vnd"),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              TextButton(
                                child: Text('HỦY',
                                    style: TextStyle(color: Colors.red)),
                                onPressed: () {
                                  SweetAlert.show(context,
                                      title: "Chú ý",
                                      subtitle: "Bạn có muốn hủy đơn hàng ? ",
                                      style: SweetAlertStyle.confirm,
                                      showCancelButton: true,
                                      onPress: (bool isConfirm) {
                                    if (isConfirm) {
                                      http
                                          .delete(GlobalVariable.API_ENDPOINT +
                                              'delete/' +
                                              listOrders[indexList].id +
                                              '/shipper/' +
                                              widget.userData.username)
                                          .then((response) {
                                        print(GlobalVariable.API_ENDPOINT +
                                            listOrders[indexList].id +
                                            '/shipper/' +
                                            widget.userData.username);
                                        print(
                                            'Status cancel : ${response.statusCode}');
                                        if (response.statusCode == 200) {
                                          SweetAlert.show(context,
                                              title: "Hủy đơn hàng thành công",
                                              style: SweetAlertStyle.success);
                                          setState(() {
                                            listOrders.removeWhere((item) =>
                                                item.id ==
                                                listOrders[indexList].id);
                                          });
                                        } else {
                                          SweetAlert.show(context,
                                              title: "Đã xảy ra lỗi !",
                                              style: SweetAlertStyle.error);
                                        }
                                      });
                                    }
                                  });
                                  // http
                                  //     .delete(API_ENDPOINT +
                                  //         element.order.id +
                                  //         'shipper' +
                                  //         widget.userData.id)
                                  //     .then((response) {
                                  //      String tmp = element.order.id;
                                  //       List newOrders = listOrders.removeWhere((elemen) => elemen.order.id == tmp);
                                  //   setState(() {
                                  //     Iterable list = json.decode(response.body);
                                  //     listHistory = list
                                  //         .map((model) => History.fromJson(model))
                                  //         .toList();
                                  //   });
                                  // });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                )
              ],
            )
          : Center(child: const Text('Không có đơn hàng nào')),
      floatingActionButton: listOrders.length > 0
          ? Stack(
              children: <Widget>[
                Positioned(
                  bottom: 0.0,
                  right: 10.0,
                  child: FloatingActionButton.extended(
                    heroTag: 'save',
                    label: Text('Xem chi tiết'),
                    backgroundColor: Colors.green,
                    onPressed: () {
                      if (listOrders.length > 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              list: listOrders,
                              userData: widget.userData,
                            ),
                          ),
                        );
                      } else {
                        SweetAlert.show(context,
                            title: "Thông báo",
                            subtitle: "Hiện tại chưa có đơn hàng ",
                            style: SweetAlertStyle.error);
                      }
                      // What you want to do
                    },
                    // child: Icon(Icons.save),
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(5.0),
                    // ),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildHistoryList() {
    _getHistory();

    return Scaffold(
      appBar: AppBar(
          title: const Text('Lịch sử giao hàng'),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.green),
      body: listHistory.length > 0
          ? ListView.builder(
              itemCount: listHistory.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Image.asset("assets/bxh.jpg"),
                        title: Text(
                            utf8.decode(
                                latin1.encode(listHistory[index].market.name),
                                allowMalformed: true),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            listHistory[index].createDate +
                                " " +
                                listHistory[index].createTime,
                            style: TextStyle(fontSize: 16, color: Colors.red)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryDetail(
                                orderID: listHistory[index].id,
                                userId: widget.userData.username,
                                supAdd: utf8.decode(
                                    latin1
                                        .encode(listHistory[index].market.name),
                                    allowMalformed: true),
                                deAdd: utf8.decode(
                                    latin1.encode(
                                        listHistory[index].addressDelivery),
                                    allowMalformed: true),
                                costShipping: listHistory[index].costDelivery,
                                costShopping: listHistory[index].costShopping,
                                totalCost: listHistory[index].totalCost,
                              ),
                            ),
                          );
                        },
                        trailing: Text(
                            oCcy.format(listHistory[index].totalCost) + " vnd"),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          listHistory[index].status == 24
                              ? Text(
                                  "Hoàn tất",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                )
                              : Text(
                                  "Đã bị hủy",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                )
                        ],
                      ),
                    ],
                  ),
                );
              },
            )
          : Center(child: const Text('Lịch sử trống')),
    );
  }

  Widget _buildInfo() {
    final oCcy = new NumberFormat("#,##0", "en_US");
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text('Cài đặt'),
            backgroundColor: Colors.green),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://toppng.com/uploads/preview/roger-berry-avatar-placeholder-11562991561rbrfzlng6h.png"),
              ),
              title: Text(
                utf8.decode(latin1.encode('${widget.userData.fullname} '),
                    allowMalformed: true),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: RatingBar.builder(
                initialRating: widget.userData.rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.question_answer,
                color: const Color.fromRGBO(0, 175, 82, 1),
              ),
              title: Text(
                'Hỗ trợ',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                ),
              ),
              trailing: Text("0918681111"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.phone,
                color: const Color.fromRGBO(0, 175, 82, 1),
              ),
              title: Text(
                'Số điện thoại của tôi',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                ),
              ),
              trailing: Text(widget.userData.username),
            ),
            ListTile(
              leading: Icon(
                Icons.format_list_numbered,
                color: const Color.fromRGBO(0, 175, 82, 1),
              ),
              title: Text(
                'Biển số xe',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                ),
              ),
              trailing: Text(widget.userData.vin),
            ),
            ListTile(
              leading: Icon(
                Icons.assignment_ind,
                color: const Color.fromRGBO(0, 175, 82, 1),
              ),
              title: Text(
                'Đơn hàng nhận được tối đa',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                ),
              ),
              subtitle: Text(
                maxOrderAccept.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              trailing: TextButton(
                onPressed: () {
                  showDialog<int>(
                      context: context,
                      builder: (BuildContext context) {
                        return new NumberPickerDialog.integer(
                          minValue: 1,
                          maxValue: 3,
                          title: new Text("Chọn số lượng"),
                          initialIntegerValue: 1,
                        );
                      }).then((int value) async {
                    var bodyPut = {
                      "maxNumOrder": value,
                      "role": "shipper",
                      "username": widget.userData.username
                    };
                    var url =
                        GlobalVariable.API_ENDPOINT + 'account/maxnumorder';
                    var response = await http.put(
                      Uri.encodeFull(url),
                      headers: {
                        'Content-type': 'application/json',
                        "Accept": "application/json",
                      },
                      encoding: Encoding.getByName("utf-8"),
                      body: jsonEncode(bodyPut),
                    );
                    print(response.statusCode.toString() + " max order");
                    if (response.statusCode == 200) {
                      setState(() {
                        maxOrderAccept = value;
                      });
                    }
                  });
                },
                child: Text('Thay đổi'),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.account_balance_wallet,
                color: const Color.fromRGBO(0, 175, 82, 1),
              ),
              title: Text(
                'Ví của tôi',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                ),
              ),
              trailing: Text(oCcy.format(widget.userData.wallet) + " vnd"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.gavel,
                color: const Color.fromRGBO(0, 175, 82, 1),
              ),
              title: Text(
                'Chính sách',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                ),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: const Color.fromRGBO(0, 175, 82, 1),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.security,
                color: const Color.fromRGBO(0, 175, 82, 1),
              ),
              title: Text(
                'Mật Khẩu',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                ),
              ),
              trailing: TextButton(
                child: Text('Thay đổi'),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Stack(
                            overflow: Overflow.visible,
                            children: <Widget>[
                              Positioned(
                                right: -40.0,
                                top: -40.0,
                                child: InkResponse(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: CircleAvatar(
                                    child: Icon(Icons.close),
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                              ),
                              Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextField(
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          labelText: 'Mật khẩu hiện tại',
                                          icon: Icon(Icons.security),
                                        ),
                                        controller: oldController,
                                        onChanged: (val) {
                                          // (val) is looking at the value in the textbox.
                                          oldPass = val;
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextField(
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          labelText: 'Mật khẩu mới',
                                          icon: Icon(Icons.security),
                                        ),
                                        controller: newController,
                                        onChanged: (val) {
                                          // (val) is looking at the value in the textbox.
                                          newPass = val;
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextField(
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          labelText: 'Xác nhận mật khẩu mới',
                                          icon: Icon(Icons.security),
                                        ),
                                        controller: validController,
                                        onChanged: (val) {
                                          // (val) is looking at the value in the textbox.
                                          validatePass = val;
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: RaisedButton(
                                        child: Text("Xác nhận"),
                                        onPressed: () async {
                                          if (validatePass != newPass) {
                                            showDialog(
                                                context: context,
                                                builder: (_) => new AlertDialog(
                                                      title: new Text("Lỗi"),
                                                      content: new Text(
                                                          "Mật khẩu mới chưa đúng !"),
                                                      actions: <Widget>[
                                                        FlatButton(
                                                          child: Text('Ok'),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        )
                                                      ],
                                                    ));
                                          } else {
                                            var bodyUpdatePass = {
                                              "amount": 0,
                                              "newPwd": newPass,
                                              "oldPwd": oldPass,
                                              "role": "shipper",
                                              "username":
                                                  widget.userData.username,
                                            };

                                            var url =
                                                GlobalVariable.API_ENDPOINT +
                                                    'account/password';
                                            var response = await http.put(
                                              Uri.encodeFull(url),
                                              headers: {
                                                'Content-type':
                                                    'application/json',
                                                "Accept": "application/json",
                                              },
                                              encoding:
                                                  Encoding.getByName("utf-8"),
                                              body: jsonEncode(bodyUpdatePass),
                                            );
                                            if (response.statusCode == 200) {
                                              showDialog(
                                                  context: context,
                                                  builder: (_) =>
                                                      new AlertDialog(
                                                        title: new Text(
                                                            "Thông báo"),
                                                        content: new Text(
                                                            "Cập nhật mật khẩu thành công !"),
                                                        actions: <Widget>[
                                                          FlatButton(
                                                            child: Text('Ok'),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          )
                                                        ],
                                                      ));
                                            }
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                },
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.add_to_home_screen,
                color: const Color.fromRGBO(0, 175, 82, 1),
              ),
              title: Text(
                'Đăng xuất',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                ),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: const Color.fromRGBO(0, 175, 82, 1),
              ),
              onTap: () {
                SweetAlert.show(context,
                    title: "Chú ý",
                    subtitle: "Bạn có muốn đăng xuất khỏi ứng dụng ? ",
                    style: SweetAlertStyle.confirm,
                    showCancelButton: true, onPress: (bool isConfirm) {
                  if (isConfirm) {
                    // _clockTimer.cancel();
                    GlobalVariable.IS_LOG_OUT = true;
                    RestarApp.restartApp(context);
                  }
                });
              },
            ),
          ],
        ));
  }
}

class SignOut {
  static bool number = false;
}

class OrderInfo extends StatefulWidget {
  final Order data;
  OrderInfo({Key key, this.data}) : super(key: key);

  @override
  _OrderInfoState createState() => _OrderInfoState();
}

class _OrderInfoState extends State<OrderInfo> {
  final oCcy = new NumberFormat("#,##0", "en_US");
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
            leading:Text('Mã đơn hàng : ',style: TextStyle(fontWeight: FontWeight.bold))
          ,
            title: Text(
          '${widget.data.id}',
          style: TextStyle(color: Colors.red,fontSize: 14,fontWeight: FontWeight.bold),
        )),

        Card(
          child: ListTile(
            leading: Text('Số món'),
            trailing: Text(oCcy.format(widget.data.detail.length)),
          ),
        ),
        Card(
          child: ListTile(
            leading: Text('Tiền công mua hàng'),
            trailing: Text(oCcy.format(widget.data.costShopping) + " vnd"),
          ),
        ),
        Card(
          child: ListTile(
            leading: Text('Tiền ship'),
            trailing: Text(oCcy.format(widget.data.costDelivery) + " vnd"),
          ),
        ),
        Card(
          child: ListTile(
            leading: Text('Tổng tiền'),
            trailing: Text(oCcy.format(widget.data.totalCost) + " vnd"),
          ),
        ),
      ],
    );
  }
}

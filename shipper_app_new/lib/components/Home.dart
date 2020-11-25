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
import 'Login.dart';
import 'OrderDetail.dart';
import 'package:intl/intl.dart';
import 'package:sweetalert/sweetalert.dart';
import 'package:grouped_list/grouped_list.dart';

class MyHomeWidget extends StatefulWidget {
  final User userData;
  MyHomeWidget({Key key, this.userData}) : super(key: key);

  @override
  _MyHomeWidgetState createState() => _MyHomeWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyHomeWidgetState extends State<MyHomeWidget> {
  String title = "Title";
  String helper = "helper";
  int _counter = 0;
  final oCcy = new NumberFormat("#,##0", "en_US");
  StreamController<int> _events;
  String token_app;
  Location location;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  Future<List<Orders>> futureOrders;
  int _selectedIndex = 0;
  var listOrders = new List<Orders>();
  var listHistory = new List<History>();
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = Set();
  // Position _currentPosition;
  LocationData currentLocation;
  Timer _clockTimer;

  var listOrderDetails = new List();
  _getCurrentLocation() async {
    currentLocation = await location.getLocation();
  }

  Future<String> _calculation = Future<String>.delayed(
    Duration(seconds: 1),
    () => 'Data Loaded',
  );

  Future<String> _getOrders() async {
    // print(GlobalVariable.API_ENDPOINT + "shipper/" + '${widget.userData.id}');
    // print(API_ENDPOINT +
    // "shipper/" +
    // '${widget.userData.id}' +
    // "/lat/10.847440/lng/106.796640");
    // 'http://25.72.134.12:1234/smhu/api/shipper/98765/lat/10.800777/lng/106.732639'
    //http://192.168.43.81/smhu/api/shipper/98765/lat/10.779534/lng/106.631451
    await http
        .get(GlobalVariable.API_ENDPOINT + "shipper/" + '${widget.userData.id}')
        .then((response) {
      print("Response don hang " + response.body);
      setState(() {
        Iterable list = json.decode(response.body);
        listOrders = list.map((model) => Orders.fromJson(model)).toList();
      });
    });
    return 'Success';
  }

  updateOrders() async {
    List<Map<String, dynamic>> data = new List<Map<String, dynamic>>();
    for (Orders orders in listOrders) {
      Map<String, dynamic> order = {
        "costDelivery": orders.order.costDelivery,
        "addressDelivery": orders.order.addressDelivery,
        "costShopping": orders.order.costShopping,
        "cust": '${orders.order.cust}',
        "dateDelivery": "${orders.order.dateDelivery}",
        "details": [
          for (OrderDetail detail in orders.order.detail)
            {
              "foodName": utf8.decode(latin1.encode("${detail.foodId}"),
                  allowMalformed: true),
              "foodId": "${detail.foodId}",
              "id": "${detail.id}",
              "image": "${detail.image}",
              "priceOriginal": detail.priceOriginal,
              "pricePaid": detail.pricePaid,
              "saleOff": detail.saleOff,
              "weight": detail.weight
            },
        ],
        "id": "${orders.order.id}",
        "market": {
          "addr1": utf8.decode(latin1.encode("${orders.order.market.addr1}"),
              allowMalformed: true),
          "addr2": utf8.decode(latin1.encode("${orders.order.market.addr2}"),
              allowMalformed: true),
          "addr3": utf8.decode(latin1.encode("${orders.order.market.addr3}"),
              allowMalformed: true),
          "addr4": utf8.decode(latin1.encode("${orders.order.market.addr4}"),
              allowMalformed: true),
          "id": "${orders.order.market.id}",
          "lat": "${orders.order.market.lat}",
          "lng": "${orders.order.market.lng}",
          "name": utf8.decode(latin1.encode("${orders.order.market.name}"),
              allowMalformed: true),
        },
        "note": "phuong nguyen",
        "shipper": widget.userData.id,
        "status": 21,
        "timeDelivery": "12:12:12",
        "totalCost": orders.order.totalCost
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

  _getHistory() {
    http
        .get(GlobalVariable.API_ENDPOINT +
            "histories/shipper/" +
            '${widget.userData.id}' +
            "/page/1")
        .then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        listHistory = list.map((model) => History.fromJson(model)).toList();
      });
    });
  }

  void showMarker() {
    // get a LatLng for the source location
    // from the LocationData currentLocation object
    var pinPosition =
        LatLng(currentLocation.latitude, currentLocation.longitude);
    // get a LatLng out of the LocationData object

    markers.add(Marker(
        markerId: MarkerId('currentLocation'),
        position: pinPosition,
        icon: BitmapDescriptor.defaultMarker));
    // destination pin
  }

  void updateMarkerOnMap() async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: 16,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    setState(() {
      // updated position
      var pinPosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);

      // the trick is to remove the marker (by id)
      // and add it again at the updated location
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

        _events = new StreamController<int>();
        _events.add(10);
        _startTimer();
        Timer _timer;
        BuildContext dialogContext;
        showDialog(
            context: context,
            builder: (BuildContext builderContext) {
              dialogContext = context;
              _timer = Timer(Duration(seconds: 10), () {
                Navigator.of(context).pop();
              });

              return AlertDialog(
                title: Text("Thông báo"),
                content: StreamBuilder<int>(
                    stream: _events.stream,
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      return Container(
                          height: 300,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text("Có đơn hàng mới gần đây"),
                              Text("Bạn có muốn tiếp nhận ?"),
                              Image.asset(
                                'assets/veget.png',
                                height: 150,
                                width: 150,
                              ),
                              new Expanded(
                                  child: new Align(
                                      alignment: Alignment.bottomCenter,
                                      child: new Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text('${snapshot.data.toString()}',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 30)),
                                        ],
                                      ))),
                            ],
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
      },
      onResume: (message) async {
        // setState(() {
        //   title = message["data"]["title"];
        //   helper = "You have open the application from notification";
        // });
      },
    );

    _clockTimer = Timer.periodic(new Duration(seconds: 5), (timer) {
      _updatePos();
    });
  }

  _updatePos() {
    print(GlobalVariable.API_ENDPOINT +
        "shipper/" +
        '${widget.userData.id}' +
        "/lat/" +
        '${currentLocation.latitude}' +
        "/lng/" +
        '${currentLocation.longitude}' +
        '/' +
        '${token_app}');
    http
        .get(GlobalVariable.API_ENDPOINT +
            "shipper/" +
            '${widget.userData.id}' +
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
      'Index 1: Business',
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
                  _buildNotify(),
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
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.location_on,
              ),
              title: Text('Bản Đồ'),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications,
              ),
              title: Text('Thông Báo'),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.assignment,
              ),
              title: Text(''),
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

  Widget _buildNotify() {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Thông báo"),
          centerTitle: true,
          backgroundColor: Colors.green),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[],
        ),
      ),
    );
  }

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
                      utf8.decode(
                          latin1.encode(listOrders[0].order.market.name),
                          allowMalformed: true),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
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
                            title: Text(listOrders[indexList].order.id),
                            trailing: Text(oCcy.format(
                                    listOrders[indexList].order.totalCost) +
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
                                              listOrders[indexList].order.id +
                                              '/shipper/' +
                                              widget.userData.id)
                                          .then((response) {
                                        print(GlobalVariable.API_ENDPOINT +
                                            listOrders[indexList].order.id +
                                            '/shipper/' +
                                            widget.userData.id);
                                        print(
                                            'Status cancel : ${response.statusCode}');
                                        if (response.statusCode == 200) {
                                          SweetAlert.show(context,
                                              title: "Hủy đơn hàng thành công",
                                              style: SweetAlertStyle.success);
                                          setState(() {
                                            listOrders.removeWhere((item) =>
                                                item.order.id ==
                                                listOrders[indexList].order.id);
                                          });
                                        } else {
                                          // SweetAlert.show(context,
                                          //     title: '${response.statusCode}',
                                          //     style: SweetAlertStyle.error);
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
      floatingActionButton: listOrders.length > 0 ? Stack(
        children: <Widget>[
          Positioned(
            bottom: 80.0,
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
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: FloatingActionButton(
              heroTag: 'close',
              backgroundColor: Colors.green,
              onPressed: () {
                _getOrders();
              },
              child: Icon(Icons.get_app_rounded),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
        ],
      ) : null,
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
                return ListTile(
                    leading: Icon(Icons.home),
                    title: Text(utf8.decode(
                        latin1.encode(listHistory[index].id),
                        allowMalformed: true)),
                    trailing: Text(
                        oCcy.format(listHistory[index].totalCost) + " vnd"),
                    subtitle: Text(utf8.decode(
                            latin1.encode(listHistory[index].marketName),
                            allowMalformed: true) +
                        '\n' +
                        '${utf8.decode(latin1.encode(listHistory[index].addressDelivery), allowMalformed: true)}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HistoryDetail(orderID: listHistory[index].id),
                        ),
                      );
                    });
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
                utf8.decode(
                    latin1.encode('${widget.userData.lastName} ' +
                        '${widget.userData.middleName} ' +
                        '${widget.userData.firstName} '),
                    allowMalformed: true),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${widget.userData.phone}',
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
                    _clockTimer.cancel();
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

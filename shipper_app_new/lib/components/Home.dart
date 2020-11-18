import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shipper_app_new/model/History.dart';
import 'package:shipper_app_new/model/Orders.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:shipper_app_new/constant/constant.dart';
import 'package:shipper_app_new/model/User.dart';
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
  var listOrderDetails = new List();
  _getCurrentLocation() async {
    currentLocation = await location.getLocation();
  }

  Future<String> _calculation = Future<String>.delayed(
    Duration(seconds: 1),
    () => 'Data Loaded',
  );

  _getOrders() {
    print(API_ENDPOINT + "shipper/" + '${widget.userData.id}');
    // print(API_ENDPOINT +
    // "shipper/" +
    // '${widget.userData.id}' +
    // "/lat/10.847440/lng/106.796640");
    // 'http://25.72.134.12:1234/smhu/api/shipper/98765/lat/10.800777/lng/106.732639'
    //http://192.168.43.81/smhu/api/shipper/98765/lat/10.779534/lng/106.631451
    http
        .get(API_ENDPOINT + "shipper/" + '${widget.userData.id}')
        .then((response) {
      print("Response don hang " + response.body);
      setState(() {
        Iterable list = json.decode(response.body);
        listOrders = list.map((model) => Orders.fromJson(model)).toList();
      });
    });
  }

  _getHistory() {
    http
        .get(API_ENDPOINT +
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
              // _timer = Timer(Duration(seconds: 10), () {
              //   Navigator.of(context).pop();
              // });

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
                              Image.asset('assets/veget.png',height: 150,width: 150,),
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
                    onPressed: () {
                      _getOrders();
                      Navigator.pop(dialogContext);
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

    Timer.periodic(new Duration(seconds: 5), (timer) {
      _updatePos();
    });
  }

  _updatePos() {
    http
        .get(API_ENDPOINT +
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
                  // _buildHistoryList(),
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
                Icons.location_searching,
              ),
              title: Text(''),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.assignment,
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
          title: const Text('Đơn hàng có thể tiếp nhận'),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.green),
      body: listOrders.length > 0
          ? GroupedListView<dynamic, String>(
              elements: listOrders,
              groupBy: (element) => utf8.decode(
                  latin1.encode(element.order.market.name),
                  allowMalformed: true),
              groupComparator: (value1, value2) => value2.compareTo(value1),
              order: GroupedListOrder.DESC,
              useStickyGroupSeparators: true,
              groupSeparatorBuilder: (String value) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              itemBuilder: (c, element) {
                return Card(
                  elevation: 8.0,
                  margin:
                      new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Container(
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      leading: Icon(Icons.add_shopping_cart_rounded),
                      title: Text(element.order.id),
                      subtitle: Text(
                          (element.value / 1000.round()).toString() + " km"),
                      trailing:
                          Text(oCcy.format(element.order.totalCost) + " vnd"),
                    ),
                  ),
                );
              },
            )
          : Center(child: const Text('Không có đơn hàng nào')),
      floatingActionButton: Stack(
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
      ),
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
                        latin1.encode(listHistory[index].marketName),
                        allowMalformed: true)),
                    trailing: Icon(Icons.check),
                    subtitle: Text(utf8.decode(
                        latin1.encode(listHistory[index].addressDelivery),
                        allowMalformed: true)),
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => DetailScreen(
                      //         orderObject: listOrders[index],
                      //         detailObject: listOrders[index].order.detail),
                      //   ),
                      // );
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
          ],
        ));
  }
}

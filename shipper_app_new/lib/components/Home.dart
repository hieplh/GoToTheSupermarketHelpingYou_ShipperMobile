import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shipper_app_new/model/History.dart';
import 'package:shipper_app_new/model/Orders.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:shipper_app_new/constant/constant.dart';
import 'package:shipper_app_new/model/User.dart';
import 'OrderDetail.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

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
  StreamController<int> _events;
  String token_app;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  Future<List<Orders>> futureOrders;
  int _selectedIndex = 0;
  var listOrders = new List<Orders>();
  var listHistory = new List<History>();
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = Set();
  Position _currentPosition;
  LatLng latlong = null;
  var listOrderDetails = new List();
  _getCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      latlong = new LatLng(position.latitude, position.longitude);
      markers.add(Marker(
        markerId: MarkerId("BIGCTHAODIEN"),
        draggable: true,
        position:
            new LatLng(_currentPosition.latitude, _currentPosition.longitude),
        infoWindow: InfoWindow(title: 'Vị trí hiện tại'),
        icon: BitmapDescriptor.defaultMarker,
      ));
      // markers.add(Marker(
      //   markerId: MarkerId("VINTHAODIEN"),
      //   draggable: true,
      //   position: new LatLng(10.978089, 106.685200),
      //   infoWindow: InfoWindow(title: 'Vinmart Thảo Điền'),
      //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      // ));
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
          zoom: 16.0)));
    });
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
      print(response.body);
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

    _getCurrentLocation();

    _firebaseMessaging.getToken().then((token) {
      token_app = token.substring(2);
      print(token_app);
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
                                      )))
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
                    onPressed: () {},
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
            "/lat/10.848833/lng/106.752591/" +
            '${token_app}')
        .then((response) {
      print(response.body);
    });
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
    return Scaffold(
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
    );
  }

  Widget _buildMap() {
    _getCurrentLocation();
    return Container(
        child: Stack(
      children: [
        GoogleMap(
          initialCameraPosition:
              CameraPosition(target: LatLng(10.801273, 106.733498), zoom: 10.0),
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
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
          children: <Widget>[
            Text(helper),
            Text(
              '$title',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
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
          ? ListView.builder(
              itemCount: listOrders.length,
              itemBuilder: (context, index) {
                return ListTile(
                    leading: Icon(Icons.add_shopping_cart_rounded),
                    title: Text(utf8.decode(
                        latin1.encode(listOrders[index].order.market.name),
                        allowMalformed: true)),
                    trailing: Text(listOrders[index]
                            .order
                            .totalCost
                            .toString()
                            .replaceAll(regex, "") +
                        " vnd"),
                    subtitle: Text(utf8.decode(
                        latin1.encode((listOrders[index].value / 1000.round())
                                .toString() +
                            " km"),
                        allowMalformed: true)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                              orderObject: listOrders[index],
                              userData: widget.userData,
                              detailObject: listOrders[index].order.detail),
                        ),
                      );
                    });
              },
            )
          : Center(child: const Text('Không có đơn hàng nào')),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _getOrders();
      //   },
      //   child: Icon(Icons.navigation),
      //   backgroundColor: Colors.green,
      // ),
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
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: const Color.fromRGBO(0, 175, 82, 1),
              ),
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
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: const Color.fromRGBO(0, 175, 82, 1),
              ),
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
                Icons.location_city,
                color: const Color.fromRGBO(0, 175, 82, 1),
              ),
              title: Text(
                'GPS',
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

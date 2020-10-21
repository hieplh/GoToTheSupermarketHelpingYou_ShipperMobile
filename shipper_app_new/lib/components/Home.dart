import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shipper_app_new/model/Orders.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'OrderDetail.dart';
// Future<Orders> getOders() async {
//   final response = await http.get(
//       'http://10.1.148.136:1234/smhu/api/shipper/98765/lat/10.780539/lng/106.651088');
//   if (response.statusCode == 200) {
//     print(json.decode(response.body)[0]);
//     return Orders.fromJson(json.decode(response.body)[0]);
//   } else {
//     throw Exception('fail');
//   }
// }

class MyHomeWidget extends StatefulWidget {
  MyHomeWidget({Key key}) : super(key: key);

  @override
  _MyHomeWidgetState createState() => _MyHomeWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyHomeWidgetState extends State<MyHomeWidget> {
  Future<List<Orders>> futureOrders;
  int _selectedIndex = 0;
  var listOrders = new List<Orders>();
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
        position: new LatLng(10.97726, 106.68605439999999),
        infoWindow: InfoWindow(title: 'Big C Thảo Điền'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
      markers.add(Marker(
        markerId: MarkerId("VINTHAODIEN"),
        draggable: true,
        position: new LatLng(10.978089, 106.685200),
        infoWindow: InfoWindow(title: 'Vinmart Thảo Điền'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(10.97728, 106.68605439999999), zoom: 18.0)));
    });
  }

  Future<String> _calculation = Future<String>.delayed(
    Duration(seconds: 1),
    () => 'Data Loaded',
  );

  _getOrders() {
    http
        .get(
            'http://25.72.134.12:1234/smhu/api/shipper/98765/lat/10.800777/lng/106.732639')
        .then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        listOrders = list.map((model) => Orders.fromJson(model)).toList();
        // var orderInList = json.decode(response.body).order.toString();

        // Iterable marketList = json.decode(response.body)[0].order.market;
        // Iterable listOrderDetails = json.decode(response.body)[0].order.details;

        // listMarket = marketList.map((model) => Market.fromJson(model)).toList();
        // listOrderDetails = listOrderDetails
        //     .map((model) => OrderDetail.fromJson(model))
        //     .toList();
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();
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
                Card(
                  child: Column(
                    children: <Widget>[],
                  ),
                ),
                _buildOrderReceive(),
                Card(
                  child: Column(
                    children: <Widget>[],
                  ),
                ),
                Card(
                  child: Column(
                    children: <Widget>[],
                  ),
                ),
              ];
              return Center(
                child: _widgetOptions.elementAt(_selectedIndex),
              );
            }
          }),

      // Center(
      //   child: FutureBuilder<List<Orders>>(
      //     future: _getOrders(),
      //     builder: (context, AsyncSnapshot snapshot) {
      //       if (snapshot.hasData) {
      //         return Center(
      //           child: Card(
      //             color: Colors.amber,
      //             child: Column(
      //               mainAxisSize: MainAxisSize.min,
      //               children: <Widget>[
      //                 ListTile(
      //                   leading: Icon(Icons.album),
      //                   title: Text(utf8.decode(
      //                       latin1.encode(snapshot.data.distance),
      //                       allowMalformed: true)),
      //                   subtitle: Text(snapshot.data.value.toString()),
      //                 ),
      //                 Row(
      //                   mainAxisAlignment: MainAxisAlignment.end,
      //                   children: <Widget>[
      //                     RaisedButton(
      //                       child: const Text('ACCEPT ORDERS'),
      //                       onPressed: () {/* ... */},
      //                     ),
      //                     const SizedBox(width: 8),
      //                     RaisedButton(
      //                       child: const Text('REJECT'),
      //                       onPressed: () {/* ... */},
      //                     ),
      //                     const SizedBox(width: 8),
      //                   ],
      //                 ),
      //               ],
      //             ),
      //           ),
      //         );
      //       } else if (snapshot.hasError) {
      //         return Text("${snapshot.error}");
      //       }

      //       // By default, show a loading spinner.
      //       return CircularProgressIndicator();
      //     },
      //   ),
      // ),,

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.location_on,
            ),
            title: Text('Location'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications,
            ),
            title: Text('Notification'),
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
            title: Text('Activity'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
            ),
            title: Text('Setting'),
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

  Widget _buildOrderReceive() {
    _getOrders();

    return ListView.builder(
      itemCount: listOrders.length,
      itemBuilder: (context, index) {
        return ListTile(
            leading: Icon(Icons.home),
            title: Text(utf8.decode(latin1.encode(listOrders[index].distance),
                allowMalformed: true)),
            trailing: Icon(Icons.more_vert),
            subtitle: Text(utf8.decode(
                latin1.encode(listOrders[index].order.market.name),
                allowMalformed: true)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                      orderObject: listOrders[index],
                      detailObject: listOrders[index].order.detail),
                ),
              );
            });
      },
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shipper3/models/oderModel.dart';
import 'package:shipper3/models/shipperLocationModel.dart';
import 'dart:ui' as ui;

import '../apis/callLocationApis.dart';
import 'package:http/http.dart' as http;

class GPSLocation extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Orders> futureOders;
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  GoogleMapController _controller;
  String newLat;
  String newLng;
  String shipperID = '98765';
  var _dialog = false ;


 Future<Orders> getOders() async {
    final response = await http.get('http://192.168.1.6/smhu/api/shipper/98765/lat/10.780539/lng/106.651088');
    if(response.statusCode ==200){
      return Orders.fromJson(jsonDecode(response.body));
    }else {
      throw Exception('fail');
    }
 }
  static final CameraPosition initialLocation =
      CameraPosition(target: LatLng(10.805272, 106.647525), zoom: 15.4746);

  Future<Uint8List> getMarker(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
    // ByteData byteData = await DefaultAssetBundle.of(context).load("assets/shipper.png");
    // return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("Car"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  void getCurrentLocation() async {
    final Uint8List markerIcon = await getMarker('assets/shipper.png', 100);
    try {
      Uint8List imageData = await getMarker('assets/shipper.png', 100);
      var location = await _locationTracker.getLocation();
      //API.callLocation(shipperLocation(lat: location.latitude.toString(),lng:location.longitude.toString(),shipperId: shipperID));
      // newLat = location.latitude.toString();
      // newLng= location.longitude.toString();
      updateMarkerAndCircle(location, imageData);
      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }
      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(
                  bearing: 192.8334901395799,
                  target: LatLng(newLocalData.latitude, newLocalData.longitude),
                  tilt: 0,
                  zoom: 16.00)));
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FutureBuilder<Orders>(
          future: futureOders,
          builder: (context , snapshot){
            if(snapshot.hasData){
              return Text(snapshot.data.distance);
            }else if (snapshot.hasError) {
              return Text("Fail");
            }
            //return CircularProgressIndicator();
          },
        ),
        // child: GoogleMap(
        //   mapType: MapType.terrain,
        //   initialCameraPosition: initialLocation,
        //   markers: Set.of((marker != null) ? [marker] : []),
        //   circles: Set.of((circle != null) ? [circle] : []),
        //   onMapCreated: (GoogleMapController controller) {
        //     _controller = controller;
        //   },
        // ),
      ),
      floatingActionButton: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25.0, 0, 0, 0),
              child: FloatingActionButton(
                child: Icon(Icons.location_searching),
                onPressed: () {
                  getCurrentLocation();
                 // callLocation();
                  getOders();
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => Oder()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

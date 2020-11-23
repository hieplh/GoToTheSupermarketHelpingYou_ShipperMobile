import 'dart:convert';
import 'dart:math';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:shipper_app_new/constant/constant.dart';
import 'package:shipper_app_new/model/Orders.dart';
import 'package:shipper_app_new/model/User.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shipper_app_new/model/pin_pill_info.dart';
import 'package:sweetalert/sweetalert.dart';

import 'Step.dart';
import 'map_pin_pill.dart';

const double CAMERA_ZOOM = 15;

const LatLng SOURCE_LOCATION = LatLng(10.8414, 106.7462);
// const LatLng DEST_LOCATION = LatLng(10.822787, 106.770953);

class RouteSupermarket extends StatefulWidget {
  final List<OrderDetail> orderDetails;
  final User userData;

  final List<Map<String, dynamic>> data;
  RouteSupermarket({
    Key key,
    @required this.orderDetails,
    this.data,
    this.userData,
  }) : super(key: key);
  @override
  RouteSupermarketState createState() => RouteSupermarketState();
}

class RouteSupermarketState extends State<RouteSupermarket> {
  double distanceToSupermarket;
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
// for my drawn routes on the map
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;
  String googleAPIKey = 'AIzaSyDl3HXWngkUA1yFkSXDeXSzu_3KyPkH810';
// for my custom marker pins
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
// the user's initial location and current location
// as it moves
  LocationData currentLocation;
// a reference to the destination location
  LocationData destinationLocation;
// wrapper around the location API
  Location location;
  double pinPillPosition = -100;
  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: LatLng(0, 0),
      distance: 0.00,
      locationName: '',
      labelColor: Colors.grey);

  PinInformation destinationPinInfo;

  @override
  void initState() {
    super.initState();

    // create an instance of Location
    location = new Location();
    polylinePoints = PolylinePoints();
    setInitialLocation();
    setSourceAndDestinationIcons();

    // subscribe to changes in the user's location
    // by "listening" to the location's onLocationChanged event
    location.onLocationChanged().listen((LocationData cLoc) {
      // cLoc contains the lat and long of the
      // current user's position in real time,
      // so we're holding on to it

      currentLocation = cLoc;

      updatePinOnMap();
      setState(() {
        distanceToSupermarket = (calculateDistance(
            currentLocation.longitude,
            currentLocation.latitude,
            destinationLocation.latitude,
            destinationLocation.longitude));
      });
    });
    // set custom marker pins

    // set the initial location
  }

  void setSourceAndDestinationIcons() async {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.0), 'assets/cart.png')
        .then((onValue) {
      destinationIcon = onValue;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.0), 'assets/driving_pin.png')
        .then((onValue) {
      sourceIcon = onValue;
    });
  }

  _updateOrder() async {
    if (calculateDistance(currentLocation.latitude, currentLocation.longitude,
            destinationLocation.latitude, destinationLocation.longitude) <
        0.05) {
      var url = API_ENDPOINT + 'orders/update';
      var response = await http.put(
        Uri.encodeFull(url),
        headers: {
          'Content-type': 'application/json',
          "Accept": "application/json",
        },
        encoding: Encoding.getByName("utf-8"),
        body: jsonEncode(widget.data),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Steps(
                    item: widget.orderDetails,
                    data: widget.data,
                    userData: widget.userData,
                  )),
        );
      } else {
        // If the server did not return a 200 OK response,
        // SweetAlert.show(context,
        //     subtitle: "Xác nhận không thành công", style: SweetAlertStyle.error);
        // then throw an exception.
        throw Exception(response.body);
      }
    } else {
      SweetAlert.show(context,
          title: "Chưa đi đến siêu thị !", style: SweetAlertStyle.error);
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void setInitialLocation() async {
    final latDes = double.parse(widget.data[0]['market']['lat']);
    final longDes = double.parse(widget.data[0]['market']['lng']);

    // print("phuong " + latDes.toString());

    // set the initial location by pulling the user's
    // current location from the location's getLocation()
    currentLocation = await location.getLocation();

    // hard-coded destination for this example
    destinationLocation =
        LocationData.fromMap({"latitude": latDes, "longitude": longDes});
    var pinPosition =
        LatLng(currentLocation.latitude, currentLocation.longitude);
    // get a LatLng out of the LocationData object
    var destPosition =
        LatLng(destinationLocation.latitude, destinationLocation.longitude);
    distanceToSupermarket = (calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        destinationLocation.latitude,
        destinationLocation.longitude));

    // sourcePinInfo = PinInformation(
    //     locationName: "Start Location",
    //     location: SOURCE_LOCATION,
    //     pinPath: "assets/driving_pin.png",
    //     avatarPath: "assets/friend1.jpg",
    //     labelColor: Colors.blueAccent);
    //
    // destinationPinInfo = PinInformation(
    //     locationName: "End Location",
    //     location: destPosition,
    //     pinPath: "assets/cart.png",
    //     avatarPath: "assets/friend2.jpg",
    //     labelColor: Colors.purple);

    // add the initial source location pin
    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        // onTap: () {
        //   setState(() {
        //     currentlySelectedPin = sourcePinInfo;
        //     pinPillPosition = 0;
        //   });
        // },
        icon: sourceIcon));

    _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: destPosition,
        icon: destinationIcon));
    currentlySelectedPin = PinInformation(
        locationName: widget.data[0]['market']['name'],
        location: SOURCE_LOCATION,
        pinPath: "assets/destination_map_marker.png",
        avatarPath: "assets/cart.png",
        distance: distanceToSupermarket,
        labelColor: Colors.purple);
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition =
        CameraPosition(zoom: CAMERA_ZOOM, target: SOURCE_LOCATION);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: CAMERA_ZOOM);
    }
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              myLocationEnabled: true,
              compassEnabled: true,
              tiltGesturesEnabled: false,
              polylines: _polylines,
              mapType: MapType.normal,
              initialCameraPosition: initialCameraPosition,
              onTap: (LatLng loc) {
                pinPillPosition = -100;
              },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                // my map has completed being created;
                // i'm ready to show the pins on the map
                showPinsOnMap();
              },
              markers: _markers,
            ),
            MapPinPillComponent(
                pinPillPosition: 0, currentlySelectedPin: currentlySelectedPin)
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // print(widget.orderDetails.length.toString());
            _updateOrder();
          },
          label: Text('Đi đến siêu thị hoàn tất'),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  void showPinsOnMap() {
    // get a LatLng for the source location
    // from the LocationData currentLocation object

    // set the route lines on the map from source to destination
    // for more info follow this tutorial
    setPolylines();
  }

  void setPolylines() async {
    List<PointLatLng> result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPIKey,
        currentLocation.latitude,
        currentLocation.longitude,
        destinationLocation.latitude,
        destinationLocation.longitude);
    polylineCoordinates.clear();
    if (result.isNotEmpty) {
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        _polylines.add(Polyline(
            width: 2, // set the width of the polylines
            polylineId: PolylineId("poly"),
            color: Colors.red,
            points: polylineCoordinates));
      });
    }
  }

  void updatePinOnMap() async {
    setPolylines();

    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
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

      // sourcePinInfo.location = pinPosition;

      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          // onTap: () {
          //   setState(() {
          //     currentlySelectedPin = sourcePinInfo;
          //     pinPillPosition = 0;
          //   });
          // },
          position: pinPosition, // updated position
          icon: sourceIcon));
    });
  }
}

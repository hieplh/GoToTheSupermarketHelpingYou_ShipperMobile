import 'dart:convert';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:shipper_app_new/constant/constant.dart';
import 'package:shipper_app_new/model/User.dart';
import 'package:geocoder/geocoder.dart';
import 'package:shipper_app_new/model/pin_pill_info.dart';
import 'dart:async';
import 'DeliverySuccess.dart';
import 'package:http/http.dart' as http;

const double CAMERA_ZOOM = 14;

const LatLng SOURCE_LOCATION = LatLng(10.8414, 106.7462);
const LatLng DEST_LOCATION = LatLng(10.822787, 106.770953);

class RouteCustomer extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final User userData;
  RouteCustomer({Key key, this.data, this.userData}) : super(key: key);
  @override
  RouteCustomerState createState() => RouteCustomerState();
}

class RouteCustomerState extends State<RouteCustomer> {
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
      locationName: '',
      labelColor: Colors.grey);
  PinInformation sourcePinInfo;
  PinInformation destinationPinInfo;

  @override
  void initState() {
    super.initState();

    // create an instance of Location
    location = new Location();
    polylinePoints = PolylinePoints();

    // subscribe to changes in the user's location
    // by "listening" to the location's onLocationChanged event
    location.onLocationChanged().listen((LocationData cLoc) {
      // cLoc contains the lat and long of the
      // current user's position in real time,
      // so we're holding on to it

      currentLocation = cLoc;

      updatePinOnMap();
    });
    // set custom marker pins
    setSourceAndDestinationIcons();
    // set the initial location
    setInitialLocation();
  }

  _updateOrder() async {
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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => SuccessScreen(
                  userData: widget.userData,
                  data: widget.data,
                )),
        ModalRoute.withName('/'),
      );
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => MyHomeWidget(userData: widget.userData)),
      // );
    } else {
      // If the server did not return a 200 OK response,
      // SweetAlert.show(context,
      //     subtitle: "Xác nhận không thành công", style: SweetAlertStyle.error);
      // then throw an exception.
      throw Exception(response.body);
    }
  }

  void setSourceAndDestinationIcons() async {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.0), 'assets/driving_pin.png')
        .then((onValue) {
      sourceIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.0),
            'assets/destination_map_marker.png')
        .then((onValue) {
      destinationIcon = onValue;
    });
  }

  void setInitialLocation() async {
    // print("Dia chi giao hang " + widget.des);
    final query = utf8.decode(latin1.encode(widget.data[0]['addressDelivery']),
        allowMalformed: true);
    var addresses = await Geocoder.local.findAddressesFromQuery(query);
    var first = addresses.first;
    print("Dia chi giao hang : " +
        first.coordinates.latitude.toString() +
        first.coordinates.longitude.toString());
    // set the initial location by pulling the user's
    // current location from the location's getLocation()
    currentLocation = await location.getLocation();

    // hard-coded destination for this example
    destinationLocation = LocationData.fromMap({
      "latitude": first.coordinates.latitude,
      "longitude": first.coordinates.longitude
    });
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
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
              myLocationEnabled: true,
              compassEnabled: true,
              tiltGesturesEnabled: false,
              markers: _markers,
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
              }),

          // MapPinPillComponent(
          //     pinPillPosition: pinPillPosition,
          //     currentlySelectedPin: currentlySelectedPin)
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // print(widget.orderDetails.length.toString());
          _updateOrder();
        },
        label: Text('Hoàn Tất Giao Hàng'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void showPinsOnMap() {
    // get a LatLng for the source location
    // from the LocationData currentLocation object
    var pinPosition =
        LatLng(currentLocation.latitude, currentLocation.longitude);
    // get a LatLng out of the LocationData object
    var destPosition =
        LatLng(destinationLocation.latitude, destinationLocation.longitude);

    // add the initial source location pin
    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        icon: sourceIcon));
    // destination pin
    _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: destPosition,
        icon: destinationIcon));
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

      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: pinPosition, // updated position
          icon: sourceIcon));
    });
  }
}

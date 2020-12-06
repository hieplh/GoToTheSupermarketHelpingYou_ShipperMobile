import 'dart:convert';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
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
  double distanceToSupermarket = 0.00;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;
  List<Map<String, dynamic>> tmp = new List();
  String googleAPIKey = 'AIzaSyDl3HXWngkUA1yFkSXDeXSzu_3KyPkH810';
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  List<OrderDetail> tmpDetail = new List();
  Timer getOrdersTimer;
  LocationData currentLocation;
  LocationData destinationLocation;
  var listOrders = new List<Order>();
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
  Future<String> _getOrders() async {
    await http
        .get(GlobalVariable.API_ENDPOINT + "shipper/" + '${widget.userData.id}')
        .then((response) {
      print("Response don hang RouteSuppermarket ");
      if (response.body.isNotEmpty) {
        setState(() {
          Iterable list = json.decode(response.body);
          listOrders = list.map((model) => Order.fromJson(model)).toList();
        });
        if (listOrders.length > tmp.length) {
          _setNewListOrder();
          showDialog(
              context: context,
              builder: (_) => new AlertDialog(
                    title: new Text("Thông báo"),
                    content: new Text('Có đơn hàng mới'),
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
      } else {}
    });

    return 'Success';
  }

  Future<String> _setNewListOrder() async {
    List<Map<String, dynamic>> data = new List<Map<String, dynamic>>();
    for (Order orderInList in listOrders) {
      Map<String, dynamic> order = {
        "costDelivery": orderInList.costDelivery,
        "addressDelivery": orderInList.addressDelivery,
        "costShopping": orderInList.costShopping,
        "cust": '${orderInList.cust}',
        "dateDelivery": "${orderInList.dateDelivery}",
        "details": [
          for (OrderDetail detail in orderInList.detail)
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
        "shipper": widget.userData.id,
        "status": 21,
        "timeDelivery": "12:12:12",
        "totalCost": orderInList.totalCost
      };
      data.add(order);
    }
    tmp = await data;
    List<OrderDetail> oD = new List<OrderDetail>();
    for (Order orders in listOrders) {
      for (OrderDetail detail in orders.detail) {
        oD.add(detail);
      }
    }
    tmpDetail = await oD;
    return 'Success';
  }

  @override
  void initState() {
    super.initState();
    tmp = widget.data;
    tmpDetail = widget.orderDetails;
    // create an instance of Location
    setInitialLocation().then((value) => showPinsOnMap()).then((value) =>
        location.onLocationChanged().listen((LocationData cLoc) async {
          currentLocation = await cLoc;

          await updatePinOnMap();
        }));
    // _firebaseMessaging.configure(
    //   onMessage: (message) async {
    //     await _getOrders();
    //     await _setNewListOrder();
    //     await showDialog(
    //         context: context,
    //         builder: (_) => new AlertDialog(
    //               title: new Text("Thông báo"),
    //               content: new Text('Có đơn hàng mới'),
    //               actions: <Widget>[
    //                 FlatButton(
    //                   child: Text('OK'),
    //                   onPressed: () async {
    //                     await Navigator.of(context).pop();
    //
    //                   },
    //                 )
    //               ],
    //             ));
    //   },
    //   onResume: (message) async {
    //     // setState(() {
    //     //   title = message["data"]["title"];
    //     //   helper = "You have open the application from notification";
    //     // });
    //   },
    // );
    getOrdersTimer = Timer.periodic(new Duration(seconds: 5), (timer) {
      _getOrders();
    });
  }

  // void setSourceAndDestinationIcons() async {
  //   BitmapDescriptor.fromAssetImage(
  //           ImageConfiguration(devicePixelRatio: 2.0), 'assets/cart.png')
  //       .then((onValue) {
  //     destinationIcon = onValue;
  //   });
  //   BitmapDescriptor.fromAssetImage(
  //           ImageConfiguration(devicePixelRatio: 2.0), 'assets/driving_pin.png')
  //       .then((onValue) {
  //     sourceIcon = onValue;
  //   });
  // }

  _updateOrder() async {
    if (calculateDistance(currentLocation.latitude, currentLocation.longitude,
            destinationLocation.latitude, destinationLocation.longitude) <
        0.05) {
      var url = GlobalVariable.API_ENDPOINT + 'orders/update';
      var response = await http.put(
        Uri.encodeFull(url),
        headers: {
          'Content-type': 'application/json',
          "Accept": "application/json",
        },
        encoding: Encoding.getByName("utf-8"),
        body: jsonEncode(tmp),
      );
      print("Response code la ${response.statusCode}");
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Steps(
                    item: tmpDetail,
                    data: tmp,
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

  Future<String> setInitialLocation() async {
    location = await new Location();
    polylinePoints = await PolylinePoints();
    final latDes = await double.parse(widget.data[0]['market']['lat']);
    final longDes = await double.parse(widget.data[0]['market']['lng']);

    // print("phuong " + latDes.toString());

    // set the initial location by pulling the user's
    // current location from the location's getLocation()
    currentLocation = await location.getLocation();

    // hard-coded destination for this example
    destinationLocation =
        await LocationData.fromMap({"latitude": latDes, "longitude": longDes});
    var pinPosition =
        await LatLng(currentLocation.latitude, currentLocation.longitude);
    // get a LatLng out of the LocationData object
    var destPosition = await LatLng(
        destinationLocation.latitude, destinationLocation.longitude);
    distanceToSupermarket = await (calculateDistance(
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
    await _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        // onTap: () {
        //   setState(() {
        //     currentlySelectedPin = sourcePinInfo;
        //     pinPillPosition = 0;
        //   });
        // },
        icon: sourceIcon));

    await _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: destPosition,
        icon: destinationIcon));

    await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.0), 'assets/cart.png')
        .then((onValue) {
      destinationIcon = onValue;
    });
    await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.0), 'assets/driving_pin.png')
        .then((onValue) {
      sourceIcon = onValue;
    });
    return "Success";
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
              },
              markers: _markers,
            ),
            AnimatedPositioned(
              top: 0,
              right: 0,
              left: 0,
              duration: Duration(milliseconds: 200),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.all(20),
                  height: 70,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            blurRadius: 20,
                            offset: Offset.zero,
                            color: Colors.grey.withOpacity(0.5))
                      ]),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 50,
                        height: 50,
                        margin: EdgeInsets.only(left: 10),
                        child: ClipOval(
                            child: Image.asset("assets/cart.png",
                                fit: BoxFit.cover)),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(widget.data[0]['market']['name'],
                                  style: TextStyle(fontSize: 14)),
                              Text(
                                  'Khoảng cách: ${distanceToSupermarket.toStringAsFixed(2)}' +
                                      " km",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.red)),
                              // Text('Longitude: ${widget.currentlySelectedPin.location.longitude.toString()}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: EdgeInsets.all(15),
                      //   child: Image.asset(widget.currentlySelectedPin.pinPath, width: 50, height: 50),
                      // )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            // print(widget.orderDetails.length.toString());
           await getOrdersTimer.cancel();
           await _updateOrder();
          },
          label: Text('Đi đến siêu thị hoàn tất'),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  Future<String> showPinsOnMap() async {
    await setPolylines();
    return "Success";
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
    await setPolylines();

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
      distanceToSupermarket = calculateDistance(
          currentLocation.latitude,
          currentLocation.longitude,
          destinationLocation.latitude,
          destinationLocation.longitude);
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

class CheckInterval {
  static bool isHasOrder = false;
}

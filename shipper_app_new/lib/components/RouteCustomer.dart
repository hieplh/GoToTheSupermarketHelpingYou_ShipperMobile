import 'dart:convert';
import 'dart:math';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:shipper_app_new/components/CustomerDetail.dart';
import 'package:shipper_app_new/components/camera.dart';
import 'package:shipper_app_new/constant/constant.dart';
import 'package:shipper_app_new/model/Orders.dart';
import 'package:shipper_app_new/model/User.dart';
import 'package:geocoder/geocoder.dart';
import 'package:shipper_app_new/model/pin_pill_info.dart';
import 'dart:async';
import 'DeliverySuccess.dart';
import 'package:http/http.dart' as http;
import 'package:sweetalert/sweetalert.dart';
import 'Home.dart';
import 'Step.dart';

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
  double distanceToAddressDelivery = 0.00;
// for my drawn routes on the map
  var listOrders = new List<Order>();
  Set<Polyline> _polylines = Set<Polyline>();
  String imagePath = "assets/destination_map_marker.png";
  List<LatLng> polylineCoordinates = [];
  String marketName = '';
  List<Map<String, dynamic>> tmpList = new List();
  List<OrderDetail> tmpDetail = new List();
  bool hasNewOrder = false;
  int countShow = 0;
  PolylinePoints polylinePoints;
  String googleAPIKey = 'AIzaSyDl3HXWngkUA1yFkSXDeXSzu_3KyPkH810';
// for my custom marker pins
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  BitmapDescriptor superMarketIcon;
  int countUpdate = 0;
// the user's initial location and current location
// as it moves
  LocationData currentLocation;
// a reference to the destination location
  LocationData destinationLocation;
// wrapper around the location API
  Location location;
  double pinPillPosition = 0;
  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: LatLng(0, 0),
      distance: 0.00,
      locationName: '',
      labelColor: Colors.grey);
  List<String> addressDelivery = new List<String>();
  List<String> orderID = new List<String>();
  int currentIndex = 0;
  String currentOrderId = '';
  String orderIdFromMarker = '';
  String addressNearby = '';
  PinInformation sourcePinInfo;
  PinInformation destinationPinInfo;
  Timer getOrdersTimer;
  @override
  void initState() {
    super.initState();

    setInitialLocation().then((value) => showPinsOnMap()).then((value) =>
        location.onLocationChanged().listen((LocationData cLoc) async {
          currentLocation = await cLoc;

          await updatePinOnMap();
        }));
    getOrdersTimer = Timer.periodic(new Duration(seconds: 5), (timer) {
      _getOrders();
    });
  }

  _showDialogNewOrder() async {
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

  Future<String> _getOrders() async {
    await http
        .get(GlobalVariable.API_ENDPOINT +
            "shipper/" +
            '${widget.userData.username}' +
            '/pre-order')
        .then((response) {
      print("Response don hang RouteCustomer " + response.body);

      print("Tmp ${tmpList.length} '${tmpDetail.length}");
      if (response.body.isNotEmpty && response.body.length > countShow) {
        countShow = response.body.length;

        setState(() {
          Iterable list = json.decode(response.body);
          listOrders = list.map((model) => Order.fromJson(model)).toList();
        });

        _showDialogNewOrder();
        setState(() {
          marketName = listOrders[0].market.name;
        });
        _setNewListOrder();

        _markers.add(Marker(
            markerId: MarkerId('Supermarket'),
            position: LatLng(double.parse(listOrders[0].market.lat),
                double.parse(listOrders[0].market.lng)),
            icon: superMarketIcon));

        // if (listOrders.length > tmp.length) {
        //   _setNewListOrder();

        // }
      } else {}
    });

    return 'Success';
  }

  Future<String> _setNewListOrder() async {
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
        "shipper": widget.userData.username,
        "status": 21,
        "timeDelivery": "12:12:12",
        "totalCost": orderInList.totalCost
      };
      data.add(order);
    }
    tmpList = await data;
    List<OrderDetail> oD = new List<OrderDetail>();
    for (Order orders in listOrders) {
      for (OrderDetail detail in orders.detail) {
        oD.add(detail);
      }
    }
    tmpDetail = await oD;
    return 'Success';
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  _updateOrder() async {
    var url = GlobalVariable.API_ENDPOINT + 'orders/update';
    var response = await http.put(
      Uri.encodeFull(url),
      headers: {
        'Content-type': 'application/json',
        "Accept": "application/json",
      },
      encoding: Encoding.getByName("utf-8"),
      body: jsonEncode(tmpList),
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception(response.body);
    }
  }

  void setSourceAndDestinationIcons() async {
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.0),
            'assets/destination_map_marker.png')
        .then((onValue) {
      destinationIcon = onValue;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.0), 'assets/driving_pin.png')
        .then((onValue) {
      sourceIcon = onValue;
    });
  }

  Future<String> setInitialLocation() async {
    location = await new Location();
    polylinePoints = await PolylinePoints();
    currentLocation = await location.getLocation();
    var pinPosition =
        await LatLng(currentLocation.latitude, currentLocation.longitude);
    await _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        icon: sourceIcon));
    await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.0),
            'assets/destination_map_marker.png')
        .then((onValue) {
      destinationIcon = onValue;
    });

    for (var i = 0; i < widget.data.length; i++) {
      var addressFromMap = await widget.data[i].values.toList();
      // final query = await utf8.decode(latin1.encode(addressFromMap[1]),
      //     allowMalformed: true);
      // var addresses = await Geocoder.local.findAddressesFromQuery(query);
      // var first = await addresses.first;
      var destPosition = await LatLng(double.parse(addressFromMap[1]['lat']),
          double.parse(addressFromMap[1]['lng']));
      await _markers.add(Marker(
          markerId: MarkerId(addressFromMap[6]),
          position: destPosition,
          icon: destinationIcon));
    }

    List<Marker> listmarkers = await _markers
        .where((marker) => marker.markerId.value != 'sourcePin')
        .toList();

    destinationLocation = await LocationData.fromMap({
      "latitude": listmarkers[0].position.latitude,
      "longitude": listmarkers[0].position.longitude
    });

    double minDistance = await calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        listmarkers[0].position.latitude,
        listmarkers[0].position.longitude);

    for (var i = 0; i < listmarkers.length; i++) {
      if (await calculateDistance(
              currentLocation.latitude,
              currentLocation.longitude,
              listmarkers[i].position.latitude,
              listmarkers[i].position.longitude) <
          minDistance) {
        destinationLocation = await LocationData.fromMap({
          "latitude": listmarkers[i].position.latitude,
          "longitude": listmarkers[i].position.longitude
        });
      }
    }
    Marker tmpMarker = await _markers.firstWhere(
        (element) => element.position.latitude == destinationLocation.latitude);

    String initID = await tmpMarker.markerId.value;
    Map<String, dynamic> tmpMap = await widget.data
        .where((element) => element.values.toList()[6] == initID)
        .first;
    setState(() {
      orderIdFromMarker = initID;
      addressNearby = tmpMap.values.toList()[1]['address'];
      distanceToAddressDelivery = calculateDistance(
          currentLocation.latitude,
          currentLocation.longitude,
          destinationLocation.latitude,
          destinationLocation.longitude);
    });

    await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.0), 'assets/driving_pin.png')
        .then((onValue) {
      sourceIcon = onValue;
    });
    await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.0), 'assets/cart.png')
        .then((onValue) {
      superMarketIcon = onValue;
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
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              }),
          AnimatedPositioned(
            top: pinPillPosition + 10,
            right: 0,
            left: 0,
            duration: Duration(milliseconds: 200),
            child: Card(
              margin: EdgeInsets.only(top: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  ListTile(
                    leading: Image.asset(imagePath),
                    title: Text(orderIdFromMarker,
                        style: TextStyle(fontSize: 16, color: Colors.green)),
                    subtitle: Text(
                        utf8.decode(latin1.encode(addressNearby),
                            allowMalformed: true),
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    trailing: Text(
                        '${distanceToAddressDelivery.toStringAsFixed(2)}' +
                            " km",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold)),
                  ),
                  hasNewOrder == false
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            TextButton(
                              child: Text('HỦY',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.red)),
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
                                            orderIdFromMarker +
                                            '/shipper/' +
                                            widget.userData.username)
                                        .then((response) {
                                      if (response.statusCode == 200) {
                                        widget.data.removeWhere((element) =>
                                            element.values.toList()[6] ==
                                            orderIdFromMarker);
                                        if (widget.data.length > 0) {
                                          _setNewPin();
                                          if (_markers.length == 1) {
                                            polylineCoordinates.clear();
                                            setState(() {
                                              pinPillPosition = -130;
                                            });
                                          }
                                        } else if (widget.data.length == 0) {
                                          showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (_) => new AlertDialog(
                                                    title:
                                                        new Text("Thông báo"),
                                                    content: new Text(
                                                      "Tất cả đơn hàng đã bị hủy",
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 20),
                                                    ),
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        child: Text(
                                                            'Quay về màn hình chính!'),
                                                        onPressed: () {
                                                          Navigator
                                                              .pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (BuildContext
                                                                        context) =>
                                                                    MyHomeWidget(
                                                                        userData:
                                                                            widget.userData)),
                                                            ModalRoute.withName(
                                                                '/'),
                                                          );
                                                        },
                                                      )
                                                    ],
                                                  ));
                                        }
                                      } else {}
                                    });
                                  }
                                });
                              },
                            ),
                            SizedBox(width: 8),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CustomerPage(
                                                orderID: orderIdFromMarker,
                                              )));
                                },
                                child: Text("Thông tin khách hàng",
                                    style: TextStyle(color: Colors.green))),
                            SizedBox(width: 8),
                          ],
                        )
                      : Row(),
                ],
              ),
            ),
          )
          // MapPinPillComponent(
          //     pinPillPosition: 0, currentlySelectedPin: currentlySelectedPin),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: hasNewOrder == false
          ? FloatingActionButton.extended(
              onPressed: () {
                // print(widget.orderDetails.length.toString());
                // _updateOrder();
                List<Marker> listmarkers = _markers
                    .where((marker) => marker.markerId.value != 'sourcePin')
                    .toList();
                if (listmarkers.length == 0) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => SuccessScreen(
                              userData: widget.userData,
                              data: widget.data,
                            )),
                    ModalRoute.withName('/'),
                  );
                } else {
                  SweetAlert.show(context,
                      title: "Chưa đến điểm giao hàng !",
                      style: SweetAlertStyle.error);
                }
              },
              label: Text('Hoàn Tất Giao Hàng'),
              backgroundColor: Colors.green,
            )
          : FloatingActionButton.extended(
              onPressed: () async {
                // print(widget.orderDetails.length.toString());
                // _updateOrder();
                if (calculateDistance(
                        currentLocation.latitude,
                        currentLocation.longitude,
                        destinationLocation.latitude,
                        destinationLocation.longitude) <
                    0.05) {
                  await _updateOrder();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Steps(
                              item: tmpDetail,
                              data: tmpList,
                              userData: widget.userData,
                            )),
                  );
                } else {
                  SweetAlert.show(context,
                      title: "Chưa đi đến siêu thị !",
                      style: SweetAlertStyle.error);
                }
              },
              label: Text('Đi siêu thị hoàn tất'),
              backgroundColor: Colors.green,
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

  _showMaterialDialog(Map<String, dynamic> od) async {
    // bool checkDuplicate = false;
    // List address = List();
    // await widget.data.forEach((u) {
    //   if (address.contains(u["addressDelivery"]))
    //     checkDuplicate = true;
    //   else {
    //     checkDuplicate = false;
    //     address.add(u["addressDelivery"]);
    //   }
    // });
    List<Map<String, dynamic>> listTmpDup = new List();
    for (int i = 0; i < widget.data.length; i++) {
      for (int j = i + 1; j < widget.data.length; j++) {
        if (widget.data[i]['addressDelivery']['address'] ==
            (widget.data[j]['addressDelivery']['address'])) {
          listTmpDup.add(widget.data[i]);
          listTmpDup.add(widget.data[j]);
        }
      }
    }
    if (listTmpDup.contains(od)) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => new AlertDialog(
                title: new Text("Thông báo"),
                content: new Text('Đã tới địa điểm giao của đơn hàng'
                    '\n'
                    '\nXin vui lòng chụp hình mặt hàng trước khi chuyển giao cho khách '),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Chụp hình'),
                    onPressed: () async {
                      var url = GlobalVariable.API_ENDPOINT + 'orders/update';
                      var response = await http.put(
                        Uri.encodeFull(url),
                        headers: {
                          'Content-type': 'application/json',
                          "Accept": "application/json",
                        },
                        encoding: Encoding.getByName("utf-8"),
                        body: jsonEncode(listTmpDup),
                      );
                      if (response.statusCode == 200) {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CameraScreen(
                                    shipperId: widget.userData.username,
                                    listTmpDup: listTmpDup)));
                      } else {}
                    },
                  ),
                  FlatButton(
                    child: Text(
                      'Thông tin khách hàng',
                      style: TextStyle(color: Colors.green),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CustomerPage(
                                    orderID: orderIdFromMarker,
                                  )));
                    },
                  )
                ],
              ));
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => new AlertDialog(
                title: new Text("Thông báo"),
                content: new Text(
                    'Đã tới địa điểm giao của đơn hàng ${od['id']}'
                    '\n'
                    '\nXin vui lòng chụp hình mặt hàng trước khi chuyển giao cho khách '),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      'Chụp hình',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () async {
                      var url = GlobalVariable.API_ENDPOINT + 'orders/update';
                      var response = await http.put(
                        Uri.encodeFull(url),
                        headers: {
                          'Content-type': 'application/json',
                          "Accept": "application/json",
                        },
                        encoding: Encoding.getByName("utf-8"),
                        body: '[' + jsonEncode(od) + ']',
                      );
                      print("Loi la ${response.statusCode}"+"${response.body}");
                      if (response.statusCode == 200) {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CameraScreen(
                                      shipperId: widget.userData.username,
                                      orderId: od['id'],
                                    )));
                      } else {}
                    },
                  ),
                  FlatButton(
                    child: Text(
                      'Thông tin khách hàng',
                      style: TextStyle(color: Colors.green),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CustomerPage(
                                    orderID: orderIdFromMarker,
                                  )));
                    },
                  )
                ],
              ));
    }
  }

  _setNewPin() {
    if (_markers.length > 1) {
      Marker tmp = _markers.firstWhere((element) =>
          element.position.latitude == destinationLocation.latitude);

      currentOrderId = tmp.markerId.value;
      _markers.removeWhere((m) =>
          m.position.latitude == destinationLocation.latitude &&
          m.position.longitude == destinationLocation.longitude);
      polylineCoordinates.removeWhere(
          (element) => element.latitude == destinationLocation.latitude);

      List<Marker> listmarkers = _markers
          .where((marker) => marker.markerId.value != 'sourcePin')
          .toList();
      if (listmarkers.length == 0) {
        polylineCoordinates.clear();
      } else if (listmarkers.length == 1) {
        destinationLocation = LocationData.fromMap({
          "latitude": listmarkers[0].position.latitude,
          "longitude": listmarkers[0].position.longitude
        });
      } else {
        destinationLocation = LocationData.fromMap({
          "latitude": listmarkers[0].position.latitude,
          "longitude": listmarkers[0].position.longitude
        });

        double minDistance = calculateDistance(
            currentLocation.latitude,
            currentLocation.longitude,
            listmarkers[0].position.latitude,
            listmarkers[0].position.longitude);

        for (var i = 0; i < listmarkers.length; i++) {
          if (calculateDistance(
                  currentLocation.latitude,
                  currentLocation.longitude,
                  listmarkers[i].position.latitude,
                  listmarkers[i].position.longitude) <
              minDistance) {
            destinationLocation = LocationData.fromMap({
              "latitude": listmarkers[i].position.latitude,
              "longitude": listmarkers[i].position.longitude
            });
            currentOrderId = listmarkers[i].markerId.value;
          }
        }
      }
    } else {
      polylineCoordinates.clear();
      setState(() {
        pinPillPosition = -130;
      });
    }
  }

  void updatePinOnMap() async {
    if (calculateDistance(currentLocation.latitude, currentLocation.longitude,
            destinationLocation.latitude, destinationLocation.longitude) <
        0.05) {
      if (listOrders.length > 0) {
        Marker market = _markers
            .where((element) => element.markerId.value == 'Supermarket')
            .toList()
            .first;
        if (destinationLocation.latitude != market.position.latitude ||
            market.position.latitude == null) {
          if (_markers.length > 1) {
            _markers.removeWhere((m) =>
                m.position.latitude == destinationLocation.latitude &&
                m.position.longitude == destinationLocation.longitude);
            polylineCoordinates.removeWhere(
                (element) => element.latitude == destinationLocation.latitude);

            List<Marker> listmarkers = _markers
                .where((marker) => marker.markerId.value != 'sourcePin')
                .toList();
            if (listmarkers.length == 0) {
              List<Map<String, dynamic>> rs = widget.data
                  .where((element) =>
                      element.values.toList()[6] == orderIdFromMarker)
                  .toList();

              _showMaterialDialog(rs[0]);
              polylineCoordinates.clear();
            } else if (listmarkers.length == 1) {
              destinationLocation = LocationData.fromMap({
                "latitude": listmarkers[0].position.latitude,
                "longitude": listmarkers[0].position.longitude
              });

              List<Map<String, dynamic>> rs = widget.data
                  .where((element) =>
                      element.values.toList()[6] == orderIdFromMarker)
                  .toList();

              _showMaterialDialog(rs[0]);

              // addressNearby = addressDelivery[0];
              // currentOrderId = orderID[0];
            } else {
              destinationLocation = LocationData.fromMap({
                "latitude": listmarkers[0].position.latitude,
                "longitude": listmarkers[0].position.longitude
              });

              // addressNearby = addressDelivery[0];
              // currentOrderId = orderID[0];

              double minDistance = calculateDistance(
                  currentLocation.latitude,
                  currentLocation.longitude,
                  listmarkers[0].position.latitude,
                  listmarkers[0].position.longitude);

              for (var i = 0; i < listmarkers.length; i++) {
                if (calculateDistance(
                        currentLocation.latitude,
                        currentLocation.longitude,
                        listmarkers[i].position.latitude,
                        listmarkers[i].position.longitude) <
                    minDistance) {
                  destinationLocation = LocationData.fromMap({
                    "latitude": listmarkers[i].position.latitude,
                    "longitude": listmarkers[i].position.longitude
                  });
                  currentOrderId = listmarkers[i].markerId.value;

                  // addressNearby = addressDelivery[i];
                  // currentIndex = i;
                  // currentOrderId = orderID[i];
                }
              }

              List<Map<String, dynamic>> rs = widget.data
                  .where((element) =>
                      element.values.toList()[6] == orderIdFromMarker)
                  .toList();

              _showMaterialDialog(rs[0]);

              // setState(() {
              //   distanceToAddressDelivery = calculateDistance(
              //       currentLocation.latitude,
              //       currentLocation.longitude,
              //       destinationLocation.latitude,
              //       destinationLocation.longitude);
              //   currentlySelectedPin = PinInformation(
              //       locationName: addressNearby,
              //       location: SOURCE_LOCATION,
              //       pinPath: "assets/destination_map_marker.png",
              //       avatarPath: "assets/destination_map_marker.png",
              //       distance: distanceToAddressDelivery,
              //       labelColor: Colors.purple);
              // });
            }
          } else {
            polylineCoordinates.clear();
            setState(() {
              pinPillPosition = -150;
            });
          }
        } else {
          setState(() {
            imagePath = "assets/cart.png";
            hasNewOrder = true;
            orderIdFromMarker = listOrders[0].market.id;
            addressNearby = marketName;
            distanceToAddressDelivery = calculateDistance(
                currentLocation.latitude,
                currentLocation.longitude,
                destinationLocation.latitude,
                destinationLocation.longitude);
          });
        }
      } else {
        if (_markers.length > 1) {
          _markers.removeWhere((m) =>
              m.position.latitude == destinationLocation.latitude &&
              m.position.longitude == destinationLocation.longitude);
          polylineCoordinates.removeWhere(
              (element) => element.latitude == destinationLocation.latitude);

          List<Marker> listmarkers = _markers
              .where((marker) => marker.markerId.value != 'sourcePin')
              .toList();
          if (listmarkers.length == 0) {
            List<Map<String, dynamic>> rs = widget.data
                .where((element) =>
                    element.values.toList()[6] == orderIdFromMarker)
                .toList();

            _showMaterialDialog(rs[0]);
            polylineCoordinates.clear();
          } else if (listmarkers.length == 1) {
            destinationLocation = LocationData.fromMap({
              "latitude": listmarkers[0].position.latitude,
              "longitude": listmarkers[0].position.longitude
            });

            List<Map<String, dynamic>> rs = widget.data
                .where((element) =>
                    element.values.toList()[6] == orderIdFromMarker)
                .toList();

            _showMaterialDialog(rs[0]);

            // addressNearby = addressDelivery[0];
            // currentOrderId = orderID[0];
          } else {
            destinationLocation = LocationData.fromMap({
              "latitude": listmarkers[0].position.latitude,
              "longitude": listmarkers[0].position.longitude
            });

            // addressNearby = addressDelivery[0];
            // currentOrderId = orderID[0];

            double minDistance = calculateDistance(
                currentLocation.latitude,
                currentLocation.longitude,
                listmarkers[0].position.latitude,
                listmarkers[0].position.longitude);

            for (var i = 0; i < listmarkers.length; i++) {
              if (calculateDistance(
                      currentLocation.latitude,
                      currentLocation.longitude,
                      listmarkers[i].position.latitude,
                      listmarkers[i].position.longitude) <
                  minDistance) {
                destinationLocation = LocationData.fromMap({
                  "latitude": listmarkers[i].position.latitude,
                  "longitude": listmarkers[i].position.longitude
                });
                currentOrderId = listmarkers[i].markerId.value;

                // addressNearby = addressDelivery[i];
                // currentIndex = i;
                // currentOrderId = orderID[i];
              }
            }

            List<Map<String, dynamic>> rs = widget.data
                .where((element) =>
                    element.values.toList()[6] == orderIdFromMarker)
                .toList();

            _showMaterialDialog(rs[0]);

            // setState(() {
            //   distanceToAddressDelivery = calculateDistance(
            //       currentLocation.latitude,
            //       currentLocation.longitude,
            //       destinationLocation.latitude,
            //       destinationLocation.longitude);
            //   currentlySelectedPin = PinInformation(
            //       locationName: addressNearby,
            //       location: SOURCE_LOCATION,
            //       pinPath: "assets/destination_map_marker.png",
            //       avatarPath: "assets/destination_map_marker.png",
            //       distance: distanceToAddressDelivery,
            //       labelColor: Colors.purple);
            // });
          }
        } else {
          polylineCoordinates.clear();
          setState(() {
            pinPillPosition = -150;
          });
        }
      }

      // setPolylines();
      // if (countUpdate != widget.data.length) {

      // }

    }
    if (_markers.length > 1) {
      setPolylines();
    } else if (_markers.length == 1) {
      polylineCoordinates.clear();
    }

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
    if (_markers.length > 1) {
      if (listOrders.length > 0) {
        Marker market = _markers
            .where((element) => element.markerId.value == 'Supermarket')
            .toList()
            .first;
        if (destinationLocation.latitude == market.position.latitude) {
          setState(() {
            imagePath = "assets/cart.png";
            hasNewOrder = true;
            orderIdFromMarker = listOrders[0].market.id;
            addressNearby = marketName;
            distanceToAddressDelivery = calculateDistance(
                currentLocation.latitude,
                currentLocation.longitude,
                destinationLocation.latitude,
                destinationLocation.longitude);
          });
        } else {
          Marker tmpMarker = _markers.firstWhere((element) =>
              element.position.latitude == destinationLocation.latitude);

          String initID = tmpMarker.markerId.value;
          Map<String, dynamic> tmpMap = widget.data
              .where((element) => element.values.toList()[6] == initID)
              .first;
          setState(() {
            orderIdFromMarker = initID;
            addressNearby = tmpMap.values.toList()[1]['address'];
          });
        }
      } else {
        Marker tmpMarker = _markers.firstWhere((element) =>
            element.position.latitude == destinationLocation.latitude);

        String initID = tmpMarker.markerId.value;
        Map<String, dynamic> tmpMap = widget.data
            .where((element) => element.values.toList()[6] == initID)
            .first;
        setState(() {
          orderIdFromMarker = initID;
          addressNearby = tmpMap.values.toList()[1]['address'];
        });
      }
    }
    setState(() {
      // updated position

      distanceToAddressDelivery = calculateDistance(
          currentLocation.latitude,
          currentLocation.longitude,
          destinationLocation.latitude,
          destinationLocation.longitude);
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

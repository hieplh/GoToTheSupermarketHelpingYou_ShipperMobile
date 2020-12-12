import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shipper_app_new/constant/constant.dart';

class PreviewScreen extends StatefulWidget {
  final String imgPath;
  final String fileName;
  final String shipperId;
  final String orderId;
  final List<Map<String, dynamic>> listTmpDup;
  PreviewScreen(
      {this.imgPath,
      this.fileName,
      this.shipperId,
      this.orderId,
      this.listTmpDup});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  Future<String> upload(File tmpFile, String shipperId, String orderID) async {
    var stream =
        new http.ByteStream(DelegatingStream.typed(tmpFile.openRead()));
    var length = await tmpFile.length();

    var uri = Uri.parse(GlobalVariable.API_ENDPOINT + "upload/images/");

    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(tmpFile.path),
        contentType: new MediaType('image', 'png'));
    request.fields["orderId"] = orderID;
    request.fields["shipperId"] = shipperId;
    //contentType: new MediaType('image', 'png'));

    request.files.add(multipartFile);
    var response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {
      return 'Success';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Image.file(
                File(widget.imgPath),
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 60,
                color: Colors.black,
                child: Center(
                  child: IconButton(
                    icon: Icon(
                      Icons.share,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      getBytes().then((bytes) {
                        print('here now');
                        print(widget.imgPath);
                        print(bytes.buffer.asUint8List());
                        Share.file('Share via', widget.fileName,
                            bytes.buffer.asUint8List(), 'image/path');
                      });
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (widget.listTmpDup!=null) {
            for (var item in widget.listTmpDup) {
              upload(File(widget.imgPath), widget.shipperId, item['id']);
            }
          } else {
            upload(File(widget.imgPath), widget.shipperId, widget.orderId);
          }

          int count = 0;
          Navigator.of(context).popUntil((_) => count++ >= 2);
        },
        label: Text('Xác nhận'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future getBytes() async {
    Uint8List bytes = File(widget.imgPath).readAsBytesSync() as Uint8List;
//    print(ByteData.view(buffer))
    return ByteData.view(bytes.buffer);
  }
}

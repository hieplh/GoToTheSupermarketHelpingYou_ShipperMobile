import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shipper_app_new/constant/constant.dart';
import 'package:shipper_app_new/model/Record.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:direct_select/direct_select.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import 'package:intl/intl.dart';

class Wallet extends StatefulWidget {
  final String userPhone;
  final double totalCostInWallet;

  final DateTime currentDay = new DateTime.now();

  Wallet({Key key, this.userPhone, this.totalCostInWallet}) : super(key: key);

  @override
  _WalletState createState() => new _WalletState();
}

class _WalletState extends State<Wallet> {
  DateTime selectedDate = DateTime.now();
  var recordMonth = new StatisticMonth();
  final oCcy = new NumberFormat("#,##0", "en_US");
  var listRecords = new List<Record>();
  var currentMonth = DateTime.now().month;

  List data;

  final elements1 = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12"
  ];
  int selectedIndex1 = 0;
  List<Widget> _buildItems1() {
    return elements1
        .map((val) => MySelectionItem(
              title: val,
            ))
        .toList();
  }

  fetchRecord() async {
    var response = await http.get(GlobalVariable.API_ENDPOINT +
        'trans/${widget.userPhone}/${DateFormat('MM-yyyy').format(selectedDate)}');

    if (response.statusCode == 200) {
      recordMonth = StatisticMonth.fromJson(jsonDecode(response.body));

      setState(() {
        listRecords = recordMonth.record;
      });
    } else {
      throw Exception('Failed to load album');
    }
  }




  @override
  void initState() {
    super.initState();
    fetchRecord();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Ví của tôi'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: listRecords == null
          ? CircularProgressIndicator()
          : SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Card(
                        child: ListTile(
                      leading: Icon(Icons.payment),
                      title: Text(
                        'Tổng số dư trong ví',
                        style: (TextStyle(fontSize: 18)),
                      ),
                      trailing: Text(
                        oCcy.format(widget.totalCostInWallet) + " vnd",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    )),
                    ListTile(
                      leading: Text(
                        'Chọn thời gian để xem thống kê',
                        style: (TextStyle(fontSize: 18)),
                      ),
                    ),
                    Card(
                        child: ListTile(
                      title: Text(
                        DateFormat('MM-yyyy').format(selectedDate),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      trailing: RaisedButton(
                        child: Text("Thay đổi"),
                        onPressed: () {
                          showMonthPicker(
                            context: context,
                            firstDate: DateTime(DateTime.now().year - 1, 5),
                            lastDate: DateTime(DateTime.now().year + 1, 9),
                            initialDate: selectedDate,
                            locale: Locale("en"),
                          ).then((date) {
                            if (date != null) {
                              setState(() {
                                selectedDate = date;
                              });
                              fetchRecord();
                            }
                          });
                        },
                      ),
                    )),
                    Center(
                        child: Container(
                            child: SfCartesianChart(

                                // Initialize category axis

                                primaryXAxis: CategoryAxis(
                                    labelStyle: ChartTextStyle(
                                      color: Colors.deepOrange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    labelIntersectAction:
                                        AxisLabelIntersectAction.multipleRows),
                                title: ChartTitle(
                                    text: 'Thống kê thu nhập trong tháng ${DateFormat('MM-yyyy').format(selectedDate)}'),
                                tooltipBehavior: TooltipBehavior(enable: true),
                                legend: Legend(
                                    textStyle: ChartTextStyle(

                                        fontSize: 15,

                                        fontWeight: FontWeight.w900),
                                    isVisible: true,
                                    position: LegendPosition.bottom),
                                series: <CartesianSeries>[
                          ColumnSeries<Record, String>(
                              color: Colors.green,
                              name: "Tiền thu nhập (vnd)",
                              dataSource: listRecords,
                              xValueMapper: (Record data, _) =>
                                  "Ngày " + data.fromdate,
                              yValueMapper: (Record data, _) =>
                                  data.amountEarned.round(),
                              dataLabelSettings: DataLabelSettings(
                                  // Renders the data label
                                  isVisible: true)),
                          ColumnSeries<Record, String>(
                              name: "Tiền bị trừ vì hủy đơn (vnd)",
                              dataSource: listRecords,
                              xValueMapper: (Record data, _) =>
                                  "Ngày " + data.fromdate,
                              yValueMapper: (Record data, _) =>
                                  data.amountCharged.abs(),
                              dataLabelSettings: DataLabelSettings(
                                  // Renders the data label
                                  isVisible: true)),
                        ]))),
                    Card(child: ListTile(title: Text('Thu Chi'))),
                    ListTile(
                      leading: Icon(Icons.countertops_outlined),
                      title: Text('Tổng'),
                      trailing: Text(recordMonth.amount != null
                          ? oCcy.format(recordMonth.amount.amountTotal) + " vnd"
                          : "0"),
                    ),
                    ListTile(
                      leading: Icon(Icons.backup),
                      title: Text('Tiền mua hàng'),
                      trailing: Text(recordMonth.amount != null
                          ? oCcy.format(recordMonth.amount.amountRefund) +
                              " vnd"
                          : "0"),
                    ),
                    ListTile(
                      leading: Icon(Icons.assignment),
                      title: Text('Tiền thu nhập'),
                      trailing: Text(recordMonth.amount != null
                          ? oCcy.format(recordMonth.amount.amountEarned) +
                              " vnd"
                          : "0"),
                    ),
                    ListTile(
                      leading: Icon(Icons.local_atm),
                      title: Text('Tiền bị trừ vì hủy đơn'),
                      trailing: Text(recordMonth.amount != null
                          ? oCcy.format(recordMonth.amount.amountCharged) +
                              " vnd"
                          : "0"),
                    ),
                    Card(child: ListTile(title: Text('Đơn hàng'))),
                    ListTile(
                      leading: Icon(Icons.border_all),
                      title: Text('Số đơn hàng đã nhận : '),
                      trailing: Text(recordMonth.numberOrders != null
                          ? recordMonth.numberOrders.numOrders.toString()
                          : "0"),
                    ),
                    ListTile(
                      leading: Icon(Icons.remove_circle),
                      title: Text('Số đơn hàng đã từ chối'),
                      trailing: Text(recordMonth.numberOrders != null
                          ? recordMonth.numberOrders.numRejected.toString()
                          : "0"),
                    ),
                    ListTile(
                      leading: Icon(Icons.cancel),
                      title: Text('Số đơn hàng đã hủy'),
                      trailing: Text(recordMonth.numberOrders != null
                          ? recordMonth.numberOrders.numCanceled.toString()
                          : "0"),
                    ),
                    ListTile(
                      leading: Icon(Icons.done),
                      title: Text('Số đơn hàng giao thành công'),
                      trailing: Text(recordMonth.numberOrders != null
                          ? recordMonth.numberOrders.numDone.toString()
                          : "0"),
                    ),
                    SizedBox(height: 50),

                  ])),
    );
  }
}

class MySelectionItem extends StatelessWidget {
  final String title;
  final bool isForList;

  const MySelectionItem({Key key, this.title, this.isForList = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.0,
      child: isForList
          ? Padding(
              child: _buildItem(context),
              padding: EdgeInsets.all(10.0),
            )
          : Card(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: Stack(
                children: <Widget>[
                  _buildItem(context),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.arrow_drop_down),
                  )
                ],
              ),
            ),
    );
  }

  _buildItem(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Text(title),
    );
  }
}

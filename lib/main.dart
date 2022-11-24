import 'dart:async';

import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  bool connected = false;
  List availableBluetoothDevices = [];

  Future<void> getBluetooth(BuildContext cc) async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");

    setState(() {
      availableBluetoothDevices = bluetooths!;
    });
  }

  Future<void> setConnect(String mac) async {
    final String? result = await BluetoothThermalPrinter.connect(mac);
    print("state conneected $result");
    if (result == "true") {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Device connected now take the print")));
      setState(() {
        connected = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Device not connected try Again!")));
    }
  }

  Future<void> printTicket() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getTicket();
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      await printGraphics();
      print("Print $result");
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<void> printGraphics() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getGraphicsTicket();
      final result = await BluetoothThermalPrinter.writeBytes(bytes);

      print("Print $result");
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<List<int>> getGraphicsTicket() async {
    List<int> bytes = [];

    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    // Print QR Code using native function
    bytes += generator.qrcode('example.com');

    // bytes += generator.hr();

    // Print Barcode using native function
    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));

    bytes += generator.cut();

    return bytes;
  }

  Future<List<int>> getTicket() async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    bytes += generator.text("FRIENDI",
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 0);
    bytes += generator.hr(len: 30, ch: " ");

    bytes += generator.text("FRIENDI 50 SR",
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 0);
    bytes += generator.hr(len: 30, ch: " ");

    bytes += generator.text("-Purchase details-",
        styles: PosStyles(
          align: PosAlign.center,
        ),
        linesAfter: 1);
    // bytes += generator.text('Tel: +919591708470',
    //     styles: PosStyles(align: PosAlign.center));

    // bytes += generator.hr();
    // bytes += generator.row([
    //   PosColumn(
    //       text: "",
    //       width: 1,
    //       styles: PosStyles(align: PosAlign.left,)),
    //   PosColumn(
    //       text: 'Date:', width: 8, styles: PosStyles(align: PosAlign.left)),
    //   PosColumn(
    //       text: '15/04/22',
    //       width: 4,
    //       styles: PosStyles(
    //         align: PosAlign.center,
    //       )),
    //   PosColumn(
    //       text: '0',
    //       width: 2,
    //       styles: PosStyles(align: PosAlign.center, bold: true)),
    //   PosColumn(
    //       text: 'Total',
    //       width: 2,
    //       styles: PosStyles(align: PosAlign.right, bold: true)),
    // ]);

    bytes += generator.row([
      PosColumn(text: "", width: 1),
      PosColumn(
          text: "Date: ",
          width: 3,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "15/04/22",
          width: 4,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.row([
      PosColumn(text: "", width: 1),
      PosColumn(
          text: "Time: ",
          width: 3,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "10:55",
          width: 4,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.row([
      PosColumn(text: "", width: 1),
      PosColumn(
          text: "Serial No: ",
          width: 3,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "348hh55840",
          width: 4,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.row([
      PosColumn(text: "", width: 1),
      PosColumn(
          text: "Token ID: ",
          width: 3,
          styles: PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: "540",
          width: 4,
          styles: PosStyles(
            align: PosAlign.center,
          )),
      PosColumn(text: "", width: 2, styles: PosStyles(align: PosAlign.center)),
      PosColumn(text: "", width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    // bytes += generator.row([
    //   PosColumn(text: "4", width: 1),
    //   PosColumn(
    //       text: "Rova Dosa",
    //       width: 5,
    //       styles: PosStyles(
    //         align: PosAlign.left,
    //       )),
    //   PosColumn(
    //       text: "70",
    //       width: 2,
    //       styles: PosStyles(
    //         align: PosAlign.center,
    //       )),
    //   PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
    //   PosColumn(text: "70", width: 2, styles: PosStyles(align: PosAlign.right)),
    // ]);
    // bytes += generator.text("",
    //     styles: PosStyles(
    //       align: PosAlign.center,
    //     ),
    //     linesAfter: 1);
    bytes += generator.hr(len: 30, ch: " ");
    bytes += generator.text("Activation Number",
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size1,
        ),
        linesAfter: 0);
    bytes += generator.hr(len: 30);
    bytes += generator.text("78558458745455",
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 0);

    bytes += generator.hr(len: 30);
    bytes += generator.text("Recharge information",
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size1,
        ),
        linesAfter: 0);
    bytes += generator.hr(len: 30);
    bytes += generator.text("*4545#serial",
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
        linesAfter: 0);

    bytes += generator.hr(len: 30);

    // bytes += generator.row([
    //   PosColumn(
    //       text: 'TOTAL',
    //       width: 6,
    //       styles: PosStyles(
    //         align: PosAlign.left,
    //         height: PosTextSize.size4,
    //         width: PosTextSize.size4,
    //       )),
    //   PosColumn(
    //       text: "160",
    //       width: 6,
    //       styles: PosStyles(
    //         align: PosAlign.right,
    //         height: PosTextSize.size4,
    //         width: PosTextSize.size4,
    //       )),
    // ]);

    // bytes += generator.hr(ch: '=', linesAfter: 1);

    // ticket.feed(2);

    // bytes += generator.text("26-11-2020 15:22:45",
    // styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    // bytes += generator.text(
    // 'Note: Goods once sold will not be taken back or exchanged.',
    // styles: PosStyles(align: PosAlign.center, bold: false));
    // bytes += await getGraphicsTicket();
    bytes += generator.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));
    // bytes += generator.cut();

    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size.width;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bluetooth Thermal printer'),
        ),
        body: Builder(builder: (context) {
          return Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Search Paired Bluetooth"),
                TextButton(
                  onPressed: () async {
                    PermissionStatus location =
                        await Permission.location.request();
                    PermissionStatus btooth =
                        await Permission.bluetoothScan.request();
                    PermissionStatus btooth1 =
                        await Permission.bluetoothConnect.request();
                    PermissionStatus btooth2 =
                        await Permission.bluetoothAdvertise.request();
                    // PermissionStatus near =
                    // await Permission.nearbyWifiDevices.request();
                    print(location.isGranted);

                    if (location.isGranted &&
                        btooth.isGranted &&
                        btooth1.isGranted &&
                        btooth2.isGranted) {
                      print("permission granted");
                      this.getBluetooth(context);
                    } else {
                      openAppSettings();
                    }
                  },
                  child: Text("Search"),
                ),
                Container(
                  height: 200,
                  child: ListView.builder(
                    itemCount: availableBluetoothDevices.length > 0
                        ? availableBluetoothDevices.length
                        : 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          String select = availableBluetoothDevices[index];
                          List list = select.split("#");
                          // String name = list[0];
                          String mac = list[1];
                          this.setConnect(mac);
                        },
                        title: Text('${availableBluetoothDevices[index]}'),
                        subtitle: Text("Click to connect"),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                // TextButton(
                //   onPressed: connected ? this.printGraphics : null,
                //   child: Text("Print"),
                // ),
                TextButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blueAccent)),
                  onPressed: connected ? this.printTicket : null,
                  child: Text("Print Ticket"),
                ),
                Center(
                  child: Container(
                      color: Color.fromARGB(165, 107, 204, 253).withOpacity(.5),
                      width: 250,
                      height: MediaQuery.of(context).size.height * .1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Icon(Icons.info_rounded),
                            Text(
                                maxLines: 3,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                                "you should pair yor phone with the printer atleast once before you search for the printers avilable"),
                          ],
                        ),
                      )),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}

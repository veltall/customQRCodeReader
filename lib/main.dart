import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QRScanner',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.ralewayTextTheme(),
      ),
      home: const MyHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHome extends ConsumerWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<String> data = ref.watch(stringProvider);
    var tableData = data
        .map((e) => TableRow(
              decoration: (int.parse(e.split(',').first) % 2 == 1)
                  ? BoxDecoration(color: Colors.grey.shade300)
                  : (int.parse(e.split(',').first) % 10 == 0 &&
                          int.parse(e.split(',').first) > 0)
                      ? BoxDecoration(color: Colors.green.shade200)
                      : null,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(e.split(',').first),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(e.split(',')[1]),
                  // child: Text('asfdfd'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(e.split(',').last),
                ),
              ],
            ))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Demo Home Page')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.all(10),
          child: ListView(
            children: [
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder.symmetric(
                  inside: BorderSide(color: Colors.grey.shade400),
                  outside: const BorderSide(),
                ),
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: IntrinsicColumnWidth(flex: 1),
                  2: FixedColumnWidth(100),
                },
                children: <TableRow>[
                  TableRow(
                    decoration:
                        BoxDecoration(color: Theme.of(context).primaryColor),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'ID',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Data',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Timestamp',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  ...(tableData),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            key: const Key("floatingactionbutton1"),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const QRViewExample(),
              ));
            },
            label: const Text("Scan"),
            icon: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(width: 32),
          // FloatingActionButton.extended(
          //   key: const Key("floatingactionbutton2"),
          //   onPressed: () {
          //     ref.read(stringProvider.state).state = [
          //       ...ref.watch(stringProvider),
          //       newLine,
          //     ];
          //     ref.read(idProvider.state).state++;
          //   },
          //   label: const Text("Build"),
          //   icon: const Icon(Icons.add),
          // ),
        ],
      ),
    );
  }
}

class QRViewExample extends ConsumerStatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends ConsumerState<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context, ref)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    Text(
                        'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                  else
                    const Text('Scan a code'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.toggleFlash();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: controller?.getFlashStatus(),
                            builder: (context, snapshot) {
                              return Text('Flash: ${snapshot.data}');
                            },
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.flipCamera();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: controller?.getCameraInfo(),
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                return Text(
                                    'Camera facing ${describeEnum(snapshot.data!)}');
                              } else {
                                return const Text('loading');
                              }
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.pauseCamera();
                          },
                          child: const Text('pause',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.resumeCamera();
                          },
                          child: const Text('resume',
                              style: TextStyle(fontSize: 20)),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context, WidgetRef ref) {
    // For this example we check how wide or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      String newLine = ref.watch(idProvider).toString() +
          ",${scanData.code}," +
          DateTime.now().toString();
      if (!ref.watch(codeProvider).contains(scanData.code.toString())) {
        ref.read(codeProvider.state).state = [
          ...ref.watch(codeProvider),
          scanData.code.toString(),
        ];
        ref.read(stringProvider.state).state = [
          ...ref.watch(stringProvider),
          newLine,
        ];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Captured Code"),
            duration: Duration(milliseconds: 500),
          ),
        );
        ref.read(idProvider.state).state++;
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

var stringProvider = StateProvider((ref) {
  var val = <String>[];
  return val;
});
var idProvider = StateProvider((ref) {
  return 0;
});
var codeProvider = StateProvider((ref) {
  return <String>[];
});

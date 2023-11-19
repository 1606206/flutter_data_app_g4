import 'package:flutter/material.dart';
import 'package:edge/ble_controller.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BLE DEVICE"),
        centerTitle: true,
      ),
      body: GetBuilder<BleController>(
        init: BleController(),
        builder: (controller) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 15,
                ),
                StreamBuilder<List<ScanResult>>(
                  stream: controller.scanResults,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<ScanResult> devices = snapshot.data!;
                      ScanResult? targetDevice;

                      for (var device in devices) {
                        if (device.device.name == "Grupo 4" &&
                            device.device.id.id == "F0:09:D9:4C:E9:18") {
                          targetDevice = device;
                          break;
                        }
                      }

                      if (targetDevice != null) {
                        // Puedes realizar acciones específicas para el dispositivo encontrado.
                        return Card(
                          elevation: 2,
                          child: ListTile(
                            title: Text(targetDevice.device.name),
                            subtitle: Text(targetDevice.device.id.id),
                            trailing: Text(targetDevice.rssi.toString()),
                          ),
                        );
                      } else {
                        return Center(
                          child: Text("Device not found"),
                        );
                      }
                    } else {
                      return Center(
                        child: Text("No Device Found"),
                      );
                    }
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.isConnected.value) {
                      controller.disconnectDevice();
                    } else {
                      controller.scanDevices();
                    }
                  },
                  child: Text(controller.isConnected.value
                      ? "Disconnect"
                      : "Connect to Grupo 4"),
                ),
                SizedBox(
                  height: 15,
                ),

                //---------------------------------LIDIAR CON CONCURRENCIA Y ESTDOS---------------------------
                /*
                FutureBuilder(
                  future: controller.connectedDevice?.state,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      return Text('Device State: ${snapshot.data}');
                    } else {
                      return Text('Error: ${snapshot.error}');
                    }
                  },
                ),
                */
              ],
            ),
          );
        },
      ),
    );
  }
}

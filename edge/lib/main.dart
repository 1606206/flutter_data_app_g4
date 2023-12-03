import 'package:flutter/material.dart';
import 'package:edge/ble_controller.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

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
  Uuid service_uuid = Uuid.parse("19b10000-e8f2-537e-4f6c-d104768a1214");
  Uuid characteristicUUID = Uuid.parse("19b10001-e8f2-537e-4f6c-d104768a1214");
  FlutterReactiveBle flutter_reactive = FlutterReactiveBle();

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
                ElevatedButton(
                  onPressed: () async {
                    if (controller.isConnected.value) {
                      print("Reading characteristic...");
                      //await controller.readCharacteristic();
                      final characteristic = QualifiedCharacteristic(
                        serviceId: service_uuid,
                        characteristicId: characteristicUUID,
                        deviceId: "F0:09:D9:4C:E9:18",
                      );
                      final characteristic_response = await flutter_reactive
                          .readCharacteristic(characteristic);
                      print(characteristic_response);
                    } else {
                      print("Connecting...");
                      controller.connectToGrupo4();
                    }
                  },
                  child: Obx(() => Text(controller.isConnected.value
                      ? "Read Characteristic"
                      : "Connect")),
                ),
                SizedBox(height: 15),
                Obx(() => Text(controller.connectionStatus.value)),
              ],
            ),
          );
        },
      ),
    );
  }
}

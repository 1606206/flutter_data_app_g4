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
  final String characteristicUUID = "tu_uuid_de_caracteristica_a_leer";

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
                      print("Disconnecting...");
                      controller.disconnectDevice();
                    } else {
                      print("Connecting...");
                      controller.connectToGrupo4();
                      controller.simulateData(); // Simular datos aquí
                      controller
                          .startSimulatedDataListening(); // Iniciar la escucha de datos simulados
                      await Future.delayed(Duration(
                          seconds:
                              1)); // Esperar un poco antes de iniciar la escucha de datos reales (puedes ajustar según sea necesario)
                      controller.startDataListening(characteristicUUID);
                      controller.discoverServices();
                    }
                  },
                  child: Obx(() => Text(
                      controller.isConnected.value ? "Disconnect" : "Connect")),
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

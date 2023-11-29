import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class BleController extends GetxController {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  //-------------------------------SCAN COMPLETO QUE MUESTRA POR PANTALLA EL DISPOSITIVO EN CUESTION--------------------------------------
  // Ya no es necesario pero no lo quiero borrar, ya que ahora nos conectamos directamente
  Future scanDevices() async {
    var blePermission = await Permission.bluetoothScan.status;
    if (blePermission.isDenied) {
      if (await Permission.bluetoothScan.request().isGranted) {
        if (await Permission.bluetoothConnect.request().isGranted) {
          flutterBlue.scan(timeout: Duration(seconds: 10)).listen((result) {
            if (result.device.name == "Grupo 4" &&
                result.device.id.id == "F0:09:D9:4C:E9:18") {
              // Aquí, puedes manejar el dispositivo encontrado.
              print("Device Found: ${result.device.name}");
              connectToDevice(result); // O cualquier otra acción que desees
            }
          });
        }
      }
    } else {
      flutterBlue.scan(timeout: Duration(seconds: 10)).listen((result) {
        if (result.device.name == "Grupo 4" &&
            result.device.id.id == "F0:09:D9:4C:E9:18") {
          // Aquí, puedes manejar el dispositivo encontrado.
          print("Device Found: ${result.device.name}");
          connectToDevice(result); // O cualquier otra acción que desees
        }
      });
    }
  }

  void connectToGrupo4() async {
    var result =
        await flutterBlue.scan(timeout: Duration(seconds: 10)).firstWhere(
              (result) =>
                  result.device.name == "Grupo 4" &&
                  result.device.id.id == "F0:09:D9:4C:E9:18",
              orElse: () => null as dynamic,
            );

    if (result != null && result is ScanResult) {
      await connectToDevice(result);
    } else {
      print("Device not found during scan.");
    }
  }

  //--------------------------CONECTARSE AL DISPOSITIVO-----------------------------
  RxBool isConnected = false.obs;
  RxString connectionStatus = "Not yet connected to Grupo 4".obs;
  BluetoothDevice? connectedDevice;
  Future connectToDevice(ScanResult device) async {
    print(
        "Connecting to device: ${device.device.name} (${device.device.id.id})");

    connectedDevice = device.device;

    try {
      await connectedDevice!.connect();
      print("Connected successfully!");
      isConnected.value = true;
      connectionStatus.value = "Connected to Grupo 4";
    } catch (e) {
      print("Connection failed: $e");
      isConnected.value = false;
      connectionStatus.value = "Not yet connected to Grupo 4";
    }
  }

  void disconnectDevice() {
    if (connectedDevice != null) {
      connectedDevice!.disconnect();
      isConnected.value = false;
      connectedDevice = null;
      connectionStatus.value = "Not yet connected to Grupo 4";
    }
  }

  //--------------------------RECIBIR DATOS DEL DISPOSITIVO GRUPO 4-----------------------------
  final String characteristicUUID = "19b10001-e8f2-537e-4f6c-d104768a1214";
  Future<void> readCharacteristic() async {
    try {
      if (!isConnected.value) {
        print("Not connected to Grupo 4");
        return;
      }

      await Future.delayed(
          Duration(milliseconds: 100)); // Ajusta el valor según sea necesario

      if (connectedDevice != null) {
        List<BluetoothService> services =
            await connectedDevice!.discoverServices();
        for (BluetoothService service in services) {
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            if (characteristic.uuid.toString() == characteristicUUID) {
              List<int> value = await characteristic.read();
              String hexValue = value
                  .map((e) => e.toRadixString(16).padLeft(2, '0'))
                  .join(' ');
              print("Read value from characteristic: $hexValue");
              // Puedes realizar acciones adicionales con el valor leído aquí
            }
          }
        }
      }
    } catch (e) {
      print("Error al intentar leer la característica: $e");
    }
  }

  Stream<List<ScanResult>> get scanResults => flutterBlue.scanResults;
}

import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  FlutterBlue flutterBlue = FlutterBlue.instance;
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

  //--------------------------CONECTARSE AL DISPOSITIVO-----------------------------
  RxBool isConnected = false.obs;
  BluetoothDevice? connectedDevice;
  Future connectToDevice(ScanResult device) async {
    print(
        "Connecting to device: ${device.device.name} (${device.device.id.id})");

    connectedDevice = device.device;

    try {
      await connectedDevice!.connect();
      print("Connected successfully!");
      isConnected.value = true;
    } catch (e) {
      print("Connection failed: $e");
    }
  }

  void disconnectDevice() {
    if (connectedDevice != null) {
      connectedDevice!.disconnect();
      isConnected.value = false;
      connectedDevice = null;
    }
  }

  //--------------------------ENVIAR DATOS AL DISPOSITIVO-----------------------------
  Future<void> sendData(String data) async {
    if (connectedDevice != null) {
      List<BluetoothService> services =
          await connectedDevice!.discoverServices();
      services.forEach((service) {
        service.characteristics.forEach((characteristic) {
          // Aquí, puedes enviar datos utilizando characteristic.write()
          // Asegúrate de verificar las propiedades de la característica (writeWithResponse o writeWithoutResponse).
        });
      });
    }
  }

  Stream<List<ScanResult>> get scanResults => flutterBlue.scanResults;
}

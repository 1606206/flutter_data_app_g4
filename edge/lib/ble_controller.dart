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
  Future<void> discoverServices() async {
    if (connectedDevice != null) {
      List<BluetoothService> services =
          await connectedDevice!.discoverServices();

      services.forEach((service) {
        print("Service UUID: ${service.uuid}");

        service.characteristics.forEach((characteristic) {
          print("Characteristic UUID: ${characteristic.uuid}");
          // Puedes imprimir otras propiedades de la característica si es necesario
        });
      });
    }
  }

  BluetoothCharacteristic? findCharacteristic(
      List<BluetoothService> services, String characteristicUUID) {
    BluetoothCharacteristic? targetCharacteristic;

    services.forEach((service) {
      service.characteristics.forEach((characteristic) {
        if (characteristic.uuid.toString() == characteristicUUID) {
          targetCharacteristic = characteristic;
        }
      });
    });

    return targetCharacteristic;
  }

  Future<void> readCharacteristic(String characteristicUUID) async {
    if (connectedDevice != null) {
      List<BluetoothService> services =
          await connectedDevice!.discoverServices();

      services.forEach((service) {
        service.characteristics.forEach((characteristic) async {
          if (characteristic.uuid.toString() == characteristicUUID) {
            List<int> value = await characteristic.read();
            print("Received data: $value");
            // Puedes procesar los datos recibidos aquí
          }
        });
      });
    }
  }

  void listenToCharacteristic(String characteristicUUID) async {
    if (connectedDevice != null) {
      List<BluetoothService> services =
          await connectedDevice!.discoverServices();

      BluetoothCharacteristic? targetCharacteristic = findCharacteristic(
        services,
        characteristicUUID,
      );

      if (targetCharacteristic != null) {
        await targetCharacteristic.setNotifyValue(true);

        targetCharacteristic.value.listen((value) {
          print("Received data: $value");
          // Puedes procesar los datos recibidos aquí
        });
      } else {
        print("Characteristic not found");
      }
    }
  }

  void startDataListening(String characteristicUUID) {
    listenToCharacteristic(characteristicUUID);
  }

  //-------------------------------------------------SIMULACION DE RECIBIMIENTO DE DATOS CREANDO UN NUEVO STREAMCONTROLLER--------------------------
  // Nuevo StreamController para emitir datos simulados
  final StreamController<List<int>> _simulatedDataStream =
      StreamController<List<int>>.broadcast();

  // Método para simular el envío de datos
  void simulateData() {
    final List<int> simulatedData = [1, 2, 3, 4, 5]; // Datos simulados
    _simulatedDataStream.add(simulatedData);
  }

  // Método para iniciar la escucha de datos simulados
  void startSimulatedDataListening() {
    _simulatedDataStream.stream.listen((data) {
      print("Simulated data received: $data");
      // Puedes procesar y almacenar los datos simulados según tus necesidades
    });
  }

  Stream<List<ScanResult>> get scanResults => flutterBlue.scanResults;
}

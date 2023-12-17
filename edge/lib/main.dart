import 'package:flutter/material.dart';
import 'package:edge/ble_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'bbdd_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  Map<DateTime, int> _events = {};

  @override
  void initState() {
    super.initState();
    cargarDatosDesdeJsonALista();
  }

  Future<void> cargarDatosDesdeJsonALista() async {
    try {
      // Load data from the BBDD.json file using rootBundle
      String jsonString = await rootBundle.loadString('assets/BBDD.json');
      List<dynamic> datos = jsonDecode(jsonString);

      // Crear un Map para almacenar las fechas y clientes
      Map<DateTime, int> eventsMap = {};

      // Iteratively update Map for each data set
      for (var dato in datos) {
        String fechaString = dato['fecha'];
        DateTime fecha = DateTime.parse(fechaString);
        int nuevosClientes = dato['clientes'];

        // Agregar la entrada al Map
        eventsMap[fecha] = nuevosClientes;
      }

      // Imprimir el Map para depurar y verificar si los datos se están cargando correctamente
      print('Datos cargados desde JSON: $eventsMap');

      setState(() {
        _events = eventsMap;
      });
    } catch (error) {
      print('Error al cargar datos desde JSON: $error');
      // Handle the error as needed
    }
  }

  bool showCalendar = false;
  bool readCharacteristicPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BLE CALENDAR"),
        centerTitle: true,
      ),
      body: GetBuilder<BleController>(
        init: BleController(),
        builder: (controller) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!readCharacteristicPressed)
                  ElevatedButton(
                    onPressed: () async {
                      if (controller.isConnected.value) {
                        print("Reading characteristic...");
                        // await controller.readCharacteristic();
                        final characteristic = QualifiedCharacteristic(
                          serviceId: service_uuid,
                          characteristicId: characteristicUUID,
                          deviceId: "F0:09:D9:4C:E9:18",
                        );
                        final characteristic_response = await flutter_reactive
                            .readCharacteristic(characteristic);
                        print(characteristic_response);
                        await cargarDatosDesdeJsonAbaseDeDatos();
                        // Mostrar el calendario después de leer la característica
                        setState(() {
                          showCalendar = true;
                          readCharacteristicPressed = true;
                        });
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
                if (showCalendar && _events.isNotEmpty)
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      child: TableCalendar(
                        focusedDay: DateTime.now(),
                        firstDay: DateTime.now().subtract(Duration(days: 365)),
                        lastDay: DateTime.now().add(Duration(days: 365)),
                        calendarFormat: CalendarFormat.month,
                        calendarStyle: CalendarStyle(
                          markerDecoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekendStyle: TextStyle(color: Colors.red),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                        ),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, date, _) {
                            Color color = _getColorForDate(
                                DateTime(date.year, date.month, date.day));
                            return GestureDetector(
                              onTap: () {
                                _showClientCountDialog(date);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color,
                                ),
                                child: Center(
                                  child: Text(
                                    date.day.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getColorForDate(DateTime date) {
    int clients = _events[date] ?? 0;

    print("Fecha evaluada en _getColorForDate: $date");
    print("Clientes asociados a la fecha en _getColorForDate: $clients");

    if (clients > 60) {
      return const Color.fromARGB(255, 163, 34, 25);
    } else if (clients >= 30 && clients <= 60) {
      return const Color.fromARGB(255, 185, 169, 17);
    } else if (clients > 0) {
      return const Color.fromARGB(255, 62, 206, 67);
    } else {
      return Colors.grey;
    }
  }

  void _showClientCountDialog(DateTime date) {
    // Formatear la fecha seleccionada para coincidir con el formato en _events
    DateTime formattedDate = DateTime(date.year, date.month, date.day);

    int clients = _events[formattedDate] ?? 0;

    // Utilizar DateFormat para formatear la fecha en el formato deseado
    String formattedDateString = DateFormat("MMMM d").format(formattedDate);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Number of Clients"),
          content: Text(
              "On the date of $formattedDateString there has been $clients clients."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}

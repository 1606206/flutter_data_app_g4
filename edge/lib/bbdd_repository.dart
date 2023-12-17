import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // Necesario para cargar datos desde un archivo JSON
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

Future<void> actualizarClientesPorFecha(
    String fecha, int nuevosClientes) async {
  try {
    // Referencia a la colección 'actividad'
    CollectionReference actividadCollection =
        FirebaseFirestore.instance.collection('actividad');

    // Consultar si ya existe un documento con la fecha
    QuerySnapshot querySnapshot =
        await actividadCollection.where('fecha', isEqualTo: fecha).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Si el documento ya existe, actualiza el número de clientes
      DocumentSnapshot document = querySnapshot.docs.first;
      int clientesActuales = document['clientes'];
      int totalClientes = clientesActuales + nuevosClientes;

      // Actualiza el documento existente
      await document.reference.update({'clientes': totalClientes});
      print('Número de clientes actualizado para la fecha $fecha.');
    } else {
      // Si no existe, crea un nuevo documento
      await actividadCollection
          .add({'fecha': fecha, 'clientes': nuevosClientes});
      print(
          'Nuevo documento creado para la fecha $fecha con $nuevosClientes clientes.');
    }
  } catch (error) {
    print('Error al actualizar los clientes en Firestore: $error');
    // Puedes manejar el error según tus necesidades
  }
}

// Función para cargar datos desde un archivo JSON
Future<void> cargarDatosDesdeJsonAbaseDeDatos() async {
  try {
    // Load data from the BBDD.json file using rootBundle
    String jsonString = await rootBundle.loadString('assets/BBDD.json');
    List<dynamic> datos = jsonDecode(jsonString);

    // Iteratively update Firestore for each data set
    for (var dato in datos) {
      String fecha = dato['fecha'];
      int nuevosClientes = dato['clientes'];

      // Call the function to update or create documents in Firestore
      await actualizarClientesPorFecha(fecha, nuevosClientes);
    }
  } catch (error) {
    print('Error al cargar datos desde JSON: $error');
    // Handle the error as needed
  }
}

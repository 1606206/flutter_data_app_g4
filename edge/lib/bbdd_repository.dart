import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // Necesario para cargar datos desde un archivo JSON
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

//Funcion que sirve para eliminr toda la base de datos anterior (solo queremos los datos nuevos)
Future<void> reiniciarDatos() async {
  try {
    // Referencia a la colección 'actividad'
    CollectionReference actividadCollection =
        FirebaseFirestore.instance.collection('actividad');

    // Obtener todos los documentos de la colección
    QuerySnapshot querySnapshot = await actividadCollection.get();

    // Iniciar un batch para eliminar documentos en lotes
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Agregar operaciones de eliminación al lote
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Ejecutar el lote para eliminar todos los documentos a la vez
    await batch.commit();

    print(
        'Todos los documentos de la colección "actividad" han sido eliminados.');

    // Llamada a la función para cargar datos desde el archivo JSON
    await cargarDatosDesdeJsonAbaseDeDatos();
  } catch (error) {
    print('Error al reiniciar los datos en Firestore: $error');
  }
}

//aqui añadimos todos los nuevos clientes
Future<void> addClientesPorFecha(String fecha, int nuevosClientes) async {
  try {
    // Referencia a la colección 'actividad'
    CollectionReference actividadCollection =
        FirebaseFirestore.instance.collection('actividad');

    // Añadir un nuevo documento con los datos proporcionados
    await actividadCollection.add({'fecha': fecha, 'clientes': nuevosClientes});

    print(
        'Nuevo documento creado para la fecha $fecha con $nuevosClientes clientes.');
  } catch (error) {
    print('Error al añadir los clientes en Firestore: $error');
  }
}

// Función para cargar datos desde un archivo JSON
Future<void> cargarDatosDesdeJsonAbaseDeDatos() async {
  try {
    String jsonString = await rootBundle.loadString('assets/BBDD.json');
    List<dynamic> datos = jsonDecode(jsonString);

    for (var dato in datos) {
      String fecha = dato['fecha'];
      int nuevosClientes = dato['clientes'];

      await addClientesPorFecha(fecha, nuevosClientes);
    }
  } catch (error) {
    print('Error al cargar datos desde JSON: $error');
  }
}

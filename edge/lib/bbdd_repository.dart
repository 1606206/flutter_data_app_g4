import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // Necesario para cargar datos desde un archivo JSON
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

// Función para actualizar el campo "numero" en Firestore
Future<void> actualizarNumero(String documentId, int nuevoNumero) async {
  //Firebase.initializeApp();
  try {
    // Referencia al documento específico que deseas actualizar
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('prueba').doc(documentId);

    // Actualizar el campo "numero" en el documento
    await docRef.update({'numero': nuevoNumero});

    print('Campo "numero" actualizado correctamente en Firestore.');
  } catch (error) {
    print('Error al actualizar el campo "numero" en Firestore: $error');
    // Puedes manejar el error según tus necesidades
  }
}

// Uso de la función para actualizar el campo "numero" en el documento con ID "jtEGRGkx14RmAAb7NyYT"

Future<void> agregarNumeroAleatorio(int nuevoNumero) async {
  try {
    // Referencia a la colección 'prueba'
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('prueba');

    // Generar un nuevo ID aleatorio para el documento
    String nuevoId = collectionRef.doc().id;

    // Crear el nuevo documento con el número asociado
    await collectionRef.doc(nuevoId).set({'numero': nuevoNumero});

    print('Nuevo documento creado con éxito en Firestore. ID: $nuevoId');
  } catch (error) {
    print('Error al agregar el número en Firestore: $error');
    // Puedes manejar el error según tus necesidades
  }
}

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

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa Firebase
import 'package:path_provider/path_provider.dart';
import 'package:flutter/widgets.dart';

Future<void> sendDataToFirestore() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegúrate de que Flutter esté inicializado

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Obtener la ruta del archivo BBDD.json
  String filePath = await _getFilePath('BBDD.json');

  // Leer el contenido del archivo JSON
  String jsonData = await File(filePath).readAsString();
  List<dynamic> datos = json.decode(jsonData);

  // Obtener referencia de la colección "actividad" en Firestore
  CollectionReference actividadCollection =
      FirebaseFirestore.instance.collection('actividad');

  // Recorrer los datos y agregar a Firestore con un ID personalizado
  datos.forEach((dato) async {
    // Crear un documento con ID personalizado
    await actividadCollection
        .doc('${dato["fecha"]}_${dato["clientes"]}')
        .set(dato);
  });
}

// Función para obtener la ruta del archivo en el directorio de documentos
Future<String> _getFilePath(String fileName) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  return '$appDocPath/$fileName';
}

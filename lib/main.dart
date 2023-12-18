import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(
      MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Reconocer Imagen'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  XFile? _image;

  Future<void> getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            mostrarTitulo(),
            Container(
              width: 250,
              height: 250,
              color: Colors.grey,
              child: Center(
                child: _image == null
                    ? Text('Aqui va la foto')
                    : Image.file(File(_image!.path)),
              ),
            ),
            botones(getImage),
            ElevatedButton(
              onPressed: () {
                if (_image == null) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error no ha tomado una foto'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Volver a intentar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  uploadImage(_image);
                }
              },
              child: Text("Enviar"),
            ),
            // Pasar getImage como argumento a botones
          ],
        ),
      ),
    );
  }
}

class botones extends StatelessWidget {
  final VoidCallback getImage; // Agregar un parámetro para getImage
  botones(this.getImage); // Inicializar getImage en el constructor

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: () async {
            // Hacer que onPressed sea una función asíncrona
            var image = getImage();// Esperar el resultado de getImage
          },
          child: Text("Tomar foto"),
        ),
        SizedBox(width: 10), // Espacio entre los botones

      ],
    );
  }
}

class mostrarTitulo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Tome una fotografía',
      style: TextStyle(fontSize: 40),
    );
  }
}


class tomarFoto extends StatefulWidget {
  @override
  _tomarFotoState createState() => _tomarFotoState();
}

class _tomarFotoState extends State<tomarFoto> {
  XFile? _image;

  Future<XFile?> getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
    return image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tomar Foto'),
      ),
      body: Center(
        child: _image == null
            ? Text('No image selected.')
            : Container(
          width: 250,
          height: 250,
          child: Image.file(File(_image!.path), fit: BoxFit.cover),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage, // Llama a getImage cuando se presiona el botón
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}

Future<void> uploadImage(XFile? img) async {
  var url = Uri.parse('http://localhost:8000/docs'); // Reemplaza con la URL de tu API
  var request = await http.MultipartRequest('POST', url);
  try{
    if(img != null) {
      print("Si hay imagen");
      request.files.add(await http.MultipartFile.fromPath(
        'image', // Este es el nombre del campo que espera tu API
        img.path, // Usa img.path para obtener la ruta de la imagen
      ));
    } else {
      print("No hay imagen");
    }
  }catch(e){
    print(e);
  }

  var response = await request.send();

  if (response.statusCode == 200) {
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
  } else {
    print('Failed to upload image.');
  }
}
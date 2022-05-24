import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mars Photos',
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.red,
              foregroundColor: Colors.black
          )
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<MarsPhoto>> futureMarsPhotos;

  Future<List<MarsPhoto>> fetchMarsPhotos() async {
    final String yesterday = DateFormat("yyyy-M-d").format(DateTime.now().subtract(const Duration(days: 1)));
    final response = await http.get(Uri.parse('https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?earth_date=2022-5-22&api_key=ooRR4jQXE0asSoeD93k2N5kp2Q6sOoYDJSNcohUh'));
    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<String, dynamic>();
      List<MarsPhoto> listOfString =
      List<MarsPhoto>.from(items['photos'].map((marsPhoto) => MarsPhoto.fromJson(marsPhoto)));

      return listOfString;
    } else {
      throw Exception('Failed to load Mars photos');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Mars Photos (yesterday)'),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: FutureBuilder<List<MarsPhoto>>(
                future: fetchMarsPhotos(),
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    return ListView(
                      children: snapshot.data!.map((data) {
                        return Container(
                            padding: EdgeInsets.all(16),
                            alignment: Alignment.center,
                            child: Image.network(data.img_src)
                        );
                      }).toList(),
                    );
                  }else if(snapshot.hasError){
                    return Text('${snapshot.error}');
                  }
                  return const CircularProgressIndicator();
                }
            )
      ),
    );
  }
}

class MarsPhoto {
  final int id;
  final int sol;
  final String img_src;
  final String earth_date;
  //final Camera camera;
  //final Rover rover;

  const MarsPhoto({required this.id, required this.sol,
    required this.img_src, required this.earth_date,
    //required this.camera, required this.rover
  });

  factory MarsPhoto.fromJson(Map<String, dynamic> json) {
    return MarsPhoto(
      id: json['id'],
      sol: json['sol'],
      img_src: json['img_src'],
      earth_date: json['earth_date'],
      //camera: json['camera'],
      //rover: json['rover']
    );
  }
}

class Camera {
  final int id;
  final String name;
  final int rover_id;
  final String full_name;

  const Camera({required this.id, required this.name, required this.rover_id, required this.full_name});

  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      id: json['id'],
      name: json['name'],
      rover_id: json['rover_id'],
      full_name: json['full_name']
    );
  }
}

class Rover {
  final int id;
  final String name;
  final String landing_date;
  final String launch_date;
  final String status;

  const Rover({required this.id, required this.name, required this.landing_date,
    required this.launch_date, required this.status});

  factory Rover.fromJson(Map<String, dynamic> json) {
    return Rover(
        id: json['id'],
        name: json['name'],
        landing_date: json['landing_date'],
        launch_date: json['launch_date'],
        status: json['status']
    );
  }
}
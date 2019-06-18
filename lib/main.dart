import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  var data = await readData();

  if (data != null) {
    String message = await readData();
    print(message);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _enterDataField = TextEditingController();
  String _savedData = "";

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  _loadSavedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(
      () {
        if (preferences.getString('data') != null &&
            preferences.getString('data').isNotEmpty) {
          _savedData = preferences.getString('data');
        } else {
          _savedData = 'Empty SP';
        }
      },
    );
  }

  _saveMessage(String message) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('data', message);
    _loadSavedData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Read/Write'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: Container(
        padding: EdgeInsets.all(13.4),
        alignment: Alignment.topCenter,
        child: ListTile(
          title: TextField(
            controller: _enterDataField,
            decoration: InputDecoration(labelText: 'Write Something'),
          ),
          subtitle: FlatButton(
            color: Colors.redAccent,
            onPressed: () {
              writeData(_enterDataField.text);
              _saveMessage(_enterDataField.text);
            },
            child: Column(
              children: <Widget>[
                Text(
                  'Save Data',
                  style: TextStyle(color: Colors.white70),
                ),
                Padding(
                  padding: EdgeInsets.all(14.5),
                ),
                Text(
                  'sharedPreference : $_savedData',
                  style: TextStyle(color: Colors.white70),
                ),
                FutureBuilder(
                  future: readData(),
                  builder: (BuildContext context, AsyncSnapshot<String> data) {
                    if (data.hasData != null) {
                      return Text(
                        'file : ${data.data.toString()}',
                        style: TextStyle(color: Colors.white70),
                      );
                    } else {
                      return Text('No data saved');
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;

  return File('$path/data.txt');
}

Future<File> writeData(String message) async {
  final file = await _localFile;

  return file.writeAsString('$message');
}

Future<String> readData() async {
  try {
    final file = await _localFile;
    String data = await file.readAsString();
    return data;
  } catch (e) {
    return 'Nothing saved yet!';
  }
}

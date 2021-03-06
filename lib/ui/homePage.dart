import 'package:flutter/material.dart';
import '../utils/currentUser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/currentUser.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

SharedPreferences sharedPreferences;


class HomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }

}

class HomePageState extends State<HomePage>{
  String data = '';
  String name = '';
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // For your reference print the AppDoc directory
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.txt');
  }

  Future<void> readcontent() async {
    try {
      final file = await _localFile;
      // Read the file
      String contents = await file.readAsString();
      setState(() {
        this.data = contents;
      });
    } catch (e) {
      // If there is an error reading, return a default String
      setState(() {
        this.data = 'ยังไม่มีการใส่ข้อมูล';
      });
    }
  }

  @override
  void initState() {
    // TODO: implement setState
    super.initState();
    readcontent();
    _getName();
  }

  Future<void> _getName() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
     name = prefs.getString('name'); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
          children: <Widget>[
            ListTile(
              title: Text('Hello ${name}'),
              subtitle: Text('this is my quote "${data}"'),
            ),
            RaisedButton(
              child: Text("PROFILE SETUP"),
              onPressed: () {
                Navigator.of(context).pushNamed('/profile');
              },
            ),
            RaisedButton(
              child: Text("MY FRIENDS"),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/friend');
              },
            ),
            RaisedButton(
              child: Text("SIGN OUT"),
              onPressed: () async {
                CurrentUser.USERID = null;
                CurrentUser.NAME = null;
                CurrentUser.AGE = null;
                CurrentUser.PASSWORD = null;
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('userid', "");
                prefs.setString('name', "");
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
          ],
        ),
      ),
    );
  }

}
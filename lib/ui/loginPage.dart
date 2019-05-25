import 'package:flutter/material.dart';
import 'package:mobilefinal2/db/userDB.dart';
import 'package:toast/toast.dart';
import '../utils/currentUser.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }

}

class LoginPageState extends State<LoginPage>{
  final _formkey = GlobalKey<FormState>();
  UserUtils user = UserUtils();
  final userid = TextEditingController();
  final password = TextEditingController();
  bool isValid = false;
  int formState = 0;
  String _userid = "";

  @override
  void initState(){
    super.initState();
    _isEverLogin();
  }

  Future<void> _isEverLogin() async {
    await _getUsername();
    if (this._userid != ""){
      await _autoLogin();
    }
  }

  Future<void> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('userid');
    if (username == null){
      setState(() {
       this._userid = ""; 
      });
    } else {
      setState(() {
       this._userid = username; 
      });
    }
  }

  Future<void> _autoLogin() async {
    await user.open("user.db");
    Future<List<User>> allUser = user.getAllUser();
    var userList = await allUser;
    for(var i=0; i < userList.length;i++){
      if (this._userid == userList[i].userid){
        CurrentUser.ID = userList[i].id;
        CurrentUser.USERID = userList[i].userid;
        CurrentUser.NAME = userList[i].name;
        CurrentUser.AGE = userList[i].age;
        CurrentUser.PASSWORD = userList[i].password;
        print("this user valid");
        break;
      }
    }
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formkey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 15, 30, 0),
          children: <Widget>[
            Image.asset(
              "assets/banner.jpg",
              width: 200,
              height: 200,
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: "User Id",
                icon: Icon(Icons.account_box, size: 40, color: Colors.grey),
              ),
              controller: userid,
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value.isNotEmpty) {
                  this.formState += 1;
                }
              }
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Password",
                icon: Icon(Icons.lock, size: 40, color: Colors.grey),
              ),
              controller: password,
              obscureText: true,
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value.isNotEmpty) {
                  this.formState += 1;
                }
              }
            ),
            Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 10)),
            RaisedButton(
              child: Text("Login"),
              onPressed: () async {
                _formkey.currentState.validate();
                await user.open("user.db");
                Future<List<User>> allUser = user.getAllUser();

                Future isUserValid(String userid, String password) async {
                  var userList = await allUser;
                  for(var i=0; i < userList.length;i++){
                    if (userid == userList[i].userid && password == userList[i].password){
                      CurrentUser.ID = userList[i].id;
                      CurrentUser.USERID = userList[i].userid;
                      CurrentUser.NAME = userList[i].name;
                      CurrentUser.AGE = userList[i].age;
                      CurrentUser.PASSWORD = userList[i].password;
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('userid', userList[i].userid);
                      prefs.setString('name', userList[i].name);
                      this.isValid = true;
                      break;
                    }
                  }
                }

                if(this.formState != 2){
                  Toast.show("Please fill out this form", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                  this.formState = 0;
                } else {
                  this.formState = 0;
                  print("${userid.text}, ${password.text}");
                  await isUserValid(userid.text, password.text);
                  if( !this.isValid){
                    Toast.show("Invalid user or password", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                  } else {
                    Navigator.pushReplacementNamed(context, '/home');
                    userid.text = "";
                    password.text = "";
                  }
                }
              },
            ),
            FlatButton(
              child: Container(
                child: Text("register new user", textAlign: TextAlign.right),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/register');
              },
              padding: EdgeInsets.only(left: 180.0),
            ),
          ],
        ),
      ),
    );
  }
}
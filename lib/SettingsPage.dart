import 'package:analog/Views/Login/Login.dart';
import 'package:analog/main.dart';
import 'package:analog/services/AuthService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Stack(children: [
        Image.asset('assets/TopImg.png', fit: BoxFit.cover,),
        //flex: 50,
        //child: Image.asset('assets/LoginImg.png')),
        Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 140, bottom: 5),
                child: Text(
                  'Settings',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin:
                    EdgeInsets.only(left: 35, right: 35, bottom: 5, top: 40),
                child: TextField(
                  controller: _emailController,
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 70, bottom: 5),
                height: 50,
                width: 180,
                color: Colors.indigo,
                child: ElevatedButton(
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    onPressed: () {
                      final auth = AuthService();
                      auth.signOut();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                          builder: (context) =>
                          Login()));
                    }),
              ), //
            ]),
      ]),
    );
  }

  @override
  void initState() {
    getUserInfo();
  }

  void getUserInfo() {
    _emailController.text = FirebaseAuth.instance.currentUser!.email!;
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }
}

import 'package:analog/Views/Login/Login.dart';
import 'package:analog/Views/Screens//Homepage.dart';
import 'package:analog/services/AuthService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateHome();
  }

  _navigateHome() async {
    await Future.delayed(Duration(milliseconds: 3000), () {});
    final user = AuthService().getCurrentUser();
    if (user == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    } else
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Homepage(title: 'Analog', userId: user.uid)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              //color: Color(0xFFFAEDE6),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.deepPurple,
                radius: 100.0,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 97.0,
                  child: Icon(
                    Icons.polymer,
                    color: Colors.purpleAccent.shade700,
                    size: 80.0,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 5.0, bottom: 20),
              ),
              Text(
                'ANALOG',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = ui.Gradient.linear(
                      const Offset(40, 80),
                      const Offset(145, 50),
                      <Color>[
                        Colors.purpleAccent.shade400,
                        Colors.lightBlueAccent.shade200,
                      ],
                    ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

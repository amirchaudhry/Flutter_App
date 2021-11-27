import 'package:analog/Views/Login/ForgotPasswordPage.dart';
import 'package:analog/Views/Screens/Homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'SignUp.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String email = '';
  String password = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            Image.asset('assets/TopImg.png', fit: BoxFit.cover,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 100, bottom: 5),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.only(left: 35, right: 35, bottom: 5, top: 30),
                  child: TextField(
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                    maxLines: 1,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                    onChanged: (value) {
                      email = value;
                    },
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.only(left: 35, right: 35, bottom: 10, top: 10),
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                    onChanged: (value) {
                      password = value;
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 5, top: 10),
                  child: TextButton(
                    child: Text('Forgot Password?',
                        style: TextStyle(color: Colors.red)),
                    onPressed: _handleForgotPassword,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10, top: 10),
                  height: 50,
                  width: 180,
                  color: Colors.indigo,
                  child: ElevatedButton(
                      child: Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      onPressed: _handleSignIn),
                ), //
                Container(
                  margin: EdgeInsets.only(bottom: 5, top: 5),
                  height: 50,
                  width: 180,
                  color: Colors.indigo,
                  child: ElevatedButton(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUp()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  void _handleSignIn() {
    try {
      if (this.email.isNotEmpty && this.password.isNotEmpty) {
        _firebaseAuth
            .signInWithEmailAndPassword(
                email: this.email, password: this.password)
            .then((value) {
          User? user = value.user;
          if (user != null)
          // If success: go to home
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Homepage(
                      title: 'Home',
                      userId: user.uid,
                    )),
          );
        });
      } else {
        createSnackBar('Email and Password Cannot Be Blank', context);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Sorry! User Not Found!'),
                  content: Text('Please re-enter the credentials.'),
                ));
      } else if (e.code == 'wrong-password') {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Sorry! Wrong Password!'),
                  content: Text('Please re-enter your password.'),
                ));
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Sorry! Login Failed!'),
                  content: Text('${e.message}'),
                ));
      }
    } catch (e) {
      print(e);
    }
  }

  void createSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$message')));
  }

  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
    );
  }
}

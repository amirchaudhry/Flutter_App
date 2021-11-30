import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = new TextEditingController();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text('Password Reset',
          style: TextStyle(
            color: Colors.black,
          ),),
        backgroundColor: Color(0xFF8DD1EF),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/TopImg.png',
            fit: BoxFit.cover,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 130, bottom: 5),
                child: Text(
                  'Password Reset',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin:
                    EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 5),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  maxLines: 1,
                  obscureText: false,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      hintText: 'Please Enter your Email'),
                ),
              ),
              Container(
                height: 50,
                width: 200,
                //width: double.infinity,
                margin: EdgeInsets.only(top: 80, bottom: 5),
                padding: EdgeInsets.all(4.0),
                child: ElevatedButton(
                    onPressed: _sendPasswordLink,
                    child: Text(
                      'Send Reset Link',
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _sendPasswordLink() {
    try {
      if (_emailController.text.isNotEmpty) {
        _firebaseAuth.sendPasswordResetEmail(email: _emailController.text);
      }
    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Failed to Send Link!'),
                content: Text('${e.message}'),
              ));
    }
  }
}

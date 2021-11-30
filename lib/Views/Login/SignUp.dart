import 'package:analog/Views/Screens/Homepage.dart';
import 'package:analog/services/DatabaseManager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  final _reminderManager = DatabaseManager();
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _emailAddressController = new TextEditingController();
  final _passwordController = new TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
    _emailAddressController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          title: Text('Sign Up',
            style: TextStyle(
              color: Colors.black,
            ),),
          backgroundColor: Color(0xFF8DD1EF),
        ),
        body: Stack(
          children: [
            Image.asset('assets/TopImg.png', fit: BoxFit.cover,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 130, bottom: 5),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.only(left: 35, right: 35, bottom: 5, top: 30),
                  child: TextField(
                    controller: _emailAddressController,
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.only(left: 35, right: 35, bottom: 10, top: 10),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10, top: 50),
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
                    onPressed: _handleSignUp,
                  ),
                ) //
              ],
            ),
          ],
        ));
  }

  void createSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$message')));
  }

  void _handleSignUp() async {
    if (_emailAddressController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
                email: _emailAddressController.text,
                password: _passwordController.text);
        createSnackBar('Registration Successful', context);
        // Create necessary User Info in the DB
        widget._reminderManager.updateAmount(userCredential.user!.uid, 0.0);
        // Go to the Home Page
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Homepage(
                    title: 'Home',
                    userId: userCredential.user!.uid,
                  )),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('Oops! Password Too Weak!'),
                    content: Text('Please set a strong password.'),
                  ));
        } else if (e.code == 'email-already-in-use') {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('Account already Exists!'),
                    content: Text('Please try logging in.'),
                  ));
        } else {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('Sorry! Registration Failed!'),
                    content: Text('${e.message}'),
                  ));
        }
      } catch (e) {
        print('SIGN_UP-PAGE: Error Signing Up - $e');
      }
    } else {
      createSnackBar('Email or Password Cannot be Empty', context);
    }
  }
}

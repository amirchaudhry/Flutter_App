import 'package:analog/Model/LocalUser.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  static final AuthService _authService = AuthService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  factory AuthService() {
    return _authService;
  }

  AuthService._internal();

  Future<LocalUser?> getUserFromFirebase() async {
    final User? user = _firebaseAuth.currentUser;

    return user != null ? LocalUser(uid: user.uid) : null;
  }

  Stream<String> get onAuthStateChanged => _firebaseAuth.authStateChanges().map((event) => event!.uid);

  signOut() {
    _firebaseAuth.signOut();
  }

  getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
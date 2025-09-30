import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream for auth state changes
  Stream<User?> get user => _auth.authStateChanges();

  // Sign in with email & password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      // You can handle specific errors here if you want
      return null;
    }
  }

  // Register with email & password
  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      // You can handle specific errors here if you want
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

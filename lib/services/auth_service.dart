import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up with Role
  Future<User?> signUp(String email, String password, String role) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        // Save user role in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'role': role,
        });
      }
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Sign In with Role Check
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    try {
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        // Fetch user role from Firestore
        DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(user.uid).get();
        if (snapshot.exists) {
          return {'user': user, 'role': snapshot['role']};
        }
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

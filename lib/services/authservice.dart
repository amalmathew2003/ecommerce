
import 'package:firebase_auth/firebase_auth.dart';

class Authservice {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //sign up
  // Future<User?> signUp(String email, String password) async {
  //   try {
  //     final UserCredential userCredential = await firebaseAuth
  //         .createUserWithEmailAndPassword(email: email, password: password);
  //     log("$email,$password");
  //     return userCredential.user;
  //   } catch (e) {
  //     throw Exception(e.toString());
  //   }
  // }

  // login......................
  Future<User?> login(String email, String password) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //log out
  Future<void> logOut() async {
    await firebaseAuth.signOut();
  }

  //get user
  User? get getUser => firebaseAuth.currentUser;
}

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_config/flutter_config.dart';

import '/models/user.dart' as user_model;

class AuthService with ChangeNotifier {
  final _auth = FirebaseAuth.instance; //firebase auth instance

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges(); //stream of user to track auth state

  user_model.User?
      authUser; //authenticated user info. null if not authenticated

  bool get isVerified =>
      _auth.currentUser?.emailVerified ??
      false; //prevent unverified users from accessing app

  AuthService() {
    //listen to auth state changes
    authStateChanges.listen((User? user) async {
      if (user != null) {
        //if user is authenticated
        updateAuthUser(user);
      } else {
        //if user is not authenticated
        authUser = null;
      }
      notifyListeners();
    });
  }

  //update authUser with user info coming from firebase
  Future<void> updateAuthUser(User? user) async {
    final token = await user?.getIdToken(true);
    if (token is! String) {
      return;
    }
    final res = await http
        .post(Uri.parse('${FlutterConfig.get('API_URL')}/user'), body: {
      'email': user?.email,
      'name': user?.displayName,
      'uid': user?.uid,
    }, headers: {
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode == 200) {
      authUser = user_model.User.fromJson(jsonDecode(res.body));
    } else {
      authUser = null;
    }

    notifyListeners();
  }

  //sign user in with email and password to firebase, create user in mongodb, and update authUser
  Future<String> signup(String email, String password, String username) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      //TODO: check if username is unique
      await userCredential.user!.updateDisplayName(username);
      await userCredential.user!.sendEmailVerification();
      updateAuthUser(userCredential.user);
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      return e.toString();
    }
    return 'done';
  }

  //sign user in with email and password to firebase and update authUser
  Future<String> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      updateAuthUser(userCredential.user);
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return 'done';
  }

  //sign user in with google to firebase and update authUser, create user in mongodb if not already created
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    try {
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      updateAuthUser(userCredential.user);
    } on FirebaseAuthException catch (e) {
      print(e.code);
    }
  }

  //sign user in with facebook to firebase and update authUser, create user in mongodb if not already created
  Future<void> signInWithFacebook() async {
    // final LoginResult loginResult = await FacebookAuth.instance.login();
    // final OAuthCredential facebookAuthCredential =
    //     FacebookAuthProvider.credential(loginResult.accessToken!.token);
    // _auth.signInWithCredential(facebookAuthCredential);
  }

  //sign user out of firebase and update authUser
  Future<void> logout() async {
    await _auth.signOut();
  }

  //reload user info from firebase. used for updating email verification status
  void reload() {
    _auth.currentUser!.reload();
  }
}

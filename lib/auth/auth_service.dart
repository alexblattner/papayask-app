import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_config/flutter_config.dart';
import 'package:papayask_app/models/notification.dart';
import 'package:papayask_app/questions/questions_service.dart';

import '/models/user.dart' as user_model;

class AuthService with ChangeNotifier {
  final questionsService = QuestionsService();
  final _auth = FirebaseAuth.instance; //firebase auth instance
  var _notifications = <AppNotification>[];
  var streamConnected = false;

  void updateConnected(bool connected) {
    streamConnected = connected;
  }

  List<AppNotification> get notifications {
    _notifications.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return _notifications;
  }

  int get notificationsCount =>
      _notifications.where((element) => element.isRead == false).length;

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
      if (user != null && authUser == null) {
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
    try {
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
        authUser!.questions = questionsService.questions;
        await getNotifications();
      } else {
        authUser = null;
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
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
      print(e.code);
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

  Future<String> updateUser(Map<String, dynamic> data) async {
    final token = await _auth.currentUser?.getIdToken(true);
    if (token is! String) {
      return 'error';
    }
    try {
      final res = await http.patch(
          Uri.parse('${FlutterConfig.get('API_URL')}/user/${authUser!.id}'),
          body: jsonEncode(data),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-type': 'application/json',
            'Accept': 'application/json'
          });
      if (res.statusCode == 200) {
        final convertedData = jsonDecode(res.body);
        user_model.User updatedUser =
            user_model.User.fromJson(convertedData['user']);
        authUser = updatedUser;
        notifyListeners();
        return 'done';
      } else {
        return 'error';
      }
    } catch (e) {
      print(e);
      return e.toString();
    }
  }

  Future<String> becomeAnAdvisor() async {
    final token = await _auth.currentUser?.getIdToken(true);
    if (token is! String) {
      return 'Please login first';
    }
    try {
      final res = await http.post(
          Uri.parse('${FlutterConfig.get('API_URL')}/confirmation-application'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-type': 'application/json',
            'Accept': 'application/json'
          });
      final convertedData = jsonDecode(res.body);
      if (res.statusCode == 200) {
        authUser!.advisorStatus = 'pending';
        notifyListeners();
        return 'done';
      } else {
        return convertedData['message'];
      }
    } catch (e) {
      print(e);
      return 'Something went wrong';
    }
  }

  Future<void> getNotifications() async {
    final token = await _auth.currentUser?.getIdToken(true);
    if (token is! String) {
      return;
    }
    try {
      final res = await http.get(
          Uri.parse('${FlutterConfig.get('API_URL')}/notifications'),
          headers: {
            'Authorization': 'Bearer $token',
          });
      if (res.statusCode == 200) {
        final convertedData = jsonDecode(res.body);
        _notifications = convertedData
            .map<AppNotification>((json) => AppNotification.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> readNotifications(List<AppNotification> nots) async {
    for (AppNotification not in nots) {
      not.isRead = true;
    }
    notifyListeners();
    final token = await _auth.currentUser?.getIdToken(true);
    if (token is! String) {
      return;
    }
    if (nots.isEmpty) {
      return;
    }
    try {
      await http.patch(
          Uri.parse(
              '${FlutterConfig.get('API_URL')}/notifications/read-notifications'),
          body: jsonEncode({
            'notifications': nots.map((e) => e.id).toList(),
          }),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-type': 'application/json',
            'Accept': 'application/json'
          });
    } catch (e) {
      print(e);
    }
  }
}

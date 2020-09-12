import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'api.dart';
import 'models.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  List<User> _allUsers = List<User>();
  List<User> get users => _allUsers;
  FirebaseUser _user;

  UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn() {
    loadAllUsers().then((usresList) {
      _allUsers = usresList;
    });
  }

  Future<List<User>> loadAllUsers() async {
    final response = await http.get(API.GetAllUsers);

    if (response.statusCode == 200) {
      List<dynamic> list = json.decode(response.body);
      List<User> users = list.map((jl) => User.fromMap(jl)).toList();
      return users;
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<FirebaseUser> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _firebaseAuth.signInWithCredential(credential);

    FirebaseUser currentUser = await _firebaseAuth.currentUser();
    return currentUser;
  }

  Future<void> signInWithCredentials(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp({String email, String password}) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  void createNewUser(FirebaseUser currentUser) {
    final usersRef = Firestore.instance.collection(UsersProps.collectionName);

    // return User(
    //     uid: data[UsersProps.uid],
    //     email: data[UsersProps.email],
    //     name: data[UsersProps.name],
    //     photoUrl: data[UsersProps.photoUrl],
    //     lastSignInTime: data[UsersProps.lastSignInTime]);

    usersRef.document(currentUser.uid).setData({
      UsersProps.uid: currentUser.uid,
      UsersProps.email: currentUser.email,
      UsersProps.displayName: currentUser.displayName ?? currentUser.email,
      UsersProps.photoUrl: currentUser.photoUrl ?? 'https://picsum.photos/200/200',
      UsersProps.lastSignInTime: DateTime.now().toUtc(),
    });
  }

  Future<void> signOut() async {
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }

  FirebaseUser get user {
    return _user;
  }

  Future<FirebaseUser> getUser() async {
    _user = await _firebaseAuth.currentUser();

    createNewUser(_user);

    return _user;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

DateTime getTimeFromMap(String prop, Map data) {
  try {
    Timestamp dateData = data[prop];
    if (dateData == null) {
      return DateTime.now().toUtc();
    }
    return dateData.toDate();
  } catch (e) {
    print(e);
    return DateTime.now().toUtc();
  }
}

T getStrListParam<T>(String param, dynamic data, T value) {
  var ret;

  try {
    ret = (data?.containsKey(param) ?? false)
        ? (data[param] as List<dynamic>).map((e) => e.toString()).toList()
        : value;
  } catch (e) {
    print(e);
    return value;
  }

  return ret;
}

T getParam<T>(String param, Map data, T defaultValue) {
  var ret;

  try {
    ret = (data?.containsKey(param) ?? false) ? data[param] as T : defaultValue;
  } catch (e) {
    print(e);
    return defaultValue;
  }

  return ret;
}

abstract class UsersProps {
  static const String uid = "uid";
  static const String collectionName = "users";
  static const String displayName = "displayName";
  static const String photoUrl = "photoUrl";
  static const String lastSignInTime = "lastSignInTime";
  static const String email = "email";
}

class User {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final DateTime lastSignInTime;

  User({this.uid, this.email, this.displayName, this.photoUrl, this.lastSignInTime});

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
        uid: data[UsersProps.uid],
        email: data[UsersProps.email],
        displayName: data[UsersProps.displayName],
        photoUrl: data[UsersProps.photoUrl],
        lastSignInTime: data[UsersProps.lastSignInTime]);
  }
}

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

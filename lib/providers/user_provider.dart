// import 'package:flutter/foundation.dart';
// import 'package:local_service_provider/model/user.dart';
// import 'package:local_service_provider/resources/auth_methods.dart';

// class UserProvider with ChangeNotifier {
//   UserModel? _user;
//   final AuthMethods _authMethods = AuthMethods();
//   UserModel get getUser => _user!;

//   Future<void> refreshUser() async {
//     UserModel user = await _authMethods.getUserDetails();
//     _user = user;
//     notifyListeners();
//   }
// }

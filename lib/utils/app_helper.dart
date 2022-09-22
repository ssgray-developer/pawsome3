import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AppHelper {
  static firstRunCheck() async {
    // purpose of what we're doing here is clearing out the keychain items across
    // installations (they persist after installations)

    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    const String hasRunBeforePrefKey = 'localStorage.hasRunBefore';
    final bool hasRunBefore =
        sharedPreferences.getBool(hasRunBeforePrefKey) ?? false;
    if (hasRunBefore) {
      return;
    }
    await sharedPreferences.setBool(hasRunBeforePrefKey, true);

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseAuth.instance.signOut();
    }
  }
}

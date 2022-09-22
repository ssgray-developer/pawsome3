import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pawsome/model/firebase_methods/auth_methods.dart';
import 'package:pawsome/utils/utils.dart';
import 'package:pawsome/view/home.dart';

import '../resources/strings_manager.dart';

class VerifyEmailScreen extends StatefulWidget {
  final PackageInfo packageInfo;
  const VerifyEmailScreen({Key? key, required this.packageInfo})
      : super(key: key);

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
          const Duration(seconds: 3), (timer) => checkEmailVerified());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    // call after email verification!
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? HomeScreen(
          packageInfo: widget.packageInfo,
        )
      : Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.verifyEmail).tr(),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  AppStrings.verificationEmailSent,
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ).tr(),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)),
                  onPressed: canResendEmail ? sendVerificationEmail : null,
                  icon: const Icon(
                    Icons.email_rounded,
                    size: 32,
                  ),
                  label: const Text(
                    AppStrings.resendEmail,
                    style: TextStyle(fontSize: 24),
                  ).tr(),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)),
                  onPressed: () => AuthMethods.signOutUser(),
                  icon: const Icon(
                    Icons.email_rounded,
                    size: 32,
                  ),
                  label: const Text(
                    AppStrings.cancel,
                    style: TextStyle(fontSize: 24),
                  ).tr(),
                )
              ],
            ),
          ),
        );
}

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pawsome/model/firebase_methods/auth_methods.dart';
import 'package:pawsome/resources/strings_manager.dart';
import 'package:pawsome/utils/utils.dart';

import '../resources/values_manager.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool isLoading = false;

  final formKey = GlobalKey<FormState>();

  final FocusNode _emailNode = FocusNode();

  final emailTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    emailTextEditingController.dispose();

    super.dispose();
  }

  void resetPassword() async {
    setState(() => isLoading = true);
    final ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      final String res = await AuthMethods.resetPassword(
          emailTextEditingController.text.trim());
      if (res == 'success') {
        setState(() => isLoading = false);
        showSnackBar(context, AppStrings.resetPasswordEmailSent.tr());
      } else {
        setState(() => isLoading = false);
        showSnackBar(context, res, defaultColor: false);
      }
    } else {
      setState(() => isLoading = false);
      showSnackBar(context, AppStrings.noConnection.tr(), defaultColor: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading,
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: const Text(AppStrings.resetPassword).tr(),
          ),
          body: Container(
            padding: const EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    AppStrings.checkEmailResetPassword,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24),
                  ).tr(),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: emailTextEditingController,
                    focusNode: _emailNode,
                    cursorColor: Theme.of(context).primaryColor,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        labelText: AppStrings.email.tr(),
                        labelStyle: TextStyle(
                            fontSize: AppSize.s20,
                            letterSpacing: AppSize.s0,
                            color: _emailNode.hasFocus
                                ? Theme.of(context).primaryColor
                                : Colors.grey[600]!),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor))),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) =>
                        email != null && !EmailValidator.validate(email)
                            ? AppStrings.enterValidEmail.tr()
                            : null,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50)),
                      icon: isLoading
                          ? const SpinKitCircle(
                              color: Colors.white,
                              size: 24.0,
                            )
                          : const Icon(
                              Icons.email_rounded,
                            ),
                      onPressed: resetPassword,
                      label: const Text(
                        AppStrings.resetPassword,
                        // style: TextStyle(fontSize: 24),
                      ).tr(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

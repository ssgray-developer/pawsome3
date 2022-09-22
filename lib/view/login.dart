import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pawsome/model/firebase_methods/auth_methods.dart';
import 'package:pawsome/resources/strings_manager.dart';
import 'package:pawsome/resources/values_manager.dart';
import 'package:pawsome/view/forgot_password.dart';
import 'package:pawsome/view/register.dart';
import 'package:provider/provider.dart';
import '../utils/utils.dart';
import '../utils/validation_methods.dart';
import '../viewmodel/login_viewmodel.dart';
import '../viewmodel/user_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  static const String id = '/login';
  final PackageInfo packageInfo;

  const LoginScreen({Key? key, required this.packageInfo}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final FocusNode _emailNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();

  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  bool _passwordVisible = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _emailNode.addListener(() {
      setState(() {});
    });
    _passwordNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
    super.dispose();
  }

  void loginUser() async {
    // Provider.of<LoginViewModel>(context, listen: false).setIsLoading = true;

    if (_emailFormKey.currentState!.validate() &&
        _passwordFormKey.currentState!.validate()) {
      if (await checkConnectivity()) {
        final String res = await AuthMethods.loginUser(
            _emailTextEditingController.text.trim(),
            _passwordTextEditingController.text.trim());

        // Provider.of<LoginViewModel>(context, listen: false).setIsLoading = false;

        // final UserViewModel userViewModel =
        //     Provider.of<UserViewModel>(context, listen: false);
        // await userViewModel.refreshUser();
        // origin = await Geolocator.getCurrentPosition();

        if (res == 'success') {
          final UserViewModel userViewModel =
              Provider.of<UserViewModel>(context, listen: false);
          await userViewModel.refreshUser();
          // LocationPermission permission;
          // permission = await Geolocator.requestPermission();
          // origin = await Geolocator.getCurrentPosition();
          //
          // if (!mounted) return;
          // Navigator.of(context).pushAndRemoveUntil(
          //     MaterialPageRoute(
          //       builder: (context) => const HomeScreen(),
          //     ),
          //     (route) => false);
        } else {
          if (!mounted) return;
          showSnackBar(context, res);
        }
      } else {
        showSnackBar(context, AppStrings.noConnection.tr(),
            defaultColor: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: GestureDetector(
          child: Stack(
            children: [
              SvgPicture.asset(
                'assets/images/login_background.svg',
                fit: BoxFit.fitHeight,
                // height: MediaQuery.of(context).size.height,
              ),
              Container(
                color: Colors.transparent,
                child: Column(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 6,
                      child: Container(
                        color: Colors.transparent,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(40.0),
                              topLeft: Radius.circular(40.0),
                            ),
                          ),
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            // reverse: true,
                            child: Container(
                              padding: const EdgeInsets.all(60.0),
                              child: Column(
                                children: [
                                  Form(
                                    key: _emailFormKey,
                                    child: TextFormField(
                                      controller: _emailTextEditingController,
                                      focusNode: _emailNode,
                                      validator: (value) {
                                        if (value == null ||
                                            !ValidationMethods.isEmailValid(
                                                value)) {
                                          return AppStrings.enterValidEmail
                                              .tr();
                                        }
                                        return null;
                                      },
                                      maxLines: 1,
                                      keyboardType: TextInputType.emailAddress,
                                      cursorColor:
                                          Theme.of(context).primaryColor,
                                      decoration: InputDecoration(
                                          labelText: AppStrings.email.tr(),
                                          labelStyle: TextStyle(
                                              fontSize: AppSize.s20,
                                              color: _emailNode.hasFocus
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : Colors.grey[600]!),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor)),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: AppSize.s5)),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppSize.s20,
                                  ),
                                  Form(
                                    key: _passwordFormKey,
                                    child: TextFormField(
                                      controller:
                                          _passwordTextEditingController,
                                      focusNode: _passwordNode,
                                      enableInteractiveSelection: false,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return AppStrings.enterYourPassword
                                              .tr();
                                        }
                                        return null;
                                      },
                                      style: const TextStyle(
                                          letterSpacing: AppSize.s5),
                                      maxLines: 1,
                                      obscureText: !_passwordVisible,
                                      cursorColor:
                                          Theme.of(context).primaryColor,
                                      decoration: InputDecoration(
                                        labelText: AppStrings.password.tr(),
                                        labelStyle: TextStyle(
                                            fontSize: AppSize.s20,
                                            letterSpacing: AppSize.s0,
                                            color: _passwordNode.hasFocus
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey[600]!),
                                        // enabledBorder: UnderlineInputBorder(
                                        //     borderSide: BorderSide(
                                        //         color:
                                        //             Theme.of(context).primaryColor)),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                        suffixIcon: IconButton(
                                          icon: Icon(_passwordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                          color: _passwordNode.hasFocus
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey[600]!,
                                          onPressed: () {
                                            setState(() {
                                              _passwordVisible =
                                                  !_passwordVisible;
                                            });
                                          },
                                        ),
                                        // suffixIconConstraints:
                                        //     const BoxConstraints(maxHeight: 20),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: AppSize.s5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppSize.s16,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ForgotPasswordScreen())),
                                      child: Text(
                                        AppStrings.forgotPassword.tr(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppSize.s28,
                                  ),
                                  SizedBox(
                                    width: 230.0,
                                    height: 50.0,
                                    child: ElevatedButton(
                                      onPressed: loginUser,
                                      child: Provider.of<LoginViewModel>(
                                                  context)
                                              .getIsLoading
                                          ? const SpinKitCircle(
                                              color: Colors.white,
                                              size: 24.0,
                                            )
                                          : const Text(AppStrings.signInUpper)
                                              .tr(),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(AppStrings.dontHaveAccount)
                                          .tr(),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      RegisterScreen(
                                                        packageInfo:
                                                            widget.packageInfo,
                                                      )));
                                        },
                                        child: Text(
                                          AppStrings.signUp,
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ).tr(),
                                      )
                                    ],
                                  ),
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  //   children: [
                                  //     SignInButton(
                                  //       Buttons.FacebookNew,
                                  //       shape: RoundedRectangleBorder(
                                  //           borderRadius:
                                  //               BorderRadius.circular(10.0)),
                                  //       padding: const EdgeInsets.symmetric(
                                  //           horizontal: 18.0, vertical: 10.0),
                                  //       text: 'Sign up with Facebook',
                                  //       onPressed: () {},
                                  //     ),
                                  //     SignInButton(
                                  //       Buttons.Google,
                                  //       shape: RoundedRectangleBorder(
                                  //         borderRadius: BorderRadius.circular(10.0),
                                  //         side: BorderSide(width: 1.0),
                                  //       ),
                                  //       padding: const EdgeInsets.symmetric(
                                  //           horizontal: 18.0, vertical: 4.0),
                                  //       text: 'Sign up with Google',
                                  //       onPressed: () {},
                                  //     ),
                                  //   ],
                                  // )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

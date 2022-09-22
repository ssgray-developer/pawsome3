import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pawsome/model/firebase_methods/auth_methods.dart';
import 'package:pawsome/model/location.dart';
import 'package:pawsome/utils/utils.dart';
import 'package:pawsome/utils/validation_methods.dart';
import '../resources/strings_manager.dart';
import '../resources/values_manager.dart';

class RegisterScreen extends StatefulWidget {
  static const String id = '/register';
  final PackageInfo packageInfo;

  const RegisterScreen({Key? key, required this.packageInfo}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final FocusNode _nameNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();

  final TextEditingController _nameTextEditingController =
      TextEditingController();
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();

  bool _passwordVisible = false;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameNode.addListener(() {
      setState(() {});
    });
    _emailNode.addListener(() {
      setState(() {});
    });
    _passwordNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameTextEditingController.dispose();
    _emailTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    _nameNode.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
    super.dispose();
  }

  void signUpUser() async {
    setState(() => isLoading = true);
    if (_nameFormKey.currentState!.validate() &&
        _emailFormKey.currentState!.validate() &&
        _passwordFormKey.currentState!.validate()) {
      if (await checkConnectivity()) {
        await AuthMethods.registerUser(
                _nameTextEditingController.text.trim(),
                _emailTextEditingController.text.trim(),
                _passwordTextEditingController.text.trim())
            .then((value) async {
          if (value == 'success') {
            await Geolocator.requestPermission();
            LocationModel.origin = await LocationModel.determinePosition();
            Navigator.of(context).pop();
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) =>
            //         LoadingScreen(packageInfo: widget.packageInfo),
            //   ),
            // );
          } else {
            if (!mounted) return;
            showSnackBar(context, value, defaultColor: false);
          }
          setState(() => isLoading = false);
        });
      } else {
        showSnackBar(context, AppStrings.noConnection.tr(),
            defaultColor: false);
      }

      // if (res == 'success') {
      //   if (!mounted) return;
      //   Navigator.of(context).pushReplacementNamed(HomeScreen.id);
      // } else {
      //   if (!mounted) return;
      //   showSnackBar(context, res);
      // }
    }
    // if (!mounted) return;
    setState(() => isLoading = false);
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
          backgroundColor: Theme.of(context).primaryColor,
          body: Stack(
            children: [
              SvgPicture.asset(
                'assets/images/register_background.svg',
                fit: BoxFit.fitHeight,
                // height: MediaQuery.of(context).size.height,
              ),
              Container(
                color: Colors.transparent,
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 11,
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
                            physics: const ClampingScrollPhysics(),
                            reverse: true,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 60.0, vertical: 10.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Container(),
                                      ),
                                      Expanded(
                                        flex: 7,
                                        child: const Text(
                                          AppStrings.signUpTo,
                                          style:
                                              TextStyle(fontSize: AppSize.s28),
                                        ).tr(),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Container(),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          AppStrings.pawsome,
                                          style: TextStyle(
                                            fontSize: 36,
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: AppSize.s20,
                                  ),
                                  const Text(
                                    AppStrings.enterInfo,
                                    textAlign: TextAlign.start,
                                  ).tr(),
                                  const SizedBox(
                                    height: AppSize.s12,
                                  ),
                                  Form(
                                    key: _nameFormKey,
                                    child: TextFormField(
                                      controller: _nameTextEditingController,
                                      focusNode: _nameNode,
                                      cursorColor:
                                          Theme.of(context).primaryColor,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return AppStrings.enterUsername.tr();
                                        }
                                        return null;
                                      },
                                      maxLines: 1,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                          labelText: AppStrings.name.tr(),
                                          // enabledBorder: UnderlineInputBorder(
                                          //     borderSide: BorderSide(
                                          //   color: Theme.of(context).primaryColor,
                                          // )),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                          )),
                                          labelStyle: TextStyle(
                                              fontSize: AppSize.s20,
                                              color: _nameNode.hasFocus
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : Colors.grey[600]!),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: AppSize.s5)),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppSize.s20,
                                  ),
                                  Form(
                                    key: _emailFormKey,
                                    child: TextFormField(
                                      controller: _emailTextEditingController,
                                      focusNode: _emailNode,
                                      cursorColor:
                                          Theme.of(context).primaryColor,
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
                                      decoration: InputDecoration(
                                          labelText: AppStrings.email.tr(),
                                          labelStyle: TextStyle(
                                              fontSize: AppSize.s20,
                                              color: _emailNode.hasFocus
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : Colors.grey[600]!),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor,
                                          )),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
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
                                      cursorColor:
                                          Theme.of(context).primaryColor,
                                      enableInteractiveSelection: false,
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            !ValidationMethods.isPasswordValid(
                                                value)) {
                                          return AppStrings.enterStrongPassword
                                              .tr();
                                        }
                                        return null;
                                      },
                                      style: const TextStyle(
                                          letterSpacing: AppSize.s5),
                                      maxLines: 1,
                                      obscureText: !_passwordVisible,
                                      decoration: InputDecoration(
                                        labelText: AppStrings.password.tr(),
                                        labelStyle: TextStyle(
                                            fontSize: AppSize.s20,
                                            letterSpacing: AppSize.s0,
                                            color: _passwordNode.hasFocus
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey[600]!),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                        )),
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
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: AppSize.s5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppSize.s12,
                                  ),
                                  Visibility(
                                    visible: false,
                                    maintainSize: true,
                                    maintainAnimation: true,
                                    maintainState: true,
                                    child: SignInButton(
                                      Buttons.FacebookNew,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18.0, vertical: 10.0),
                                      text: AppStrings.signUpFacebook.tr(),
                                      onPressed: () {},
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppSize.s4,
                                  ),
                                  Visibility(
                                    visible: false,
                                    maintainSize: true,
                                    maintainAnimation: true,
                                    maintainState: true,
                                    child: SignInButton(
                                      Buttons.Google,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        side: const BorderSide(width: 1.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18.0, vertical: 4.0),
                                      text: AppStrings.signUpGoogle.tr(),
                                      onPressed: () {},
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppSize.s12,
                                  ),
                                  SafeArea(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            AppStrings.signIn,
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ).tr(),
                                        ),
                                        const SizedBox(
                                          width: 40.0,
                                        ),
                                        SizedBox(
                                          width: 110.0,
                                          height: 50.0,
                                          child: Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: ElevatedButton.icon(
                                              onPressed: signUpUser,
                                              icon: isLoading
                                                  ? const SpinKitCircle(
                                                      color: Colors.white,
                                                      size: 24.0,
                                                    )
                                                  : const Icon(
                                                      Icons
                                                          .arrow_right_alt_sharp,
                                                    ),
                                              label: const Text(AppStrings.next)
                                                  .tr(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
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

import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pawsome/viewmodel/theme_viewmodel.dart';
import 'package:pawsome/widget/custom_dialogs.dart';
import 'package:provider/provider.dart';

import '../model/firebase_methods/auth_methods.dart';
import '../model/firebase_methods/firestore_methods.dart';
import '../model/firebase_methods/storage_methods.dart';
import '../model/user.dart';
import '../resources/strings_manager.dart';
import '../utils/utils.dart';
import '../viewmodel/user_viewmodel.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({Key? key}) : super(key: key);

  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  Uint8List? _image;
  late TextEditingController _controller;
  late TextEditingController _emailController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _verifyPasswordController;
  final _usernameFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: Provider.of<UserViewModel>(context, listen: false).getUser.username,
    );
    _emailController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _verifyPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _verifyPasswordController.dispose();
    super.dispose();
  }

  Future<void> saveToFirebase() async {
    if (await checkConnectivity()) {
      if (_usernameFormKey.currentState!.validate()) {
        await AuthMethods.updateUser('username', _controller.text.trim());
        Provider.of<UserViewModel>(context, listen: false)
            .refreshName(_controller.text.trim());
      }

      if (_image != null) {
        final String photoUrl = await StorageMethods.uploadImageToStorage(
            FirebaseAuth.instance.currentUser!.uid, _image!, null, false);

        await AuthMethods.updateUser('photoUrl', photoUrl);
      }

      User user = await AuthMethods().getUserDetails(null);

      await FirestoreMethods.updateRegisteredPet(user).then((value) {
        if (value == 'success') {
          Navigator.of(context).pop();
        } else {
          showSnackBar(context, value);
        }
      });
    } else {
      showSnackBar(context, AppStrings.noConnection.tr());
    }
  }

  Future<void> selectImage() async {
    Uint8List? im = await pickImage();
    if (im != null) {
      setState(() {
        _image = im;
      });
      Provider.of<UserViewModel>(context, listen: false).refreshPicture(im);
    }
  }

  ImageProvider _getNetworkImage() {
    if (Provider.of<UserViewModel>(context).getUser.photoUrl == '') {
      return const AssetImage('assets/images/default_picture.png');
    } else {
      return NetworkImage(Provider.of<UserViewModel>(context).getUser.photoUrl);
    }
  }

  Future<void> authenticateWithEmailAndPassword() async {
    final email = _emailController.text.trim();
    final currentPassword = _currentPasswordController.text.trim();
    if (email == '' || currentPassword == '') {
      HapticFeedback.vibrate();
    } else {
      final res = await AuthMethods.authenticateUser(email, currentPassword);
      if (res == 'success') {
        _emailController.clear();
        _currentPasswordController.clear();
        Navigator.of(context).pop();
        Future.delayed(const Duration(milliseconds: 500));
        showChangePasswordDialog();
        // showSnackBar(context, 'Password successfully changed.');
      } else {
        _emailController.clear();
        _currentPasswordController.clear();
        Navigator.of(context).pop();
        Future.delayed(const Duration(seconds: 1));
        showSnackBar(context, res);
      }
    }
  }

  Future<void> changePasswordAfterAuthenticate() async {
    final newPassword = _newPasswordController.text.trim();
    final verifyPassword = _verifyPasswordController.text.trim();
    if (newPassword == verifyPassword) {
      final res = await AuthMethods.changePassword(newPassword);
      if (res == 'success') {
        _newPasswordController.clear();
        _verifyPasswordController.clear();
        Navigator.of(context).pop();
        Future.delayed(const Duration(seconds: 1));
        showSnackBar(context, AppStrings.changePasswordSuccessful.tr());
      } else {
        _newPasswordController.clear();
        _verifyPasswordController.clear();
        Navigator.of(context).pop();
        Future.delayed(const Duration(seconds: 1));
        showSnackBar(context, res);
      }
    } else {
      HapticFeedback.vibrate();
    }
  }

  void showChangePasswordDialog() {
    final bool _isDark =
        Provider.of<ThemeViewModel>(context, listen: false).isDarkMode;
    if (!Platform.isIOS) {
      showAlertDialog(
        context: context,
        title: AppStrings.changePassword.tr(),
        cancelActionText: AppStrings.cancel.tr(),
        defaultActionText: AppStrings.confirm.tr(),
        children: [
          TextField(
            controller: _newPasswordController,
            style: TextStyle(color: _isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: AppStrings.newPassword.tr(),
            ),
            obscureText: true,
          ),
          const SizedBox(
            height: 5,
          ),
          TextField(
            controller: _verifyPasswordController,
            style: TextStyle(color: _isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: AppStrings.verifyNewPassword.tr(),
            ),
            obscureText: true,
          ),
        ],
        onPressed: () async {
          await changePasswordAfterAuthenticate();
        },
      );
    } else {
      showAlertDialog(
        context: context,
        title: AppStrings.changePassword.tr(),
        cancelActionText: AppStrings.cancel.tr(),
        defaultActionText: AppStrings.confirm.tr(),
        children: [
          CupertinoTextField(
            controller: _newPasswordController,
            placeholder: AppStrings.newPassword.tr(),
            style: TextStyle(color: _isDark ? Colors.white : Colors.black),
            obscureText: true,
          ),
          const SizedBox(
            height: 5,
          ),
          CupertinoTextField(
            controller: _verifyPasswordController,
            placeholder: AppStrings.verifyNewPassword.tr(),
            style: TextStyle(color: _isDark ? Colors.white : Colors.black),
            obscureText: true,
          ),
        ],
        onPressed: () async {
          await changePasswordAfterAuthenticate();
        },
      );
    }
  }

  void showAuthenticateUserDialog() {
    final bool _isDark =
        Provider.of<ThemeViewModel>(context, listen: false).isDarkMode;
    if (!Platform.isIOS) {
      showAlertDialog(
        context: context,
        title: AppStrings.authenticateUser.tr(),
        cancelActionText: AppStrings.cancel.tr(),
        defaultActionText: AppStrings.confirm.tr(),
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: _isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: AppStrings.email.tr(),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          TextField(
            controller: _currentPasswordController,
            style: TextStyle(color: _isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: AppStrings.currentPassword.tr(),
            ),
            obscureText: true,
          ),
        ],
        onPressed: () async {
          await authenticateWithEmailAndPassword();
        },
      );
    } else {
      showAlertDialog(
        context: context,
        title: AppStrings.authenticateUser.tr(),
        cancelActionText: AppStrings.cancel.tr(),
        defaultActionText: AppStrings.confirm.tr(),
        children: [
          CupertinoTextField(
            controller: _emailController,
            placeholder: AppStrings.email.tr(),
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: _isDark ? Colors.white : Colors.black),
          ),
          const SizedBox(
            height: 5,
          ),
          CupertinoTextField(
            controller: _currentPasswordController,
            placeholder: AppStrings.currentPassword.tr(),
            style: TextStyle(color: _isDark ? Colors.white : Colors.black),
            obscureText: true,
          ),
        ],
        onPressed: () async {
          await authenticateWithEmailAndPassword();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    UserViewModel _user = Provider.of<UserViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 80,
        leading: TextButton(
          child: Text(
            AppStrings.done.tr(),
            style: const TextStyle(color: Colors.white),
          ),
          onPressed: () async {
            FocusManager.instance.primaryFocus?.unfocus();
            await saveToFirebase();
            _user.refreshUser();
          },
          style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
        ),
        title: const Text(AppStrings.personalInfo).tr(),
      ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.profilePictureUsername,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ).tr(),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await selectImage();
                      },
                      child: _image != null
                          ? CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              backgroundImage: MemoryImage(_image!),
                              radius: 50,
                            )
                          : CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              backgroundImage: _getNetworkImage(),
                              radius: 50,
                            ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Form(
                        key: _usernameFormKey,
                        child: TextFormField(
                          controller: _controller,
                          cursorColor: Theme.of(context).primaryColor,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 1,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.enterUsername.tr();
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  AppStrings.security,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ).tr(),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    onPressed: showAuthenticateUserDialog,
                    child: const Text(AppStrings.changePassword).tr()),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  AppStrings.email,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ).tr(),
                const SizedBox(
                  height: 10,
                ),
                Text(_user.getUser.email),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/services.dart';
// import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
// import 'package:pawsome/resources/font_manager.dart';
// import 'package:pawsome/view/pet_details.dart';
//
// import '../configuration/configuration.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   final ScrollController _controller = ScrollController();
//
//   ScrollPhysics _physics = const BouncingScrollPhysics();
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _controller.addListener(() {
//       if (_controller.offset >= 20) {
//         setState(() {
//           _physics = const ClampingScrollPhysics();
//         });
//       } else {
//         setState(() {
//           _physics = const BouncingScrollPhysics();
//         });
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         systemOverlayStyle: SystemUiOverlayStyle.dark,
//         centerTitle: true,
//         titleTextStyle: TextStyle(
//           fontSize: 14,
//           color: Colors.black,
//         ),
//         leading: IconButton(
//           icon: Icon(
//             Icons.menu,
//             color: Colors.black,
//           ),
//           onPressed: () => ZoomDrawer.of(context)!.toggle(),
//         ),
//         title: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               onPressed: () {},
//               icon: Icon(
//                 Icons.location_on,
//                 color: Theme.of(context).primaryColor,
//                 size: 20,
//               ),
//             ),
//             Text(
//               'Kuching, ',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Text(
//               'Ukraine',
//             ),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         controller: _controller,
//         physics: _physics,
//         child: Column(
//           children: [
//             SizedBox(
//               height: 5.0,
//             ),
//             Container(
//               margin: EdgeInsets.symmetric(horizontal: 5.0),
//             ),
//             const SizedBox(
//               height: 10.0,
//             ),
//             Column(
//               children: [
//                 const SizedBox(
//                   height: 30.0,
//                 ),
//                 Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 15.0),
//                   child: TextField(
//                     decoration: InputDecoration(
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: Colors.transparent),
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide:
//                             BorderSide(color: Theme.of(context).primaryColor),
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       prefixIcon: Icon(
//                         Icons.search,
//                         color: Colors.grey[400],
//                       ),
//                       hintText: 'Search pet',
//                       hintStyle:
//                           TextStyle(letterSpacing: 1, color: Colors.grey[400]),
//                       filled: true,
//                       fillColor: Colors.white,
//                       suffixIcon:
//                           Icon(Icons.tune_sharp, color: Colors.grey[400]),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 30.0,
//                 ),
//                 Container(
//                   height: 120,
//                   child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: categories.length,
//                       itemBuilder: (context, index) {
//                         return Container(
//                           padding: const EdgeInsets.all(10),
//                           child: Column(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(10),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(10),
//                                   boxShadow: shadowList,
//                                 ),
//                                 child: Image(
//                                   image: AssetImage(
//                                       categories[index]['imagePath']),
//                                   height: 50,
//                                   width: 50,
//                                 ),
//                               ),
//                               const SizedBox(
//                                 height: 10.0,
//                               ),
//                               Text(
//                                 categories[index]['name'],
//                                 style: TextStyle(
//                                   color: Colors.grey[700],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }),
//                 ),
//                 const SizedBox(
//                   height: 20.0,
//                 ),
//                 ListView.builder(
//                   physics: ScrollPhysics(),
//                   itemCount: catMapList.length,
//                   scrollDirection: Axis.vertical,
//                   shrinkWrap: true,
//                   itemBuilder: (context, index) {
//                     return Container(
//                       height: 230,
//                       margin: EdgeInsets.symmetric(horizontal: 20),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Stack(
//                               children: [
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     color: (index % 2 == 0)
//                                         ? Colors.blueGrey[200]
//                                         : Colors.orangeAccent[200],
//                                     borderRadius: BorderRadius.circular(20),
//                                     boxShadow: shadowList,
//                                   ),
//                                   margin: EdgeInsets.only(top: 40),
//                                 ),
//                                 Align(
//                                     child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Hero(
//                                       tag: 'pet${catMapList[index]['id']}',
//                                       child: Image.asset(
//                                           catMapList[index]['imagePath'])),
//                                 )),
//                               ],
//                             ),
//                           ),
//                           Expanded(
//                             child: Container(
//                               margin: EdgeInsets.only(top: 65, bottom: 20),
//                               padding: EdgeInsets.all(15),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.only(
//                                     topRight: Radius.circular(20),
//                                     bottomRight: Radius.circular(20)),
//                                 boxShadow: shadowList,
//                               ),
//                               child: Column(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceAround,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         catMapList[index]['name'],
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 21.0,
//                                           color: Colors.grey[600],
//                                         ),
//                                       ),
//                                       (catMapList[index]['sex'] == 'male')
//                                           ? Icon(
//                                               Icons.male_rounded,
//                                               color: Colors.grey[500],
//                                             )
//                                           : Icon(
//                                               Icons.female_rounded,
//                                               color: Colors.grey[500],
//                                             ),
//                                     ],
//                                   ),
//                                   Text(
//                                     catMapList[index]['Species'],
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey[500],
//                                     ),
//                                   ),
//                                   Text(
//                                     catMapList[index]['year'] + ' years old',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey[400],
//                                     ),
//                                   ),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     children: [
//                                       Icon(
//                                         Icons.location_on,
//                                         color: Theme.of(context).primaryColor,
//                                         size: 18,
//                                       ),
//                                       // SizedBox(
//                                       //   width: 3,
//                                       // ),
//                                       Text(
//                                         'Distance: ' +
//                                             catMapList[index]['distance'],
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.grey[400],
//                                         ),
//                                       ),
//                                     ],
//                                   )
//                                 ],
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

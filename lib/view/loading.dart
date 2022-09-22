import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pawsome/model/user.dart' as model;
import 'package:pawsome/model/location.dart';
import 'package:pawsome/view/verify_email.dart';
import 'package:pawsome/viewmodel/user_viewmodel.dart';
import 'package:provider/provider.dart';

class LoadingScreen extends StatefulWidget {
  static const String id = '/';
  final PackageInfo packageInfo;
  const LoadingScreen({Key? key, required this.packageInfo}) : super(key: key);

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {
  late Future<model.User> futureUserModel;
  // bool isLoaded = false;

  Future<model.User> addData() async {
    UserViewModel userViewModel =
        Provider.of<UserViewModel>(context, listen: false);
    await userViewModel.refreshUser();
    LocationModel.origin = await LocationModel.determinePosition();
    return userViewModel.getUser;
  }

  @override
  void initState() {
    super.initState();

    // checkVersion();
    // checkNotification();
    futureUserModel = addData();
  }

  // void checkVersion() {}
  //
  // void checkNotification() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: futureUserModel,
        builder: (BuildContext context, AsyncSnapshot<model.User> snapshot) {
          // Geolocator.requestPermission();
          if (snapshot.hasData) {
            // print('should go to homescreen');
            return VerifyEmailScreen(
              packageInfo: widget.packageInfo,
            );
          } else if (snapshot.hasError) {
            // print('Loading screen has error');
            print(snapshot.error.toString());
            return Stack(
              children: [
                Center(
                  child: SpinKitCircle(color: Theme.of(context).primaryColor),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 200),
                  child: const Center(
                    child: Text('Ensure Location Services is turned on.'),
                  ),
                ),
              ],
            );
          } else {
            // print('loading is waiting');
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: Center(
                child: SpinKitCircle(color: Theme.of(context).primaryColor),
              ),
            );
          }
        },
      ),
    );
  }
}

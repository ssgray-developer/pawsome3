import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:pawsome/resources/strings_manager.dart';
import 'package:pawsome/utils/utils.dart';
import 'package:provider/provider.dart';

import '../model/user.dart';
import '../viewmodel/user_viewmodel.dart';
import 'chat.dart';

class MissingPetDetails extends StatelessWidget {
  final Map<String, dynamic> snap;
  final User user;
  const MissingPetDetails({Key? key, required this.snap, required this.user})
      : super(key: key);

  Future<void> contactPressed(
      BuildContext context, String currentUserUid) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(snap['ownerUid'])
        .get();

    final recipientUser = User.fromSnapshot(snapshot);

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatScreen(
        chatID: compareUserId(currentUserUid, snap['ownerUid']),
        recipientUser: recipientUser,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    User _user = Provider.of<UserViewModel>(context, listen: false).getUser;

    return Container(
      padding: const EdgeInsets.all(10),
      height: MediaQuery.of(context).size.height * 0.4,
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FullScreenWidget(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(snap['photoUrl']),
                  foregroundColor: Theme.of(context).primaryColor,
                  radius: 30,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getName(snap['petClass']),
                    style: const TextStyle(fontSize: 28),
                  ),
                  Text(getName(snap['petSpecies']))
                ],
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Center(child: Text('~ ${AppStrings.description.tr()} ~')),
          const Divider(
            thickness: 1,
          ),
          Expanded(
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Text(snap['description']),
                  ),
                ),
              ),
            ),
          ),
          snap['owner'] != user.username
              ? SafeArea(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 50,
                        minWidth: 100,
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          await contactPressed(context, _user.uid);
                        },
                        child: const Text(AppStrings.contact).tr(),
                      ),
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}

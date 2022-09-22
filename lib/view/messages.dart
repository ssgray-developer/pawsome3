import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:pawsome/model/firebase_methods/auth_methods.dart';
import 'package:pawsome/view/chat.dart';
import 'package:pawsome/viewmodel/user_viewmodel.dart';
import 'package:pawsome/widget/shimmer_widget.dart';
import 'package:provider/provider.dart';
import '../model/user.dart';
import '../resources/strings_manager.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late Stream<QuerySnapshot> _messageStream;
  late Future<List<User>> _future;
  final AuthMethods _authMethods = AuthMethods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    User _user = Provider.of<UserViewModel>(context, listen: false).getUser;

    _messageStream = FirebaseFirestore.instance
        .collection('messages')
        .where('contacts', arrayContains: _user.uid)
        .orderBy('lastModified', descending: true)
        .snapshots();
  }

  Future<void> chatRoomPressed(String chatRoomId, String currentUserId) async {
    final recipientUid = chatRoomId.replaceAll(currentUserId, '');

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(recipientUid)
        .get();

    final recipientUser = User.fromSnapshot(snapshot);

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatScreen(
        chatID: chatRoomId,
        recipientUser: recipientUser,
      ),
    ));
  }

  Future<List<User>> getRecipientUser(List recipientUidList) async {
    List<User> recipientUserList = [];

    for (String recipientUid in recipientUidList) {
      User recipientUser = await _authMethods.getUserDetails(recipientUid);
      recipientUserList.add(recipientUser);
    }

    // final results = await Future.wait(futures)
    return recipientUserList;
  }

  String formatDateTime(DateTime dateTime) {
    final currentDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (currentDate == today) {
      final DateFormat formatter = DateFormat('HH:mm');
      final String formatted = formatter.format(dateTime);
      return formatted;
    } else if (currentDate == yesterday) {
      return AppStrings.yesterday.tr();
    } else {
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      final String formatted = formatter.format(dateTime);
      return formatted;
    }
  }

  Widget subtitleWidget(String message, String type) {
    if (type == 'image') {
      return const Text(
        'Photo',
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    } else if (type == 'location') {
      return const Text(
        'Location',
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    } else {
      return Text(
        message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User _user = Provider.of<UserViewModel>(context, listen: false).getUser;
    // final snapshot = context.watch<QuerySnapshot>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
          ),
          onPressed: () => ZoomDrawer.of(context)!.toggle(),
        ),
        title: const Text(
          AppStrings.messages,
        ).tr(),
      ),
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        child: StreamBuilder(
          stream: _messageStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            List recipientUidList = [];
            if (snapshot.hasData) {
              final chatRooms = snapshot.data!.docs;
              if (chatRooms.isNotEmpty) {
                for (DocumentSnapshot chatRoom in chatRooms) {
                  final List contactsList = chatRoom['contacts'];
                  contactsList.remove(_user.uid);
                  final recipientUid = contactsList[0];
                  recipientUidList.add(recipientUid);
                }
                _future = getRecipientUser(recipientUidList);
                return FutureBuilder(
                  future: _future,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<User>> futureSnapshot) {
                    if (futureSnapshot.hasData) {
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String messageText =
                              snapshot.data!.docs[index]['lastMessage'];
                          final String messageType =
                              snapshot.data!.docs[index]['type'];
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 26,
                              backgroundImage: CachedNetworkImageProvider(
                                futureSnapshot.data![index].photoUrl,
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            title: Text(
                              futureSnapshot.data![index].username,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: subtitleWidget(messageText, messageType),
                            trailing: Text(
                              formatDateTime((snapshot.data!.docs[index]
                                          ['lastModified'] ??
                                      Timestamp.now())
                                  .toDate()),
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                      chatID: snapshot.data!.docs[index].id,
                                      recipientUser:
                                          futureSnapshot.data![index])));
                            },
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(
                          height: 1,
                        ),
                      );
                    } else {
                      return ListView.builder(
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return buildMessageShimmer();
                          });
                    }
                  },
                );
              } else {
                return Center(
                  child: const Text(AppStrings.noMessages).tr(),
                );
              }
            }
            return ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return buildMessageShimmer();
                });
          },
        ),
      ),
    );
  }

  Widget buildMessageShimmer() {
    return ListTile(
      leading: const ShimmerWidget.circular(width: 52, height: 52),
      title: Align(
          alignment: Alignment.centerLeft,
          child: ShimmerWidget.rectangular(
              width: MediaQuery.of(context).size.width * 0.3, height: 16)),
      subtitle: const ShimmerWidget.rectangular(height: 14),
      trailing: ShimmerWidget.rectangular(
          height: 14, width: MediaQuery.of(context).size.width * 0.2),
    );
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawsome/model/firebase_methods/firestore_methods.dart';
import 'package:pawsome/model/firebase_methods/storage_methods.dart';
import 'package:pawsome/model/location.dart';
import 'package:pawsome/model/message.dart';
import 'package:pawsome/viewmodel/user_viewmodel.dart';
import 'package:provider/provider.dart';
import '../model/user.dart';
import '../resources/strings_manager.dart';
import '../utils/utils.dart';
import '../viewmodel/theme_viewmodel.dart';
import '../widget/date_chip.dart';
import '../widget/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String chatID;
  final User recipientUser;
  const ChatScreen(
      {Key? key, required this.chatID, required this.recipientUser})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Query<Message> _query;
  late Stream<QuerySnapshot> _stream;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  late ImagePicker _picker;
  // late File? _imageFile;
  late ScrollController _scrollController;
  String textFieldText = '';
  String? chipDate;
  DateTime? previousChipDate;
  final GlobalKey _scaffoldKey = GlobalKey();

  int queryCount = 30;

  bool isFocused = false;
  bool showFloatingButton = false;

  @override
  void initState() {
    super.initState();

    // _stream = FirebaseFirestore.instance
    //     .collection('messages')
    //     .doc(widget.chatID)
    //     .collection('chats')
    //     .orderBy('datetime', descending: true)
    //     .limit(queryCount)
    //     .snapshots();

    // _query = FirebaseFirestore.instance
    //     .collection('messages')
    //     .doc(widget.chatID)
    //     .collection('chats')
    //     .orderBy('datetime', descending: true)
    //     .withConverter<Message>(
    //         fromFirestore: (snapshot, _) => Message.fromMap(snapshot.data()!),
    //         toFirestore: (message, _) => message.toMap());

    _controller = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _focusNode.addListener(_onFocusChange);
    _picker = ImagePicker();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void pickImage(
      String senderEmail, String senderUid, ImageSource imageSource) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: imageSource);
      if (pickedFile == null) return;

      final temporaryImage = File(pickedFile.path);
      final Uint8List dataFile = await temporaryImage.readAsBytes();
      // _imageFile = temporaryImage;

      String photoUrl = await StorageMethods.uploadImageToStorage(
          'chats', dataFile, null, true);

      FirestoreMethods.uploadMessage(photoUrl, senderEmail, senderUid,
          widget.recipientUser.uid, widget.chatID, 'image');

      // sendMessage(senderEmail, senderUid);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  static final customCacheManager = CacheManager(
    Config(
      'registeredPets',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
    ),
  );

  void sendMessage(String senderEmail, String senderUid) async {
    if (await checkConnectivity()) {
      _controller.clear();
      final String finalText = textFieldText.trim();
      if (finalText != '') {
        FirestoreMethods.uploadMessage(finalText, senderEmail, senderUid,
            widget.recipientUser.uid, widget.chatID, 'string');
      }
    } else {
      showSnackBar(context, AppStrings.noConnection.tr());
    }
  }

  void shareLocation(String senderEmail, String senderUid) async {
    final Position position = await LocationModel.determinePosition();
    final String location =
        '{"latitude": ${position.latitude}, "longitude": ${position.longitude}}';

    FirestoreMethods.uploadMessage(location, senderEmail, senderUid,
        widget.recipientUser.uid, widget.chatID, 'location');
  }

  void _showTextOptionSheet(
      BuildContext context, String senderEmail, String senderUid) {
    FocusManager.instance.primaryFocus?.unfocus();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text(AppStrings.share).tr(),
        message: const Text(AppStrings.selectOption).tr(),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              pickImage(senderEmail, senderUid, ImageSource.gallery);
            },
            child: const Text(AppStrings.gallery).tr(),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              pickImage(senderEmail, senderUid, ImageSource.camera);
            },
            child: const Text(AppStrings.camera).tr(),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              shareLocation(senderEmail, senderUid);
              Navigator.pop(context);
            },
            child: const Text(AppStrings.location).tr(),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(AppStrings.cancel).tr(),
          )
        ],
      ),
    );
  }

  String formatDateTime(DateTime dateTime) {
    final currentDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (currentDate == today) {
      return AppStrings.today.tr();
    } else if (currentDate == yesterday) {
      return AppStrings.yesterday.tr();
    } else {
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      final String formatted = formatter.format(dateTime);
      return formatted;
    }
  }

  Future<void> _scrollListener() async {
    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels != 0) {
        setState(() {
          queryCount += 30;
        });
      }
    }
    if (_scrollController.position.pixels >= 500) {
      setState(() {
        showFloatingButton = true;
      });
    } else if (_scrollController.position.pixels <= 20) {
      setState(() {
        showFloatingButton = false;
      });
    }
  }

  void _scrollToField(double? location) async {
    await _scrollController.animateTo(
        location ?? _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() {
        isFocused = true;
      });
    } else {
      setState(() {
        isFocused = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User _user =
        Provider.of<UserViewModel>(context, listen: false).getUser;
    final ThemeViewModel _themeViewModel = Provider.of<ThemeViewModel>(context);

    final currentUser = _user.email;

    _stream = FirebaseFirestore.instance
        .collection('messages')
        .doc(widget.chatID)
        .collection('chats')
        .orderBy('datetime', descending: true)
        .limit(queryCount)
        .snapshots();

    return Scaffold(
      // extendBodyBehindAppBar: true,
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      floatingActionButton: showFloatingButton
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () {
                  _scrollToField(0);
                },
                child: const Icon(Icons.arrow_downward_rounded),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        leading: const BackButton(),
        title: Row(
          children: [
            FullScreenWidget(
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  widget.recipientUser.photoUrl,
                  cacheManager: customCacheManager,
                ),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Text(
              widget.recipientUser.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _stream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Expanded(
                    child: Center(
                      child: SpinKitCircle(
                        color: Theme.of(context).primaryColor,
                        size: 30,
                      ),
                    ),
                  );
                }
                final messages = snapshot.data!.docs;
                chipDate = null;
                List<Widget> messageBubbles = [];
                for (var message in messages) {
                  final messageData = message.data() as Map<String, dynamic>;
                  final dateTime = messageData['datetime'] as Timestamp?;
                  if (dateTime == null) return const SizedBox();
                  final messageText = messageData['text'];
                  final messageSender = messageData['sender'];

                  final currentUser = _user.email;
                  final isSeen = messageData['seen'];
                  final type = messageData['type'];

                  final formattedTime = formatDateTime(dateTime.toDate());

                  if (chipDate == null) {
                    chipDate = formattedTime;
                    previousChipDate = dateTime.toDate();

                    final messageBubble = MessageBubble(
                      scaffoldContext: context,
                      sender: messageSender,
                      text: messageText,
                      isMe: currentUser == messageSender,
                      time: dateTime.toDate(),
                      isDarkMode: _themeViewModel.isDarkMode,
                      seen: isSeen,
                      type: type,
                      delivered: true,
                      sent: true,
                    );
                    messageBubbles.add(messageBubble);
                  } else {
                    if (chipDate == formattedTime) {
                      final messageBubble = MessageBubble(
                        scaffoldContext: context,
                        sender: messageSender,
                        text: messageText,
                        isMe: currentUser == messageSender,
                        time: dateTime.toDate(),
                        isDarkMode: _themeViewModel.isDarkMode,
                        seen: isSeen,
                        type: type,
                        delivered: true,
                        sent: true,
                      );
                      messageBubbles.add(messageBubble);

                      if (messages.toList().last == message) {
                        final dateChip = Center(
                          child: DateChip(
                            date: formatDateTime(previousChipDate!),
                          ),
                        );
                        messageBubbles.add(dateChip);
                      }
                    } else {
                      final dateChip = Center(
                        child: DateChip(
                          date: formatDateTime(previousChipDate!),
                        ),
                      );
                      messageBubbles.add(dateChip);

                      previousChipDate = dateTime.toDate();

                      final messageBubble = MessageBubble(
                        scaffoldContext: context,
                        sender: messageSender,
                        text: messageText,
                        isMe: currentUser == messageSender,
                        time: dateTime.toDate(),
                        isDarkMode: _themeViewModel.isDarkMode,
                        seen: isSeen,
                        type: type,
                        delivered: true,
                        sent: true,
                      );
                      chipDate = formattedTime;
                      messageBubbles.add(messageBubble);
                    }
                  }

                  // old code
                  // if (formatDateTime(chipDate!) != formattedTime) {
                  //   if (chipDate == null) {
                  //
                  //   } else {
                  //     final messageBubble = Center(
                  //       child: DateChip(
                  //         date: chipDate!,
                  //         color: Theme.of(context).primaryColor,
                  //       ),
                  //     );
                  //     messageBubbles.add(messageBubble);
                  //   }
                  // } else {
                  //   final messageBubble = MessageBubble(
                  //     scaffoldContext: context,
                  //     sender: messageSender,
                  //     text: messageText,
                  //     isMe: currentUser == messageSender,
                  //     time: dateTime.toDate(),
                  //     isDarkMode: _themeViewModel.isDarkMode,
                  //     seen: isSeen,
                  //     type: type,
                  //     delivered: true,
                  //     sent: true,
                  //   );
                  //   messageBubbles.add(messageBubble);
                  // }
                  // final messageBubble = MessageBubble(
                  //   scaffoldContext: context,
                  //   sender: messageSender,
                  //   text: messageText,
                  //   isMe: currentUser == messageSender,
                  //   time: dateTime.toDate(),
                  //   isDarkMode: _themeViewModel.isDarkMode,
                  //   seen: isSeen,
                  //   type: type,
                  //   delivered: true,
                  //   sent: true,
                  // );
                  //
                  // messageBubbles.add(messageBubble);
                  //
                  // chipDate = formattedTime;
                  // until here
                }
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: NotificationListener<UserScrollNotification>(
                      child: ListView.builder(
                        reverse: true,
                        cacheExtent: 9999,
                        controller: _scrollController,
                        itemCount: messageBubbles.length,
                        addAutomaticKeepAlives: false,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 20.0),
                        itemBuilder: (context, index) {
                          return messageBubbles[index];

                          // if (chipDate == null) {
                          //   chipDate = formattedTime;
                          //   previousChipDate = dateTime.toDate();
                          //
                          //   return MessageBubble(
                          //     scaffoldContext: context,
                          //     sender: messageData['sender'],
                          //     text: messageData['text'],
                          //     isMe: currentUser == messageData['sender'],
                          //     time: dateTime.toDate(),
                          //     isDarkMode: _themeViewModel.isDarkMode,
                          //     seen: messageData['seen'],
                          //     type: messageData['type'],
                          //     delivered: true,
                          //     sent: true,
                          //   );
                          // } else {
                          //   if (chipDate == formattedTime) {
                          //     return MessageBubble(
                          //       scaffoldContext: context,
                          //       sender: messageData['sender'],
                          //       text: messageData['text'],
                          //       isMe: currentUser == messageData['sender'],
                          //       time: dateTime.toDate(),
                          //       isDarkMode: _themeViewModel.isDarkMode,
                          //       seen: messageData['seen'],
                          //       type: messageData['type'],
                          //       delivered: true,
                          //       sent: true,
                          //     );
                          //     previousChipDate = dateTime.toDate();
                          //   } else {
                          //     return Center(
                          //       child: DateChip(
                          //         date: formatDateTime(previousChipDate!),
                          //       ),
                          //     );
                          //   }
                          // }

                          // if (index == messages.length - 1) {
                          //   print('shit');
                          //   return Center(
                          //     child: DateChip(
                          //       date: formatDateTime(previousChipDate!),
                          //     ),
                          //   );
                          // }

                          // return MessageBubble(
                          //   scaffoldContext: context,
                          //   sender: messageData['sender'],
                          //   text: messageData['text'],
                          //   isMe: currentUser == messageData['sender'],
                          //   time: dateTime.toDate(),
                          //   isDarkMode: _themeViewModel.isDarkMode,
                          //   seen: messageData['seen'],
                          //   type: messageData['type'],
                          //   delivered: true,
                          //   sent: true,
                          // );
                        },
                      ),
                      //     ListView(
                      //   reverse: true,
                      //   cacheExtent: 9999,
                      //   controller: _scrollController,
                      //   addAutomaticKeepAlives: true,
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 10.0, vertical: 20.0),
                      //   children: messageBubbles,
                      // ),
                      onNotification: (notification) {
                        if (notification.direction == ScrollDirection.reverse) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        }

                        return true;
                      },
                    ),
                  ),
                );
              },
            ),
            // Expanded(
            //   child: GestureDetector(
            //     onTap: () {
            //       FocusManager.instance.primaryFocus?.unfocus();
            //     },
            //     child: NotificationListener<UserScrollNotification>(
            //       child: FirestoreListView<Message>(
            //           reverse: true,
            //           controller: _scrollController,
            //           query: _query,
            //           pageSize: 15,
            //           itemBuilder: (context, snapshot) {
            //             if (!snapshot.metadata.hasPendingWrites) {
            //               final message = snapshot.data();
            //
            //               final formattedTime =
            //                   formatDateTime(message.timeSent);
            //               // if (chipDate != formattedTime) {
            //               //   print(message.timeSent);
            //               //   chipDate = formattedTime;
            //               //   return Center(
            //               //     child: DateChip(
            //               //       date: message.timeSent,
            //               //       color: Theme.of(context).primaryColor,
            //               //     ),
            //               //   );
            //               // } else {
            //               return MessageBubble(
            //                 scaffoldContext: context,
            //                 sender: message.sender,
            //                 text: message.text,
            //                 isMe: currentUser == message.sender,
            //                 time: message.timeSent,
            //                 isDarkMode: _themeViewModel.isDarkMode,
            //                 seen: message.isSeen,
            //                 type: message.type,
            //                 delivered: true,
            //                 sent: true,
            //               );
            //               // }
            //             } else {
            //               return const SizedBox();
            //             }
            //           }),
            //       onNotification: (notification) {
            //         if (notification.direction == ScrollDirection.reverse) {
            //           FocusManager.instance.primaryFocus?.unfocus();
            //         }
            //
            //         return true;
            //       },
            //     ),
            //   ),
            // ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              margin: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).size.height / 40),
              constraints: const BoxConstraints(
                maxHeight: 150,
              ),
              height: 70,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Center(
                child: TextField(
                  controller: _controller,
                  cursorColor: Theme.of(context).primaryColor,
                  maxLines: 2,
                  minLines: 1,
                  decoration: InputDecoration(
                    // contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    hintText: AppStrings.typeAMessage.tr(),
                    prefixIcon: IconButton(
                        color: Colors.grey,
                        onPressed: () => _showTextOptionSheet(
                            context, _user.email, _user.uid),
                        icon: const Icon(
                          Icons.add,
                        )),
                    suffixIcon: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        color: Colors.white,
                        onPressed: () {
                          _scrollToField(0);
                          sendMessage(_user.email, _user.uid);
                        },
                        icon: Transform.rotate(
                          angle: 45,
                          child: const Icon(Icons.navigation_rounded),
                        ),
                      ),
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    textFieldText = value;
                  },
                ),
              ),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.end,
              //   children: [
              //     AnimatedSwitcher(
              //       duration: const Duration(milliseconds: 80),
              //       transitionBuilder: (child, animation) {
              //         return SizeTransition(
              //           axis: Axis.horizontal,
              //           sizeFactor: animation,
              //           child: FadeTransition(
              //             opacity: animation,
              //             child: child,
              //           ),
              //         );
              //       },
              //       // transitionBuilder: (child, animation) => SizeTransition(
              //       //   sizeFactor: animation,
              //       //   child: child,
              //       //   axis: Axis.horizontal,
              //       // ),
              //       child: isFocused
              //           ? Center(
              //               child: IconButton(
              //                 padding: EdgeInsets.zero,
              //                 onPressed: () {
              //                   setState(() {
              //                     isFocused = false;
              //                   });
              //                 },
              //                 icon: const Icon(
              //                   Icons.chevron_right,
              //                   color: Colors.white,
              //                   size: 40,
              //                 ),
              //               ),
              //             )
              //           : Row(
              //               children: [
              //                 IconButton(
              //                   onPressed: () {},
              //                   icon: const Icon(
              //                     Icons.location_pin,
              //                     color: Colors.white,
              //                     size: 26,
              //                   ),
              //                 ),
              //                 IconButton(
              //                   onPressed: () {},
              //                   icon: const Icon(
              //                     Icons.camera_alt,
              //                     color: Colors.white,
              //                     size: 26,
              //                   ),
              //                 ),
              //                 Padding(
              //                   padding: const EdgeInsets.only(right: 8.0),
              //                   child: IconButton(
              //                     onPressed: () async {
              //                       await selectImage();
              //                     },
              //                     icon: const Icon(
              //                       Icons.photo_size_select_actual_outlined,
              //                       color: Colors.white,
              //                       size: 26,
              //                     ),
              //                   ),
              //                 ),
              //               ],
              //             ),
              //     ),
              //     Expanded(
              //       child: Center(
              //         child: Container(
              //           // margin: const EdgeInsets.symmetric(vertical: 6),
              //           // height: 39,
              //           child: TextField(
              //             controller: _controller,
              //             focusNode: _focusNode,
              //             onTap: () {
              //               SystemSound.play(SystemSoundType.click);
              //               setState(() {
              //                 isFocused = true;
              //               });
              //             },
              //             minLines: 1,
              //             maxLines: 5,
              //             keyboardType: TextInputType.multiline,
              //             textCapitalization: TextCapitalization.sentences,
              //             cursorColor: Theme.of(context).primaryColor,
              //             style: const TextStyle(
              //                 color: Colors.white, fontSize: 18),
              //             decoration: InputDecoration(
              //               contentPadding: const EdgeInsets.symmetric(
              //                   horizontal: 20, vertical: 5),
              //               hintText: 'Aa',
              //               hintStyle: const TextStyle(
              //                   color: Colors.grey, fontSize: 18),
              //               focusColor: const Color(0xff008000),
              //               fillColor: const Color(0xff008000),
              //               filled: true,
              //               border: OutlineInputBorder(
              //                   borderRadius: BorderRadius.circular(20.0),
              //                   borderSide: const BorderSide(
              //                       color: Color(0xff006400))),
              //               enabledBorder: OutlineInputBorder(
              //                   borderRadius: BorderRadius.circular(20.0),
              //                   borderSide: const BorderSide(
              //                       color: Color(0xff006400))),
              //               focusedBorder: OutlineInputBorder(
              //                   borderRadius: BorderRadius.circular(20.0),
              //                   borderSide: const BorderSide(
              //                       color: Color(0xff006400))),
              //             ),
              //             onChanged: (value) {
              //               if (!isFocused) {
              //                 setState(() {
              //                   isFocused = true;
              //                 });
              //               }
              //               textFieldText = value;
              //             },
              //           ),
              //         ),
              //       ),
              //     ),
              //     Center(
              //       child: IconButton(
              //         onPressed: () {
              //           sendMessage(_user.email, _user.uid);
              //         },
              //         icon: const Icon(
              //           Icons.send_rounded,
              //           color: Colors.white,
              //           size: 30,
              //         ),
              //       ),
              //     )
              //   ],
              // ),
            )
          ],
        ),
      ),
    );
  }
}

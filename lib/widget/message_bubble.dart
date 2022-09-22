import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_map/flutter_map.dart' hide Coords;
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:pawsome/utils/utils.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../model/firebase_methods/storage_methods.dart';
import '../resources/strings_manager.dart';
import '../viewmodel/theme_viewmodel.dart';
import 'animated_markers_map.dart';
import 'package:map_launcher/map_launcher.dart';

const double BUBBLE_RADIUS = 16;

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final String type;
  final bool isMe;
  final bool isDarkMode;
  final BuildContext scaffoldContext;
  final bool seen;
  final bool sent;
  final bool delivered;
  final DateTime time;

  const MessageBubble({
    Key? key,
    required this.sender,
    required this.text,
    required this.isMe,
    required this.type,
    required this.scaffoldContext,
    required this.isDarkMode,
    required this.seen,
    required this.time,
    required this.sent,
    required this.delivered,
  }) : super(key: key);

  void _showImageOptionSheet(BuildContext context, String url) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (Platform.isIOS) {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context2) => CupertinoActionSheet(
          // title: const Text(AppStrings.imageOption).tr(),
          // message: const Text(AppStrings.selectOption).tr(),
          actions: <CupertinoActionSheetAction>[
            // CupertinoActionSheetAction(
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            //   child: const Text(AppStrings.copy).tr(),
            // ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                saveImage(context, url);
              },
              child: const Text(AppStrings.save).tr(),
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
    } else {}
  }

  openMapsSheet(BuildContext context, double latitude, double longitude) async {
    try {
      final coordinates = Coords(latitude, longitude);
      final title = AppStrings.myLocation.tr();
      final availableMaps = await MapLauncher.installedMaps;

      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
            // title: const Text(AppStrings.share).tr(),
            // message: const Text(AppStrings.selectOption).tr(),
            actions: <CupertinoActionSheetAction>[
          for (var map in availableMaps)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                map.showMarker(
                  coords: coordinates,
                  title: title,
                );
              },
              child: Text(
                map.mapName,
                style: const TextStyle(color: Colors.grey),
              ),
            )
        ].followedBy([
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Container(
              child: const Text(AppStrings.cancel).tr(),
            ),
          )
        ]).toList()),
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void saveImage(BuildContext context, String url) async {
    await StorageMethods.downloadImage(url).then((String value) {
      if (value == 'success') {
        showSnackBar(context, AppStrings.imageSaved.tr());
      } else {
        showSnackBar(context, value);
      }
    });
  }

  static final customCacheManager = CacheManager(
    Config(
      'chats',
      maxNrOfCacheObjects: 100,
    ),
  );

  @override
  Widget build(BuildContext context) {
    ThemeViewModel _themeViewModel = Provider.of<ThemeViewModel>(context);

    bool stateTick = false;
    Widget? stateIcon;
    if (sent) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_rounded,
        size: 18,
        color: Colors.white,
      );
    }
    if (delivered) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all_rounded,
        size: 18,
        color: Colors.white,
      );
    }
    if (seen) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all_rounded,
        size: 18,
        color: Colors.blue,
      );
    }

    if (stateIcon != null) {
      stateIcon = Row(
        children: [
          Text(
            '${time.hour}'.padLeft(2, '0') +
                ':' +
                '${time.minute}'.padLeft(2, '0') +
                ':' +
                '${time.second}'.padLeft(2, '0'),
            style: TextStyle(
              color: isMe
                  ? Colors.white
                  : _themeViewModel.isDarkMode
                      ? Colors.white
                      : Colors.black,
              fontSize: 10,
            ),
            textAlign: isMe ? TextAlign.right : TextAlign.left,
          ),
          const SizedBox(width: 3),
          // stateIcon,
          isMe ? stateIcon : const SizedBox(),
        ],
      );
    } else {
      stateIcon = Text(
        '${time.hour}'.padLeft(2, '0') +
            ':' +
            '${time.minute}'.padLeft(2, '0') +
            ':' +
            '${time.second}'.padLeft(2, '0'),
        style: TextStyle(
          color: isMe
              ? Colors.white
              : _themeViewModel.isDarkMode
                  ? Colors.white
                  : Colors.black,
          fontSize: 10,
        ),
        textAlign: TextAlign.right,
      );
    }

    if (type == 'string') {
      return Row(
        children: [
          isMe
              ? const Expanded(
                  child: SizedBox(
                    width: 5,
                  ),
                )
              : Container(),
          GestureDetector(
            onLongPress: () {
              HapticFeedback.mediumImpact();
              Clipboard.setData(ClipboardData(text: text));
              showSnackBar(context, AppStrings.messageCopied.tr(), duration: 1);
            },
            child: Container(
              color: Colors.transparent,
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Container(
                  // padding: EdgeInsets.only(left: 10),
                  constraints: const BoxConstraints(minWidth: 80),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.background,
                    borderRadius: isMe
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          )
                        : const BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: stateTick
                            ? const EdgeInsets.fromLTRB(12, 6, 12, 20)
                            : const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 16,
                            color: isMe
                                ? Colors.white
                                : _themeViewModel.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      stateTick
                          ? Positioned(
                              bottom: isMe ? 4 : 6,
                              right: isMe ? 6 : null,
                              left: isMe ? null : 13,
                              child: stateIcon,
                            )
                          : const SizedBox(
                              width: 1,
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );

      //   Padding(
      //   padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      //   child: Column(
      //     crossAxisAlignment:
      //         isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      //     children: [
      //       Bubble(
      //         text: text,
      //         seen: seen,
      //         isSender: isMe,
      //       )
      //       // GestureDetector(
      //       //   onLongPress: () {
      //       //     HapticFeedback.mediumImpact();
      //       //     Clipboard.setData(ClipboardData(text: text));
      //       //     showSnackBar(context, AppStrings.messageCopied.tr(),
      //       //         duration: 1);
      //       //   },
      //       //   onTap: () {},
      //       //   child: Container(
      //       //     constraints: BoxConstraints(
      //       //         maxWidth: MediaQuery.of(context).size.width / 1.5,
      //       //         minWidth: 80),
      //       //     child: Material(
      //       //       borderRadius: isMe
      //       //           ? const BorderRadius.only(
      //       //               topLeft: Radius.circular(30.0),
      //       //               bottomLeft: Radius.circular(30.0),
      //       //               bottomRight: Radius.circular(15.0),
      //       //             )
      //       //           : const BorderRadius.only(
      //       //               topRight: Radius.circular(30.0),
      //       //               bottomLeft: Radius.circular(30.0),
      //       //               bottomRight: Radius.circular(30.0),
      //       //             ),
      //       //       elevation: 5.0,
      //       //       color: isMe
      //       //           ? Theme.of(context).primaryColor
      //       //           : Theme.of(context).colorScheme.background,
      //       //       child: Padding(
      //       //         padding: const EdgeInsets.only(
      //       //             top: 10, bottom: 10, left: 20.0, right: 10),
      //       //         child: Row(
      //       //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       //           mainAxisSize: MainAxisSize.min,
      //       //           crossAxisAlignment: CrossAxisAlignment.end,
      //       //           children: [
      //       //             Flexible(
      //       //               child: Text(
      //       //                 text,
      //       //                 textAlign: TextAlign.left,
      //       //                 style: TextStyle(
      //       //                     color: isMe
      //       //                         ? Colors.white
      //       //                         : _themeViewModel.isDarkMode
      //       //                             ? Colors.white
      //       //                             : Colors.black,
      //       //                     fontSize: 16),
      //       //               ),
      //       //             ),
      //       //             Text(
      //       //               '${dateTime.hour}:${dateTime.minute}:${dateTime.second}',
      //       //               style: TextStyle(fontSize: 12),
      //       //             ),
      //       //             isMe
      //       //                 ? isSeen
      //       //                     ? const Icon(
      //       //                         Icons.done_all_rounded,
      //       //                         color: Colors.white,
      //       //                         size: 18,
      //       //                       )
      //       //                     : const Icon(
      //       //                         Icons.done_rounded,
      //       //                         color: Colors.white,
      //       //                         size: 18,
      //       //                       )
      //       //                 : const SizedBox()
      //       //           ],
      //       //         ),
      //       //       ),
      //       //     ),
      //       //   ),
      //       // )
      //     ],
      //   ),
      // );
    } else if (type == 'image') {
      return Container(
        // height: MediaQuery.of(context).size.height / 2.5,
        width: MediaQuery.of(context).size.width,
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        child: GestureDetector(
          onLongPress: () {
            // final imageRef = FirebaseStorage.instance
            //     .ref()
            //     .child('chats')
            //     .child(sender)
            //     .child();
            _showImageOptionSheet(scaffoldContext, text);
          },
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(
                    left: 10, top: 10, right: 10, bottom: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: isMe
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.background,
                ),
                child: Container(
                  // height: MediaQuery.of(context).size.height / 2.5,
                  width: MediaQuery.of(context).size.width / 2,
                  alignment: Alignment.center,
                  child: FullScreenWidget(
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: InteractiveViewer(
                          maxScale: 10,
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: text,
                            cacheManager: customCacheManager,
                            placeholder: (context, url) => AspectRatio(
                              aspectRatio: 3 / 4,
                              child: Container(
                                height: double.infinity,
                                width: double.infinity,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                  bottom: isMe ? 4 : 7,
                  right: isMe ? 6 : null,
                  left: isMe ? null : 12,
                  child: stateIcon
                  // Icon(
                  //   seen ? Icons.done_all_rounded : Icons.done_rounded,
                  //   color: Colors.white,
                  //   size: 18,
                  // ),
                  )
            ],
          ),
        ),
      );
    } else {
      Map location = json.decode(text);
      return Container(
        height: MediaQuery.of(context).size.height / 2.5,
        // width: MediaQuery.of(context).size.width / 10,
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(
                  left: 10, top: 10, right: 10, bottom: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isMe
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.background,
              ),
              child: GestureDetector(
                onLongPress: () => openMapsSheet(
                    context, location['latitude'], location['longitude']),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  clipBehavior: Clip.hardEdge,
                  child: Container(
                    // height: MediaQuery.of(context).size.height / 2.5,
                    width: MediaQuery.of(context).size.width / 2,
                    alignment: Alignment.center,
                    child: AbsorbPointer(
                      absorbing: true,
                      child: FlutterMap(
                        options: MapOptions(
                          allowPanningOnScrollingParent: false,
                          enableScrollWheel: false,
                          enableMultiFingerGestureRace: false,
                          allowPanning: false,
                          minZoom: 16,
                          maxZoom: 16,
                          zoom: 16,
                          center: LatLng(
                              location['latitude'], location['longitude']),
                        ),
                        nonRotatedLayers: [
                          TileLayerOptions(
                              urlTemplate:
                                  'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                              additionalOptions: {
                                'accessToken': MAPBOX_ACCESS_TOKEN,
                                'id': isDarkMode ? MAPBOX_DARK : MAPBOX_LIGHT
                              }),
                          MarkerLayerOptions(
                            markers: [
                              Marker(
                                width: 30,
                                height: 30,
                                builder: (_) {
                                  // return _MyLocationMarker(_animationController);
                                  return Container(
                                    height: 20.0,
                                    width: 20.0,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                        shape: BoxShape.circle),
                                    child: Icon(
                                      Icons.pets_rounded,
                                      color: Theme.of(context).primaryColor,
                                      size: 18,
                                    ),
                                  );
                                },
                                point: LatLng(location['latitude'],
                                    location['longitude']),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                bottom: isMe ? 4 : 7,
                right: isMe ? 6 : null,
                left: isMe ? null : 12,
                child: stateIcon
                // Icon(
                //   seen ? Icons.done_all_rounded : Icons.done_rounded,
                //   color: Colors.white,
                //   size: 18,
                // ),
                )
          ],
        ),
      );
    }
  }
}

// Positioned(
// bottom: 10,
// right: isMe ? 15 : null,
// left: isMe ? null : 15,
// child: Icon(isSeen ? Icons.done_all_rounded : Icons.done_rounded),
// )

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pawsome/resources/font_manager.dart';
import 'package:pawsome/resources/strings_manager.dart';
import 'package:pawsome/utils/utils.dart';
import 'package:pawsome/view/chat.dart';
import 'package:pawsome/viewmodel/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import '../model/user.dart';

// ignore: must_be_immutable
class PetDetails extends StatefulWidget {
  final Map<String, dynamic> snap;
  final int index;

  const PetDetails({Key? key, required this.snap, required this.index})
      : super(key: key);

  @override
  PetDetailsState createState() => PetDetailsState();
}

class PetDetailsState extends State<PetDetails> {
  bool isFavorite = false;

  static final customCacheManager = CacheManager(
    Config(
      'registeredPets',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
    ),
  );

  Future<void> contactMePressed(String currentUserUid) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.snap['ownerUid'])
        .get();

    final recipientUser = User.fromSnapshot(snapshot);

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatScreen(
        chatID: compareUserId(currentUserUid, widget.snap['ownerUid']),
        recipientUser: recipientUser,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    User _user = Provider.of<UserViewModel>(context, listen: false).getUser;

    return Scaffold(
      appBar: AppBar(
          leading: const BackButton(),
          title: const Text(
            AppStrings.ownerPet,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ).tr(args: ['${widget.snap['owner']}'])),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        margin: const EdgeInsets.only(top: 5),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FullScreenWidget(
                        child: Hero(
                          tag: 'petPicture${widget.index}',
                          child: Container(
                            height: 150.0,
                            width: 150.0,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: CachedNetworkImage(
                              // key: UniqueKey(),
                              imageUrl: widget.snap['photoUrl'],
                              // maxHeightDiskCache: 50,
                              // height: 100,
                              // width: 100,
                              placeholder: (context, url) => Container(
                                color: Colors.black12,
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.black12,
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                widget.snap['name'],
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                getName(widget.snap['petSpecies']),
                                style: TextStyle(color: Colors.grey.shade500),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 5),
                                    constraints: const BoxConstraints(
                                      minWidth: 40,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: const Color(0xffd0f0c0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        widget.snap['gender'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: FontSize.s12,
                                            color: Color(0xff006400)),
                                      ).tr(),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 5),
                                    constraints: const BoxConstraints(
                                      minWidth: 40,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: const Color(0xffe6e6fa),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${widget.snap['age']} ' +
                                            AppStrings.yrs.tr(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: FontSize.s12,
                                            color: Color(0xff800080)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      minimumSize: Size.zero,
                                      padding: EdgeInsets.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    label: Text(
                                      k_m_b_generator(
                                          widget.snap['likes'].length),
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                    icon: const Icon(
                                      Icons.favorite_rounded,
                                      color: Colors.red,
                                    ),
                                    onPressed: null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: FullScreenWidget(
                              child: CachedNetworkImage(
                                // key: UniqueKey(),
                                fit: BoxFit.cover,
                                cacheManager: customCacheManager,
                                imageUrl: widget.snap['ownerPhotoUrl'],
                                // maxHeightDiskCache: 50,
                                // height: 100,
                                // width: 100,
                                placeholder: (context, url) => Container(
                                  color: Colors.black12,
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.black12,
                                  child: const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                textBaseline: TextBaseline.alphabetic,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                children: [
                                  Text(
                                    widget.snap['owner'],
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade900),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const Text(
                                    AppStrings.owner,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: Colors.grey),
                                  ).tr(),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: const Color(0xffffe4c4),
                                ),
                                child: Text(
                                  widget.snap['petPrice'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: FontSize.s12,
                                      color: Color(0xffa52a2a)),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        AppStrings.description,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ).tr(),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        widget.snap['description'],
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            widget.snap['owner'] != _user.username
                ? GestureDetector(
                    onTap: () async {
                      await contactMePressed(_user.uid);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20),
                            topLeft: Radius.circular(20)),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30, bottom: 20),
                          child: const Text(
                            AppStrings.contactMe,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: FontSize.s18,
                                fontWeight: FontWeight.bold),
                          ).tr(),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:provider/provider.dart';

import '../model/firebase_methods/firestore_methods.dart';
import '../model/user.dart';
import '../resources/strings_manager.dart';
import '../utils/utils.dart';
import '../viewmodel/my_pets_viewmodel.dart';
import '../viewmodel/user_viewmodel.dart';

class MissingPetList extends StatefulWidget {
  const MissingPetList({Key? key}) : super(key: key);

  @override
  _MissingPetListState createState() => _MissingPetListState();
}

class _MissingPetListState extends State<MissingPetList>
    with AutomaticKeepAliveClientMixin {
  final List<ListTile> _missingPetList = [];

  late Stream<QuerySnapshot> _missingPetStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    User _user = Provider.of<UserViewModel>(context, listen: false).getUser;
    _missingPetStream = FirebaseFirestore.instance
        .collection('missingPets')
        .where('ownerUid', isEqualTo: _user.uid)
        .orderBy('date', descending: true)
        .snapshots();
  }

  static final customCacheManager = CacheManager(
    Config(
      'myPets',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 20,
    ),
  );

  Future<void> deleteRecord(String collectionName, String postID) async {
    final res = await FirestoreMethods.deleteDocument(collectionName, postID);

    if (res == 'success') {
      showSnackBar(context, AppStrings.petRemovedSuccessfully.tr());
    } else {
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    MyPetsViewModel _myPets = Provider.of<MyPetsViewModel>(context);
    super.build(context);
    return StreamBuilder<QuerySnapshot>(
        stream: _missingPetStream,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> missingSnapshot) {
          _missingPetList.clear();
          if (missingSnapshot.hasData) {
            if (missingSnapshot.data!.docs.isEmpty) {
              return Center(
                child: const Text(AppStrings.noPetsMissing).tr(),
              );
            } else {
              return ListView.builder(
                addAutomaticKeepAlives: true,
                padding: const EdgeInsets.all(10),
                itemCount: missingSnapshot.data?.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  Map<String, dynamic>? data = missingSnapshot.data?.docs[index]
                      .data() as Map<String, dynamic>?;
                  final DateTime _date = (data?['date'] as Timestamp).toDate();
                  return ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    tileColor: Theme.of(context).colorScheme.background,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FullScreenWidget(
                        child: CachedNetworkImage(
                          imageUrl: data?['photoUrl'],
                          cacheManager: customCacheManager,
                          placeholder: (context, url) => Container(
                            color: Colors.black12,
                            height: 50,
                            width: 50,
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
                    title: Text(data?['name']),
                    subtitle: Text(
                      '${AppStrings.dateCreated.tr()}: ${_date.year}-${_date.month}-${_date.day}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: IconButton(
                      onPressed: () async {
                        _myPets.setIsLoading = true;
                        await deleteRecord('missingPets', data?['postId']);
                        _myPets.setIsLoading = false;
                      },
                      icon: const Icon(
                        Icons.delete_rounded,
                      ),
                    ),
                  );
                },
              );
            }
          }
          return Container();
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

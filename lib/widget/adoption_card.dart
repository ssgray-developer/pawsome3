import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pawsome/model/firebase_methods/firestore_methods.dart';
import 'package:pawsome/resources/strings_manager.dart';
import 'package:pawsome/utils/utils.dart';
import 'package:pawsome/view/pet_details.dart';
import 'package:pawsome/viewmodel/user_viewmodel.dart';
import 'package:pawsome/widget/like_animation.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../model/user.dart';
import '../model/location.dart';

class AdoptionCard extends StatefulWidget {
  final Map<String, dynamic> snap;
  final int index;
  const AdoptionCard({Key? key, required this.snap, required this.index})
      : super(key: key);

  @override
  State<AdoptionCard> createState() => _AdoptionCardState();
}

class _AdoptionCardState extends State<AdoptionCard> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // DefaultCacheManager().emptyCache();
    // imageCache.clear();
    // imageCache.clearLiveImages();
  }

  static final customCacheManager = CacheManager(
    Config(
      'registeredPets',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserViewModel>(context).getUser;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  PetDetails(snap: widget.snap, index: widget.index),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: 120.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Theme.of(context).colorScheme.background,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'petPicture${widget.index}',
                child: Container(
                    height: 100.0,
                    width: 100.0,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: CachedNetworkImage(
                      // key: UniqueKey(),
                      cacheManager: customCacheManager,
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
                    )
                    // Image.network(widget.snap['photoUrl']),
                    ),
              ),
              const SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Expanded(
                    //   child: Marquee(
                    //     text: widget.snap['name'],
                    //     style: const TextStyle(
                    //         fontWeight: FontWeight.bold, fontSize: 16),
                    //   ),
                    // ),
                    Text(
                      widget.snap['name'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      getName(widget.snap['petSpecies']),
                      style: const TextStyle(fontSize: 12),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      (AppStrings.yearOld
                          .plural(int.parse(widget.snap['age']))),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_pin,
                          size: 18,
                          color: Colors.deepOrange,
                        ),
                        const Text(
                          AppStrings.withinDistance,
                          style: TextStyle(color: Colors.grey),
                        ).tr(args: [
                          '${LocationModel.getDistanceBetween((widget.snap['location']['geopoint'] as GeoPoint).latitude, (widget.snap['location']['geopoint'] as GeoPoint).longitude)}'
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  widget.snap['gender'] == 'Male'
                      ? const Icon(
                          Icons.male_rounded,
                          color: Colors.blue,
                        )
                      : const Icon(
                          Icons.female_rounded,
                          color: Colors.pink,
                        ),
                  Expanded(
                    child: Container(),
                  ),
                  LikeAnimation(
                    isAnimating: widget.snap['likes'].contains(user.uid),
                    smallLike: true,
                    child: IconButton(
                      padding: const EdgeInsets.all(0),
                      alignment: Alignment.centerRight,
                      icon: widget.snap['likes'].contains(user.uid)
                          ? const Icon(
                              Icons.favorite_outlined,
                              color: Colors.pink,
                              size: 28.0,
                            )
                          : const Icon(
                              Icons.favorite_outline,
                              color: Colors.pink,
                              size: 28.0,
                            ),
                      onPressed: () async {
                        await FirestoreMethods.likePost(widget.snap['postId'],
                            user.uid, widget.snap['likes']);
                        HapticFeedback.mediumImpact();
                      },
                    ),
                  ),
                  Text(
                    k_m_b_generator(widget.snap['likes'].length),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

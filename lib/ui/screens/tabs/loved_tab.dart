import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/screens/rock_view_page.dart';
import 'package:flutter_onboarding/ui/screens/widgets/rock_list_item.dart';
import 'package:page_transition/page_transition.dart';

import '../camera_screen.dart';

class LovedTab extends StatefulWidget {
  const LovedTab({super.key});

  @override
  State<LovedTab> createState() => LovedTabState();
}

class LovedTabState extends State<LovedTab> {
  final List<Rock> _wishlistRocks = [];
  final List<Map<String, dynamic>> _wishlistRocksMap = [];
  final ValueNotifier<int> wishlistNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    loadWishlist();
  }

  void loadWishlist() async {
    try {
      _wishlistRocks.clear();
      final allDbRocks = await DatabaseHelper().findAllRocks();
      List<Map<String, dynamic>> wishlistRocksMap =
          await DatabaseHelper().wishlist();
      _wishlistRocksMap.addAll(wishlistRocksMap);
      for (final wishlistRock in wishlistRocksMap) {
        Rock? rock = Rock.rockListFirstWhere(wishlistRock['rockId']);
        final dbRock = allDbRocks.firstWhere(
          (element) => element.rockId == rock?.rockId,
          orElse: Rock.empty,
        );

        if (dbRock.rockId != 0) {
          rock = rock?.copyWith(rockImages: dbRock.rockImages);
        }
        if (rock != null) {
          _wishlistRocks.add(rock);
        }
      }

      setState(() {});
    } catch (e) {
      debugPrint('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        right: 16.0,
        bottom: 40.0,
        left: 16.0,
      ),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Constants.darkGrey,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: ValueListenableBuilder(
          valueListenable: wishlistNotifier,
          builder: (context, value, child) {
            return _wishlistRocks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.list_alt_rounded,
                            size: 50,
                            color: Constants.naturalGrey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 20),
                          Text('The Loved is empty!',
                              style: AppTypography.body2(
                                  color: AppColors.naturalWhite)),
                          const SizedBox(height: 10),
                          Text(
                              "Add any new rock to this page by seeing it's details and clicking on the heart icon on the top right of the page.",
                              textAlign: TextAlign.center,
                              style: AppTypography.body3(
                                  color: AppColors.naturalWhite)),
                          const SizedBox(height: 20),
                          _addRockToWishlistButton(),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _wishlistRocks.length,
                          cacheExtent: 2000,
                          physics: const ScrollPhysics(),
                          itemBuilder: (context, index) {
                            final rock = _wishlistRocks[index];
                            final wishlist = _wishlistRocksMap
                                .where((element) =>
                                    element['rockId'] == rock.rockId)
                                .first;
                            final imagePath = wishlist['imagePath'];

                            Map<String, dynamic> rockDefaultImage = {
                              'img1': 'https://placehold.jp/60x60.png',
                            };

                            for (final defaultImage in Rock.defaultImages) {
                              if (defaultImage['rockId'] == rock.rockId) {
                                rockDefaultImage = defaultImage;
                                break;
                              }
                            }

                            return RockListItem(
                              imagePath: imagePath,
                              imageUrl:
                                  rockDefaultImage['img1'], // Placeholder image
                              title: rock.rockName,
                              tags: const ['Loved'],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: RockViewPage(
                                      rock: rock,
                                      isUnfavoritingRock: true,
                                      pickedImage: imagePath != null
                                          ? File(imagePath)
                                          : imagePath,
                                    ),
                                    type: PageTransitionType.bottomToTop,
                                  ),
                                ).then((_) => loadWishlist());
                              },
                              onDelete: () async {
                                try {
                                  if (imagePath?.isNotEmpty == true) {
                                    if (!(await DatabaseHelper()
                                            .imageExistsCollection(
                                                imagePath)) &&
                                        !(await DatabaseHelper()
                                            .imageExistsSnapHistory(
                                                imagePath))) {
                                      final file = File(imagePath);
                                      await file.delete();
                                    }
                                  }
                                  await DatabaseHelper()
                                      .removeRockFromWishlist(rock.rockId);
                                  loadWishlist();
                                  wishlistNotifier.value++;
                                } catch (e) {
                                  debugPrint(e.toString());
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _addRockToWishlistButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          PageTransition(
            duration: const Duration(milliseconds: 400),
            child: const CameraScreen(),
            type: PageTransitionType.bottomToTop,
          ),
        ).then((_) => loadWishlist());
      },
      icon: const Icon(Icons.add),
      label: const Text(
        'Add Rock',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Constants.primaryColor,
        foregroundColor: Constants.blackColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 20.0,
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/pages/rock_view_page.dart';
import 'package:flutter_onboarding/ui/pages/tabs/tab_services/loved_tab_service.dart';
import 'package:flutter_onboarding/ui/pages/widgets/rock_list_item.dart';
import 'package:page_transition/page_transition.dart';

import '../camera_page.dart';

class LovedTab extends StatefulWidget {
  const LovedTab({super.key});

  @override
  State<LovedTab> createState() => _LovedTabState();
}

class _LovedTabState extends State<LovedTab> {
  final _store = LovedTabService.instance;

  @override
  void initState() {
    _store.loadLovedRocks().then((_) => setState(() {}));
    super.initState();
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
        child: ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: _store.lovedRocksMapNotifier,
          builder: (context, lovedRocksMap, child) =>
              ValueListenableBuilder<List<Rock>>(
            valueListenable: _store.lovedRocksNotifier,
            builder: (context, lovedRocks, child) {
              return lovedRocks.isEmpty
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
                            Text('The Loved tab is empty!',
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
                            itemCount: lovedRocks.length,
                            cacheExtent: 2000,
                            physics: const ScrollPhysics(),
                            itemBuilder: (context, index) {
                              final rock = lovedRocks[index];
                              final wishlist = lovedRocksMap
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
                                imageUrl: rockDefaultImage[
                                    'img1'], // Placeholder image
                                title: rock.rockCustomName.isNotEmpty
                                    ? rock.rockCustomName
                                    : rock.rockName,
                                tags: const ['Loved'],
                                onTap: () async {
                                  bool isRemovingFromCollection = false;
                                  final allRocks =
                                      await DatabaseHelper().findAllRocks();
                                  if (allRocks
                                      .where((rockFromAll) =>
                                          rockFromAll.rockName ==
                                              rock.rockName &&
                                          rockFromAll.isAddedToCollection)
                                      .isNotEmpty) {
                                    isRemovingFromCollection = true;
                                  }

                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      child: RockViewPage(
                                        rock: rock,
                                        isUnfavoritingRock: true,
                                        isRemovingFromCollection:
                                            isRemovingFromCollection,
                                        pickedImage: imagePath != null
                                            ? File(imagePath)
                                            : imagePath,
                                      ),
                                      type: PageTransitionType.bottomToTop,
                                    ),
                                  ).then(
                                    (_) async {
                                      await _store.loadLovedRocks();
                                      setState(() {});
                                    },
                                  );
                                },
                                onDelete: () async {
                                  try {
                                    if (imagePath?.isNotEmpty == true) {
                                      if (!(await DatabaseHelper()
                                              .imageExistsCollection(
                                                  imagePath)) &&
                                          !(await DatabaseHelper()
                                              .imageExistsSnapHistory(
                                                  imagePath)) &&
                                          (Rock.rockList
                                              .where((defaultRock) =>
                                                  defaultRock.rockId ==
                                                  rock.rockId)
                                              .isNotEmpty)) {
                                        final file = File(imagePath);
                                        await file.delete();
                                      }
                                    }
                                    await DatabaseHelper()
                                        .removeRockFromWishlist(rock.rockId);
                                    await _store.loadLovedRocks();
                                    setState(() {});
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
      ),
    );
  }

  Widget _addRockToWishlistButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        await HapticFeedback.heavyImpact();
        Navigator.push(
          context,
          PageTransition(
            duration: const Duration(milliseconds: 400),
            child: const CameraPage(),
            type: PageTransitionType.bottomToTop,
          ),
        ).then(
          (_) async {
            await _store.loadLovedRocks();
            setState(() {});
          },
        );
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

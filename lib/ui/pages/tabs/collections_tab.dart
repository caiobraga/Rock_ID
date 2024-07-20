import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/pages/camera_page.dart';
import 'package:flutter_onboarding/ui/pages/page_services/home_page_service.dart';
import 'package:flutter_onboarding/ui/pages/rock_view_page.dart';
import 'package:flutter_onboarding/ui/pages/tabs/tab_services/collections_tab_service.dart';
import 'package:flutter_onboarding/ui/pages/widgets/rock_list_item.dart';
import 'package:page_transition/page_transition.dart';

class CollectionsTab extends StatefulWidget {
  const CollectionsTab({super.key});

  @override
  State<CollectionsTab> createState() => _CollectionsTabState();
}

class _CollectionsTabState extends State<CollectionsTab> {
  final _store = CollectionsTabService.instance;

  @override
  void initState() {
    super.initState();
    _store.loadCollectionRocks().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Rock>>(
      valueListenable: _store.collectionRocksNotifier,
      builder: (context, _collectionRocks, child) => Padding(
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
          child: Scaffold(
            backgroundColor: Constants.darkGrey,
            floatingActionButton: _collectionRocks.isEmpty
                ? Center(
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      onTap: () async {
                        await HapticFeedback.heavyImpact();
                        Navigator.push(
                          context,
                          PageTransition(
                            duration: const Duration(milliseconds: 400),
                            child: const CameraPage(),
                            type: PageTransitionType.bottomToTop,
                          ),
                        ).then((_) => _store
                            .loadCollectionRocks()
                            .then((_) => setState(() {})));
                      },
                      child: Ink(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: Constants.primaryDegrade,
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white,
                            size: 40,
                            weight: 40,
                            grade: 20),
                      ),
                    ),
                  )
                : null,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _collectionRocks.length,
                    cacheExtent: 2000,
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemBuilder: (context, index) {
                      final rock = _collectionRocks[index];
                      final imagePath = rock.rockImages.isNotEmpty
                          ? rock.rockImages.first.imagePath
                          : null;

                      Map<String, dynamic> rockDefaultImage = {
                        'img1': 'https://placehold.jp/60x60.png',
                      };

                      for (final defaultImage in Rock.defaultImages) {
                        if (defaultImage['rockId'] == rock.rockId) {
                          rockDefaultImage = defaultImage;
                        }
                      }

                      return RockListItem(
                        imagePath: imagePath,
                        imageUrl: rockDefaultImage['img1'],
                        title: rock.rockCustomName.isNotEmpty
                            ? rock.rockCustomName
                            : rock.rockName,
                        tags: const ['Sulfide minerals', 'Mar', 'Jul'],
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              child: RockViewPage(
                                rock: rock,
                                isRemovingFromCollection: true,
                              ),
                              type: PageTransitionType.bottomToTop,
                            ),
                          ).then((_) => _store
                              .loadCollectionRocks()
                              .then((_) => setState(() {})));
                        },
                        onDelete: () async {
                          try {
                            if (imagePath?.isNotEmpty == true) {
                              if (!(await DatabaseHelper()
                                      .imageExistsSnapHistory(imagePath!)) &&
                                  !(await DatabaseHelper()
                                      .imageExistsLoved(imagePath)) &&
                                  (Rock.rockList
                                      .where((defaultRock) =>
                                          defaultRock.rockId == rock.rockId)
                                      .isNotEmpty)) {
                                final file = File(imagePath);
                                await file.delete();
                              }
                            }
                            await DatabaseHelper().removeRock(rock);
                            await HomePageService.instance.notifyTotalValues();
                            await _store.loadCollectionRocks();
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
            ),
          ),
        ),
      ),
    );
  }
}

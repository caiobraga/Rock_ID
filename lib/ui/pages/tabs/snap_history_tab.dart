import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/pages/camera_page.dart';
import 'package:flutter_onboarding/ui/pages/rock_view_page.dart';
import 'package:flutter_onboarding/ui/pages/tabs/tab_services/snap_history_tab_service.dart';
import 'package:flutter_onboarding/ui/pages/widgets/rock_list_item.dart';
import 'package:flutter_onboarding/utils/string_utils.dart';
import 'package:page_transition/page_transition.dart';

class SnapHistoryTab extends StatefulWidget {
  const SnapHistoryTab({super.key});

  @override
  State<SnapHistoryTab> createState() => _SnapHistoryTabState();
}

class _SnapHistoryTabState extends State<SnapHistoryTab> {
  final _store = SnapHistoryTabService.instance;

  @override
  void initState() {
    _store.loadSnapHistory().then((_) => setState(() {}));
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
          valueListenable: _store.snapHistoryNotifier,
          builder: (context, _history, child) => Scaffold(
            backgroundColor: Constants.darkGrey,
            floatingActionButton: _history.isEmpty
                ? Center(
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      onTap: () async {
                        await HapticFeedback.heavyImpact();
                        await Navigator.push(
                          context,
                          PageTransition(
                            duration: const Duration(milliseconds: 400),
                            child: const CameraPage(),
                            type: PageTransitionType.bottomToTop,
                          ),
                        );
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
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<List<Rock>>(
                        valueListenable: _store.snapHistoryRocksNotifier,
                        builder: (context, _allRocks, child) =>
                            ListView.builder(
                          itemCount: _history.length,
                          cacheExtent: 2000,
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemBuilder: (context, index) {
                            final rockId = _history[index]['rockId'];
                            final imagePath =
                                _history[index]['scannedImagePath'];
                            final rock = _allRocks.firstWhere(
                                (rock) => rock.rockId == rockId,
                                orElse: () => Rock.empty());

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
                              tags: [
                                {
                                  'icon': Icons.category,
                                  'text': StringUtils.capitalizeFirstLetter(
                                    rock.category.isEmpty
                                        ? 'Unknown'
                                        : rock.category,
                                  ),
                                },
                                {
                                  'icon': Icons.color_lens,
                                  'text': StringUtils.capitalizeFirstLetter(
                                    rock.color.isEmpty ? 'Unknown' : rock.color,
                                  ),
                                },
                                {
                                  'icon': Icons.brightness_4,
                                  'text': StringUtils.capitalizeFirstLetter(
                                    rock.luster.isEmpty
                                        ? 'Unknown'
                                        : rock.luster,
                                  ),
                                },
                              ],
                              onTap: () async {
                                try {
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
                                        isRemovingFromCollection:
                                            isRemovingFromCollection,
                                        pickedImage: imagePath != null
                                            ? File(imagePath)
                                            : imagePath,
                                        isFromSnapHistory: true,
                                      ),
                                      type: PageTransitionType.bottomToTop,
                                    ),
                                  );
                                } catch (e) {
                                  debugPrint(e.toString());
                                }
                              },
                              onDelete: () async {
                                try {
                                  if (imagePath?.isNotEmpty == true) {
                                    if (!(await DatabaseHelper()
                                            .imageExistsCollection(
                                                imagePath)) &&
                                        !(await DatabaseHelper()
                                            .imageExistsLoved(imagePath)) &&
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
                                      .removeRockFromSnapHistory(rock.rockId);
                                  await _store.loadSnapHistory();
                                } catch (e) {
                                  debugPrint(e.toString());
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

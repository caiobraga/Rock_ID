import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/screens/camera_screen.dart';
import 'package:flutter_onboarding/ui/screens/detail_page.dart';
import 'package:flutter_onboarding/ui/screens/widgets/rock_list_item.dart';
import 'package:page_transition/page_transition.dart';

class SnapHistoryTab extends StatefulWidget {
  const SnapHistoryTab({super.key});

  @override
  State<SnapHistoryTab> createState() => _SnapHistoryTabState();
}

class _SnapHistoryTabState extends State<SnapHistoryTab> {
  final List<Map<String, dynamic>> _history = [];
  final List<Rock> _allRocks = [];

  @override
  void initState() {
    super.initState();
    _loadSnapHistory();
    _loadAllRocks();
  }

  void _loadSnapHistory() async {
    try {
      _history.clear();
      List<Map<String, dynamic>> snapHistory =
          await DatabaseHelper().snapHistory();
      setState(() {
        _history.addAll(snapHistory);
      });
    } catch (e) {
      debugPrint('$e');
    }
  }

  void _loadAllRocks() async {
    try {
      _allRocks.clear();
      final allDbRocks = await DatabaseHelper().findAllRocks();
      List<Rock> allRocks = Rock.rockList;
      List<Rock> allRocksWithImages = [];

      for (Rock rock in allRocks) {
        final dbRock = allDbRocks.firstWhere(
          (element) => element.rockId == rock.rockId,
          orElse: Rock.empty,
        );

        if (dbRock.rockId != 0) {
          rock = rock.copyWith(rockImages: dbRock.rockImages);
        }

        allRocksWithImages.add(rock);
      }

      setState(() {
        _allRocks.addAll(allRocksWithImages);
      });
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
        child: Scaffold(
          backgroundColor: Constants.darkGrey,
          floatingActionButton: _history.isEmpty
              ? Center(
                  child: FloatingActionButton(
                    backgroundColor: Constants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        PageTransition(
                          duration: const Duration(milliseconds: 400),
                          child: const CameraScreen(),
                          type: PageTransitionType.bottomToTop,
                        ),
                      );
                    },
                    child: Container(
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
                            grade: 20)),
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
                    child: ListView.builder(
                      itemCount: _history.length,
                      cacheExtent: 2000,
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemBuilder: (context, index) {
                        final rockId = _history[index]['rockId'];
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
                          imagePath: _history[index]['scannedImagePath'],
                          imageUrl: rockDefaultImage['img1'],
                          title: rock.rockName,
                          tags: const ['Sulfide minerals', 'Mar', 'Jul'],
                          onTap: () async {
                            bool isRemovingFromCollection = false;
                            final allRocks =
                                await DatabaseHelper().findAllRocks();
                            if (allRocks
                                .where((rockFromAll) =>
                                    rockFromAll.rockName == rock.rockName)
                                .isNotEmpty) {
                              isRemovingFromCollection = true;
                            }

                            Navigator.push(
                              context,
                              PageTransition(
                                child: RockDetailPage(
                                  rock: rock,
                                  isRemovingFromCollection:
                                      isRemovingFromCollection,
                                  pickedImage:
                                      File(_history[index]['scannedImagePath']),
                                ),
                                type: PageTransitionType.bottomToTop,
                              ),
                            );
                          },
                          onDelete: () async {
                            await DatabaseHelper()
                                .removeRockFromSnapHistory(rock.rockId);
                            _loadSnapHistory();
                          },
                        );
                      },
                    ),
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

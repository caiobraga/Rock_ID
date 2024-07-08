import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/ui/pages/camera_page.dart';
import 'package:flutter_onboarding/ui/pages/page_services/home_page_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';

import '../../services/bottom_nav_service.dart';
import 'select_rock_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  final _bottomNavService = BottomNavService.instance;
  final _store = HomePageService.instance;

  @override
  void initState() {
    _store.notifyTotalValues().then(
          (_) => setState(() {
            _isLoading = false;
          }),
        );
    super.initState();
  }

  void _filterRocks(String query) {
    setState(() {});
  }

  void _showRockSelectionModal() {
    Navigator.push(
      context,
      PageTransition(
        duration: const Duration(milliseconds: 400),
        child: const SelectRockPage(),
        type: PageTransitionType.bottomToTop,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.9,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Constants.darkGrey,
                            hintStyle: const TextStyle(color: Constants.white),
                            hintText: 'Search for rocks',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Constants.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          style: const TextStyle(color: Constants.white),
                          onTap: _showRockSelectionModal,
                          onChanged: (query) {
                            _filterRocks(query);
                            _showRockSelectionModal();
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                color: Constants.darkGrey,
                                borderRadius: BorderRadius.circular(41),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.string(AppIcons.share),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  const Text(
                                    'Share App',
                                    style: TextStyle(
                                      color: Constants.white,
                                      fontSize: 14,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _bottomNavService.setIndex(1);
                                  _bottomNavService.rockCollectionClicked();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  margin: const EdgeInsets.only(left: 20),
                                  decoration: BoxDecoration(
                                    color: Constants.darkGrey,
                                    borderRadius: BorderRadius.circular(41),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.string(AppIcons.folderSmall),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      const Text(
                                        'Rock Collection',
                                        style: TextStyle(
                                          color: Constants.white,
                                          fontSize: 14,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Constants.darkGrey,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    SvgPicture.string(AppIcons.rock,
                                        height: 22),
                                    const SizedBox(height: 5),
                                    ValueListenableBuilder<int>(
                                      valueListenable:
                                          _store.totalScannedRocksNotifier,
                                      builder:
                                          (context, totalScannedRocks, child) {
                                        return Text(
                                          totalScannedRocks.toString(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Constants.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                    Text('Rocks',
                                        style: TextStyle(
                                          color: Constants.white.withAlpha(100),
                                        )),
                                  ],
                                ),
                              ),
                              const VerticalDivider(
                                color: Constants.naturalGrey,
                                thickness: 1.2,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    SvgPicture.string(AppIcons.coins,
                                        height: 22),
                                    const SizedBox(height: 5),
                                    ValueListenableBuilder<String>(
                                      valueListenable: _store
                                          .totalRockCollectionPriceNotifier,
                                      builder: (context,
                                          totalRockCollectionPrice, child) {
                                        return Text(
                                          totalRockCollectionPrice,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Constants.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                    Text(
                                      'Value (USD)',
                                      style: TextStyle(
                                        color: Constants.white.withAlpha(100),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    PageTransition(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: const CameraPage(),
                                      type: PageTransitionType.bottomToTop,
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 226,
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 15, right: 10, left: 10),
                                  decoration: BoxDecoration(
                                    color: Constants.darkGrey,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'RECOGNIZE THE\nDETAILS OF\nA ROCK',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Constants.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Image.asset('assets/images/rocktap.png',
                                          height: 55),
                                      const SizedBox(height: 15),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 16),
                                        margin: const EdgeInsets.all(4.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Constants.primaryColor,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: const Text(
                                          'TAP HERE',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Constants.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    PageTransition(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: const CameraPage(
                                        isScanningForRockDetails: false,
                                      ),
                                      type: PageTransitionType.bottomToTop,
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 226,
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 15, right: 10, left: 10),
                                  decoration: BoxDecoration(
                                    color: Constants.darkGrey,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'RECOGNIZE THE\nVALUE OF\nA ROCK',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Constants.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Image.asset('assets/images/coinstap.png',
                                          height: 55),
                                      const SizedBox(height: 15),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 16),
                                        margin: const EdgeInsets.all(4.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Constants.primaryColor,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: const Text(
                                          'TAP HERE',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Constants.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
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
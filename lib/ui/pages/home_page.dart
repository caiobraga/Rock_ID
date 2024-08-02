import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/ui/pages/camera_page.dart';
import 'package:flutter_onboarding/ui/pages/page_services/home_page_service.dart';
import 'package:flutter_onboarding/ui/pages/widgets/loading_component.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';

import 'select_rock_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  final _store = HomePageService.instance;
  bool isSharing = false;

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

  void _showRockSelectionModal({final bool showKeyboard = true}) {
    Navigator.push(
      context,
      PageTransition(
        duration: const Duration(milliseconds: 400),
        child: SelectRockPage(showKeyboard: showKeyboard),
        type: PageTransitionType.bottomToTop,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const LoadingComponent()
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
                            InkWell(
                              borderRadius: BorderRadius.circular(41),
                              onTap: () async {
                                setState(() {
                                  isSharing = true;
                                });
                                if (Platform.isAndroid || Platform.isIOS) {
                                  final info = await PackageInfo.fromPlatform();
                                  final appId = info.packageName;
                                  final url = Platform.isAndroid
                                      ? "https://play.google.com/store/apps/details?id=$appId"
                                      : "https://apps.apple.com/app/id$appId";
                                  await Share.share(
                                      'Identify any rock instantly with AI! $url');
                                  setState(() {
                                    isSharing = false;
                                  });
                                }
                              },
                              child: Ink(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                decoration: BoxDecoration(
                                  color: Constants.darkGrey,
                                  borderRadius: BorderRadius.circular(41),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    !isSharing
                                        ? SvgPicture.string(AppIcons.share)
                                        : const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(
                                              color: Constants.primaryColor,
                                              strokeWidth: 2,
                                            ),
                                          ),
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
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(41),
                                onTap: () => _showRockSelectionModal(
                                    showKeyboard: false),
                                child: Ink(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
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
                                        'Explore Rocks',
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
                              child: InkWell(
                                onTap: () async {
                                  await HapticFeedback.heavyImpact();
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
                                borderRadius: BorderRadius.circular(20),
                                child: Ink(
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
                                        'RECOGNIZE THE\nDETAILS OF\nA ROCK OR A GEM',
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
                                      buildTapHere(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  await HapticFeedback.heavyImpact();
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
                                borderRadius: BorderRadius.circular(20),
                                child: Ink(
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
                                        'RECOGNIZE THE\nVALUE OF\nA ROCK OR A GEM',
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
                                      buildTapHere(),
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

  Widget buildTapHere() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Constants.primaryColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: const Text(
        'TAP HERE',
        style: TextStyle(
          fontSize: 16,
          color: Constants.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

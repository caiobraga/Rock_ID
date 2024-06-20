import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/ui/screens/select_rock_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';

import '../ui/scan_page.dart';

class ShowSelectionModalService {
  Future<void> show(
    BuildContext context, {
    bool isScanningForRockDetails = true,
  }) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Constants.darkGrey, // Cor de fundo do modal
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      child: const SelectRockPage(isSavingRock: true),
                      type: PageTransitionType.bottomToTop,
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.string(
                      AppIcons.search,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Search by name',
                      style: TextStyle(
                        color: Constants.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      child: ScanPage(
                        isScanningForRockDetails: isScanningForRockDetails,
                      ),
                      type: PageTransitionType.bottomToTop,
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.string(
                      AppIcons.photo,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Identify by photo',
                      style: TextStyle(
                        color: Constants.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

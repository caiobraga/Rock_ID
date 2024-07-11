import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/services/payment_service.dart';
import 'package:flutter_onboarding/ui/pages/page_services/premium_page_service.dart';
import 'package:flutter_onboarding/ui/pages/premium_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  bool isLoadingPurchase = false;
  final _paymentService = PaymentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.blackColor,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            onPageChanged: (int page) {
              setState(() {
                currentIndex = page;
              });
            },
            controller: _pageController,
            children: [
              const CreatePage(
                backgroundImage: 'assets/images/bg1.png',
                title: Constants.titleOne,
                description: Constants.descriptionOne,
              ),
              const CreatePage(
                backgroundImage: 'assets/images/bg2.png',
                title: Constants.titleTwo,
                description: Constants.descriptionTwo,
              ),
              const CreatePage(
                backgroundImage: 'assets/images/bg3.png',
                title: Constants.titleThree,
                description: Constants.descriptionThree,
              ),
              PremiumPage(isFromOnboarding: true),
            ],
          ),
          Positioned(
            bottom: 60,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  if (currentIndex < 3) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  } else {
                    setState(() {
                      isLoadingPurchase = true;
                    });
                    await _paymentService.configureSDK(
                      context,
                      PremiumPageService
                          .instance.isFreeTrialEnabledNotifier.value,
                    );
                    await _requestReview();
                    setState(() {
                      isLoadingPurchase = false;
                    });
                  }
                },
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Ink(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    gradient: Constants.darkDegrade,
                  ),
                  child: isLoadingPurchase
                      ? const Center(
                          child: SizedBox(
                            height: 26,
                            width: 26,
                            child: CircularProgressIndicator(
                              color: Constants.white,
                              strokeWidth: 3,
                            ),
                          ),
                        )
                      : const Text(
                          'Continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

Future<void> _requestReview() async {
  final storage = Storage.instance;
  final userHistory = jsonDecode((await storage.read(key: 'userHistory'))!);
  if (!userHistory['firstPaywallShown']) {
    userHistory['firstPaywallShown'] = true;
    storage.write(
      key: 'userHistory',
      value: jsonEncode(userHistory),
    );
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    }
  }
}

class CreatePage extends StatelessWidget {
  final String backgroundImage;
  final String title;
  final String description;

  const CreatePage({
    Key? key,
    required this.backgroundImage,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 110),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.bebasNeue(
              color: Constants.primaryColor,
              fontSize: 36,
            ),
          ),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}

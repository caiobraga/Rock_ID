import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/services/payment_service.dart';
import 'package:flutter_onboarding/services/review_service.dart';
import 'package:flutter_onboarding/ui/pages/page_services/premium_page_service.dart';
import 'package:flutter_onboarding/ui/pages/premium_page.dart';
import 'package:flutter_onboarding/ui/pages/terms_page.dart';
import 'package:flutter_onboarding/ui/root_page.dart';
import 'package:flutter_onboarding/ui/widgets/ds_custom_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

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
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(currentIndex == 3
              ? 'assets/images/premium_background.png'
              : 'assets/images/onbackground.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        persistentFooterButtons: [
          Column(
            children: [
              Material(
                color: Colors.transparent,
                child: Center(
                  child: InkWell(
                    onTap: () async {
                      await HapticFeedback.heavyImpact();
                      if (currentIndex < 3) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        );
                      } else {
                        setState(() {
                          isLoadingPurchase = true;
                        });
                        final response = await _paymentService.configureSDK(
                          context,
                          PremiumPageService
                              .instance.isFreeTrialEnabledNotifier.value,
                        );
                        if (response) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'You have successfully subscribed!',
                              ),
                            ),
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            PageTransition(
                              child: const RootPage(),
                              type: PageTransitionType.bottomToTop,
                            ),
                            (route) => false,
                          );
                        }
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
              ),
              currentIndex == 3
                  ? Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TermsPage(
                                    url:
                                        'https://sites.google.com/view/rock-app-policies/terms-of-service',
                                    title: 'Policies',
                                  ),
                                ),
                              );
                            },
                            child: const DSCustomText(
                              text: 'Terms of Use',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.naturalSilver,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.naturalSilver,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            '|',
                            style: TextStyle(
                              color: AppColors.naturalSilver,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TermsPage(
                                    url:
                                        'https://sites.google.com/view/rock-app-policies/privacy-policy?authuser=0',
                                    title: 'Policies',
                                  ),
                                ),
                              );
                            },
                            child: const DSCustomText(
                              text: 'Privacy Policy',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.naturalSilver,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.naturalSilver,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(height: 48),
            ],
          ),
        ],
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
              children: const [
                CreatePage(
                  onboardingImage: 'assets/images/onb1.png',
                  title: Constants.titleOne,
                  description: Constants.descriptionOne,
                ),
                CreatePage(
                  onboardingImage: 'assets/images/onb2.png',
                  title: Constants.titleTwo,
                  description: Constants.descriptionTwo,
                ),
                CreatePage(
                  onboardingImage: 'assets/images/onb3.png',
                  title: Constants.titleThree,
                  description: Constants.descriptionThree,
                ),
                PremiumPage(
                  isFromOnboarding: true,
                  showOwnButton: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _requestReview() async {
  final storage = Storage.instance;
  final userTraces = jsonDecode((await storage.read(key: 'userTraces'))!);
  if (!userTraces['firstPaywallShown']) {
    userTraces['firstPaywallShown'] = true;
    storage.write(
      key: 'userTraces',
      value: jsonEncode(userTraces),
    );
    await ReviewService.instance.getReview();
  }
}

class CreatePage extends StatelessWidget {
  final String onboardingImage;
  final String title;
  final String description;

  const CreatePage({
    Key? key,
    required this.onboardingImage,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                onboardingImage,
                height: MediaQuery.of(context).size.height * 0.6,
                alignment: Alignment.center,
              ),
            ),
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.bebasNeue(
                color: Constants.primaryColor,
                fontSize: 36,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}

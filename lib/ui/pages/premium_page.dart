import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/services/payment_service.dart';
import 'package:flutter_onboarding/ui/pages/page_services/premium_page_service.dart';
import 'package:flutter_onboarding/ui/pages/terms_page.dart';
import 'package:flutter_onboarding/ui/root_page.dart';
import 'package:flutter_onboarding/ui/widgets/text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:page_transition/page_transition.dart';

class PremiumPage extends StatefulWidget {
  final bool isFromOnboarding;
  final bool showOwnButton;

  const PremiumPage({
    super.key,
    this.isFromOnboarding = false,
    this.showOwnButton = false,
  });

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  bool isLoadingPurchase = false;

  final _paymentService = PaymentService();

  final _store = PremiumPageService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<bool>(
        valueListenable: _store.isFreeTrialEnabledNotifier,
        builder: (context, isFreeTrialEnabled, child) => Stack(
          alignment: Alignment.center,
          children: [
            Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 27),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/premium_background.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Constants.blackColor.withOpacity(0.2),
                      ),
                      onPressed: () async {
                        await _requestReview();
                        !widget.isFromOnboarding
                            ? Navigator.pop(context)
                            : await Navigator.pushAndRemoveUntil(
                                context,
                                PageTransition(
                                    child: const RootPage(),
                                    type: PageTransitionType.bottomToTop),
                                (route) => false,
                              );
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Constants.silver,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/videos/background.gif',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.39,
              left: 30,
              right: 30,
              child: Text(
                'AI Powered Rock Identification at your Fingertips',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  textStyle: const TextStyle(
                    color: Constants.primaryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.32,
              left: 20,
              right: 20,
              child: Image.asset('assets/images/premium_benefits.png'),
            ),
            Positioned(
              bottom: 185,
              child: Text.rich(
                TextSpan(
                  text: isFreeTrialEnabled ? '7 days free, then ' : 'Just ',
                  style: const TextStyle(
                    color: Constants.white,
                    fontSize: 18,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: isFreeTrialEnabled
                          ? '\$5.99/week'
                          : '\$39.99 per year',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Constants.white,
                        fontSize: 18,
                      ),
                    ),
                    const TextSpan(
                      text: '\nNo commitment. Cancel anytime',
                      style: TextStyle(
                        color: Constants.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Visibility(
              visible: !widget.isFromOnboarding || widget.showOwnButton,
              child: Positioned(
                bottom: 60,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
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
                        !widget.isFromOnboarding
                            ? Navigator.pop(context)
                            : Navigator.pushAndRemoveUntil(
                                context,
                                PageTransition(
                                    child: const RootPage(),
                                    type: PageTransitionType.bottomToTop),
                                (route) => false,
                              );

                        await _requestReview();
                      }
                      // await _requestReview();
                      setState(() {
                        isLoadingPurchase = false;
                      });
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
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.17,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const DSCustomText(
                    text: 'Enable free trial',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 24,
                    child: Switch(
                      activeColor: AppColors.naturalBlack,
                      activeTrackColor: AppColors.primaryMedium,
                      inactiveThumbColor: AppColors.white,
                      inactiveTrackColor: Colors.transparent,
                      value: isFreeTrialEnabled,
                      onChanged: (bool value) {
                        _store.setFreeTrial(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              child: Align(
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
              ),
            ),
          ],
        ),
      ),
    );
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
}

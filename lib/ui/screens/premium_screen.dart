import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/ui/root_page.dart';
import 'package:flutter_onboarding/ui/screens/terms_screen.dart';
import 'package:flutter_onboarding/ui/widgets/text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class PremiumScreen extends StatefulWidget {
  final bool showOwnButton;

  const PremiumScreen({
    super.key,
    this.showOwnButton = false,
  });

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool isFreeTrialEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 10),
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
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      PageTransition(
                          child: const RootPage(),
                          type: PageTransitionType.bottomToTop),
                      (route) => false,
                    ),
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
            top: 300,
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
            bottom: 280,
            left: 20,
            right: 20,
            child: Image.asset('assets/images/premium_benefits.png'),
          ),
          Positioned(
            bottom: 210,
            child: Text(
              '${isFreeTrialEnabled ? '3 days free, then \$5.98/week' : 'Just \$19.99 per year'}\nNo commitment. Cancel anytime',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Constants.white,
                fontSize: 16,
              ),
            ),
          ),
          Positioned(
            bottom: 160,
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
                      setState(() {
                        isFreeTrialEnabled = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: widget.showOwnButton,
            child: Positioned(
              bottom: 60,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
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
                    child: const Text(
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
                          builder: (context) => const TermsScreen(
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
                          builder: (context) => const TermsScreen(
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
    );
  }

  Widget isFreeTrialEnabledWidget() {
    return const SizedBox(
      height: 188,
      child: Column(
        children: [
          FeatureItem(
            title: 'No Payment',
            imagePath: 'ad-freeExperience.png',
            subTitle: 'now',
          ),
          DSCustomText(
            text: "TRY 3 DAYS FOR FREE, THEN \$4.99 PER WEEK",
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryMedium,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          DSCustomText(
            text: 'Auto-renewable. Cancel anytime.',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.white,
          ),
        ],
      ),
    );
  }

  Widget freeTrialNotEnabledWidget() {
    return const SizedBox(
      height: 188,
      child: Column(
        children: [
          DSCustomText(
            text: 'JUST \$24.99 PER YEAR',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryMedium,
          ),
          SizedBox(height: 4),
          DSCustomText(
            text: 'Auto-renewable. Cancel anytime.',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.white,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subTitle;
  const FeatureItem(
      {Key? key,
      required this.imagePath,
      required this.title,
      required this.subTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFB88F71),
              Color(0xFFA16132),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        height: 64,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 42,
                width: 42,
                child: Image(
                  image: AssetImage('assets/images/$imagePath'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSCustomText(
                      text: title,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.naturalBlack,
                    ),
                    DSCustomText(
                      text: subTitle,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.naturalBlack,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

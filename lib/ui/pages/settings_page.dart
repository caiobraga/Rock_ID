import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/services/review_service.dart';
import 'package:flutter_onboarding/ui/pages/terms_page.dart';
import 'package:flutter_onboarding/ui/pages/widgets/premium_section.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Constants.primaryColor,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            : null,
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Constants.primaryColor,
          ),
        ),
        backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0).copyWith(top: 0),
          child: Column(
            children: [
              const PremiumSection(),
              InkWell(
                borderRadius: BorderRadius.circular(12),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Constants.darkGrey,
                  ),
                  child: ListTile(
                    title: const Text(
                      'Share with Friends',
                      style: TextStyle(
                        color: Constants.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: !isSharing
                        ? SvgPicture.string(
                            AppIcons.share,
                            width: 24,
                            height: 24,
                          )
                        : const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Constants.grey,
                              strokeWidth: 3,
                            ),
                          ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final Email email = Email(
                    subject: 'Gem Identifier',
                    recipients: ['Zach@fulminareholdings.com'],
                    isHTML: false,
                  );

                  try {
                    await FlutterEmailSender.send(email);
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                },
                child: Ink(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Constants.darkGrey,
                  ),
                  child: ListTile(
                    title: const Text(
                      'Contact Us',
                      style: TextStyle(
                        color: Constants.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: SvgPicture.string(
                      AppIcons.baloon,
                      width: 24,
                      height: 24,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  await ReviewService.instance.getReview();
                },
                child: Ink(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Constants.darkGrey,
                  ),
                  child: const ListTile(
                    title: Text(
                      'Encourage Us',
                      style: TextStyle(
                        color: Constants.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: Icon(
                      Icons.favorite_border,
                      size: 24,
                      color: Constants.primaryColor,
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  await Navigator.push(
                    context,
                    PageTransition(
                      duration: const Duration(milliseconds: 300),
                      child: const TermsPage(
                        url:
                            'https://sites.google.com/view/rock-app-policies/privacy-policy?authuser=0',
                        title: 'Policies',
                      ),
                      type: PageTransitionType.bottomToTop,
                    ),
                  );
                },
                child: Ink(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Constants.darkGrey,
                  ),
                  child: ListTile(
                    title: const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: Constants.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: SvgPicture.string(
                      AppIcons.shield,
                      width: 24,
                      height: 24,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  await Navigator.push(
                    context,
                    PageTransition(
                      duration: const Duration(milliseconds: 300),
                      child: const TermsPage(
                        url:
                            'https://sites.google.com/view/rock-app-policies/terms-of-service',
                        title: 'Policies',
                      ),
                      type: PageTransitionType.bottomToTop,
                    ),
                  );
                },
                child: Ink(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Constants.darkGrey,
                  ),
                  child: ListTile(
                    title: const Text(
                      'Terms of Service',
                      style: TextStyle(
                        color: Constants.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: SvgPicture.string(
                      AppIcons.clipboard,
                      width: 24,
                      height: 24,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

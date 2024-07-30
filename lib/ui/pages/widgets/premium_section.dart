import 'package:flutter/material.dart';
import 'package:flutter_onboarding/ui/pages/page_services/root_page_service.dart';
import 'package:flutter_onboarding/ui/pages/premium_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants.dart';

class PremiumSection extends StatelessWidget {
  const PremiumSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !RootPageService.instance.isPremiumActivatedNotifier.value,
      child: Column(
        children: [
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PremiumPage(),
                ),
              );
            },
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    // B88F71
                    Color(0xFFB88F71),
                    // A16132
                    Color(0xFFA16132),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Ajuste o alinhamento vertical
                children: [
                  // Icon(Icons.star_border, color: AppCollors.naturalBlack, size: 40),
                  SvgPicture.string(
                    AppIcons.crownOnly,
                    color: AppColors.naturalBlack,
                    width: 40,
                  ),
                  const SizedBox(
                      width: 10), // Espaçamento entre o ícone e o texto
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Go ',
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                  color: AppColors.naturalBlack,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                'Premium',
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDarkest,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                            height: 5), // Espaçamento entre o botão e o texto
                        Text(
                          'Try Gem ID Premium for free',
                          style: GoogleFonts.montserrat(
                            textStyle: const TextStyle(
                              color: AppColors.naturalBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          'Claim your offer now',
                          style: GoogleFonts.montserrat(
                            textStyle: const TextStyle(
                              color: AppColors.naturalBlack,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

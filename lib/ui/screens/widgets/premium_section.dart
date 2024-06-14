import 'package:flutter/material.dart';
import 'package:flutter_onboarding/ui/screens/premium_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants.dart';

class PremiumSection extends StatelessWidget {
  const PremiumSection({Key? key}) : super(key: key);

  
    
      @override
      Widget build(BuildContext context) {
        return GestureDetector(
      onTap: (){
        Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
      },
      child: Container(
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
            Icon(Icons.star_border, color: AppCollors.naturalBlack, size: 40),
            const SizedBox(width: 10), // Espaçamento entre o ícone e o texto
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
                          textStyle: TextStyle(
                            color: AppCollors.naturalBlack,
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
                          color: AppCollors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          'Premium',
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppCollors.primaryDarkest,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                      height: 5), // Espaçamento entre o botão e o texto
                  Text(
                    'Try ROCKAPP Premium for free',
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        color: AppCollors.naturalBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    'Claim your offer now',
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        color: AppCollors.naturalBlack,
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
    );
      }
  }
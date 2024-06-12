import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/root_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../../db/db.dart';
import '../../services/snackbar.dart';

class RockDetailPage extends StatelessWidget {
  final Rock rock;
  final bool isSavingRock;

  const RockDetailPage(
      {Key? key, required this.rock, required this.isSavingRock})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Constants.primaryColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'BEST MATCHES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Constants.primaryColor,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          if (isSavingRock)
            IconButton(
              icon: Icon(
                Icons.save,
                color: Constants.primaryColor,
              ),
              onPressed: () => saveRock(context),
            ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.black,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Constants.darkGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/rock1.png',
                            height: 200,
                            width: 200,
                          ), // Placeholder image
                          Divider(
                            color: Constants.naturalGrey,
                            thickness: 1,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rock.rockName,
                                style: AppTypography.headline1(
                                    color: Constants.primaryColor),
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'a variety of ',
                                      style: AppTypography.body3(
                                          color: AppCollors.naturalSilver),
                                    ),
                                    TextSpan(
                                      text: rock.category,
                                      style: AppTypography.body3(
                                        color: AppCollors.primaryMedium,
                                        decoration: TextDecoration.underline,
                                        decorationColor:
                                            AppCollors.primaryMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildInfoSection('Formula', rock.formula),
                              _buildInfoSection(
                                  'Hardness', rock.hardness.toString()),
                              _buildInfoSection('Color', rock.color),
                              _buildInfoSection(
                                  'Magnetic',
                                  rock.isMagnetic
                                      ? 'Magnetic'
                                      : 'Non-magnetic'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildPremiumSection(),
                  SizedBox(height: 20),
                  _buildHealthRisksSection(),
                  SizedBox(height: 20),
                  _buildImagesSection(),
                  SizedBox(height: 20),
                  _buildLocationsSection(),
                  SizedBox(height: 20),
                  _buildFAQSection(),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: isSavingRock ? () => saveRock(context) : () => addToCollection(context),
                    icon: Icon(Icons.photo_camera, color: Constants.primaryColor),
                    label: Text(
                      isSavingRock ? 'Save' : 'Add to My Collection',
                      style: TextStyle(color: Constants.primaryColor),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Constants.darkGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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

  Widget _buildInfoSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.body3(color: AppCollors.white)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSection() {
    return Container(
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
                    SizedBox(
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
    );
  }

  Widget _buildHealthRisksSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Constants.darkGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HEALTH RISKS',
            style: TextStyle(
              color: Constants.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Quartz, silica, crystalline silica and flint are non-toxic materials, but very fine dust containing quartz, known as respirable crystalline silica (RCS), can cause serious and fatal lung diseases. '
            'Lapidaries should exercise caution when cutting silica.',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'IMAGES OF "${rock.rockName.toUpperCase()}"',
          style: TextStyle(
            color: Constants.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            _buildImageCard('Quartz', 'assets/images/emerald.png'),
            _buildImageCard('Quartz', 'assets/images/emerald2.png'),
          ],
        ),
      ],
    );
  }

  Widget _buildImageCard(String title, String assetPath) {
    return Expanded(
      child: Column(
        children: [
          Image.asset(assetPath, height: 100), // Placeholder image
          Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOCATIONS FOR "${rock.rockName.toUpperCase()}"',
          style: TextStyle(
            color: Constants.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        // Replace with actual map widgets or images
        Image.asset('assets/images/map.png', height: 150), // Placeholder image
      ],
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PEOPLE OFTEN ASK',
          style: TextStyle(
            color: Constants.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        _buildFAQItem('Is ${rock.rockName} valuable?'),
      ],
    );
  }

  Widget _buildFAQItem(String question) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Constants.darkGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        question,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void saveRock(BuildContext context) async {
    // Implement your save logic here
    try {
      await DatabaseHelper().insertRock(rock);
      ShowSnackbarService().showSnackBar('Rock Saved');
      Navigator.pushReplacement(
          context,
          PageTransition(
              child: const RootPage(),
              type: PageTransitionType.leftToRightWithFade));
    } catch (e) {
      ShowSnackbarService().showSnackBar('Error ${e}');
    }
  }

  void addToCollection(BuildContext context) {
    // Implement your add to collection logic here
    ShowSnackbarService().showSnackBar('Added to Collection');
  }
}

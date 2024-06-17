import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/root_page.dart';
import 'package:flutter_onboarding/ui/screens/widgets/expandable_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../../db/db.dart';
import '../../services/add_to_my_collection_modal.dart';
import '../../services/selection_modal.dart';
import '../../services/snackbar.dart';
import 'widgets/premium_section.dart';

class RockDetailPage extends StatefulWidget {
  final Rock rock;
  final bool isSavingRock;
  final bool? isFavoritingRock;
  final bool? showAddButton;

  const RockDetailPage({
    super.key,
    required this.rock,
    required this.isSavingRock,
    this.isFavoritingRock,
    this.showAddButton,
  });

  @override
  State<RockDetailPage> createState() => _RockDetailPageState();
}

class _RockDetailPageState extends State<RockDetailPage> {
  String buttonText = '';
  bool toFavoriteRock = false;
  bool toRemoveFromWishlist = false;

  @override
  void initState() {
    super.initState();
    DatabaseHelper().wishlist().then((wishlist) {
      setState(() {
        toFavoriteRock = widget.isFavoritingRock == true;
        for (final rockId in wishlist) {
          if (toFavoriteRock && widget.rock.rockId == rockId) {
            toRemoveFromWishlist = true;
          }
        }
        buttonText = widget.isSavingRock
            ? 'Save'
            : toRemoveFromWishlist
                ? 'Remove from Wishlist'
                : toFavoriteRock
                    ? 'Add to Wishlist'
                    : 'Add to My Collection';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Constants.primaryColor,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            : null,
        title: Text(
          'BEST MATCHES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Constants.primaryColor,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          if (widget.isSavingRock)
            IconButton(
              icon: Icon(
                Icons.save,
                color: Constants.primaryColor,
              ),
              onPressed: () => saveRock(context),
            ),
          if (widget.isFavoritingRock == true)
            IconButton(
              onPressed: () async {
                setState(() {
                  toRemoveFromWishlist
                      ? removeFromWishlist(context)
                      : addToWishlist(context);
                });
              },
              icon: Icon(
                toRemoveFromWishlist ? Icons.favorite : Icons.favorite_border,
                color: Constants.primaryColor,
              ),
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/rock1.png',
                              height: 175.75, width: 255, fit: BoxFit.cover),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Divider(
                              color: Constants.naturalGrey,
                              thickness: 1,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.rock.rockName,
                                style: AppTypography.headline1(
                                    color: Constants.primaryColor),
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'a variety of ',
                                      style: AppTypography.body3(
                                          color: AppColors.naturalSilver),
                                    ),
                                    TextSpan(
                                      text: widget.rock.category,
                                      style: AppTypography.body3(
                                        color: AppColors.primaryMedium,
                                        decoration: TextDecoration.underline,
                                        decorationColor:
                                            AppColors.primaryMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildInfoSection('Formula', widget.rock.formula),
                              _buildInfoSection(
                                  'Hardness', widget.rock.hardness.toString()),
                              _buildInfoSection('Color', widget.rock.color),
                              _buildInfoSection(
                                  'Magnetic',
                                  widget.rock.isMagnetic
                                      ? 'Magnetic'
                                      : 'Non-magnetic'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const PremiumSection(),
                  const SizedBox(height: 16),
                  _buildHealthRisksSection(),
                  const SizedBox(height: 16),
                  _buildImagesSection(),
                  // const SizedBox(height: 16),
                  // _buildLocationsSection(),
                  const SizedBox(height: 16),
                  _buildFAQSection(),
                  const SizedBox(height: 16),
                  _buildDescription(widget.rock.description),
                  const SizedBox(height: 16),
                  _buildIdentifySection(),
                  const SizedBox(height: 16),
                  const PremiumSection(),
                  const SizedBox(height: 16),
                  _buildPhysicalPropertiesSection(),
                  const SizedBox(height: 16),
                  _buildChemicalPropertiesSession(),
                  const SizedBox(height: 16),
                  _buildPriceSection(),
                  const SizedBox(height: 16),
                  _buildHealingSection(),
                  const SizedBox(height: 16),
                  _buildFormationSection(),
                  const SizedBox(height: 16),
                  _buildMeaningSection(),
                  const SizedBox(height: 16),
                  const PremiumSection(),
                  const SizedBox(height: 16),
                  _buildSelectSection(),
                  const SizedBox(height: 16),
                  _buildTypesSection(),
                  const SizedBox(height: 16),
                  _buildUsesSection(),
                  const SizedBox(height: 16),
                  const SizedBox(height: 80)
                ],
              ),
            ),
          ),
          Visibility(
            visible: widget.showAddButton != false,
            child: Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        ShowSelectionModalService().show(context);
                      },
                      child: SvgPicture.string(
                        AppIcons.camera,
                        color: Constants.primaryColor,
                        width: 50,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => widget.isSavingRock
                          ? saveRock(context)
                          : toRemoveFromWishlist
                              ? removeFromWishlist(context)
                              : toFavoriteRock
                                  ? addToWishlist(context)
                                  : addToCollection(context),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Constants.primaryColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              buttonText,
                              style: TextStyle(
                                  color: Constants.darkGrey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Info Section
  Widget _buildInfoSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              flex: 3,
              child: Text(title,
                  style: AppTypography.body3(color: AppColors.naturalWhite))),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                color: AppColors.naturalWhite,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              )),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHealthRisksSection() {
    return _buildCard(
        title: 'HEALTH RISKS',
        iconData: Icons.error_rounded,
        body: [
          Text(
            widget.rock.healthRisks,
            style: AppTypography.body3(color: AppColors.naturalWhite),
            textAlign: TextAlign.justify,
          )
        ]);
  }

  // Images Section
  Widget _buildImagesSection() {
    return _buildCard(
      title: 'IMAGES OF "${widget.rock.rockName.toUpperCase()}"',
      // iconData: Icons.image,
      icon: AppIcons.galery,
      body: [
        Row(
          children: [
            _buildImageCard(
                'Quartz', 'Color, Common', 'assets/images/rock1.png'),
            const SizedBox(width: 8),
            _buildImageCard(
                'Quartz', 'Morphology, common', 'assets/images/rock1.png'),
          ],
        ),
      ],
    );
  }

  Widget _buildImageCard(String title, String subtitle, String assetPath) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(43),
          border: Border.all(
            color: AppColors
                .naturalGrey, // Cor da borda, substitua por AppCollors.primaryColor
            width: 2, // Espessura da borda
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetPath,
              height: 45,
              width: 45,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                          color: AppColors.naturalWhite,
                          fontWeight: FontWeight.normal,
                          fontSize: 12),
                    ),
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                          color: AppColors.primaryMedium,
                          fontWeight: FontWeight.normal,
                          fontSize: 10),
                    ),
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Location Section
  Widget _buildLocationsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Constants.darkGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.image,
                  color: AppColors.primaryMedium,
                  size: 24.0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'LOCATIONS FOR "${widget.rock.rockName.toUpperCase()}"',
                  style: AppTypography.headline2(
                    color: AppColors.naturalWhite,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Divider(
              color: Constants.naturalGrey,
              thickness: 1,
            ),
          ),
          // Replace with actual map widgets or images
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8), // Define o border radius
              child: Image.asset(
                'assets/images/map.png',
                height: 265.96,
                width: 311,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FAQ Section
  Widget _buildFAQSection() {
    List<Widget> body = [];
    widget.rock.askedQuestions.forEach((Map<String, String> question) {
      question.forEach((key, value) {
        body.add(_buildFAQItem(key, value));
      });
    });
    return _buildCard(
        title: 'PEOPLE OFTEN ASK', icon: AppIcons.uncertainty, body: body);
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      // padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Constants.darkGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8), // Define o border radius
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.naturalGrey, // Cor de fundo quando colapsado
          ),
          child: ExpansionTile(
            title: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              title: Text(question,
                  style: AppTypography.body1(color: AppColors.primaryMedium)),
            ),
            iconColor: AppColors.primaryMedium,
            collapsedIconColor: AppColors.primaryMedium,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  answer,
                  style: AppTypography.body3(color: AppColors.naturalSilver),
                  textAlign: TextAlign.justify,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Description
  Widget _buildDescription(String description) {
    return _buildCard(
      title: 'DESCRIPTION',
      icon: AppIcons.description,
      body: [
        Text(
          description,
          style: AppTypography.body3(color: AppColors.naturalWhite),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  // Identify
  Widget _buildIdentifySection() {
    return _buildCard(
        title: "HOW TO IDENTIFY IT?",
        iconData: Icons.lightbulb_outline,
        body: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Color",
                  style: AppTypography.body2(color: AppColors.primaryMedium)),
              Text(widget.rock.color,
                  style: AppTypography.body3(color: AppColors.naturalSilver)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(8), // Define o border radius
                      child: Image.asset(
                        'assets/images/rocha-granito.jpg',
                        height: 103,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(8), // Define o border radius
                      child: Image.asset(
                        'assets/images/rocha-granito.jpg',
                        height: 103,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text("Luster",
                  style: AppTypography.body2(color: AppColors.primaryMedium)),
              Text(widget.rock.Luster,
                  style: AppTypography.body3(color: AppColors.naturalSilver)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(8), // Define o border radius
                child: Image.asset(
                  'assets/images/rocha-granito.jpg',
                  height: 182,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       "Learn More",
              //       style: AppTypography.body3(color: AppCollors.primaryMedium),
              //     ),
              //     const SizedBox(width: 4),
              //     Icon(
              //       Icons.expand_more,
              //       color: AppCollors.primaryMedium,
              //       size: 16,
              //     )
              //   ],
              // )
            ],
          )
        ]);
  }

  // Physical Properties
  Widget _buildPhysicalPropertiesSection() {
    return _buildCard(
        title: "PHYSICAL PROPERTIES",
        icon: AppIcons.calendarSearch,
        body: [
          _buildInfoSection('Crystal System', widget.rock.crystalSystem),
          _buildInfoSection('Colors', widget.rock.Colors.toString()),
          _buildInfoSection('Luster', widget.rock.Luster),
          _buildInfoSection('Diaphaneity', widget.rock.Diaphaneity),
        ]);
  }

  // Chemical Properties
  Widget _buildChemicalPropertiesSession() {
    return _buildCard(
      title: "CHEMICAL PROPERTIES",
      icon: AppIcons.chemical,
      body: [
        _buildInfoSection(
            'Chemical Classification', widget.rock.quimicalClassification),
        _buildInfoSection('Formula', widget.rock.formula),
        _buildInfoSection('Elements listed', widget.rock.elementsListed),
      ],
    );
  }

  // Price
  Widget _buildPriceSection() {
    return _buildCard(
      title: "PRICE",
      icon: AppIcons.price,
      body: [
        ExpandableText(
          text:
              'The price of ${widget.rock.rockName} may vary, but it is approximately ${widget.rock.price} per gram.',
          style: AppTypography.body3(color: AppColors.naturalWhite),
          maxLines:
              4, // Define o número máximo de linhas antes de exibir "Learn More"
        ),
      ],
    );
  }

  // Healing Properties
  Widget _buildHealingSection() {
    return _buildCard(
      title: "HEALING PROPERTIES",
      icon: AppIcons.heart,
      body: [
        ExpandableText(
          text: widget.rock.healingPropeties,
          style: AppTypography.body3(color: AppColors.naturalWhite),
          maxLines: 4,
        )
      ],
    );
  }

  // Formation
  Widget _buildFormationSection() {
    return _buildCard(
      title: "FORMATION",
      icon: AppIcons.formation,
      body: [
        ExpandableText(
          text: widget.rock.formulation,
          style: AppTypography.body3(color: AppColors.naturalWhite),
          maxLines: 4,
        ),
      ],
    );
  }

  // Meaning
  Widget _buildMeaningSection() {
    return _buildCard(
      title: "MEANING",
      icon: AppIcons.meaning,
      body: [
        ExpandableText(
            text: widget.rock.meaning,
            style: AppTypography.body3(color: AppColors.naturalWhite),
            maxLines: 4),
      ],
    );
  }

  // Select
  Widget _buildSelectSection() {
    return _buildCard(
      title: "HOW TO SELECT",
      icon: AppIcons.shoppingBasket,
      body: [
        ExpandableText(
          text: widget.rock.howToSelect,
          style: AppTypography.body3(color: AppColors.naturalWhite),
          maxLines: 4,
        ),
      ],
    );
  }

  // TYPES
  Widget _buildTypesSection() {
    return _buildCard(
      title: "TYPES",
      iconData: Icons.category,
      body: [
        ExpandableText(
          text: widget.rock.types,
          style: AppTypography.body3(color: AppColors.naturalWhite),
          maxLines: 4,
        ),
      ],
    );
  }

  // USES
  Widget _buildUsesSection() {
    return _buildCard(
      title: "USES",
      icon: AppIcons.monetization,
      body: [
        ExpandableText(
          text: widget.rock.uses,
          style: AppTypography.body3(color: AppColors.naturalWhite),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildCard(
      {required String title,
      IconData? iconData,
      required List<Widget> body,
      String? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Constants.darkGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (iconData != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    iconData,
                    color: AppColors.primaryMedium,
                    size: 24.0,
                  ),
                ),
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SvgPicture.string(
                    icon,
                    color: AppColors.primaryMedium,
                    width: 24,
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.headline2(
                    color: AppColors.naturalWhite,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Divider(
              color: Constants.naturalGrey,
              thickness: 1,
            ),
          ),
          ...body
        ],
      ),
    );
  }

  void saveRock(BuildContext context) async {
    // Implement your save logic here
    try {
      debugPrint('${widget.rock.toMap()}');
      await DatabaseHelper().insertRock(widget.rock);
      ShowSnackbarService().showSnackBar('Rock Saved');
      await Navigator.pushReplacement(
        context,
        PageTransition(
          child: const RootPage(),
          type: PageTransitionType.leftToRightWithFade,
        ),
      );
    } catch (e) {
      ShowSnackbarService().showSnackBar('Error $e');
    }
  }

  void addToCollection(BuildContext context) {
    // Implement your add to collection logic here
    AddToMyCollectionModalService().show(
      context,
      () {},
    );
    // ShowSnackbarService().showSnackBar('Added to Collection');
  }

  void addToWishlist(BuildContext context) async {
    try {
      await DatabaseHelper().addRockToWishlist(widget.rock.rockId);
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
            child: const RootPage(showFavorites: true),
            type: PageTransitionType.leftToRightWithFade),
        (route) => false,
      );
    } catch (e) {
      ShowSnackbarService().showSnackBar('Error $e');
    }
  }

  void removeFromWishlist(BuildContext context) async {
    try {
      await DatabaseHelper().removeRockFromWishlist(widget.rock.rockId);
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
            child: const RootPage(showFavorites: true),
            type: PageTransitionType.leftToRightWithFade),
        (route) => false,
      );
    } catch (e) {
      ShowSnackbarService().showSnackBar('Error $e');
    }
  }
}

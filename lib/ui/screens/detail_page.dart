import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/main.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/services/add_rock_to_collection_service.dart';
import 'package:flutter_onboarding/services/bottom_nav_service.dart';
import 'package:flutter_onboarding/services/image_picker.dart';
import 'package:flutter_onboarding/ui/root_page.dart';
import 'package:flutter_onboarding/ui/screens/widgets/expandable_text.dart';
import 'package:flutter_onboarding/ui/screens/widgets/input_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import '../../db/db.dart';
import '../../services/selection_modal.dart';
import '../../services/snackbar.dart';
import 'widgets/premium_section.dart';

class RockDetailPage extends StatefulWidget {
  final Rock rock;
  final bool isSavingRock;
  final bool isFavoritingRock;
  final bool isUnfavoritingRock;
  final bool showAddButton;
  final bool isRemovingFromCollection;
  final File? pickedImage;

  const RockDetailPage({
    super.key,
    required this.rock,
    required this.isSavingRock,
    this.isFavoritingRock = false,
    this.isUnfavoritingRock = false,
    this.showAddButton = true,
    this.isRemovingFromCollection = false,
    this.pickedImage,
  });

  @override
  State<RockDetailPage> createState() => _RockDetailPageState();
}

class _RockDetailPageState extends State<RockDetailPage> {
  String buttonText = '';
  bool _feedbackGiven = false;
  final _addRockToCollectionService = AddRockToCollectionService.instance;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    setState(() {
      _addRockToCollectionService.setRockData(widget.rock);
      buttonText = widget.isSavingRock
          ? 'Save'
          : widget.isUnfavoritingRock
              ? 'Remove from Wishlist'
              : widget.isFavoritingRock
                  ? 'Add to Wishlist'
                  : widget.isRemovingFromCollection
                      ? 'Remove from My Collection'
                      : 'Add to My Collection';
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: Text(
          widget.pickedImage == null ? 'BEST MATCHES' : 'ESTIMATED VALUE',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Constants.primaryColor,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          if (widget.isSavingRock && widget.pickedImage == null)
            IconButton(
              icon: const Icon(
                Icons.save,
                color: Constants.primaryColor,
              ),
              onPressed: () => saveRock(),
            ),
          if (widget.isFavoritingRock || widget.isUnfavoritingRock)
            IconButton(
              onPressed: () async {
                setState(() {
                  widget.isUnfavoritingRock
                      ? _removeFromWishlist()
                      : _addToWishlist();
                });
              },
              icon: Icon(
                widget.isUnfavoritingRock
                    ? Icons.favorite
                    : Icons.favorite_border,
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
                          widget.pickedImage == null
                              ? widget.rock.image != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(
                                        widget.rock.image!,
                                        fit: BoxFit.cover,
                                        height: 255,
                                      ),
                                    )
                                  : Image.asset('assets/images/rock1.png',
                                      height: 175.75,
                                      width: 255,
                                      fit: BoxFit.cover)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    widget.pickedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Divider(
                              color: Constants.naturalGrey,
                              thickness: 1,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.pickedImage != null)
                                ..._buildInfoSectionCost()
                              else
                                ..._buildInfoSectionRock(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.pickedImage == null) ..._buildDetailsAboutRock(),
                ],
              ),
            ),
          ),
          Visibility(
            visible:
                widget.pickedImage == null && widget.showAddButton != false,
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
                          ? saveRock()
                          : widget.isUnfavoritingRock
                              ? _removeFromWishlist()
                              : widget.isFavoritingRock
                                  ? _addToWishlist()
                                  : widget.isRemovingFromCollection
                                      ? _removeFromCollection()
                                      : _addToCollection(),
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
                              style: const TextStyle(
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
              textAlign: TextAlign.right,
              style: GoogleFonts.montserrat(
                  textStyle: const TextStyle(
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
                      textStyle: const TextStyle(
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
                      textStyle: const TextStyle(
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
              const Padding(
                padding: EdgeInsets.only(right: 8),
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
          const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 16),
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
          decoration: const BoxDecoration(
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
              Text(widget.rock.luster,
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
          _buildInfoSection('Colors', widget.rock.colors.toString()),
          _buildInfoSection('Luster', widget.rock.luster),
          _buildInfoSection('Diaphaneity', widget.rock.diaphaneity),
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
          const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 16),
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

  void saveRock() async {
    try {
      String timestamp = DateTime.now().toIso8601String();
      await DatabaseHelper().addRockToSnapHistory(
        widget.rock.rockId,
        timestamp,
        image: widget.rock.image,
      );

      ShowSnackbarService().showSnackBar('Rock Saved');
      await Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          child: const RootPage(),
          type: PageTransitionType.leftToRightWithFade,
        ),
        (route) => false,
      );
    } catch (e) {
      ShowSnackbarService().showSnackBar('Error $e');
    }
  }

  void _removeFromCollection() async {
    await DatabaseHelper().removeRock(widget.rock.rockName);
    Navigator.pushAndRemoveUntil(
      context,
      PageTransition(
          child: const RootPage(),
          type: PageTransitionType.leftToRightWithFade),
      (route) => false,
    );
    BottomNavService.instance.setIndex(1);
  }

  void _addToCollection() {
    _showAddRockToCollectionModal();
  }

  void _addToWishlist() async {
    try {
      await DatabaseHelper().addRockToWishlist(widget.rock.rockId);
      await Navigator.pushAndRemoveUntil(
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

  void _removeFromWishlist() async {
    try {
      await DatabaseHelper().removeRockFromWishlist(widget.rock.rockId);
      await Navigator.pushAndRemoveUntil(
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

  List<Widget> _buildInfoSectionRock() {
    return <Widget>[
      Text(
        widget.rock.rockName,
        style: AppTypography.headline1(color: Constants.primaryColor),
      ),
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'a variety of ',
              style: AppTypography.body3(color: AppColors.naturalSilver),
            ),
            TextSpan(
              text: widget.rock.category,
              style: AppTypography.body3(
                color: AppColors.primaryMedium,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primaryMedium,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _buildInfoSection('Formula', widget.rock.formula),
      _buildInfoSection('Hardness', widget.rock.hardness.toString()),
      _buildInfoSection('Color', widget.rock.color),
      _buildInfoSection(
          'Magnetic', widget.rock.isMagnetic ? 'Magnetic' : 'Non-magnetic'),
    ];
  }

  List<Widget> _buildDetailsAboutRock() {
    return <Widget>[
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
    ];
  }

  List<Widget> _buildInfoSectionCost() {
    return <Widget>[
      _buildInfoSection('Estimated value', '\$20'),
      _buildInfoSection('Possible price range', '\$13 ~ \$70'),
      Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Constants.lightestBrown,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Note',
              style: TextStyle(
                color: Constants.darkestBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'The estimated price shown above is for reference only. We recommend using our AI valuation tool for raw stones and tumbled stones.',
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: Color.fromRGBO(126, 78, 43, 1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      if (!_feedbackGiven)
        Column(
          children: [
            const SizedBox(height: 25),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Are you satisfied with the result?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Constants.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _feedbackGiven = true;
                    });
                    scaffoldMessengerKey.currentState?.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Thanks for your feedback!',
                          textAlign: TextAlign.center,
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.sentiment_satisfied_alt,
                  ),
                  label: const Text('Yes'),
                  style: TextButton.styleFrom(
                    foregroundColor: Constants.white,
                    side: const BorderSide(
                      width: 1,
                      color: Constants.silver,
                    ),
                    iconColor: Constants.lightestGreen,
                  ),
                ),
                const SizedBox(width: 20),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _feedbackGiven = true;
                    });
                    scaffoldMessengerKey.currentState?.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Thanks for your feedback!',
                          textAlign: TextAlign.center,
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  icon: const Icon(Icons.sentiment_dissatisfied_sharp),
                  label: const Text('No'),
                  style: TextButton.styleFrom(
                    foregroundColor: Constants.white,
                    side: const BorderSide(
                      width: 1,
                      color: Constants.silver,
                    ),
                    iconColor: Constants.lightestRed,
                  ),
                ),
              ],
            ),
          ],
        ),
    ];
  }

  void _showAddRockToCollectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).pop();
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.88,
              minChildSize: 0.88,
              maxChildSize: 0.88,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Stack(
                  children: [
                    SingleChildScrollView(
                      controller: scrollController,
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: const BoxDecoration(
                          color: Constants.darkGrey,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'COLLECTION DETAILS',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontSize: 28,
                                        ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Constants.primaryColor,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Container(
                                color: Constants.white,
                                height: 0.1,
                              ),
                              InputWidget(
                                controller: _addRockToCollectionService
                                    .numberController,
                                label: 'No.',
                                hintText: 'Tap to enter the number',
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '*Auto numbered: 3',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  Text(
                                    'Use this',
                                    style: TextStyle(
                                      color: Constants.primaryColor,
                                      fontSize: 14,
                                    ),
                                  )
                                ],
                              ),
                              InputWidget(
                                label: 'Name',
                                required: true,
                                controller:
                                    _addRockToCollectionService.nameController,
                                hintText: 'Tap to enter the name',
                                rightIcon: InkWell(
                                  onTap: () {
                                    _addRockToCollectionService.nameController
                                        .clear();
                                  },
                                  child: const Icon(
                                    Icons.clear,
                                    color: Constants.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Photos',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ValueListenableBuilder(
                                valueListenable:
                                    _addRockToCollectionService.imageNotifier,
                                builder: (context, value, child) => InkWell(
                                  onTap: () async {
                                    final _imageFile =
                                        await ImagePickerService()
                                            .pickImageFromGallery();
                                    final _image =
                                        await _imageFile?.readAsBytes();
                                    if (_image != null) {
                                      setState(() {
                                        _addRockToCollectionService
                                            .imageNotifier.value = _image;
                                      });
                                    }
                                  },
                                  child: widget.rock.image != null ||
                                          _addRockToCollectionService
                                                  .imageNotifier.value !=
                                              null ||
                                          widget.rock.imageURL.isNotEmpty
                                      ? Stack(
                                          children: [
                                            Container(
                                              height: 100,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                color: Constants.colorInput,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: widget.rock.image !=
                                                            null ||
                                                        (value as Uint8List?) !=
                                                            null
                                                    ? Image.memory(
                                                        value as Uint8List? ??
                                                            widget.rock.image!,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : widget.rock.imageURL
                                                            .isNotEmpty
                                                        ? Image.network(
                                                            widget
                                                                .rock.imageURL,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : null,
                                              ),
                                            ),
                                            const Positioned(
                                              right: 3,
                                              bottom: 3,
                                              child: Icon(
                                                Icons.image_search,
                                                color: Constants.white,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: Constants.colorInput,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Constants.primaryColor,
                                          ),
                                        ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: InputWidget(
                                      label: 'Acquisition',
                                      controller: _addRockToCollectionService
                                          .dateController,
                                      hintText: 'Date acquired',
                                      textInputType: TextInputType.datetime,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    child: InputWidget(
                                      label: '',
                                      controller: _addRockToCollectionService
                                          .costController,
                                      hintText: 'Cost',
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      onChanged: (value) {
                                        if (value.isEmpty) return;
                                        final formatter = NumberFormat.currency(
                                          symbol: '',
                                          decimalDigits: 0,
                                        );
                                        final formattedValue =
                                            formatter.format(double.tryParse(
                                                  value.replaceAll(
                                                    RegExp(r'[^\d.]'),
                                                    '',
                                                  ),
                                                ) ??
                                                0.0);
                                        _addRockToCollectionService
                                            .costController
                                            .value = TextEditingValue(
                                          text: formattedValue,
                                          selection: TextSelection.collapsed(
                                            offset: formattedValue.length,
                                          ),
                                        );
                                      },
                                      rightIcon: const Icon(
                                        Icons.attach_money_sharp,
                                        color: Constants.white,
                                        size: 20,
                                      ),
                                      textInputType: TextInputType.number,
                                    ),
                                    width: 150,
                                  ),
                                ],
                              ),
                              InputWidget(
                                label: 'Locality',
                                controller: _addRockToCollectionService
                                    .localityController,
                                hintText: 'Tap to enter',
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: InputWidget(
                                      label: 'Size',
                                      controller: _addRockToCollectionService
                                          .lengthController,
                                      hintText: 'Length',
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    height: 60,
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.close,
                                          size: 15,
                                          color: Constants.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: InputWidget(
                                      label: '',
                                      controller: _addRockToCollectionService
                                          .widthController,
                                      hintText: 'Width',
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    height: 60,
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.close,
                                          size: 15,
                                          color: Constants.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: InputWidget(
                                      labelFromWidget: Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(child: Container()),
                                            SizedBox(
                                              width: 70,
                                              child: ValueListenableBuilder(
                                                valueListenable:
                                                    _addRockToCollectionService
                                                        .unitOfMeasurementNotifier,
                                                builder: (context, type, _) {
                                                  return Container(
                                                    clipBehavior: Clip.hardEdge,
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              26),
                                                      color:
                                                          Constants.blackColor,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Expanded(
                                                          child: InkWell(
                                                            child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24),
                                                                color: _addRockToCollectionService
                                                                            .unitOfMeasurementNotifier
                                                                            .value ==
                                                                        'inch'
                                                                    ? Constants
                                                                        .naturalGrey
                                                                    : Constants
                                                                        .blackColor,
                                                              ),
                                                              child: Text(
                                                                'inch',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      Constants
                                                                          .white,
                                                                  fontWeight: _addRockToCollectionService
                                                                              .unitOfMeasurementNotifier
                                                                              .value ==
                                                                          'inch'
                                                                      ? FontWeight
                                                                          .w600
                                                                      : FontWeight
                                                                          .normal,
                                                                  fontSize: 11,
                                                                ),
                                                              ),
                                                            ),
                                                            onTap: _addRockToCollectionService
                                                                .toggleUnitOfMeasurement,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: InkWell(
                                                            child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(4),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              24),
                                                                  color: _addRockToCollectionService
                                                                              .unitOfMeasurementNotifier
                                                                              .value ==
                                                                          'cm'
                                                                      ? Constants
                                                                          .naturalGrey
                                                                      : Constants
                                                                          .blackColor,
                                                                ),
                                                                child: Text(
                                                                  'cm',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Constants
                                                                        .white,
                                                                    fontWeight: _addRockToCollectionService.unitOfMeasurementNotifier.value ==
                                                                            'cm'
                                                                        ? FontWeight
                                                                            .w600
                                                                        : FontWeight
                                                                            .normal,
                                                                    fontSize:
                                                                        11,
                                                                  ),
                                                                )),
                                                            onTap: _addRockToCollectionService
                                                                .toggleUnitOfMeasurement,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      controller: _addRockToCollectionService
                                          .heightController,
                                      hintText: 'Height',
                                    ),
                                  ),
                                ],
                              ),
                              InputWidget(
                                label: 'Notes',
                                controller:
                                    _addRockToCollectionService.notesController,
                                hintText: 'Tap to add your notes here...',
                                maxLines: 5,
                              ),
                              const SizedBox(
                                height: 45,
                              ), // Adicionado espaço para o botão "Save"
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Constants.darkGrey,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: InkWell(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                await _addRockToCollectionService
                                    .addRockToCollection(widget.rock);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  PageTransition(
                                      child: const RootPage(),
                                      type: PageTransitionType
                                          .leftToRightWithFade),
                                  (route) => false,
                                );
                                BottomNavService.instance.setIndex(1);
                              }
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 33,
                                    decoration: BoxDecoration(
                                      color: Constants.primaryColor,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: const Text(
                                      'Save',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Constants.blackColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

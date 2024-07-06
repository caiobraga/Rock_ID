import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/main.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/services/add_rock_to_collection_service.dart';
import 'package:flutter_onboarding/services/bottom_nav_service.dart';
import 'package:flutter_onboarding/services/image_picker.dart';
import 'package:flutter_onboarding/services/payment_service.dart';
import 'package:flutter_onboarding/ui/root_page.dart';
import 'package:flutter_onboarding/ui/screens/camera_screen.dart';
import 'package:flutter_onboarding/ui/screens/premium_screen.dart';
import 'package:flutter_onboarding/ui/screens/tabs/loved_tab.dart';
import 'package:flutter_onboarding/ui/screens/widgets/expandable_text.dart';
import 'package:flutter_onboarding/ui/screens/widgets/input_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../db/db.dart';
import '../../services/snackbar.dart';
import 'widgets/premium_section.dart';

class RockViewPage extends StatefulWidget {
  final Rock rock;
  final bool isFavoritingRock;
  final bool isUnfavoritingRock;
  final bool showAddButton;
  final bool isRemovingFromCollection;
  final bool isFromSnapHistory;
  final File? pickedImage;
  final Map<String, dynamic>? identifyPriceResponse;
  final bool isAddingFromRockList;

  const RockViewPage({
    super.key,
    required this.rock,
    this.isFavoritingRock = false,
    this.isUnfavoritingRock = false,
    this.showAddButton = true,
    this.isRemovingFromCollection = false,
    this.pickedImage,
    this.identifyPriceResponse,
    this.isAddingFromRockList = false,
    this.isFromSnapHistory = false,
  });

  @override
  State<RockViewPage> createState() => _RockViewPageState();
}

class _RockViewPageState extends State<RockViewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String buttonText = '';
  bool _feedbackGiven = false;
  final _addRockToCollectionService = AddRockToCollectionService.instance;
  final _formKey = GlobalKey<FormState>();
  bool isUnfavoritingRock = false;
  Map<String, dynamic> rockDefaultImage = {
    'img1': 'assets/images/rock1.png',
    'img2': 'assets/images/rock1.png',
    'cmi1': 'assets/images/rocha-granito.jpg',
    'cmi2': 'assets/images/rocha-granito.jpg',
    'cmi3': 'assets/images/rocha-granito.jpg',
  };
  bool costVisible = true;
  final _screenshotController = ScreenshotController();
  bool _isLoadingShare = false;
  bool _hideEditIcon = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    setState(() {
      defineFavorite();
      _addRockToCollectionService.setRockData(widget.rock, widget.pickedImage);
      buttonText = widget.isUnfavoritingRock
          ? 'Remove from Wishlist'
          : widget.isFavoritingRock
              ? 'Add to Wishlist'
              : widget.isRemovingFromCollection
                  ? 'Remove from My Collection'
                  : 'Add to My Collection';
      for (final defaultImage in Rock.defaultImages) {
        if (defaultImage['rockId'] == widget.rock.rockId) {
          rockDefaultImage = defaultImage;
        }
      }
    });
  }

  void defineFavorite() async {
    final wishlistRocksMap = await DatabaseHelper().wishlist();

    for (final wishlistRock in wishlistRocksMap) {
      if (wishlistRock['rockId'] == widget.rock.rockId) {
        setState(() {
          isUnfavoritingRock = true;
        });
        break;
      }
    }
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
          widget.identifyPriceResponse == null
              ? 'BEST MATCHES'
              : 'ESTIMATED VALUE',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Constants.primaryColor,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              isUnfavoritingRock
                  ? _removeFromWishlist()
                  : () {
                      _addToWishlist();
                      setState(() {
                        isUnfavoritingRock = !isUnfavoritingRock;
                      });
                    }();
            },
            icon: Icon(
              isUnfavoritingRock ? Icons.favorite : Icons.favorite_border,
              color: Constants.lightestRed,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          widget.isRemovingFromCollection && !widget.isFromSnapHistory
              ? Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Details'),
                        Tab(text: 'Info'),
                      ],
                      labelColor: Constants.primaryColor,
                      labelStyle:
                          AppTypography.body3(fontWeight: FontWeight.w500),
                      unselectedLabelColor: Colors.white,
                      unselectedLabelStyle:
                          AppTypography.body3(fontWeight: FontWeight.bold),
                      indicatorColor: Constants.primaryColor,
                      dividerHeight: 0,
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildDetailsTab(),
                          _buildInfoTab(),
                        ],
                      ),
                    ),
                  ],
                )
              : _buildInfoTab(),
          Visibility(
            visible: widget.identifyPriceResponse == null &&
                widget.showAddButton != false,
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
                      onTap: () async {
                        await Navigator.push(
                          context,
                          PageTransition(
                            duration: const Duration(milliseconds: 200),
                            child: const CameraScreen(),
                            type: PageTransitionType.bottomToTop,
                          ),
                        );
                      },
                      child: SvgPicture.string(
                        AppIcons.camera,
                        color: Constants.primaryColor,
                        width: 50,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => widget.isUnfavoritingRock
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

  Widget _buildDetailsTab() {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 0),
        child: FloatingActionButton(
          backgroundColor: Constants.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          onPressed: () async {
            try {
              setState(() {
                _isLoadingShare = true;
                _hideEditIcon = true;
              });

              final imageBytes = await _screenshotController.capture();
              if (imageBytes != null) {
                // Obtenha o diretório temporário
                final tempDir = await getTemporaryDirectory();
                final file = File('${tempDir.path}/screenshot.png');

                // Salve o arquivo no diretório temporário
                await file.writeAsBytes(imageBytes);

                // Crie o XFile a partir do caminho do arquivo
                final xFile = XFile(file.path);

                setState(() {
                  _isLoadingShare = false;
                  _hideEditIcon = false;
                });

                // Compartilhe o arquivo
                await Share.shareXFiles([xFile],
                    text: 'Take a look at my rock!');
                await file.delete();
              }
            } catch (e) {
              debugPrint('ERROR: $e');
            }
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: Constants.primaryDegrade,
            ),
            child: !_isLoadingShare
                ? const Icon(
                    Icons.share,
                    color: Constants.white,
                    size: 34,
                  )
                : const Padding(
                    padding: EdgeInsets.all(14.0),
                    child: CircularProgressIndicator(
                      color: Constants.white,
                    ),
                  ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Screenshot(
                controller: _screenshotController,
                child: Container(
                  decoration: BoxDecoration(
                    color: Constants.darkGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: widget.isRemovingFromCollection
                            ? _showAddRockToCollectionModal
                            : null,
                        child: Stack(
                          children: [
                            widget.rock.rockImages.isNotEmpty &&
                                        widget.rock.rockImages.first
                                                .imagePath !=
                                            null ||
                                    (_addRockToCollectionService
                                                .imageNotifier.value !=
                                            null &&
                                        _addRockToCollectionService
                                            .imageNotifier.value!.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(_addRockToCollectionService
                                              .imageNotifier.value ??
                                          widget.rock.rockImages.first
                                              .imagePath!),
                                      fit: BoxFit.cover,
                                      height: 200,
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  )
                                : _addRockToCollectionService
                                            .imageNotifier.value !=
                                        null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(_addRockToCollectionService
                                              .imageNotifier.value!),
                                          fit: BoxFit.cover,
                                          height: 200,
                                          width:
                                              MediaQuery.of(context).size.width,
                                        ),
                                      )
                                    : rockDefaultImage['img1']
                                            .startsWith('assets')
                                        ? Image.asset(
                                            rockDefaultImage['img1'],
                                            height: 200,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            fit: BoxFit.cover,
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.network(
                                              rockDefaultImage['img1'],
                                              height: 200,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress != null &&
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null &&
                                                    loadingProgress
                                                            .cumulativeBytesLoaded <
                                                        loadingProgress
                                                            .expectedTotalBytes!) {
                                                  return SizedBox(
                                                    height: 50,
                                                    width: 50,
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Constants
                                                            .primaryColor,
                                                        value: loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                (loadingProgress
                                                                        .expectedTotalBytes ??
                                                                    1)
                                                            : null,
                                                      ),
                                                    ),
                                                  );
                                                }

                                                return child;
                                              },
                                            ),
                                          ),
                            Visibility(
                              visible: widget.isRemovingFromCollection &&
                                  !_hideEditIcon,
                              child: Positioned(
                                top: 3,
                                right: 3,
                                width: 32,
                                height: 32,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Constants.naturalGrey,
                                  ),
                                  child: const Icon(
                                    Icons.edit_note,
                                    color: Constants.primaryColor,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                          if (widget.identifyPriceResponse != null)
                            ..._buildInfoSectionCost()
                          else
                            ..._buildDetailsSectionRock(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
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
                      widget.rock.rockImages.isNotEmpty &&
                                  widget.rock.rockImages.first.imagePath !=
                                      null ||
                              (_addRockToCollectionService
                                          .imageNotifier.value !=
                                      null &&
                                  _addRockToCollectionService
                                      .imageNotifier.value!.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_addRockToCollectionService
                                        .imageNotifier.value ??
                                    widget.rock.rockImages.first.imagePath!),
                                fit: BoxFit.cover,
                                height: 255,
                              ),
                            )
                          : rockDefaultImage['img1'].startsWith('assets')
                              ? Image.asset(rockDefaultImage['img1'],
                                  height: 175.75, width: 255, fit: BoxFit.cover)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    rockDefaultImage['img1'],
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress != null &&
                                          loadingProgress.expectedTotalBytes !=
                                              null &&
                                          loadingProgress
                                                  .cumulativeBytesLoaded <
                                              loadingProgress
                                                  .expectedTotalBytes!) {
                                        return SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: Constants.primaryColor,
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                              .expectedTotalBytes ??
                                                          1)
                                                  : null,
                                            ),
                                          ),
                                        );
                                      }

                                      return child;
                                    },
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
                          if (widget.identifyPriceResponse != null)
                            ..._buildInfoSectionCost()
                          else
                            ..._buildInfoSectionRock(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ..._buildDetailsAboutRock(),
        ],
      ),
    );
  }

  // Info Section
  Widget _buildInfoSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Text(title,
                style: AppTypography.body3(color: AppColors.naturalWhite)),
          ),
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
                ),
              ),
            ),
          ),
          Visibility(
            visible: title == 'Cost',
            child: InkWell(
              onTap: () => setState(() {
                costVisible = !costVisible;
              }),
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Icon(
                  costVisible ? Icons.visibility : Icons.visibility_off,
                  color: Constants.white,
                  size: 20,
                ),
              ),
            ),
          ),
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
            _buildImageCard(widget.rock.rockName, widget.rock.color,
                rockDefaultImage['img1']),
            const SizedBox(width: 8),
            _buildImageCard(widget.rock.rockName, widget.rock.luster,
                rockDefaultImage['img2']),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            assetPath.startsWith('assets')
                ? Image.asset(
                    assetPath,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(43),
                    child: Image.network(
                      assetPath,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress != null &&
                            loadingProgress.expectedTotalBytes != null &&
                            loadingProgress.cumulativeBytesLoaded <
                                loadingProgress.expectedTotalBytes!) {
                          return SizedBox(
                            height: 50,
                            width: 50,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Constants.primaryColor,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                              ),
                            ),
                          );
                        }

                        return child;
                      },
                    ),
                  ),
            const SizedBox(width: 8),
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
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                          color: AppColors.primaryMedium,
                          fontWeight: FontWeight.normal,
                          fontSize: 10),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
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
                      child: rockDefaultImage['cmi1'].startsWith('assets')
                          ? Image.asset(
                              rockDefaultImage['cmi1'],
                              height: 103,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              rockDefaultImage['cmi1'],
                              height: 103,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress != null &&
                                    loadingProgress.expectedTotalBytes !=
                                        null &&
                                    loadingProgress.cumulativeBytesLoaded <
                                        loadingProgress.expectedTotalBytes!) {
                                  return SizedBox(
                                    height: 103,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                      color: Constants.primaryColor,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                    )),
                                  );
                                }

                                return child;
                              },
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(8), // Define o border radius
                      child: rockDefaultImage['cmi2'].startsWith('assets')
                          ? Image.asset(
                              rockDefaultImage['cmi2'],
                              height: 103,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              rockDefaultImage['cmi2'],
                              height: 103,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress != null &&
                                    loadingProgress.expectedTotalBytes !=
                                        null &&
                                    loadingProgress.cumulativeBytesLoaded <
                                        loadingProgress.expectedTotalBytes!) {
                                  return SizedBox(
                                    height: 103,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                      color: Constants.primaryColor,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                    )),
                                  );
                                }

                                return child;
                              },
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
                child: rockDefaultImage['cmi3'].startsWith('assets')
                    ? Image.asset(
                        rockDefaultImage['cmi3'],
                        height: 182,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        rockDefaultImage['cmi3'],
                        height: 182,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress != null &&
                              loadingProgress.expectedTotalBytes != null &&
                              loadingProgress.cumulativeBytesLoaded <
                                  loadingProgress.expectedTotalBytes!) {
                            return SizedBox(
                              height: 182,
                              child: Center(
                                child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                    color: Constants.primaryColor),
                              ),
                            );
                          }

                          return child;
                        },
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

  void _removeFromCollection() async {
    _showDeleteConfirmationDialog(isRemovingFromLoved: false);
  }

  void _addToCollection() {
    _showAddRockToCollectionModal();
  }

  void _addToWishlist() async {
    try {
      await DatabaseHelper().addRockToWishlist(
        widget.rock.rockId,
        widget.rock.rockImages.isNotEmpty
            ? widget.rock.rockImages.first.imagePath
            : widget.pickedImage?.path,
      );
      if (widget.isFavoritingRock) {
        await Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
              child: const RootPage(showFavorites: true),
              type: PageTransitionType.leftToRightWithFade),
          (route) => false,
        );
      } else {
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Rock added to Loved!'),
            duration: Duration(seconds: 1),
          ),
        );
      }
      LovedTabState().wishlistNotifier.value++;
      LovedTabState().loadWishlist();
      setState(() {});
    } catch (e) {
      ShowSnackbarService().showSnackBar('Error $e');
    }
  }

  void _removeFromWishlist() {
    _showDeleteConfirmationDialog();
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
      _buildInfoSection(
          'Hardness',
          widget.rock.hardness == 0
              ? "The hardness on this rock may vary"
              : widget.rock.hardness.toString()),
      _buildInfoSection('Color', widget.rock.color),
      _buildInfoSection(
          'Magnetic', widget.rock.isMagnetic ? 'Magnetic' : 'Non-magnetic'),
    ];
  }

  List<Widget> _buildDetailsSectionRock() {
    return <Widget>[
      Text(
        widget.rock.rockName,
        style: AppTypography.headline1(color: Constants.primaryColor),
      ),
      const SizedBox(height: 16),
      _buildInfoSection(
          'Cost',
          costVisible
              ? '\$${_addRockToCollectionService.costController.text}'
              : '\$****'),
      _buildInfoSection('Size',
          '${_addRockToCollectionService.lengthController.text} x ${_addRockToCollectionService.widthController.text} x ${_addRockToCollectionService.heightController.text} ${_addRockToCollectionService.unitOfMeasurementNotifier.value == 'inch' ? 'inches' : 'cm'}'),
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
      const SizedBox(height: 80),
    ];
  }

  List<Widget> _buildInfoSectionCost() {
    return <Widget>[
      _buildInfoSection('Estimated value',
          '\$${widget.identifyPriceResponse!['price'].toString()}'),
      _buildInfoSection('Possible price range',
          '\$${widget.identifyPriceResponse!['price_range']['min'].toString()} ~ \$${widget.identifyPriceResponse!['price_range']['max'].toString()}'),
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.88,
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Constants.darkGrey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ROCK DETAILS',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
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
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              ValueListenableBuilder<String?>(
                                valueListenable:
                                    _addRockToCollectionService.imageNotifier,
                                builder: (context, value, child) => InkWell(
                                    onTap: () async {
                                      final _imageFile =
                                          await ImagePickerService()
                                              .pickImageFromGallery(context);
                                      if (_imageFile != null) {
                                        setState(() {
                                          _addRockToCollectionService
                                              .imageNotifier
                                              .value = _imageFile.path;
                                        });
                                      }
                                    },
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        widget.rock.rockImages.isNotEmpty &&
                                                    widget.rock.rockImages.first
                                                            .imagePath !=
                                                        null ||
                                                _addRockToCollectionService
                                                        .imageNotifier.value !=
                                                    null ||
                                                widget.rock.imageURL.isNotEmpty
                                            ? Container(
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
                                                  child: widget.rock.rockImages
                                                                  .isNotEmpty &&
                                                              widget
                                                                      .rock
                                                                      .rockImages
                                                                      .first
                                                                      .imagePath !=
                                                                  null ||
                                                          value != null
                                                      ? Image.file(
                                                          File(
                                                            value ??
                                                                widget
                                                                    .rock
                                                                    .rockImages
                                                                    .first
                                                                    .imagePath!,
                                                          ),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : widget.rock.imageURL
                                                              .isNotEmpty
                                                          ? Image.network(
                                                              widget.rock
                                                                  .imageURL,
                                                              fit: BoxFit.cover,
                                                              loadingBuilder:
                                                                  (context,
                                                                      child,
                                                                      loadingProgress) {
                                                                if (loadingProgress != null &&
                                                                    loadingProgress
                                                                            .expectedTotalBytes !=
                                                                        null &&
                                                                    loadingProgress
                                                                            .cumulativeBytesLoaded <
                                                                        loadingProgress
                                                                            .expectedTotalBytes!) {
                                                                  return Center(
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                    color: Constants
                                                                        .primaryColor,
                                                                    value: loadingProgress.expectedTotalBytes !=
                                                                            null
                                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                                            (loadingProgress.expectedTotalBytes ??
                                                                                1)
                                                                        : null,
                                                                  ));
                                                                }

                                                                return child;
                                                              },
                                                            )
                                                          : null,
                                                ),
                                              )
                                            : Container(
                                                height: 100,
                                                width: 100,
                                                clipBehavior: Clip.hardEdge,
                                                decoration: BoxDecoration(
                                                  color: Constants.colorInput,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Image.network(
                                                  rockDefaultImage['img1']
                                                          .startsWith('assets')
                                                      ? 'https://placehold.jp/100x100.png'
                                                      : rockDefaultImage[
                                                          'img1'],
                                                  fit: BoxFit.cover,
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
                                        Visibility(
                                          visible: _addRockToCollectionService
                                                  .imageNotifier.value !=
                                              null,
                                          child: Positioned(
                                            top: -5,
                                            right: -5,
                                            width: 22,
                                            height: 22,
                                            child: IconButton(
                                              icon: const Icon(Icons.close),
                                              style: IconButton.styleFrom(
                                                  foregroundColor:
                                                      Constants.darkGrey,
                                                  backgroundColor:
                                                      Constants.lightestRed),
                                              iconSize: 20,
                                              padding: const EdgeInsets.all(0),
                                              onPressed: () {
                                                setState(() {
                                                  _addRockToCollectionService
                                                      .imageNotifier
                                                      .value = null;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                        FilteringTextInputFormatter.digitsOnly,
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
                                      maxLength: 13,
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
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      textInputType: TextInputType.number,
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
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      textInputType: TextInputType.number,
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
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      hintText: 'Height',
                                      textInputType: TextInputType.number,
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
                              ), // Adicionado espaço para o botão "Save"
                              const SizedBox(
                                height: 70,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: MediaQuery.of(context).viewInsets.bottom < 1,
                  child: Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () async {
                        final numberOfRocksSaved =
                            (await DatabaseHelper().getNumberOfRocksSaved()) ??
                                0;
                        if (numberOfRocksSaved >= 3 &&
                            !(await PaymentService.checkIfPurchased())) {
                          await Navigator.push(
                            context,
                            PageTransition(
                              duration: const Duration(milliseconds: 300),
                              child: const PremiumScreen(),
                              type: PageTransitionType.bottomToTop,
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          if (_formKey.currentState!.validate()) {
                            await _addRockToCollectionService
                                .addRockToCollection(widget.rock);
                            if (!widget.isRemovingFromCollection) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                PageTransition(
                                    child: const RootPage(),
                                    type:
                                        PageTransitionType.leftToRightWithFade),
                                (route) => false,
                              );
                              BottomNavService.instance.setIndex(1);
                            } else {
                              scaffoldMessengerKey.currentState?.showSnackBar(
                                const SnackBar(
                                  content: Text('Rock edited successfuly!'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          }
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 50,
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
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog({final bool isRemovingFromLoved = true}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.blackColor,
          surfaceTintColor: Colors.transparent,
          title: Text(
            isRemovingFromLoved
                ? 'Removing rock from loved'
                : 'Removing rock from collection',
            style: const TextStyle(color: Constants.lightestRed),
          ),
          content: Text(
            'Are you sure you want to remove the rock from ${isRemovingFromLoved ? 'loved' : 'collection'}?',
            style: const TextStyle(color: Constants.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Constants.darkGrey,
                backgroundColor: Constants.primaryColor,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  if (isRemovingFromLoved) {
                    final imagePath = widget.rock.rockImages.isNotEmpty
                        ? widget.rock.rockImages.first.imagePath
                        : null;
                    if (imagePath?.isNotEmpty == true) {
                      if (!(await DatabaseHelper()
                              .imageExistsCollection(imagePath!)) &&
                          !(await DatabaseHelper()
                              .imageExistsSnapHistory(imagePath))) {
                        final file = File(imagePath);
                        await file.delete();
                      }
                    }
                    await DatabaseHelper()
                        .removeRockFromWishlist(widget.rock.rockId);
                    if (widget.isUnfavoritingRock) {
                      await Navigator.pushAndRemoveUntil(
                        context,
                        PageTransition(
                            child: const RootPage(showFavorites: true),
                            type: PageTransitionType.leftToRightWithFade),
                        (route) => false,
                      );
                    } else {
                      setState(() {
                        isUnfavoritingRock = !isUnfavoritingRock;
                      });
                      scaffoldMessengerKey.currentState?.showSnackBar(
                        const SnackBar(
                          content: Text('Rock removed from Loved.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      Navigator.pop(context);
                    }
                    LovedTabState().wishlistNotifier.value++;
                    setState(() {});
                  } else {
                    await DatabaseHelper().removeRock(widget.rock.rockId);

                    for (final rockImage in widget.rock.rockImages) {
                      if (!(await DatabaseHelper()
                              .imageExistsLoved(rockImage.imagePath!)) &&
                          !(await DatabaseHelper()
                              .imageExistsSnapHistory(rockImage.imagePath!))) {
                        final file = File(rockImage.imagePath!);
                        await file.delete();
                      }
                    }

                    Navigator.pushAndRemoveUntil(
                      context,
                      PageTransition(
                          child: const RootPage(),
                          type: PageTransitionType.leftToRightWithFade),
                      (route) => false,
                    );
                    BottomNavService.instance.setIndex(1);
                  }
                } catch (e) {
                  ShowSnackbarService().showSnackBar('Error $e');
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Constants.lightestRed,
              ),
              child: const Text('Remove rock'),
            ),
          ],
        );
      },
    );
  }
}

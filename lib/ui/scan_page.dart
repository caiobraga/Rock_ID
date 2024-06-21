import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/services/get_rock.dart';
import 'package:flutter_onboarding/services/image_picker.dart';
import 'package:flutter_onboarding/ui/screens/detail_page.dart';
import 'package:flutter_onboarding/ui/screens/widgets/loading_component.dart';
import 'package:page_transition/page_transition.dart';

import '../db/db.dart';
import 'root_page.dart';

class ScanPage extends StatefulWidget {
  final bool isScanningForRockDetails;

  const ScanPage({
    Key? key,
    required this.isScanningForRockDetails,
  }) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  Rock? _rock;
  File? _image;
  bool _isLoading = false;
  int _loadingPercentage = 0;
  String? _errorMessage;

  final ValueNotifier<int> _loadingNotifier = ValueNotifier<int>(0);

  String _chosenRockForm = '';
  String _chosenImagePath = '';
  final List<Map<String, dynamic>> _rockForms = [
    {
      'icon': Icons.category,
      'text': 'Ornament (e.g tumbled, tower, sphere)',
    },
    {
      'icon': Icons.landscape,
      'text': 'Raw (e.g rough, geode, cluster)',
    },
    {
      'icon': Icons.circle,
      'text': 'Loose gemstone (e.g faceted, cabochon)',
    },
    {
      'icon': Icons.local_mall,
      'text': 'Jewelry (e.g pendant, bracelet)',
    },
  ];

  Future<void> _showImageSourceActionSheet(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          decoration: const BoxDecoration(
            color: Constants.darkGrey, // Cor de fundo do modal
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: Constants.silver,
                ),
                title: const Text(
                  'Take a photo',
                  style: TextStyle(
                    color: Constants.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  _image =
                      await ImagePickerService().pickImageFromCamera(context);
                  _startScanning(addToSnap, navigator);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Constants.silver,
                ),
                title: const Text(
                  'Pick from gallery',
                  style: TextStyle(
                    color: Constants.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  _image = await ImagePickerService().pickImageFromGallery();
                  _startScanning(addToSnap, navigator);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> addToSnap() async {
    _rock = await GetRockService().getRock(_image);
    String timestamp = DateTime.now().toIso8601String();
    if (_rock != null) {
      await DatabaseHelper().addRockToSnapHistory(_rock!.rockId, timestamp);
    }
  }

  void _showLoadingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(15),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Constants.darkGrey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: _loadingNotifier,
                builder: (context, value, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (_isLoading)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Identifying $_loadingPercentage%',
                                  style: const TextStyle(
                                    color: Constants.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (_image != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    clipBehavior: Clip.hardEdge,
                                    child: Image.file(
                                      File(_image!.path),
                                      fit: BoxFit.cover,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              2,
                                    ),
                                  )
                                else
                                  const LoadingComponent(),
                              ],
                            ),
                          ),
                        ),
                      if (_errorMessage != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildErrorImageRow(
                                Icons.verified,
                                Constants.mediumGreen,
                                'assets/images/prefectImage.png',
                                'This is a good Exemple',
                                Constants.lightestGreen,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'The following will lead to poor results',
                                style: TextStyle(
                                  color: Constants.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildErrorImageRow(
                                Icons.close,
                                Constants.mediumRed,
                                'assets/images/smal_stone.png',
                                'Too far',
                                Constants.lightestRed,
                                assetPath2: 'assets/images/blurred.jpg',
                                label2: 'Image blurred',
                              ),
                              const SizedBox(height: 10),
                              _buildErrorImageRow(
                                Icons.close,
                                Constants.mediumRed,
                                'assets/images/varias_rochas.png',
                                'Too many',
                                Constants.lightestRed,
                                assetPath2: 'assets/images/too_dark.png',
                                label2: 'Too dark',
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 10),
                                  margin: const EdgeInsets.only(top: 10),
                                  decoration: BoxDecoration(
                                    color: Constants.primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 30, // Size of the icon
                                        color: Constants
                                            .darkGrey, // Color of the icon
                                      ),
                                      SizedBox(
                                          width:
                                              10), // Space between icon and text
                                      Text(
                                        'Retake',
                                        style: TextStyle(
                                          fontSize: 18, // Size of the text
                                          color: Constants
                                              .darkGrey, // Color of the text,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorImageRow(
    IconData icon,
    Color color,
    String assetPath1,
    String label1,
    Color labelColor, {
    String? assetPath2,
    String? label2,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
            child:
                _buildErrorImage(assetPath1, label1, icon, color, labelColor)),
        if (assetPath2 != null && label2 != null)
          Expanded(
              child: _buildErrorImage(
                  assetPath2, label2, icon, color, labelColor)),
      ],
    );
  }

  Widget _buildErrorImage(String assetPath, String label, IconData icon,
      Color color, Color labelColor) {
    return Column(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                assetPath,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Positioned(
              right: 3,
              top: 3,
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _startScanning(Future<void> Function() scanningFunction,
      NavigatorState navigator) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _loadingNotifier.value = 0;
    _startLoading();
    _showLoadingBottomSheet(context);
    try {
      await scanningFunction();
      if (_rock != null) {
        if (widget.isScanningForRockDetails) {
          _showRockDetails(navigator);
          return;
        }

        Navigator.pop(context);
        _showSelectRockDetailsBottomSheet();
      }
    } catch (e) {
      debugPrint('$e');
      setState(() {
        _errorMessage = e.toString().substring(11);
        _isLoading = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
        _loadingPercentage = 0;
      });
    }
  }

  void _startLoading() {
    Timer.periodic(const Duration(milliseconds: 200), (Timer timer) {
      if (_loadingPercentage >= 99) {
        timer.cancel();
      } else {
        _loadingPercentage += 1;
        _loadingNotifier.value = _loadingPercentage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () async {
        _showImageSourceActionSheet(context);
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Constants.primaryColor.withOpacity(.15),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Constants.primaryColor,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Constants.primaryColor.withOpacity(.15),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.share,
                          color: Constants.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 100,
              right: 20,
              left: 20,
              child: Container(
                width: size.width * .8,
                height: size.height * .8,
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/code-scan.png',
                          height: 100,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Tap to Scan',
                          style: TextStyle(
                            color: Constants.primaryColor.withOpacity(.80),
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSelectRockDetailsBottomSheet() {
    bool _isChoosingRockForm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(33, 37, 40, 1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Text(
                                  'Tell us a bit more about your stone for improved valuation accuracy.',
                                  style: TextStyle(
                                    color: Constants.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              }, //to login screen. We will update later
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  color: Constants.silver,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          _isChoosingRockForm
                              ? "What's the form of your stone?"
                              : "What's the size of your stone? (Choose the closest one)",
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            color: Constants.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _isChoosingRockForm
                            ? Column(
                                children: _rockForms.map((form) {
                                  return Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _chosenRockForm = form['text'];
                                            _isChoosingRockForm = false;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 20),
                                          decoration: BoxDecoration(
                                            color: Constants.blackColor,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                form['icon'],
                                                color: Constants.primaryColor,
                                              ),
                                              const SizedBox(width: 15),
                                              Expanded(
                                                child: Text(
                                                  form['text'],
                                                  style: const TextStyle(
                                                    color: Constants.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  );
                                }).toList(),
                              )
                            : Expanded(
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 15,
                                    mainAxisSpacing: 15,
                                    childAspectRatio: 1.38,
                                  ),
                                  itemCount: 4,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    List<String> imagePaths = [
                                      'assets/images/small_rock.png',
                                      'assets/images/medium_rock.png',
                                      'assets/images/big_rock.png',
                                      'assets/images/bigger_rock.png'
                                    ];

                                    return InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        setState(() {
                                          _chosenImagePath = imagePaths[index];
                                          _showRockDetails(
                                            Navigator.of(context),
                                          );
                                        });
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.asset(imagePaths[index],
                                            fit: BoxFit.contain),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRockDetails(NavigatorState navigator) {
    navigator
        .push(PageTransition(
            child: RockDetailPage(rock: _rock!, isSavingRock: true),
            type: PageTransitionType.fade))
        .then((value) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RootPage()),
        (route) => false,
      );
    });
  }
}

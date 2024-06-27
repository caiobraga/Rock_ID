import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/services/get_rock.dart';
import 'package:flutter_onboarding/ui/root_page.dart';
import 'package:flutter_onboarding/ui/screens/detail_page.dart';
import 'package:flutter_onboarding/ui/screens/premium_screen.dart';
import 'package:flutter_onboarding/ui/screens/widgets/loading_component.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  final bool isScanningForRockDetails;

  const CameraScreen({
    super.key,
    this.isScanningForRockDetails = true,
  });

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  final ImagePicker _picker = ImagePicker();
  bool _isCameraInitialized = false;
  bool _isLoadingCamera = true;
  bool _isLoading = false;
  Timer? _loadingTimer;
  bool _flashOn = false;

  Rock? _rock;
  File? _image;
  String? _errorMessage;

  final ValueNotifier<int> _loadingNotifier = ValueNotifier<int>(0);

  String? _chosenRockForm;
  String? _chosenRockSize;
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

  @override
  void initState() {
    initializeCamera();
    super.initState();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _cameraController = CameraController(
          cameras![0],
          ResolutionPreset.max,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      _isLoadingCamera = false;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.darkGrey,
        toolbarHeight: 40,
        centerTitle: false,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.close,
                color: Constants.white,
                size: 30,
              ),
            ),
            TextButton.icon(
              label: const Text('Unlimited IDs'),
              onPressed: () => Navigator.push(
                  context,
                  PageTransition(
                      child: const PremiumScreen(),
                      type: PageTransitionType.bottomToTop)),
              icon: SvgPicture.string(
                AppIcons.crownOnly,
                height: 14,
              ),
              style: TextButton.styleFrom(
                foregroundColor: Constants.darkGrey,
                backgroundColor: Constants.primaryColor,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (!_flashOn) {
                setState(() {
                  _flashOn = true;
                });
                _cameraController?.setFlashMode(FlashMode.torch);
                return;
              }

              setState(() {
                _flashOn = false;
              });
              _cameraController?.setFlashMode(FlashMode.off);
            },
            icon: Icon(
              _flashOn ? Icons.flash_off : Icons.flash_on,
              color: Constants.white,
              size: 28,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingCamera
                ? const LoadingComponent()
                : _isCameraInitialized && _cameraController != null
                    ? FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: _cameraController!.value.previewSize!.height,
                          height: _cameraController!.value.previewSize!.width,
                          child: CameraPreview(_cameraController!),
                        ),
                      )
                    : Center(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Constants.blackColor,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Welcome to the Rock ID Camera!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Take a photo and identify the rocks like a professional.',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _requestCameraPermission,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  backgroundColor: Constants.primaryColor,
                                  foregroundColor: Constants.darkGrey,
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: const Text(
                                  'Allow Access',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 80, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _requestGalleryPermission,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo, color: Colors.white),
                          Text(
                            'Photos',
                            style: TextStyle(color: Constants.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Constants.primaryColor,
                  onTap: () async {
                    if (await Permission.camera.isGranted) {
                      if (_isCameraInitialized) {
                        final takenPicture =
                            await _cameraController!.takePicture();
                        setState(() {
                          _image = File(takenPicture.path);
                        });
                        _startScanning(
                            _scanningFunction, Navigator.of(context));
                      } else {
                        await _requestCameraPermission();
                      }
                    } else {
                      await _requestCameraPermission();
                    }
                  },
                  customBorder: const CircleBorder(),
                  child: Ink(
                    decoration: const ShapeDecoration(
                      shape: CircleBorder(),
                      color: Constants.white,
                    ),
                    child: const Icon(
                      Icons.circle,
                      color: Constants.primaryColor,
                      size: 66,
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _showLoadingBottomSheet(showTips: true);
                    },
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.help, color: Colors.white),
                          Text(
                            'Snap Tips',
                            style: TextStyle(color: Constants.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Constants.darkGrey,
    );
  }

  void _showLoadingBottomSheet({final bool showTips = false}) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Constants.blackColor,
      clipBehavior: Clip.none,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: _errorMessage != null || showTips
                  ? MediaQuery.of(context).size.height * 0.7
                  : MediaQuery.of(context).size.height,
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
                      if (_isLoading && _errorMessage == null && !showTips) ...[
                        Image(
                          image: FileImage(_image!),
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 3,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress != null &&
                                loadingProgress.expectedTotalBytes != null &&
                                loadingProgress.cumulativeBytesLoaded <
                                    loadingProgress.expectedTotalBytes!) {
                              return const LoadingComponent();
                            }

                            return child;
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 50,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  'Wait for a moment',
                                  style: TextStyle(
                                    color: Constants.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Identifying $value%',
                                  style: const TextStyle(
                                    color: Constants.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 100),
                                const LoadingComponent()
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (_errorMessage != null || showTips)
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
                              const SizedBox(height: 15),
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
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.camera_alt,
                                        size: 30, // Size of the icon
                                        color: Constants
                                            .darkGrey, // Color of the icon
                                      ),
                                      const SizedBox(
                                          width:
                                              10), // Space between icon and text
                                      Text(
                                        !showTips ? 'Retake' : 'Got it!',
                                        style: const TextStyle(
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
      _loadingNotifier.value = 0;
    });
    _startLoading();
    _showLoadingBottomSheet();
    try {
      await scanningFunction();
      if (_rock != null) {
        if (widget.isScanningForRockDetails) {
          String timestamp = DateTime.now().toIso8601String();
          await DatabaseHelper().addRockToSnapHistory(
            _rock!.rockId,
            timestamp,
          );
          _showRockDetails(navigator);
          return;
        }

        Navigator.pop(context);
        _showSelectRockDetailsBottomSheet();
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('$e');
      setState(() {
        _errorMessage = e.toString().substring(11);
        _isLoading = false;
        _loadingNotifier.value = 0;
        _loadingTimer?.cancel();
      });
    } finally {
      setState(() {
        _isLoading = false;
        _loadingNotifier.value = 0;
        _loadingTimer?.cancel();
      });
    }
  }

  void _startLoading() {
    _loadingTimer =
        Timer.periodic(const Duration(milliseconds: 200), (Timer timer) {
      if (_loadingNotifier.value >= 99) {
        timer.cancel();
      } else {
        _loadingNotifier.value += 1;
      }
    });
  }

  void _showSelectRockDetailsBottomSheet() {
    bool _isChoosingRockForm = true;
    bool _isLoadingRockPrice = false;

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
              child: _isLoadingRockPrice
                  ? const LoadingComponent()
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Column(
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
                                    onTap: () async {
                                      setState(() {
                                        _isLoadingRockPrice = true;
                                      });
                                      NavigatorState navigator =
                                          Navigator.of(context);
                                      final response = await GetRockService()
                                          .identifyRockPrice(_rock!.rockName,
                                              _chosenRockForm, _chosenRockSize);

                                      if (mounted) {
                                        setState(() {
                                          _isLoadingRockPrice = false;
                                        });
                                        _showRockDetails(navigator,
                                            rockPriceResponse: response);
                                      }
                                    },
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
                                                  _chosenRockForm =
                                                      form['text'];
                                                  _isChoosingRockForm = false;
                                                });
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20,
                                                        horizontal: 20),
                                                decoration: BoxDecoration(
                                                  color: Constants.blackColor,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      form['icon'],
                                                      color: Constants
                                                          .primaryColor,
                                                    ),
                                                    const SizedBox(width: 15),
                                                    Expanded(
                                                      child: Text(
                                                        form['text'],
                                                        style: const TextStyle(
                                                          color:
                                                              Constants.white,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                  : SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.4,
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
                                            'assets/images/small_rock.png', // 1/3 of a hand
                                            'assets/images/medium_rock.png', // more than half of a hand
                                            'assets/images/big_rock.png', // the size of a hand
                                            'assets/images/bigger_rock.png' // bigger than a hand
                                          ];

                                          return InkWell(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            onTap: () async {
                                              setState(() {
                                                _chosenRockSize = imagePaths[
                                                            index]
                                                        .contains('small')
                                                    ? '1/3 of the size of a human hand'
                                                    : imagePaths[index]
                                                            .contains('medium')
                                                        ? '2/3 of the size of a human hand'
                                                        : imagePaths[index]
                                                                .contains('big')
                                                            ? 'the size of a human hand'
                                                            : 'bigger than a human hand';
                                              });

                                              setState(() {
                                                _isLoadingRockPrice = true;
                                              });
                                              NavigatorState navigator =
                                                  Navigator.of(context);
                                              final response =
                                                  await GetRockService()
                                                      .identifyRockPrice(
                                                          _rock!.rockName,
                                                          _chosenRockForm,
                                                          _chosenRockSize);

                                              if (mounted) {
                                                _showRockDetails(navigator,
                                                    rockPriceResponse:
                                                        response);
                                                setState(() {
                                                  _isLoadingRockPrice = false;
                                                });
                                              }
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.asset(
                                                  imagePaths[index],
                                                  fit: BoxFit.contain),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  void _showRockDetails(NavigatorState navigator,
      {final Map<String, dynamic>? rockPriceResponse}) async {
    bool isRemovingFromCollection = false;
    final allRocks = await DatabaseHelper().findAllRocks();
    if (allRocks.where((rock) => rock.rockId == _rock?.rockId).isNotEmpty) {
      isRemovingFromCollection = true;
    }

    navigator
        .push(PageTransition(
            child: RockDetailPage(
              rock: _rock!,
              isSavingRock: false,
              pickedImage: _image,
              identifyPriceResponse: rockPriceResponse,
              isRemovingFromCollection: isRemovingFromCollection,
            ),
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

  Future<void> _requestCameraPermission() async {
    try {
      PermissionStatus status = await Permission.camera.request();
      if (status.isGranted) {
        if (!_isCameraInitialized) {
          initializeCamera();
        }
      } else if (status.isPermanentlyDenied) {
        _showSettingsDialog();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _showSettingsDialog({bool isGallery = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.blackColor,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Permission Required',
            style: TextStyle(color: Constants.lightestBrown),
          ),
          content: Text(
            'This app needs ${!isGallery ? 'camera' : 'gallery'} access to function properly. Please open settings and grant ${!isGallery ? 'camera' : 'gallery'} permission.',
            style: const TextStyle(color: Constants.white),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: Constants.lightestRed,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              style: TextButton.styleFrom(
                foregroundColor: Constants.darkGrey,
                backgroundColor: Constants.primaryColor,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestGalleryPermission() async {
    PermissionStatus status = await Permission.photos.request();
    if (status.isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        _startScanning(_scanningFunction, Navigator.of(context));
      }
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(isGallery: true);
    }
  }

  Future<void> _scanningFunction() async {
    _rock = await GetRockService().getRock(_image);
  }
}

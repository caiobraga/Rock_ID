import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/main.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/services/get_rock.dart';
import 'package:flutter_onboarding/services/mix_panel_service.dart';
import 'package:flutter_onboarding/ui/pages/page_services/home_page_service.dart';
import 'package:flutter_onboarding/ui/pages/page_services/root_page_service.dart';
import 'package:flutter_onboarding/ui/pages/premium_page.dart';
import 'package:flutter_onboarding/ui/pages/rock_view_page.dart';
import 'package:flutter_onboarding/ui/pages/widgets/loading_component.dart';
import 'package:flutter_onboarding/ui/root_page.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/snackbar.dart';

class CameraPage extends StatefulWidget {
  final bool isScanningForRockDetails;

  const CameraPage({
    super.key,
    this.isScanningForRockDetails = true,
  });

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  final ImagePicker _picker = ImagePicker();
  bool _isCameraInitialized = false;
  bool _isLoadingCamera = true;
  bool _isLoading = false;
  Timer? _loadingTimer;
  bool _flashOn = false;
  bool _loadingDismissed = true;
  bool _isLoadingRockPrice = false;

  Rock? _rock;
  File? _image;
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier(null);
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

  bool isPremiumEnabled =
      RootPageService.instance.isPremiumActivatedNotifier.value;

  @override
  void initState() {
    initializeCamera();
    _openSnapTipsFirstTime();
    super.initState();
  }

  Future<void> initializeCamera() async {
    try {
      if (await Permission.camera.isGranted) {
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
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      _isLoadingCamera = false;
    });
  }

  void _openSnapTipsFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstOpen = prefs.getBool('isFirstOpen') ?? true;

    if (isFirstOpen) {
      _showLoadingBottomSheet(showTips: true);
      await prefs.setBool('isFirstOpen', false);
    }
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
                size: 24,
              ),
            ),
            Visibility(
              visible: !isPremiumEnabled,
              child: TextButton.icon(
                label: const Text('Unlimited IDs'),
                onPressed: () => Navigator.push(
                  context,
                  PageTransition(
                    child: const PremiumPage(),
                    type: PageTransitionType.topToBottom,
                  ),
                ),
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
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (_isCameraInitialized) {
                if (!_flashOn) {
                  _cameraController?.setFlashMode(FlashMode.torch).then(
                        (value) => setState(() {
                          _flashOn = true;
                        }),
                      );
                  return;
                }
                _cameraController?.setFlashMode(FlashMode.off).then(
                      (value) => setState(() {
                        _flashOn = false;
                      }),
                    );
              }
            },
            icon: Icon(
              _flashOn ? Icons.flash_off : Icons.flash_on,
              color: Constants.white,
              size: 22,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingCamera
                ? LoadingComponent(
                    scanningForPrice: !widget.isScanningForRockDetails)
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
                          padding: const EdgeInsets.all(20),
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
                    final _mixPanel = await MixpanelService.init();
                    _mixPanel.track("Rock Scanned");
                    _mixPanel.track('Save Rock', properties: {
                      'log_count': 10,
                      'is_premium': isPremiumEnabled ? true : false,
                    });
                    try {
                      await _cameraController!.pausePreview();
                      if (await Permission.camera.isGranted) {
                        if (_isCameraInitialized) {
                          final takenPicture =
                              await _cameraController!.takePicture();
                          await _cameraController!.resumePreview();
                          if (_flashOn) {
                            await _cameraController!
                                .setFlashMode(FlashMode.off);
                            setState(() {
                              _flashOn = false;
                            });
                          }
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
                    } catch (e) {
                      ShowSnackbarService().showSnackBar(
                          e.toString().replaceAll('Exception: ', ''));
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
    setState(() {
      _loadingDismissed = false;
    });

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Constants.blackColor,
      clipBehavior: Clip.none,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return ValueListenableBuilder<String?>(
                valueListenable: _errorMessageNotifier,
                builder: (context, errorMessage, child) {
                  if (errorMessage
                          ?.contains('need to have an internet connection') ==
                      true) {
                    Navigator.pop(context);
                  }
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: errorMessage != null || showTips
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
                        return ListView(
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          children: [
                            if (_isLoading &&
                                errorMessage == null &&
                                !showTips) ...[
                              Image(
                                image: FileImage(_image!),
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height / 3,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress != null &&
                                      loadingProgress.expectedTotalBytes !=
                                          null &&
                                      loadingProgress.cumulativeBytesLoaded <
                                          loadingProgress.expectedTotalBytes!) {
                                    return const LoadingComponent();
                                  }

                                  return child;
                                },
                              ),
                              Padding(
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
                                    const SizedBox(height: 80),
                                    LoadingComponent(
                                      scanningForPrice:
                                          !widget.isScanningForRockDetails,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if ((errorMessage != null &&
                                    !errorMessage.contains(
                                        'need to have an internet connection') ||
                                showTips))
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildErrorImageRow(
                                    Icons.verified,
                                    Constants.mediumGreen,
                                    'assets/images/prefectImage.png',
                                    'This is a good Example',
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
                                  const SizedBox(height: 10),
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
                          ],
                        );
                      },
                    ),
                  );
                });
          },
        );
      },
    ).then((_) {
      setState(() {
        _loadingNotifier.value = 0;
        _loadingTimer?.cancel();
        _loadingTimer = null;
        _loadingDismissed = true;
      });
      if (_errorMessageNotifier.value
              ?.contains('need to have an internet connection') ==
          true) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text(
              'You need to have an internet connection to scan a rock.',
              style: TextStyle(
                color: Constants.darkGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Constants.lightestRed,
          ),
        );
      }
    });
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
    final _mixPanel = await MixpanelService.init();
    _mixPanel.track("Rock Scanned");
    setState(() {
      _isLoading = true;
      _errorMessageNotifier.value = null;
    });
    _startLoading();
    _showLoadingBottomSheet();
    try {
      final storage = Storage.instance;
      final userTraces = jsonDecode((await storage.read(key: 'userTraces'))!);
      if (userTraces['numberOfRocksScanned'] >= 10 && !isPremiumEnabled) {
        await Navigator.push(
          context,
          PageTransition(
            duration: const Duration(milliseconds: 300),
            child: const PremiumPage(),
            type: PageTransitionType.topToBottom,
          ),
        );
        Navigator.pop(context);

        return;
      }

      await scanningFunction();
      if (!_loadingDismissed) {
        if (_rock != null) {
          await DatabaseHelper().addRockToSnapHistory(
            _rock!.rockId,
            _image?.path,
          );
          final _mixPanel = await MixpanelService.init();
          _mixPanel.track('Save Rock', properties: {
            'log_count': userTraces['numberOfRocksScanned'],
            'is_premium': isPremiumEnabled ? true : false,
          });
          userTraces['numberOfRocksScanned']++;
          await storage.write(key: 'userTraces', value: jsonEncode(userTraces));
          await HomePageService.instance.notifyTotalValues();

          if (widget.isScanningForRockDetails) {
            _showRockDetails(navigator);
            return;
          }

          Navigator.pop(context);
          _showSelectRockDetailsBottomSheet();
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint('$e');
      setState(() {
        debugPrint('ERROR: $e');
        _errorMessageNotifier.value = e.toString().substring(11);
        _isLoading = false;
        _loadingTimer?.cancel();
      });
    } finally {
      setState(() {
        _isLoading = false;
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
                                      try {
                                        setState(() {
                                          _isLoadingRockPrice = true;
                                        });
                                        NavigatorState navigator =
                                            Navigator.of(context);
                                        final response = await GetRockService()
                                            .identifyRockPrice(
                                                _rock!.rockName,
                                                _chosenRockForm,
                                                _chosenRockSize);

                                        if (mounted) {
                                          _showRockDetails(navigator,
                                              rockPriceResponse: response);
                                        }
                                      } catch (e) {
                                        ShowSnackbarService().showSnackBar(e
                                            .toString()
                                            .replaceAll('Exception: ', ''));
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
                                              try {
                                                setState(() {
                                                  _chosenRockSize = imagePaths[
                                                              index]
                                                          .contains('small')
                                                      ? '1/3 of the size of a human hand'
                                                      : imagePaths[index]
                                                              .contains(
                                                                  'medium')
                                                          ? '2/3 of the size of a human hand'
                                                          : imagePaths[index]
                                                                  .contains(
                                                                      'big')
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
                                                }
                                              } catch (e) {
                                                ShowSnackbarService()
                                                    .showSnackBar(e
                                                        .toString()
                                                        .replaceAll(
                                                            'Exception: ', ''));
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
    try {
      if (rockPriceResponse?['error'] != null) {
        throw Exception(rockPriceResponse!['error']);
      }

      bool isRemovingFromCollection = false;
      final allRocks = await DatabaseHelper().findAllRocks();
      if (allRocks
          .where((rock) =>
              rock.rockId == _rock?.rockId && rock.isAddedToCollection)
          .isNotEmpty) {
        isRemovingFromCollection = true;
      }

      navigator
          .push(PageTransition(
              child: RockViewPage(
                rock: _rock!,
                pickedImage: _image,
                identifyPriceResponse: rockPriceResponse,
                isRemovingFromCollection: isRemovingFromCollection,
              ),
              type: PageTransitionType.fade))
          .then((value) {
        setState(() {
          _isLoadingRockPrice = false;
        });
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const RootPage()),
          (route) => false,
        );
      });
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
    }
  }

  Future<void> _requestCameraPermission() async {
    try {
      PermissionStatus status = await Permission.camera.request();
      if (status.isGranted) {
        if (!_isCameraInitialized) {
          await initializeCamera();
        }
      } else if (status.isPermanentlyDenied || status.isDenied) {
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
    if (_flashOn) {
      await _cameraController!.setFlashMode(FlashMode.off);
      setState(() {
        _flashOn = false;
      });
    }
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _startScanning(_scanningFunction, Navigator.of(context));
    }
  }

  Future<void> _scanningFunction() async {
    _rock = await GetRockService().getRock(_image);
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/services/get_rock.dart';
import 'package:flutter_onboarding/services/image_picker.dart';
import 'package:flutter_onboarding/ui/screens/detail_page.dart';
import 'package:page_transition/page_transition.dart';

import '../services/snackbar.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  Rock? _rock;
  File? _image;
  bool _isLoading = false;
  int _loadingPercentage = 0;
  String? _errorMessage;

  ValueNotifier<int> _loadingNotifier = ValueNotifier<int>(0);

  Future<void> _showImageSourceActionSheet(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text(
                  'Gallery',
                  style: TextStyle(
                    color: Constants.primaryColor,
                  ),
                ),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  _startScanning(() async {
                    _image = await ImagePickerService().pickImageFromGallery();
                    _rock = await GetRockService().getRock(_image);
                  }, navigator);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text(
                  'Camera',
                  style: TextStyle(
                    color: Constants.primaryColor,
                  ),
                ),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  _startScanning(() async {
                    _image = await ImagePickerService().pickImageFromCamera();
                    _rock = await GetRockService().getRock(_image);
                  }, navigator);
                },
              ),
            ],
          ),
        );
      },
    );
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
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: _loadingNotifier,
                builder: (context, value, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (_isLoading)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Identifying ${_loadingPercentage}%',
                            style: TextStyle(
                              color: Constants.primaryColor.withOpacity(.80),
                              fontSize: 16,
                            ),
                          ),
                          if (_image != null)
                            Image.file(
                              File(_image!.path),
                              height: 200,
                              fit: BoxFit.cover,
                            )
                          else
                            CircularProgressIndicator(),
                        ],
                      ),
                      if (_errorMessage != null)
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            _buildErrorImageRow(
                              Icons.verified,
                              Colors.blue,
                              'assets/images/prefectImage.png',
                              'This is a good Exemple',
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'The following will lead to poor results',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildErrorImageRow(
                              Icons.close,
                              Colors.red,
                              'assets/images/smal_stone.png',
                              'Too far',
                              'assets/images/blurred.jpg',
                              'Blurred images',
                            ),
                            const SizedBox(height: 10),
                            _buildErrorImageRow(
                              Icons.close,
                              Colors.red,
                              'assets/images/varias_rochas.png',
                              'Too many',
                              'assets/images/too_dark.png',
                              'Too dark',
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 30, // Size of the icon
                                    color: Colors.white, // Color of the icon
                                  ),
                                  SizedBox(width: 10), // Space between icon and text
                                  Text(
                                    'Retake',
                                    style: TextStyle(
                                      fontSize: 18, // Size of the text
                                      color: Colors.white, // Color of the text
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
          },
        );
      },
    );
  }

  Widget _buildErrorImageRow(
    IconData icon,
    Color color,
    String assetPath1,
    String label1, [
    String? assetPath2,
    String? label2,
  ]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(child: _buildErrorImage(assetPath1, label1, icon, color)),
        if (assetPath2 != null && label2 != null)
        Expanded(child: _buildErrorImage(assetPath2, label2, icon, color)),
      ],
    );
  }

  Widget _buildErrorImage(String assetPath, String label, IconData icon, Color color) {
    return Column(
      children: [
        Stack(
          children: [
            Image.asset(
              assetPath,
              height: 100,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),
            
            Positioned(
              right: 0,
              top: 0,
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
          ],
        ),
        Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
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
        navigator.push(PageTransition(
            child: RockDetailPage(rock: _rock!, isSavingRock: true),
            type: PageTransitionType.fade));
      }
    } catch (e) {
      print(e);
      setState(() {
        _errorMessage = '${e.toString().substring(11)}';
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
    Timer.periodic(Duration(milliseconds: 200), (Timer timer) {
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
                      child: Icon(
                        Icons.close,
                        color: Constants.primaryColor,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      debugPrint('favorite');
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Constants.primaryColor.withOpacity(.15),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
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
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/services/get_rock.dart';
import 'package:flutter_onboarding/services/image_picker.dart';
import 'package:flutter_onboarding/ui/root_page.dart';

import 'screens/home_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  Rock? _rock;
  File? _image;
  bool _isLoading = false;

  Future<void> _showImageSourceActionSheet(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery',
                style: TextStyle(
                            color: Constants.primaryColor,
                          )
                ),
                onTap: () async {
                  try{
                    final navigator = Navigator.of(context); 
                  navigator.pop();
                    setState(() {
                      _isLoading = true;
                    });
                    _image = await ImagePickerService().pickImageFromGallery();
                    _rock = await GetRockService().getRock(context, _image);
                    
                    
                    if (_rock != null) {
                      // Handle the rock data
                      await DatabaseHelper().insertRock(_rock!);
                    }
                    setState(() {
                      _isLoading = false;
                    });
                    navigator.pushReplacement(MaterialPageRoute(builder: (_) => const RootPage())); 
                  } catch(e){
                    print(e);
                    SnackBar(content: Text('Error: $e'));
                  }
                  
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera',
                style: TextStyle(
                            color: Constants.primaryColor,
                          )
                ),
                onTap: () async {
                  final navigator = Navigator.of(context); 
                  navigator.pop();
                    setState(() {
                      _isLoading = true;
                    });
                    _image = await ImagePickerService().pickImageFromCamera();
                    _rock = await GetRockService().getRock(context, _image);
                    
                    
                    if (_rock != null) {
                      // Handle the rock data
                      await DatabaseHelper().insertRock(_rock!);
                      
                    }
                    setState(() {
                      _isLoading = false;
                    });
                    navigator.pop();
                },
              ),
            ],
          ),
        );
      },
    );
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
                      if (_isLoading)
                        const SizedBox(
                          height: 20,
                        ),
                      if (_isLoading)
                        CircularProgressIndicator(),
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

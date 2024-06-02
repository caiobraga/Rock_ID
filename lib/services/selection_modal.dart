import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/services/chat_gpt.dart';
import 'package:flutter_onboarding/ui/screens/select_rock_page.dart';
import 'package:page_transition/page_transition.dart';
import '../constants.dart';
import 'dart:io';

import '../ui/scan_page.dart';

class ShowSelectionModalService {
  Future<void> show(BuildContext context) async {
   showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.black, // Cor de fundo do modal
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.push(context, PageTransition(child: SelectRockPage(), type: PageTransitionType.bottomToTop)).then((value) => Navigator.of(context).pop());
                },
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[800],
                    child: Icon(Icons.search, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Search by name',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, PageTransition(child: const ScanPage(), type: PageTransitionType.bottomToTop)).then((value) => Navigator.of(context).pop());
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[800],
                      child: Icon(Icons.camera_alt, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Identify by photo',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

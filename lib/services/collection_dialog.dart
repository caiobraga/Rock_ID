import 'package:flutter/material.dart';

import '../constants.dart';
import '../db/db.dart';
import '../models/collection.dart';
/*
class CollectionDialogService {

  void show(BuildContext context, void Function() onItemAdded) {
      final TextEditingController _collectionNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.black,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.black,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'CREATE NEW COLLECTION',
                  style: TextStyle(
                    color: Constants.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _collectionNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Name your new collection',
                    hintText: 'Enter name',
                    hintStyle: const TextStyle(color: Colors.white54),
                    labelStyle: TextStyle(color: Constants.primaryColor),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter description',
                    hintStyle: const TextStyle(color: Colors.white54),
                    labelStyle: TextStyle(color: Constants.primaryColor),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Constants.primaryColor,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Constants.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('OK'),
                      onPressed: () async {
                        final String collectionName = _collectionNameController.text;
                        final String description = _descriptionController.text;

                        if (collectionName.isNotEmpty) {
                          try {
                            /*Collection newCollection = Collection(
                              collectionId: 0,
                              collectionName: collectionName,
                              description: description,
                            );

                            await DatabaseHelper().insertCollection(newCollection);
                            Navigator.of(context).pop();
                            onItemAdded();*/
                          } catch (e) {
                            debugPrint('$e');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}*/
import 'package:flutter/material.dart';
import '../constants.dart';
import '../db/db.dart';
import '../models/collection.dart';

class AddNewCollectionModalService {
  Future<void> show(BuildContext context, void Function() onItemAdded) async {
    final TextEditingController _numberController = TextEditingController();
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _dateController = TextEditingController();
    final TextEditingController _costController = TextEditingController();
    final TextEditingController _localityController = TextEditingController();
    final TextEditingController _lengthController = TextEditingController();
    final TextEditingController _widthController = TextEditingController();
    final TextEditingController _heightController = TextEditingController();
    final TextEditingController _notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'COLLECTION DETAILS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _numberController,
                  decoration: InputDecoration(
                    labelText: 'No.',
                    labelStyle: const TextStyle(color: Colors.white),
                    hintText: 'Tap to enter the number',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Constants.primaryColor),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Auto numbered: 3 Use this',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: const TextStyle(color: Colors.white),
                    hintText: 'Tap to enter the name',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Constants.primaryColor),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Icon(Icons.image, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Date acquired',
                          labelStyle: const TextStyle(color: Colors.white),
                          hintText: 'Tap to enter',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: const OutlineInputBorder(),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Constants.primaryColor),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _costController,
                        decoration: InputDecoration(
                          labelText: 'Cost',
                          labelStyle: const TextStyle(color: Colors.white),
                          hintText: 'Tap to enter',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: const OutlineInputBorder(),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Constants.primaryColor),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _localityController,
                  decoration: InputDecoration(
                    labelText: 'Locality',
                    labelStyle: const TextStyle(color: Colors.white),
                    hintText: 'Tap to enter',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Constants.primaryColor),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _lengthController,
                        decoration: InputDecoration(
                          labelText: 'Length',
                          labelStyle: const TextStyle(color: Colors.white),
                          hintText: 'Tap to enter',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: const OutlineInputBorder(),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Constants.primaryColor),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _widthController,
                        decoration: InputDecoration(
                          labelText: 'Width',
                          labelStyle: const TextStyle(color: Colors.white),
                          hintText: 'Tap to enter',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: const OutlineInputBorder(),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Constants.primaryColor),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _heightController,
                        decoration: InputDecoration(
                          labelText: 'Height',
                          labelStyle: const TextStyle(color: Colors.white),
                          hintText: 'Tap to enter',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: const OutlineInputBorder(),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Constants.primaryColor),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    labelStyle: const TextStyle(color: Colors.white),
                    hintText: 'Tap to add your notes here...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Constants.primaryColor),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      final String number = _numberController.text;
                      final String name = _nameController.text;
                      final String description = _notesController.text;
                      final String dateAcquired = _dateController.text;
                      final double cost =
                          double.tryParse(_costController.text) ?? 0.0;
                      final String locality = _localityController.text;
                      final double length =
                          double.tryParse(_lengthController.text) ?? 0.0;
                      final double width =
                          double.tryParse(_widthController.text) ?? 0.0;
                      final double height =
                          double.tryParse(_heightController.text) ?? 0.0;
                      final String notes = _notesController.text;

                      if (name.isNotEmpty) {
                        try {
                          Collection newCollection = Collection(
                            collectionId: 0,
                            collectionName: name,
                            description: description,
                            number: number,
                            dateAcquired: dateAcquired,
                            cost: cost,
                            locality: locality,
                            length: length,
                            width: width,
                            height: height,
                            notes: notes,
                          );

                          await DatabaseHelper()
                              .insertCollection(newCollection);

                          Navigator.of(context).pop();
                          onItemAdded();
                        } catch (e) {
                          debugPrint('$e');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
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
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../db/db.dart';
import '../models/collection.dart';

class AddNewCollectionModalService {
  List<String> pathsImage = [
    'https://static3.depositphotos.com/1000839/188/i/450/depositphotos_1888666-stock-photo-large-rock-stone-isolated.jpg'
  ];

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
    void onTap() async {
      final String number = _numberController.text;
      final String name = _nameController.text;
      final String description = _notesController.text;
      final String dateAcquired = _dateController.text;
      final double cost = double.tryParse(_costController.text) ?? 0.0;
      final String locality = _localityController.text;
      final double length = double.tryParse(_lengthController.text) ?? 0.0;
      final double width = double.tryParse(_widthController.text) ?? 0.0;
      final double height = double.tryParse(_heightController.text) ?? 0.0;
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

          await DatabaseHelper().insertCollection(newCollection);

          Navigator.of(context).pop();
          onItemAdded();
        } catch (e) {
          debugPrint('$e');
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return InkWell(
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            Navigator.of(context).pop();
          },
          child: DraggableScrollableSheet(
            initialChildSize: 0.88,
            minChildSize: 0.88,
            maxChildSize: 0.88,
            builder: (BuildContext context, ScrollController scrollController) {
              return InkWell(
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {},
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Constants.darkGrey,
                      borderRadius: const BorderRadius.only(
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
                              icon: Icon(
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
                          controller: _numberController,
                          label: 'No.',
                          hintText: 'Tap to enter the number',
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              '*Auto numbered: 3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(
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
                          controller: _nameController,
                          hintText: 'Tap to enter the name',
                          // clearButton: true,
                          rightIcon: Padding(
                            padding: const EdgeInsets.all(8.0).copyWith(
                              right: 14,
                            ),
                            child: InkWell(
                              onTap: () {
                                _nameController.clear();
                              },
                              child: Icon(
                                Icons.clear,
                                color: Constants.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          runSpacing: 16,
                          spacing: 16,
                          children: [
                            ...pathsImage.map((e) {
                              return Container(
                                height: 100,
                                width: 100,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Constants.colorInput,
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Image.network(
                                  e,
                                  fit: BoxFit.fill,
                                ),
                              );
                            }).toList(),
                            Container(
                              margin: const EdgeInsets.only(right: 16),
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Constants.colorInput,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: InkWell(
                                onTap: () {},
                                child: Icon(
                                  Icons.add,
                                  color: Constants.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: InputWidget(
                                label: 'Acquisition',
                                controller: _dateController,
                                hintText: 'Date acquired',
                                textInputType: TextInputType.datetime,
                                rightIcon: Padding(
                                  padding: const EdgeInsets.all(8.0).copyWith(
                                    right: 14,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      _dateController.clear();
                                    },
                                    child: Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      color: Constants.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              child: InputWidget(
                                label: '',
                                controller: _costController,
                                hintText: 'Cost',
                                rightIcon: Container(
                                  height: 52,
                                  color: Constants.darkGrey,
                                  padding: const EdgeInsets.all(8.0).copyWith(
                                    right: 14,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      _nameController.clear();
                                    },
                                    child: Icon(
                                      Icons.attach_money_sharp,
                                      color: Constants.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                              width: 150,
                            ),
                          ],
                        ),
                        InputWidget(
                          label: 'Locality',
                          controller: _localityController,
                          hintText: 'Tap to enter',
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: InputWidget(
                                label: 'Size',
                                controller: _lengthController,
                                hintText: 'Length',
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              height: 60,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'X',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Constants.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: InputWidget(
                                label: '',
                                controller: _widthController,
                                hintText: 'Width',
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              height: 60,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'X',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Constants.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: InputWidget(
                                label: '',
                                controller: _heightController,
                                hintText: 'Height',
                              ),
                            ),
                          ],
                        ),
                        InputWidget(
                          label: 'Notes',
                          controller: _notesController,
                          hintText: 'Tap to add your notes here...',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                height: 33,
                                decoration: BoxDecoration(
                                  color: Constants.primaryColor,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: InkWell(
                                  onTap: onTap,
                                  child: Text(
                                    'Save',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Constants.blackColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class InputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final bool required;
  final int maxLines;
  final Widget? rightIcon;
  final TextInputType textInputType;
  const InputWidget({
    super.key,
    required this.controller,
    this.label,
    this.textInputType = TextInputType.none,
    this.required = false,
    this.rightIcon,
    this.maxLines = 1,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final isDateTime = textInputType == TextInputType.datetime;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              label ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Visibility(
              visible: required,
              child: const Text(
                '*',
                style: TextStyle(color: Colors.red),
              ),
            )
          ],
        ),
        Container(
          margin: const EdgeInsets.only(
            top: 4,
          ),
          decoration: BoxDecoration(
            color: Constants.colorInput,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: maxLines * 52,
                  child: TextField(
                    maxLines: maxLines,
                    onTap: isDateTime
                        ? () {
                            _selectDate(
                                context: context, controller: controller);
                          }
                        : null,
                    keyboardType: textInputType,
                    readOnly: isDateTime,
                    controller: controller,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelStyle: GoogleFonts.montserrat().copyWith(
                        color: Constants.naturalGrey,
                      ),
                      hintText: hintText,
                      hintStyle: GoogleFonts.montserrat().copyWith(
                        color: Constants.naturalGrey,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Constants.primaryColor,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              rightIcon ?? Container(),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate({
    required BuildContext context,
    required TextEditingController controller,
  }) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        controller.text = picked.toLocal().toString().split(' ').first;
      }
    } catch (e) {}
  }
}

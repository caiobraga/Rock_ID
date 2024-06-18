import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onboarding/models/collection_image.dart';
import 'package:flutter_onboarding/services/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
    final ValueNotifier<List<File>> _photosNotifier = ValueNotifier([]);
    final ValueNotifier<String> _unitOfMeasurementNotifier =
        ValueNotifier('inch');

    void toggleUnitOfMeasurement() {
      if (_unitOfMeasurementNotifier.value == 'inch') {
        _unitOfMeasurementNotifier.value = 'cm';
        return;
      }

      _unitOfMeasurementNotifier.value = 'inch';
    }

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
      final String unitOfMeasurement = _unitOfMeasurementNotifier.value;
      final List<File> collectionImageFiles = _photosNotifier.value;

      if (name.isNotEmpty) {
        try {
          List<CollectionImage> images = [];
          for (var element in collectionImageFiles) {
            images.add(CollectionImage(
              collectionId: 0,
              id: 0,
              image: await element.readAsBytes(),
            ));
          }
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
            unitOfMeasurement: unitOfMeasurement,
            collectionImagesFiles: images,
          );

          await DatabaseHelper().insertCollection(newCollection);

          Navigator.of(context).pop();
          onItemAdded();
        } catch (e) {
          debugPrint('$e');
        }

        return;
      }
    }

    _showImageOptions() {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
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
                  onTap: () async {
                    Navigator.pop(context);
                    final _image =
                        await ImagePickerService().pickImageFromGallery();
                    if (_image != null) {
                      _photosNotifier.value =
                          List.from([..._photosNotifier.value, _image]);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[800],
                        child: const Icon(Icons.image, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Select from gallery',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    final _image =
                        await ImagePickerService().pickImageFromCamera(context);
                    if (_image != null) {
                      _photosNotifier.value =
                          List.from([..._photosNotifier.value, _image]);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[800],
                        child:
                            const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Take photo',
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).pop();
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.88,
              minChildSize: 0.88,
              maxChildSize: 0.88,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return GestureDetector(
                  onTap: () {},
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: const BoxDecoration(
                        color: Constants.darkGrey,
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
                          InputWidget(
                            controller: _numberController,
                            label: 'No.',
                            hintText: 'Tap to enter the number',
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '*Auto numbered: 3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
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
                            rightIcon: Padding(
                              padding: const EdgeInsets.all(8.0).copyWith(
                                right: 14,
                              ),
                              child: InkWell(
                                onTap: () {
                                  _nameController.clear();
                                },
                                child: const Icon(
                                  Icons.clear,
                                  color: Constants.white,
                                  size: 24,
                                ),
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
                          ValueListenableBuilder<List<File>>(
                              valueListenable: _photosNotifier,
                              builder: (context, list, _) {
                                return Wrap(
                                  runSpacing: 8,
                                  spacing: 8,
                                  children: [
                                    ...list.map((e) {
                                      return Container(
                                        height: 100,
                                        width: 100,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Constants.colorInput,
                                          border: Border.all(),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Image.file(
                                          e,
                                          fit: BoxFit.fill,
                                        ),
                                      );
                                    }).toList(),
                                    Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: Constants.colorInput,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: InkWell(
                                        onTap: () async {
                                          _showImageOptions();
                                        },
                                        child: const Icon(
                                          Icons.add,
                                          color: Constants.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
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
                                      child: const Icon(
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
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
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
                                    _costController.value = TextEditingValue(
                                      text: formattedValue,
                                      selection: TextSelection.collapsed(
                                        offset: formattedValue.length,
                                      ),
                                    );
                                  },
                                  rightIcon: Container(
                                    height: 52,
                                    color: Constants.darkGrey,
                                    padding: const EdgeInsets.all(8.0).copyWith(
                                      right: 14,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        _costController.clear();
                                      },
                                      child: const Icon(
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
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: InputWidget(
                                  label: 'Size',
                                  controller: _lengthController,
                                  hintText: 'Length',
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                height: 60,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                  controller: _widthController,
                                  hintText: 'Width',
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                height: 60,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                                  _unitOfMeasurementNotifier,
                                              builder: (context, type, _) {
                                                return Container(
                                                  clipBehavior: Clip.hardEdge,
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            26),
                                                    color: Constants.blackColor,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Expanded(
                                                        child: InkWell(
                                                          child: Container(
                                                            alignment: Alignment
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
                                                              color: _unitOfMeasurementNotifier
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
                                                              style: TextStyle(
                                                                color: Constants
                                                                    .white,
                                                                fontWeight: _unitOfMeasurementNotifier
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
                                                          onTap:
                                                              toggleUnitOfMeasurement,
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
                                                                color: _unitOfMeasurementNotifier
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
                                                                  color:
                                                                      Constants
                                                                          .white,
                                                                  fontWeight: _unitOfMeasurementNotifier
                                                                              .value ==
                                                                          'cm'
                                                                      ? FontWeight
                                                                          .w600
                                                                      : FontWeight
                                                                          .normal,
                                                                  fontSize: 11,
                                                                ),
                                                              )),
                                                          onTap:
                                                              toggleUnitOfMeasurement,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
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
                            maxLines: 5,
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                              onTap: onTap,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 33,
                                        decoration: BoxDecoration(
                                          color: Constants.primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        child: const Text(
                                          'Save',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Constants.blackColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class InputWidget extends StatelessWidget {
  final TextEditingController controller;
  final Widget? labelFromWidget;
  final String? label;
  final String? hintText;
  final bool required;
  final int maxLines;
  final Widget? rightIcon;
  final TextInputType textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  const InputWidget({
    super.key,
    required this.controller,
    this.labelFromWidget,
    this.label,
    this.textInputType = TextInputType.text,
    this.required = false,
    this.rightIcon,
    this.maxLines = 1,
    this.hintText,
    this.inputFormatters,
    this.onChanged,
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
            labelFromWidget ??
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
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: maxLines * 52,
                  child: TextField(
                    maxLines: maxLines,
                    inputFormatters: inputFormatters,
                    onTap: isDateTime
                        ? () {
                            _selectDate(
                                context: context, controller: controller);
                          }
                        : null,
                    onChanged: onChanged,
                    keyboardType: textInputType,
                    readOnly: isDateTime,
                    controller: controller,
                    cursorColor: Constants.primaryColor,
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
                      focusedBorder: const OutlineInputBorder(
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

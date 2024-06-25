import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:google_fonts/google_fonts.dart';

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
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                maxLines: maxLines,
                inputFormatters: inputFormatters,
                onTap: isDateTime
                    ? () {
                        _selectDate(context: context, controller: controller);
                      }
                    : null,
                onChanged: onChanged,
                keyboardType: textInputType,
                readOnly: isDateTime,
                controller: controller,
                cursorColor: Constants.primaryColor,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Constants.colorInput,
                  constraints: const BoxConstraints(
                    minHeight: 52,
                  ),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: GoogleFonts.montserrat().copyWith(
                    color: Constants.naturalGrey,
                  ),
                  hintText: hintText,
                  hintStyle: GoogleFonts.montserrat().copyWith(
                    color: Constants.naturalGrey,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Constants.primaryColor,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Constants.mediumRed,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Constants.mediumRed,
                    ),
                  ),
                  suffixIcon: rightIcon,
                ),
                style: const TextStyle(
                  color: Colors.white,
                ),
                validator: (value) {
                  if (required && (value == null || value.isEmpty)) {
                    return 'Mandatory field!';
                  }

                  return null;
                },
              ),
            ),
          ],
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
    } catch (e) {
      debugPrint('$e');
    }
  }
}

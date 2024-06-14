import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class DSCustomText extends StatelessWidget {
  final Color? color;
  final double fontSize;
  final String text;
  final FontWeight fontWeight;
  final TextOverflow? overflow;
  const DSCustomText({
    Key? key,
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    this.color,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        color: color ?? AppCollors.white,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      overflow: overflow ?? TextOverflow.ellipsis,
      textAlign: TextAlign.start,
    );
  }
}

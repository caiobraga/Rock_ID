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
  final TextDecoration? decoration;
  final Color? decorationColor;
  final TextAlign? textAlign;
  final IconData? icon;
  const DSCustomText({
    Key? key,
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    this.color,
    this.overflow,
    this.decoration,
    this.decorationColor,
    this.textAlign,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return icon == null
        ? Text(
            text,
            style: GoogleFonts.montserrat(
              color: color ?? AppColors.white,
              fontSize: fontSize,
              fontWeight: fontWeight,
              decoration: decoration,
              decorationColor: decorationColor,
            ),
            overflow: overflow ?? TextOverflow.ellipsis,
            textAlign: textAlign ?? TextAlign.start,
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color ?? AppColors.white,
                size: 14,
              ),
              const SizedBox(width: 2),
              Text(
                text.length > 10 ? '${text.substring(0, 9)}...' : text,
                style: GoogleFonts.montserrat(
                  color: color ?? AppColors.white,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  decoration: decoration,
                  decorationColor: decorationColor,
                ),
                overflow: overflow ?? TextOverflow.ellipsis,
                textAlign: textAlign ?? TextAlign.start,
              ),
            ],
          );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingComponent extends StatelessWidget {
  const LoadingComponent({super.key});

  @override
  Widget build(BuildContext context) {
    const double loadingWidgetSize = 20;

    return Stack(
      children: [
        // Blurred background
        Container(),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: loadingWidgetSize),
            child: Container(
              width: 110,
              height: 75,
              decoration: BoxDecoration(
                color: Constants.blackColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.grey.shade200,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  LoadingAnimationWidget.prograssiveDots(
                    color: Colors.grey.shade200,
                    size: loadingWidgetSize,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'dart:math';
import 'dart:ui';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

const sliderHeight = 360.0;
const sliderWidth = 135.0;
const maxStretchDistance = 100;

class RubberBandSlider extends StatefulWidget {
  const RubberBandSlider({super.key});

  @override
  State<RubberBandSlider> createState() => _RubberBandSliderState();
}

class _RubberBandSliderState extends State<RubberBandSlider> {
  double sliderValue = 0;
  double drag = 0;
  double stretchDistance = 0;
  double stretchScale = 1;
  Duration rubberBandAnimationDuration = const Duration(milliseconds: 50);
  Duration sliderAnimationDuration = const Duration(milliseconds: 50);
  final Curve rubberBandAnimationCurve = Curves.easeOut;

  final isStretchingNotifier = ValueNotifier<bool>(false);

  void _handleVerticalDragStart(DragStartDetails details) {
    rubberBandAnimationDuration = const Duration(milliseconds: 50);
    sliderAnimationDuration = const Duration(milliseconds: 50);
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      drag += -details.delta.dy;
      final realTimeSliderValue = lerpDouble(0, 1, drag / sliderHeight) ?? 0;
      sliderValue = realTimeSliderValue.clamp(0, 1);
      stretchDistance = (realTimeSliderValue - sliderValue) * sliderHeight;
      final mappedScale =
          (sliderHeight + stretchDistance.abs().clamp(0, maxStretchDistance)) /
              sliderHeight;
      stretchScale = 1 + 0.18 * log(mappedScale);
    });
    if (stretchDistance.abs() > 0) {
      isStretchingNotifier.value = true;
    } else {
      isStretchingNotifier.value = false;
    }
  }

  void _handleVerticalDragEndOrCancel() {
    rubberBandAnimationDuration = const Duration(milliseconds: 450);
    sliderAnimationDuration = const Duration(milliseconds: 200);
    setState(() {
      drag = lerpDouble(0, sliderHeight, sliderValue) ?? 0;
      stretchScale = 1.0;
      stretchDistance = 0;
    });
  }

  void _isStretchingNotifierListener() {
    if (isStretchingNotifier.value) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  void initState() {
    super.initState();
    isStretchingNotifier.addListener(_isStretchingNotifierListener);
  }

  @override
  void dispose() {
    isStretchingNotifier.removeListener(_isStretchingNotifierListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: _handleVerticalDragStart,
      onVerticalDragUpdate: _handleVerticalDragUpdate,
      onVerticalDragEnd: (_) => _handleVerticalDragEndOrCancel(),
      onVerticalDragCancel: _handleVerticalDragEndOrCancel,
      child: TweenAnimationBuilder(
        tween: Tween<Alignment>(
          begin: Alignment.center,
          end: Alignment(0.0, 3 * stretchDistance.sign),
        ),
        duration: rubberBandAnimationDuration,
        curve: Curves.linear,
        builder: (context, Alignment alignment, _) {
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 1.0,
              end: stretchScale,
            ),
            duration: rubberBandAnimationDuration,
            curve: rubberBandAnimationCurve,
            builder: (context, double value, _) {
              return Transform.scale(
                scaleY: value,
                scaleX: 1 - (value - 1),
                alignment: alignment,
                child: Container(
                  height: sliderHeight,
                  width: sliderWidth,
                  decoration: ShapeDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 40,
                        cornerSmoothing: 1.4,
                      ),
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: AnimatedFractionallySizedBox(
                    duration: sliderAnimationDuration,
                    curve: Curves.easeOut,
                    heightFactor: sliderValue,
                    widthFactor: 1,
                    alignment: Alignment.bottomCenter,
                    child: ColoredBox(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

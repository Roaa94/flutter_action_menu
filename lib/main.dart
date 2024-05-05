import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

void main() {
  runApp(const IosActionMenuApp());
}

class IosActionMenuApp extends StatefulWidget {
  const IosActionMenuApp({Key? key}) : super(key: key);

  @override
  State<IosActionMenuApp> createState() => _IosActionMenuAppState();
}

class _IosActionMenuAppState extends State<IosActionMenuApp> {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Flutter iOS Action Menu',
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue,
              Colors.lightPurple,
              Colors.darkPurple,
              Colors.darkBlue,
            ],
            stops: [0, 0.3, 0.8, 1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: ActionMenu(),
        ),
      ),
    );
  }
}

const itemHeight = 55.0;
const menuItemsMaxScale = 1.1;
const indicatorHeight = itemHeight * menuItemsMaxScale;
const maxDistance = itemHeight / 2 + indicatorHeight / 2;
const indicatorVPadding = -((itemHeight * menuItemsMaxScale - itemHeight) / 2);
const maxStretchDistance = 200;
const names = [
  'Natalie Friedman',
  'Marcus Gilmore',
  'Elise Barrett',
  'Timothy Chang',
  'Sofia Navarro',
];

class ActionMenu extends StatefulWidget {
  const ActionMenu({super.key});

  @override
  State<ActionMenu> createState() => _ActionMenuState();
}

class _ActionMenuState extends State<ActionMenu> with TickerProviderStateMixin {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final GlobalKey widgetKey = GlobalKey();

  // Overlay animation classes
  late final AnimationController _overlayAnimationController;
  late final Animation<double> _overlayScaleAnimation;
  late final Animation<double> _overlayFadeAnimation;
  late CurvedAnimation _overlayScaleAnimationCurve;

  // Menu button animation classes
  late final AnimationController _buttonAnimationController;
  late final Animation<double> _buttonScaleAnimation;

  final _link = LayerLink();
  double indicatorOffset = names.length * itemHeight;
  bool showIndicator = false;
  double stretchDistance = 0;
  double menuStretchScale = 1.0;
  double indicatorStretchScaleY = 1;

  double get indicatorCenter => indicatorOffset + indicatorHeight / 2;

  double _getListItemScale(int index) {
    final itemCenter = (itemHeight * index) + (itemHeight / 2);
    final centersDistance = (indicatorCenter - itemCenter).abs();
    if (centersDistance <= maxDistance && showIndicator) {
      return lerpDouble(menuItemsMaxScale, 1, centersDistance / maxDistance) ??
          1;
    }
    return 1;
  }

  void _handlePointerUpOrCancel() {
    if (_overlayController.isShowing) {
      _overlayAnimationController.reverse().then((_) {
        _overlayController.hide();
        setState(() {
          indicatorOffset = names.length * itemHeight;
        });
      });
    }
    if (showIndicator) setState(() => showIndicator = false);
    setState(() {
      menuStretchScale = 1.0;
      indicatorStretchScaleY = 1;
      stretchDistance = 0;
    });
  }

  RenderBox? _getMenuRenderBox() {
    return widgetKey.currentContext?.findRenderObject() as RenderBox?;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.delta.dy < -10) {
      // Open the overlay menu in response to user swap upwards gesture
      if (!_overlayController.isShowing) {
        _overlayScaleAnimationCurve.curve = Curves.easeOut;
        _overlayController.show();
        _overlayAnimationController.forward();
      }
    }

    RenderBox? box = _getMenuRenderBox();
    final localPosition = event.localPosition;
    if (box != null) {
      final compositedPosition = localPosition + Offset(0, box.size.height);
      bool isInsideHeight = box.size.heightContains(compositedPosition);
      if (isInsideHeight) {
        // Handle indicator movement
        if (!showIndicator) setState(() => showIndicator = true);
        final realtimeIndicatorOffset =
            (compositedPosition.dy - (itemHeight * menuItemsMaxScale / 2))
                .clamp(indicatorVPadding,
                    (itemHeight * (names.length - 1)) + indicatorVPadding);
        final activeIndex = (realtimeIndicatorOffset / itemHeight).round();
        setState(() {
          indicatorOffset = (itemHeight * activeIndex) - -indicatorVPadding;
        });
      } else {
        // Handle pull & stretch effect
        stretchDistance = (compositedPosition.dy -
            (compositedPosition.dy < 0 ? 0 : box.size.height));
        if (showIndicator) {
          final mappedScale = (box.size.height +
                  stretchDistance.abs().clamp(0, maxStretchDistance)) /
              box.size.height;
          setState(() {
            menuStretchScale = 1 + 0.1 * log(mappedScale);
            indicatorStretchScaleY = 1 + 0.05 * log(mappedScale);
          });
        }
      }
    }
  }

  void _handleLongPressDown(LongPressDownDetails details) {
    HapticFeedback.lightImpact();
    _buttonAnimationController.forward();
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    if (!_overlayController.isShowing) {
      _overlayController.show();
      _overlayScaleAnimationCurve.curve = Curves.easeOutBack;
      _overlayAnimationController.forward();
      _buttonAnimationController.reverse();
      HapticFeedback.mediumImpact();
    }
  }

  void _handleLongPressEndOrCancel() {
    if (_buttonScaleAnimation.status == AnimationStatus.forward ||
        _buttonScaleAnimation.status == AnimationStatus.completed) {
      _buttonAnimationController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize overlay animation classes
    _overlayAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _overlayScaleAnimationCurve = CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeOutBack,
    );
    _overlayScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      _overlayScaleAnimationCurve,
    );
    _overlayFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _overlayAnimationController, curve: Curves.easeOut),
    );

    // Initialize button animation classes
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _buttonScaleAnimation = Tween<double>(begin: 1, end: 0.9).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInBack,
      ),
    );
    _overlayController.show();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 300),
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (context) {
          return CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.topCenter,
            followerAnchor: Alignment.bottomCenter,
            offset: const Offset(0, -20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FadeTransition(
                opacity: _overlayFadeAnimation,
                child: ScaleTransition(
                  scale: _overlayScaleAnimation,
                  alignment: Alignment.bottomCenter,
                  child: _buildOverlayMenu(),
                ),
              ),
            ),
          );
        },
        child: Listener(
          onPointerUp: (_) => _handlePointerUpOrCancel(),
          onPointerCancel: (_) => _handlePointerUpOrCancel(),
          onPointerMove: _handlePointerMove,
          child: GestureDetector(
            onLongPressDown: _handleLongPressDown,
            onLongPressCancel: _handleLongPressEndOrCancel,
            onLongPressEnd: (_) => _handleLongPressEndOrCancel(),
            onLongPressStart: _handleLongPressStart,
            child: CompositedTransformTarget(
              link: _link,
              child: ScaleTransition(
                scale: _buttonScaleAnimation,
                child: const ActionMenuButton(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayMenu() {
    return TweenAnimationBuilder(
      tween: Tween<Alignment>(
        begin: Alignment.center,
        end: Alignment(0.0, -4 * stretchDistance.sign),
      ),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (context, alignment, _) {
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 1.0, end: menuStretchScale),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          builder: (context, double value, _) {
            return Transform.scale(
              alignment: alignment,
              scaleY: value,
              scaleX: 1 - (value - 1),
              child: Container(
                key: widgetKey,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                height: itemHeight * names.length,
                width: 300,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ActionMenuIndicator(
                      scaleY: indicatorStretchScaleY,
                      offset: indicatorOffset,
                      isVisible: showIndicator,
                      alignment: Alignment(
                        0.0,
                        -10 * stretchDistance.sign,
                      ),
                    ),
                    Positioned.fill(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          names.length,
                          (index) => ActionMenuListItem(
                            label: names[index],
                            index: index,
                            scale: _getListItemScale(index),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ActionMenuButton extends StatelessWidget {
  const ActionMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.7),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 5),
          ),
        ],
      ),
      height: 60,
      width: 60,
      child: Icon(
        CupertinoIcons.share_solid,
        color: Colors.black.withOpacity(0.5),
        size: 30,
      ),
    );
  }
}

class ActionMenuListItem extends StatelessWidget {
  const ActionMenuListItem({
    super.key,
    this.index = 0,
    required this.label,
    this.scale = 1.0,
  });

  final int index;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: scale,
      curve: Curves.linearToEaseOut,
      duration: const Duration(milliseconds: 450),
      child: Container(
        height: itemHeight,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        // color: Colors.blue,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.lightPurple,
                image: DecorationImage(
                  image: AssetImage('assets/images/avatar-${index + 1}.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionMenuIndicator extends StatelessWidget {
  const ActionMenuIndicator({
    super.key,
    this.scaleY = 1.0,
    this.offset = 0,
    this.isVisible = false,
    this.alignment = Alignment.center,
  });

  final double scaleY;
  final double offset;
  final bool isVisible;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.linearToEaseOut,
      top: offset,
      left: -15,
      right: -15,
      height: itemHeight * menuItemsMaxScale,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        curve: Curves.easeIn,
        duration: const Duration(milliseconds: 300),
        child: Transform.scale(
          alignment: alignment,
          scaleY: scaleY,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension SizeExtension on Size {
  bool heightContains(Offset offset) {
    return offset.dy >= 0.0 && offset.dy < height;
  }
}

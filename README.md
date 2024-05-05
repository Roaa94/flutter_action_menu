# Flutter Action Menu

Animated action menu built with Flutter. Includes effects like the rubber band effect, different gesture handling, and haptic feedback that come together for a great interactive feel.

🔗 [Original concept](https://twitter.com/jmtrivedi/status/1610017363218563072)


https://github.com/Roaa94/flutter_action_menu/assets/50345358/0821ddbe-9a9c-48e2-93e7-11f6c1a5deb8


## The Rubber Band Effect

The pull and stretch effect in the menu is similar to the sound & brightness sliders in the iOS control center.

The effect can be achieved by adjusting the scaling and positioning by the amount of stretch value, with a logarithmic function applied to it. With #Flutter this was done with a `Transform.scale` widget that increases `scaleY`, decreases `scaleX`, and switches the `alignment` between top and bottom based on the direction of the stretching.

🔗 [The standalone widget for this rubber band slider.](https://github.com/Roaa94/flutter_action_menu/blob/main/lib/rubber_band_slider.dart)

https://github.com/Roaa94/flutter_action_menu/assets/50345358/c7eb0530-9bfe-43eb-abeb-daa8da90f027


## Overlay Menu
The overlay menu is achieved using an `OverlayPortal` widget with a combination of `CompositedTransformTarget` and `CompositedTransformFollower` widgets to correctly position the overlay

<img width="500" alt="image" src="https://github.com/Roaa94/flutter_action_menu/assets/50345358/fa9b3f34-addc-4f34-bbd0-9f27b9d75a9c">

```dart
class _OverlayPortalSkeletonState extends State<OverlayPortalSkeleton> {
  final _overlayController = OverlayPortalController();
  final _link = LayerLink();

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) {
        return CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.topCenter,
          followerAnchor: Alignment.bottomCenter,
          child: const Align(
            alignment: Alignment.bottomCenter,
            child: ActionMenu(),
          ),
        );
      },
      child: CompositedTransformTarget(
        link: _link,
        child: const ActionMenuButton(),
      ),
    );
  }
}
```

## Gestures and Haptics

With different handling of gestures, using a `Listener` and a `GestureDetector` widget, both swapping up and long pressing on the action button open the overlay, with a spring effect on the long press gesture.

With those gestures, different levels of #HapticFeedback impacts are applied for an enhanced feel of responsiveness to user touch ✨ (highly recommend you run it and experience it yourself!)

```dart
import 'package: flutter/services.dart';

// Very light vibration
HapticFeedback. lightImpact);

// Light vibration
HapticFeedback. mediumImpact);

// Medium vibration
HapticFeedback. heavyImpact);
 
// Long and high vibration
HapticFeedback. vibrate();

// Very short and light vibration
// Used to indicate UI changes, for example, in a Slider widget
HapticFeedback. selectionClick();
```


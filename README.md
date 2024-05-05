# Flutter Action Menu

Animated action menu built with Flutter. Includes effects like the rubber band effect, different gesture handling, and haptic feedback that come together for a great interactive feel.

🔗 [Original concept](https://twitter.com/jmtrivedi/status/1610017363218563072)

## The Rubber Band Effect

The pull and stretch effect in the menu is similar to the sound & brightness sliders in the iOS control center.

The effect can be achieved by adjusting the scaling and positioning by the amount of stretch value, with a logarithmic function applied to it. With #Flutter this was done with a `Transform.scale` widget that increases `scaleY`, decreases `scaleX`, and switches the `alignment` between top and bottom based on the direction of the stretching.

🔗 [The standalone widget for this rubber band slider.](https://github.com/Roaa94/flutter_action_menu/blob/main/lib/rubber_band_slider.dart)

## Overlay Menu
The overlay menu is achieved using an `OverlayPortal` widget with a combination of `CompositedTransformTarget` and `CompositedTransformFollower` widgets to correctly position the overlay

## Gestures and Haptics

With different handling of gestures, using a `Listener` and a `GestureDetector` widget, both swapping up and long pressing on the action button open the overlay, with a spring effect on the long press gesture.

Additionally, different levels of #HapticFeedback impacts are applied for an enhanced feel of responsiveness to user touch ✨ (highly recommend you run it and experience it yourself!)

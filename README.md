# flutter-memos
Just for me

## [Wiki](../../wiki)

# Snippets

## [Animation with cubits](owl_animation.dart)

<a><img src="images/owl-animation.gif" width=25%></a>

***

## [AnimationBuilder with ValueNotifier:](animation_builder_with_value_notifier.dart)

<a><img src="images/starter-with-value-notifier.gif" width=25%></a>

* I converted the Flutter starter app so that an AnimationBuilder listens to a ValueNotifier and therefore the State object can be omitted.

* * *

## [Draw text on image canvas:](draw_text_on_image_canvas.dart)

no scale:
<a><img src="images/draw-text-noscale.png"></a>

upscaled:
<a><img src="images/draw-text-upscale.png"></a>

* To display a `ui.Image` directly as a widget without having converted it to an `Image` first (you need to calculate the `width` and `height` before):

    ```dart
    return Stack(
    children: [
        Container(
        width: width,
        height: height,
        color: Colors.green,
        ),
        SizedBox(
        width: width,
        height: height,
        child: RawImage(
            image: image,
        ),
        ),
    ],
    );
    ```

* * *

## [Get text bounds:](get_text_bounds.dart)

To determine the smallest rectangle that completely encloses a single-line text:

<a><img src="images/get-text-bounds.png"></a>

* I use `TextPainter` to draw the text into a `ui.Image`. Then I search for the transparent pixels to calculate the bounds.
* The bounding rectangle can also have negative values.
* (Caution) Documentation on `TextPainter.width`: *The horizontal space required to paint this text.* Not quite right: With many fonts and italics, the space is exceeded both to the left and to the right. Therefore, I reserve some extra space for the width of the temporary image.
* (Caution) The rectangle is only correct if the text itself can determine how much space it takes up. But if there is too little space, the text may be scaled down or wrapped into multiple lines.

* * *

## [Shortcuts Intents Actions:](shortcuts_intents_actions.dart)

<a><img src="images/shortcuts-intents-actions.gif" width=50%></a>

We define a `Shortcut` (cmd+T) that applies globally to all widget trees. The `Shortcut` is associated with an `Intent`. The `Intent` in turn is connected to `Actions` in different widgets and these `Actions` are implemented differently each time: The `ColorToggler` changes the color of its button label while the `WeightToggler` changes the font of its button between normal and bold. Alternatively, the `Actions` can be called directly by pressing the button itself.

* In the `ColorToggler` and in the `WeightToggler` we cannot return `ElevatedButton` directly because we need the `BuildContext` of the `Action` widget and not that of the `ColorToggler` and `WeightToggler` respectively. Therefore we need `Builder`.

* `ValueNotifier` and `AnimationBuilder` make our work easier by making calls to `setState` unnecessary.

* * *
## [FocusableActionDetector Example from Flutter documention](focusable_action_detector_example.dart)

<a><img src="images/focusable-action-detector.gif" width=50%></a>

# measure_size

A stateful widget that measures the size of a child widget immediately after it is rendered.

__CAUTION__: Does not work with `PreferredSizeWidget`

| Measuring text and drawing an overlay with matching size |
|:--------------------------------------------------------:|
|![](demo.gif)                                             |


```dart
import 'package:measure_size/measure_size.dart';

MeasureSize(
    onChange: (Size newSize) {
        /// [newSize] will be the displayed size of [Widget child]
    },
    child: Text('Lorem ipsum dolor sit amet'),
);
```

## `MeasureSize`

#### __Required__
- **`Widget child`** - This widget will be displayed and and measured.

#### __Optional__
- **`void onChange(Size newSize)`** - A callback that is fired exactly once after the first frame of the child widget is rendered.

## Example

A quick demonstration can be found in the `example` directory. To run the example:

`flutter run example/main.dart`


## Credits
Thanks to [Gene Bo](https://stackoverflow.com/users/2162226/gene-bo) and [Dev Aggarwal](https://stackoverflow.com/users/7061265/dev-aggarwalTaken) for this code in a stackoverflow answer: https://stackoverflow.com/a/60868972
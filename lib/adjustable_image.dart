import 'dart:ui';

import 'package:flutter/widgets.dart';

typedef AddTestCallback = void Function(String name, Size size);

class AdjustableImage extends StatefulWidget {
  final String imagePath;
  final double parentHeight;
  final VoidCallback tryRebuildCallback;
  Size rawImageSize;
  bool imageLoadComplete = false;
  Size adjustSize;
  Size forceSize;
  Widget resizeImage;
  double aspectRatio;

  AdjustableImage(
      {this.imagePath,
      this.parentHeight,
      this.tryRebuildCallback,
      this.resizeImage,
      this.imageLoadComplete,
      this.adjustSize,
      this.rawImageSize,
      this.aspectRatio,
      Key key})
      : super(key: key);

  @override
  AdjustableImageState createState() => AdjustableImageState();
}

class AdjustableImageState extends State<AdjustableImage> {
  Image _image;

  @override
  void initState() {
    super.initState();

    initialize();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.resizeImage != null) {
      return widget.resizeImage;
    }

    return _image;
  }

  @override
  void dispose() {
    _image.image
        .resolve(ImageConfiguration())
        .removeListener(ImageStreamListener(onImage));

    widget.resizeImage = null;

    super.dispose();
  }

  void initialize() {
    _image = Image.asset(
      widget.imagePath,
//      width: widget.forceSize.width > 0.0 ? widget.forceSize.width : null,
//      height: widget.forceSize.height > 0.0 ? widget.forceSize.height : null,
      fit: BoxFit.scaleDown,
    );

    if (!widget.imageLoadComplete) {
      _image.image
          .resolve(ImageConfiguration())
          .addListener(ImageStreamListener(onImage));
    } else {
      _image.image
          .resolve(ImageConfiguration())
          .removeListener(ImageStreamListener(onImage));
    }
  }

  void onImage(ImageInfo image, bool synchronousCall) {
    debugPrint("Image size: ${image.image.toString()}");

    final aspectRatio = image.image.width / image.image.height;
    double width = image.image.width.toDouble();
    double height = width / aspectRatio;

    if (height > widget.parentHeight) {
      height = widget.parentHeight;
      width = height * aspectRatio;
    }

    if (width < 0) {
      width = 0;
      height = width / aspectRatio;
    }

    if (height < 0) {
      height = 0;
      width = height * aspectRatio;
    }

    widget.imageLoadComplete = true;
    widget.adjustSize = Size(width, height);
    widget.tryRebuildCallback();

    widget.aspectRatio = aspectRatio;
    widget.rawImageSize =
        Size(image.image.width.toDouble(), image.image.height.toDouble());
  }
}

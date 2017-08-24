import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

export 'package:flutter/services.dart' show NetworkImage;

/// Creates an [ImageConfiguration] based on the given [BuildContext] (and
/// optionally size).
///
/// This is the object that must be passed to [BoxPainter.paint] and to
/// [ImageProvider.resolve].
ImageConfiguration createLocalImageConfiguration(BuildContext context, {Size size}) {
  return new ImageConfiguration(
      bundle: DefaultAssetBundle.of(context),
      devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
      // TODO(ianh): provide the locale
      size: size);
}

class PlutoImage extends StatefulWidget {
  /// Creates a widget that displays an [ImageStream] obtained from the network.
  ///
  /// The [src], [scale], and [repeat] arguments must not be null.
  PlutoImage.networkWithPlaceholder(String src, this.placeHolder,
      {Key key,
        double scale: 1.0,
        this.width,
        this.height,
        this.color,
        this.fit,
        this.alignment,
        this.repeat: ImageRepeat.noRepeat,
        this.centerSlice,
        this.gaplessPlayback: false})
      : image = new NetworkImage(src, scale: scale),
        super(key: key);

  /// The image to display.
  final ImageProvider image;

  final Image placeHolder;

  /// If non-null, require the image to have this width.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  final double width;

  /// If non-null, require the image to have this height.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  final double height;

  /// If non-null, apply this color filter to the image before painting.
  final Color color;

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  final BoxFit fit;

  /// How to align the image within its bounds.
  ///
  /// An alignment of (0.0, 0.0) aligns the image to the top-left corner of its
  /// layout bounds.  An alignment of (1.0, 0.5) aligns the image to the middle
  /// of the right edge of its layout bounds.
  final FractionalOffset alignment;

  /// How to paint any portions of the layout bounds not covered by the image.
  final ImageRepeat repeat;

  /// The center slice for a nine-patch image.
  ///
  /// The region of the image inside the center slice will be stretched both
  /// horizontally and vertically to fit the image into its destination. The
  /// region of the image above and below the center slice will be stretched
  /// only horizontally and the region of the image to the left and right of
  /// the center slice will be stretched only vertically.
  final Rect centerSlice;

  /// Whether to continue showing the old image (true), or briefly show nothing
  /// (false), when the image provider changes.
  final bool gaplessPlayback;

  @override
  _ImageState createState() => new _ImageState(placeHolder);

  void debugFillDescription(List<String> description) {
    description.add('image: $image');
    if (width != null) description.add('width: $width');
    if (height != null) description.add('height: $height');
    if (color != null) description.add('color: $color');
    if (fit != null) description.add('fit: $fit');
    if (alignment != null) description.add('alignment: $alignment');
    if (repeat != ImageRepeat.noRepeat) description.add('repeat: $repeat');
    if (centerSlice != null) description.add('centerSlice: $centerSlice');
  }
}

class _ImageState extends State<PlutoImage> {
  ImageStream _imageStream;
  ImageInfo _imageInfo;
  Image placeholder;

  _ImageState(this.placeholder);

  @override
  void didChangeDependencies() {
    _resolveImage();
    super.didChangeDependencies();
  }

  @override
  void reassemble() {
    _resolveImage(); // in case the image cache was flushed
    super.reassemble();
  }

  void _resolveImage() {
    final ImageStream oldImageStream = _imageStream;
    _imageStream = widget.image.resolve(createLocalImageConfiguration(context,
        size: widget.width != null && widget.height != null ? new Size(widget.width, widget.height) : null));
    assert(_imageStream != null);
    if (_imageStream.key != oldImageStream?.key) {
      oldImageStream?.removeListener(_handleImageChanged);
      if (!widget.gaplessPlayback)
        setState(() {
          _imageInfo = null;
        });
      _imageStream.addListener(_handleImageChanged);
    }
  }

  void _handleImageChanged(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      _imageInfo = imageInfo;
    });
  }

  @override
  void dispose() {
    assert(_imageStream != null);
    _imageStream.removeListener(_handleImageChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_imageInfo != null) {
      return new RawImage(
          image: _imageInfo?.image,
          width: widget.width,
          height: widget.height,
          scale: _imageInfo?.scale ?? 1.0,
          color: widget.color,
          fit: widget.fit,
          alignment: widget.alignment,
          repeat: widget.repeat,
          centerSlice: widget.centerSlice);
    } else {
      return this.placeholder;
    }
  }

  void debugFillDescription(List<String> description) {
    description.add('stream: $_imageStream');
    description.add('pixels: $_imageInfo');
  }
}
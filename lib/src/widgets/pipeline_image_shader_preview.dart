part of '../../flutter_image_filters.dart';

class PipelineImageShaderPreview extends StatefulWidget {
  final GroupShaderConfiguration configuration;
  final TextureSource texture;
  final BlendMode blendMode;

  const PipelineImageShaderPreview({
    super.key,
    required this.configuration,
    required this.texture,
    this.blendMode = BlendMode.src,
  });

  @override
  State<PipelineImageShaderPreview> createState() => _PipelineImageShaderPreviewState();
}

class _PipelineImageShaderPreviewState extends State<PipelineImageShaderPreview> {
  Image? _currentImage;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Image>(
      future: _export(),
      builder: ((context, snapshot) {
        if (snapshot.hasError && kDebugMode) {
          debugPrint(snapshot.error.toString());
          return SingleChildScrollView(
            child: Text(snapshot.error.toString()),
          );
        }
        final image = snapshot.data;
        if (image != null) {
          _currentImage = image;
          return RawImage(image: image);
        }
        // While loading, show previous image if available, otherwise sized box
        if (_currentImage != null) {
          return RawImage(image: _currentImage!);
        }
        return SizedBox(
          width: widget.texture.size.width,
          height: widget.texture.size.height,
        );
      }),
    );
  }

  Future<Image> _export() async {
    if (kDebugMode) {
      final watch = Stopwatch();
      watch.start();
      final result = await widget.configuration.export(widget.texture, widget.texture.size);
      debugPrint(
        'Exporting image took ${watch.elapsedMilliseconds} milliseconds',
      );
      return result;
    } else {
      final result = await widget.configuration.export(widget.texture, widget.texture.size);
      return result;
    }
  }
}

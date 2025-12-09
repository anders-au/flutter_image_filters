part of '../../flutter_image_filters.dart';

class PipelineImageShaderPreview extends StatelessWidget {
  final GroupShaderConfiguration configuration;
  final TextureSource texture;
  final BlendMode blendMode;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext, Object?)? errorBuilder;
  final BoxFit boxFit;
  final FilterQuality filterQuality;
  final bool isAntiAlias;

  const PipelineImageShaderPreview({
    super.key,
    required this.configuration,
    required this.texture,
    this.blendMode = BlendMode.src,
    this.loadingBuilder,
    this.errorBuilder,
    this.boxFit = BoxFit.contain,
    this.filterQuality = FilterQuality.none,
    this.isAntiAlias = true,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Image>(
      future: _export(),
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return errorBuilder?.call(context, snapshot.error) ?? (kDebugMode
              ? SingleChildScrollView(
                  child: Text(snapshot.error.toString()),
                )
              : const SizedBox.shrink());
        }
        final image = snapshot.data;
        if (image == null) {
          return loadingBuilder?.call(context) ?? const Center(child: CircularProgressIndicator());
        }

        final raw = RawImage(
          image: image,
          filterQuality: filterQuality,
          isAntiAlias: isAntiAlias,
        );

        if (boxFit == BoxFit.contain) {
          return AspectRatio(
            aspectRatio: texture.aspectRatio,
            child: FittedBox(
              fit: boxFit,
              child: raw,
            ),
          );
        }

        return SizedBox.expand(
          child: FittedBox(
            fit: boxFit,
            child: raw,
          ),
        );
      }),
    );
  }

  Future<Image> _export() async {
    if (kDebugMode) {
      final watch = Stopwatch();
      watch.start();
      final result = await configuration.export(texture, texture.size);
      debugPrint(
        'Exporting image took ${watch.elapsedMilliseconds} milliseconds',
      );
      return result;
    } else {
      final result = await configuration.export(texture, texture.size);
      return result;
    }
  }
}

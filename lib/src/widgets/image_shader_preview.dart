part of '../../flutter_image_filters.dart';

class ImageShaderPreview extends StatefulWidget {
  final ShaderConfiguration configuration;
  final TextureSource texture;
  final BoxFit fit;
  final BlendMode blendMode;
  final bool isAntiAlias;
  final FilterQuality filterQuality;
  final bool willChange;

  const ImageShaderPreview({
    super.key,
    required this.configuration,
    required this.texture,
    this.blendMode = BlendMode.src,
    this.fit = BoxFit.contain,
    this.filterQuality = FilterQuality.none,
    this.isAntiAlias = true,
    this.willChange = true,
  });

  @override
  State<ImageShaderPreview> createState() => _ImageShaderPreviewState();
}

class _ImageShaderPreviewState extends State<ImageShaderPreview> {
  FragmentProgram? _currentProgram;

  @override
  Widget build(BuildContext context) {
    final cachedProgram = widget.configuration._internalProgram;
    if (cachedProgram != null) {
      _currentProgram = cachedProgram;
      return _buildPaint(cachedProgram);
    }
    return FutureBuilder<void>(
      future: Future.value(widget.configuration.prepare()),
      builder: ((context, snapshot) {
        if (snapshot.hasError && kDebugMode) {
          return SingleChildScrollView(
            child: Text(snapshot.error.toString()),
          );
        }
        final shaderProgram = widget.configuration._internalProgram;
        if (shaderProgram != null) {
          _currentProgram = shaderProgram;
          return _buildPaint(shaderProgram);
        }
        // While loading, show previous program if available, otherwise sized box
        if (_currentProgram != null) {
          return _buildPaint(_currentProgram!);
        }
        return SizedBox(
          width: widget.texture.size.width,
          height: widget.texture.size.height,
        );
      }),
    );
  }

  Widget _buildPaint(FragmentProgram program) {
    if (widget.fit == BoxFit.contain) {
      return AspectRatio(
        aspectRatio: widget.texture.aspectRatio,
        child: CustomPaint(
          willChange: widget.willChange,
          painter: ImageShaderPainter(
            program,
            widget.texture,
            widget.configuration,
            blendMode: widget.blendMode,
            filterQuality: widget.filterQuality,
            isAntiAlias: widget.isAntiAlias,
          ),
        ),
      );
    }
    return SizedBox.expand(
      child: CustomPaint(
        willChange: widget.willChange,
        painter: ImageShaderPainter(
          program,
          widget.texture,
          widget.configuration,
          blendMode: widget.blendMode,
          filterQuality: widget.filterQuality,
          isAntiAlias: widget.isAntiAlias,
        ),
      ),
    );
  }
}

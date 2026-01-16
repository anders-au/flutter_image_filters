part of '../../flutter_image_filters.dart';

class ImageShaderPreview extends StatelessWidget {
  final ShaderConfiguration configuration;
  final TextureSource texture;
  final BoxFit boxFit;
  final BlendMode blendMode;
  final bool isAntiAlias;
  final FilterQuality filterQuality;
  final bool willChange;
  final AlignmentGeometry alignment;
  // Called while the shader is loading
  // Falls back to a CircularProgressIndicator if not provided
  final WidgetBuilder? loadingBuilder;
  // Called when an error occurs during shader loading
  /// The error [Object] is passed as the second argument
  final Widget Function(BuildContext, Object?)? errorBuilder;
  /// Called when the shader is successfully loaded
  /// The loaded [Widget] is passed as the second argument
  final Widget Function(BuildContext, Widget)? loadedBuilder;

  const ImageShaderPreview({
    super.key,
    required this.configuration,
    required this.texture,
    this.blendMode = BlendMode.src,
    this.boxFit = BoxFit.cover,
    this.filterQuality = FilterQuality.none,
    this.isAntiAlias = true,
    this.willChange = true,
    this.alignment = Alignment.center,
    this.loadingBuilder,
    this.errorBuilder,
    this.loadedBuilder,
  });

  Widget _buildLoadedWidget(FragmentProgram shaderProgram) {
    
 
    return ClipRect(
      child: SizedBox.expand(
        child: CustomPaint(
          willChange: willChange,
          painter: ImageShaderPainter(
            shaderProgram,
            texture,
            configuration,
            blendMode: blendMode,
            filterQuality: filterQuality,
            isAntiAlias: isAntiAlias,
            boxFit: boxFit,
            alignment: alignment,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cachedProgram = configuration._internalProgram;
    if (cachedProgram != null) {
      final loadedWidget = _buildLoadedWidget(cachedProgram);
      return loadedBuilder?.call(context, loadedWidget) ?? loadedWidget;
    }
    return FutureBuilder<void>(
      future: Future.value(configuration.prepare()),
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error) ?? (kDebugMode
              ? SingleChildScrollView(
                  child: Text(snapshot.error.toString()),
                )
              : const SizedBox.shrink());
        }
        final shaderProgram = configuration._internalProgram;
        if (shaderProgram == null) {
          return loadingBuilder?.call(context) ?? const Center(child: CircularProgressIndicator());
        }
        final loadedWidget = _buildLoadedWidget(shaderProgram);
        return loadedBuilder?.call(context, loadedWidget) ?? loadedWidget;
      }),
    );
  }
}

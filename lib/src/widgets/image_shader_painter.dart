part of '../../flutter_image_filters.dart';

class ImageShaderPainter extends CustomPainter {
  ImageShaderPainter(
    this._fragmentProgram,
    this._texture,
    this._configuration, {
    this.blendMode = BlendMode.src,
    this.filterQuality = FilterQuality.none,
    this.isAntiAlias = true,
    this.boxFit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  final BlendMode blendMode;
  final ShaderConfiguration _configuration;
  final TextureSource _texture;
  final FragmentProgram _fragmentProgram;
  final bool isAntiAlias;
  final FilterQuality filterQuality;
  final BoxFit boxFit;
  final AlignmentGeometry alignment;

  @override
  void paint(Canvas canvas, Size size) {
    final aspectParameter =
        _configuration.parameters.whereType<AspectRatioParameter>().firstOrNull;
    if (aspectParameter != null) {
      aspectParameter.value = size;
      aspectParameter.update(_configuration);
    }

    final additionalTextures = _configuration.parameters
        .whereType<ShaderTextureParameter>()
        .map((e) => e.textureSource);
    final textures = [
      _texture,
      ...additionalTextures.nonNulls,
    ];

    final shader = _fragmentProgram.fragmentShader();

    final additionalSizes = additionalTextures
        .map((e) => [e?.width, e?.height])
        .expand((e) => e)
        .nonNulls
        .map((e) => e.toDouble());
    [..._configuration.numUniforms, ...additionalSizes, size.width, size.height]
        .forEachIndexed((index, value) {
      shader.setFloat(index, value);
    });

    textures.forEachIndexed((index, e) {
      shader.setImageSampler(index, e.image);
    });

    if (additionalTextures.length + 1 == textures.length) {
      final paint = Paint()
        ..shader = shader
        ..isAntiAlias = isAntiAlias
        ..filterQuality = filterQuality;
      
      // Only do BoxFit calculations for contain or cover
      if (boxFit == BoxFit.contain || boxFit == BoxFit.cover) {
        final srcRect = Rect.fromLTWH(
          0,
          0,
          _texture.width.toDouble(),
          _texture.height.toDouble(),
        );
        
        final dstRect = _calculateDestinationRect(size, srcRect.size);
        
        // Update shader size parameters to match the destination rect
        shader.setFloat(
          _configuration.numUniforms.length + additionalSizes.length,
          dstRect.width,
        );
        shader.setFloat(
          _configuration.numUniforms.length + additionalSizes.length + 1,
          dstRect.height,
        );
        
        canvas.save();
        canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
        canvas.drawRect(dstRect, paint);
        canvas.restore();
      } else {
        // Default: just fill the entire canvas
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      }
    } else {
      final paint = Paint()
        ..isAntiAlias = isAntiAlias
        ..filterQuality = filterQuality;
      
      // Only do BoxFit calculations for contain or cover
      if (boxFit == BoxFit.contain || boxFit == BoxFit.cover) {
        final srcRect = Rect.fromLTWH(
          0,
          0,
          _texture.width.toDouble(),
          _texture.height.toDouble(),
        );
        
        final dstRect = _calculateDestinationRect(size, srcRect.size);
        
        canvas.drawImageRect(
          textures.first.image,
          srcRect,
          dstRect,
          paint,
        );
      } else {
        // Default: just fill the entire canvas
        canvas.drawImageRect(
          textures.first.image,
          Rect.fromLTWH(
            0,
            0,
            textures.first.width.toDouble(),
            textures.first.height.toDouble(),
          ),
          Rect.fromLTWH(0, 0, size.width, size.height),
          paint,
        );
      }
    }
  }

  Rect _calculateDestinationRect(Size canvasSize, Size imageSize) {
    final canvasAspect = canvasSize.width / canvasSize.height;
    final imageAspect = imageSize.width / imageSize.height;

    late double width;
    late double height;

    if (boxFit == BoxFit.contain) {
      if (canvasAspect > imageAspect) {
        // Canvas is wider - fit to height
        height = canvasSize.height;
        width = height * imageAspect;
      } else {
        // Canvas is taller - fit to width
        width = canvasSize.width;
        height = width / imageAspect;
      }
    } else if (boxFit == BoxFit.cover) {
      if (canvasAspect > imageAspect) {
        // Canvas is wider - fit to width
        width = canvasSize.width;
        height = width / imageAspect;
      } else {
        // Canvas is taller - fit to height
        height = canvasSize.height;
        width = height * imageAspect;
      }
    } else {
      // Default to filling the entire canvas
      width = canvasSize.width;
      height = canvasSize.height;
    }

    // Use alignment to position the rect within the canvas
    final resolvedAlignment = alignment.resolve(TextDirection.ltr);
    final left = (canvasSize.width - width) * (resolvedAlignment.x + 1) / 2;
    final top = (canvasSize.height - height) * (resolvedAlignment.y + 1) / 2;

    return Rect.fromLTWH(left, top, width, height);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is ImageShaderPainter &&
        oldDelegate._configuration != _configuration) {
      return true;
    }
    return _configuration.needRedraw;
  }
}

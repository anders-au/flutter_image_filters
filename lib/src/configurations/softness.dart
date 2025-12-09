part of '../../flutter_image_filters.dart';

/// Configuration for the softness (blur/soften) shader.
///
/// This keeps the shader parameters separate from other effects and follows
/// the same pattern used by other ShaderConfiguration classes in the repo.
class SoftnessShaderConfiguration extends ShaderConfiguration {
  // Amount of softness to apply (0.0 = none, 1.0 = maximum)
  final NumberParameter _softnessStrength;

  // Softness radius / scale (0.0..1.0) - maps to blur radius or sampling extent in the shader
  final NumberParameter _softnessRadius;

  final String filterType;
  final String displayName;

  SoftnessShaderConfiguration()
      : _softnessStrength = ShaderRangeNumberParameter(
          'softnessStrength',
          'strength',
          0.0,
          0,
          min: 0.0,
          max: 1.0,
        ),
        _softnessRadius = ShaderRangeNumberParameter(
          'softnessRadius',
          'radius',
          0.5,
          1,
          min: 0.0,
          max: 1.0,
        ),
        filterType = 'softness',
        displayName = 'Softness',
        super([
          0.0, // softnessStrength (0)
          0.5, // softnessRadius (1)
        ]);

  // Getters
  double get softnessStrength => _softnessStrength.value.toDouble();
  double get softnessRadius => _softnessRadius.value.toDouble();

  // Setters
  set softnessStrength(double value) {
    _softnessStrength.value = value.clamp(0.0, 1.0);
    _softnessStrength.update(this);
  }

  set softnessRadius(double value) {
    _softnessRadius.value = value.clamp(0.0, 1.0);
    _softnessRadius.update(this);
  }

  @override
  List<ConfigurationParameter> get parameters => [
        _softnessStrength,
        _softnessRadius,
      ];
}

part of '../../flutter_image_filters.dart';

/// Configuration for the simplified color effect shader
class GrainShaderConfiguration extends ShaderConfiguration {
  // Required for compatibility
  final NumberParameter _grainAmount;
  final NumberParameter _grainSize;

  GrainShaderConfiguration()
      : _grainAmount = ShaderRangeNumberParameter(
          'grainAmount',
          'amount',
          0.5,
          0,
          min: 0.0,
          max: 1.0,
        ),
        _grainSize = ShaderRangeNumberParameter(
          'grainSize',
          'size',
          0.5,
          1,
          min: 0.0,
          max: 1.0,
        ),
        super([
          1.0, // amount (0)
          0.5, // grainSize (2)
        ]);


  // Core parameter getters
  double get amount => _grainAmount.value.toDouble();

  // Grain parameter getters
  double get grainSize => _grainSize.value.toDouble();

  // Core parameter setters
  set amount(double value) {
    _grainAmount.value = value;
    _grainAmount.update(this);
  }


  set grainSize(double value) {
    _grainSize.value = value;
    _grainSize.update(this);
  }

  @override
  List<ConfigurationParameter> get parameters => [
        _grainAmount,
        _grainSize,
      ];
}

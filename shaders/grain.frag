#include <flutter/runtime_effect.glsl>

out vec4 fragColor;

uniform sampler2D inputImageTexture;

layout(location = 0) uniform float grainAmount; // 0.0–1.0
layout(location = 1) uniform float grainSize;  // 0.0–1.0
layout(location = 2) uniform vec2 screenSize;


vec4 processColor(vec4 sourceColor, vec2 uv){
    if (grainAmount <= 0.0) return sourceColor;

    // constants
    const float GRAIN_MIN_SIZE_PX = 0.5;   
    const float GRAIN_MAX_SIZE_PX = 3.0; 
    const vec3 LUMINANCE_WEIGHTING = vec3(0.2126, 0.7152, 0.0722);

    // Map 0..1 → fine..coarse pixel grain size
    float grainSizePx = mix(GRAIN_MAX_SIZE_PX, GRAIN_MIN_SIZE_PX, clamp(grainSize, 0.0, 1.0));

    // Convert to sampling frequency (bigger pixel size → lower freq)
    float freq = screenSize.x / grainSizePx;

    // Hash noise
    float grain = fract(sin(dot(uv * freq, vec2(12.9898, 78.233))) * 43758.5453123);

    // Shadows get more grain, highlights less
    float lum = dot(sourceColor.rgb, LUMINANCE_WEIGHTING);
    float highlightMix = mix(1.0, 0.05, lum); // 100% → 5%

    float intensity = grainAmount * highlightMix;

    vec3 finalColor = sourceColor.rgb - grain * intensity;

    return vec4(clamp(finalColor, 0.0, 1.0), sourceColor.a);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / screenSize;
    vec4 texColor = texture(inputImageTexture, uv);
    fragColor = processColor(texColor, uv);
}

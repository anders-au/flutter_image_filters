#include <flutter/runtime_effect.glsl>

uniform sampler2D inputImageTexture;

out vec4 fragColor;

// Inputs
layout(location = 0) uniform float softnessStrength; // 0.0 to 1.0
layout(location = 1) uniform float softnessRadius;   // 0.0 to 1.0 (additional scale)
layout(location = 2) uniform vec2 screenSize;


vec4 processColor(vec4 sourceColor, vec2 textureCoordinate){
    // Early out if disabled
    if (softnessStrength <= 0.0) return sourceColor;

    float localSoft = clamp(softnessStrength, 0.0, 1.0);
    float localRadius = clamp(softnessRadius, 0.0, 1.0);

    vec2 texel = 1.0 / screenSize;

    // Subtle range for base radius to keep the effect gentle
    float baseRadius = mix(0.5, 4.0, localSoft) * mix(1.0, 1.25, localRadius);

    // Small kernel and light multi-pass blur for a softening effect
    const int K = 2;    // kernel radius -> (2*K+1) samples per pass (K=2 => 5x5)
    const int PASSES = 3;
    vec3 accum = vec3(0.0);
    float total = 0.0;

    for (int p = 0; p < PASSES; ++p) {
        float passRadius = baseRadius * (1.0 + float(p) * 0.25);
        for (int y = -K; y <= K; ++y) {
            float yOff = float(y) * texel.y * passRadius / float(max(1, K));
            for (int x = -K; x <= K; ++x) {
                float xOff = float(x) * texel.x * passRadius / float(max(1, K));
                vec2 sampleUV = clamp(textureCoordinate + vec2(xOff, yOff), vec2(0.0), vec2(1.0));
                accum += texture(inputImageTexture, sampleUV).rgb;
                total += 1.0;
            }
        }
    }

    vec3 blur = accum / total;

    // Small perceptible boost so softness is visible at low strengths
    blur = clamp(blur * mix(1.0, 1.12, localSoft), 0.0, 1.0);

    // Keep overall blend subtle
    float blend = clamp(localSoft * 0.45, 0.0, 1.0);

    vec3 orig = sourceColor.rgb;
    vec3 result = mix(orig, blur, blend);

    return vec4(result, sourceColor.a);
}

void main() {
    vec2 textureCoordinate = FlutterFragCoord().xy / screenSize;
    vec4 textureColor = texture(inputImageTexture, textureCoordinate);
    fragColor = processColor(textureColor, textureCoordinate);
}

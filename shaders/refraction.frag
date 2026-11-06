#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

// Slots 0 & 1: Automatically set by Flutter Engine (pixel dimensions of clipped backdrop)
uniform vec2 uSize;

// Custom float uniforms
// Slot 2: Refraction strength (0.0 to 1.0)
uniform float uRefraction;
// Slot 3: Chromatic dispersion / aberration (0.0 to 1.0)
uniform float uDispersion;
// Slot 4: Bevel rim width in pixels (e.g. 20.0 px)
uniform float uBevelWidth;
// Slot 5: Light source angle in radians
uniform float uLightAngle;
// Slot 6: Specular highlight intensity (0.0 to 1.0)
uniform float uSpecular;
// Slot 7: Corner radius in pixels (e.g. 24.0 px)
uniform float uCornerRadius;
// Slot 8: Center lens magnification factor (e.g. 1.02)
uniform float uMagnification;

// Sampler 0: Automatically bound to the backdrop texture
uniform sampler2D uTexture;

out vec4 fragColor;

// Exact Signed Distance Function (SDF) of a rounded rectangle
float sdRoundedBox(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + vec2(r);
    return min(max(q.x, q.y), 0.0) + length(max(q, vec2(0.0))) - r;
}

// Exact surface normal derived from the rounded box SDF gradient
vec2 getRoundedBoxNormal(vec2 p, vec2 b, float r) {
    float eps = 0.5;
    float dx = sdRoundedBox(p + vec2(eps, 0.0), b, r) - sdRoundedBox(p - vec2(eps, 0.0), b, r);
    float dy = sdRoundedBox(p + vec2(0.0, eps), b, r) - sdRoundedBox(p - vec2(0.0, eps), b, r);
    vec2 n = vec2(dx, dy);
    float len = length(n);
    return len > 1e-4 ? (n / len) : vec2(0.0);
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uSize;

    #ifdef IMPELLER_TARGET_OPENGLES
    uv.y = 1.0 - uv.y;
    #endif

    vec2 halfSize = uSize * 0.5;
    vec2 p = fragCoord - halfSize;
    float maxRadius = min(halfSize.x, halfSize.y);
    float radius = clamp(uCornerRadius, 0.0, maxRadius);
    float bevelWidth = clamp(uBevelWidth, 6.0, maxRadius);

    // Exact signed distance to rounded box boundary (negative inside, 0 at border)
    float d = sdRoundedBox(p, halfSize, radius);
    float distFromBorder = -d;

    // Inside the glass container bevel rim:
    // t = 0 at the outer border edge, t = 1 at the interior flat boundary
    float t = clamp(distFromBorder / bevelWidth, 0.0, 1.0);

    // Organic meniscus curve: slope is steep at the edge (1.0) and smoothly flattens to 0 at the interior
    float slope = sin((1.0 - t) * 1.5707963);

    // Exact outward surface normal at current fragment
    vec2 outwardNormal = getRoundedBoxNormal(p, halfSize, radius);

    // 1. Optical Refraction Displacement (Snell's Law)
    // Refracts background pixels along the curved bevel rim
    float maxDisplacement = uRefraction * 8.0;
    vec2 pixelDisplacement = -outwardNormal * (slope * maxDisplacement);
    vec2 uvDisplacement = pixelDisplacement / uSize;

    // 2. Chromatic Dispersion (Wavelength-dependent refractive separation)
    float dispFactor = uDispersion * 0.30 * slope;
    vec2 uvG = uv + uvDisplacement;
    vec2 uvR = uv + uvDisplacement * (1.0 - dispFactor);
    vec2 uvB = uv + uvDisplacement * (1.0 + dispFactor);

    // Clamp UVs to avoid sampler bleeding
    uvR = clamp(uvR, vec2(0.001), vec2(0.999));
    uvG = clamp(uvG, vec2(0.001), vec2(0.999));
    uvB = clamp(uvB, vec2(0.001), vec2(0.999));

    float r = texture(uTexture, uvR).r;
    float g = texture(uTexture, uvG).g;
    float b = texture(uTexture, uvB).b;
    float a = texture(uTexture, uvG).a;

    // 3. Incident Specular Caustic Glint & Ambient Bounce (Pure additive luminosity)
    vec2 lightSourceDir = vec2(cos(uLightAngle), sin(uLightAngle));
    float nDotL = max(dot(outwardNormal, lightSourceDir), 0.0);
    float specularGlint = pow(nDotL, 5.0) * slope * uSpecular * 0.40;
    float bounceRim = pow(max(dot(-outwardNormal, lightSourceDir), 0.0), 3.0) * slope * uSpecular * 0.12;

    vec3 finalColor = vec3(r, g, b) + vec3(specularGlint + bounceRim);

    fragColor = vec4(finalColor, a);
}

#include <metal_stdlib>
using namespace metal;

// PrayerLock signature shader library.
// All functions are [[stitchable]] so SwiftUI can address them via ShaderLibrary.
// colorEffect:      half4 f(float2 pos, half4 color, <uniforms...>)   — per-pixel recolor
// distortionEffect: float2 f(float2 pos, <uniforms...>)              — per-pixel resample
// Colors are premultiplied-alpha half4. Keep math cheap: these run every frame full-screen.

// ---- helpers ---------------------------------------------------------------

static inline float hash21(float2 p) {
    return fract(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
}

// ---- paperGrain ------------------------------------------------------------
// Warm paper: subtle animated film grain + a soft radial vignette over the fill.
[[stitchable]] half4 paperGrain(float2 pos, half4 color, float2 size, float time, float intensity) {
    float2 uv = pos / size;
    float n = hash21(floor(pos) + floor(time * 24.0));
    half grain = half((n - 0.5) * 0.05 * intensity);
    float2 c = uv - 0.5;
    // Gentle vignette — strong corner darkening reads as a curved/warped sheet.
    float vig = 1.0 - dot(c, c) * 0.12;
    half3 rgb = color.rgb * half(vig) + grain * color.a;
    return half4(rgb, color.a);
}

// ---- goldFoil --------------------------------------------------------------
// Gild ONLY the gold-ish pixels of a mixed headline (accent words), leaving dark
// ink text untouched — a slow anisotropic sheen sweeps across, like gold leaf.
[[stitchable]] half4 goldFoil(float2 pos, half4 color, float2 size, float time) {
    half a = color.a;
    if (a < 0.01h) return color;
    half3 c = color.rgb / max(a, 0.001h);            // un-premultiply
    bool isGold = (c.r > 0.40h) && (c.r > c.b + 0.10h);
    if (!isGold) return color;                        // leave ink glyphs as-is
    float2 uv = pos / size;
    float d = uv.x + uv.y * 0.35;
    float sheen = 0.5 + 0.5 * sin((d - time * 0.28) * 9.0);
    sheen = pow(sheen, 2.2);
    half3 base = half3(0.62h, 0.45h, 0.22h);
    half3 hi   = half3(0.95h, 0.79h, 0.47h);
    half3 g = mix(base, hi, half(sheen));
    return half4(g * a, a);
}

// ---- godRays ---------------------------------------------------------------
// Additive warm volumetric rays radiating from a source point (dark insight beats).
[[stitchable]] half4 godRays(float2 pos, half4 color, float2 size, float time, float2 src, float strength) {
    float2 uv = pos / size;
    float2 dir = uv - src;
    float ang = atan2(dir.y, dir.x);
    float dist = length(dir);
    float rays = 0.5 + 0.5 * sin(ang * 16.0 + sin(ang * 6.0 + time * 0.25) * 2.0);
    rays = pow(rays, 3.0);
    float falloff = smoothstep(1.15, 0.0, dist);
    float glow = exp(-dist * 2.2);
    half3 warm = half3(0.88h, 0.71h, 0.40h);
    half add = half((rays * 0.09 + glow * 0.16) * falloff * strength);
    return half4(color.rgb + warm * add, color.a);
}

// ---- auroraBreath ----------------------------------------------------------
// Slow undulating warm field with a radial bloom that expands on inhale (breath→1)
// and contracts on exhale (breath→0). The prayer screen's living background.
[[stitchable]] half4 auroraBreath(float2 pos, half4 color, float2 size, float time, float breath) {
    float2 uv = pos / size;
    float2 c = uv - 0.5;
    float f = sin(uv.x * 3.0 + time * 0.20)
            + sin(uv.y * 2.4 - time * 0.16)
            + sin((uv.x + uv.y) * 2.0 + time * 0.12);
    f /= 3.0;
    float r = length(c) * (1.65 - breath * 0.55);
    float bloom = smoothstep(0.95, 0.0, r) * (0.35 + breath * 0.65);
    half3 warm = half3(0.86h, 0.66h, 0.36h);
    half3 cool = half3(0.80h, 0.75h, 0.63h);
    half3 tint = mix(cool, warm, half(0.5 + 0.5 * f));
    return half4(mix(color.rgb, tint, half(bloom * 0.45)), color.a);
}

// ---- shimmerSweep ----------------------------------------------------------
// A bright diagonal highlight band that sweeps across (CTAs, freshly-earned stats).
[[stitchable]] half4 shimmerSweep(float2 pos, half4 color, float2 size, float time) {
    if (color.a < 0.01h) return color;
    float2 uv = pos / size;
    float band = uv.x + uv.y * 0.20;
    float phase = fract(time * 0.35);
    float dd = abs(band - (phase * 1.6 - 0.3));
    float m = smoothstep(0.14, 0.0, dd);
    half3 rgb = color.rgb + half3(1.0h) * half(m * 0.32) * color.a;
    return half4(rgb, color.a);
}

// ---- unlockBloom -----------------------------------------------------------
// An expanding warm ring + central glow — the visual half of the unlock payoff.
[[stitchable]] half4 unlockBloom(float2 pos, half4 color, float2 size, float progress) {
    float2 uv = pos / size;
    float2 c = uv - 0.5;
    float r = length(c);
    float ring = smoothstep(0.035, 0.0, abs(r - progress * 0.95)) * (1.0 - progress);
    float core = exp(-r * 4.0) * progress;
    half3 warm = half3(0.96h, 0.81h, 0.46h);
    half add = half(ring * 0.55 + core * 0.35);
    return half4(color.rgb + warm * add, color.a);
}

// ---- liquidRefraction ------------------------------------------------------
// Radial ripple that refracts the layer outward from a center (unlock / state change).
[[stitchable]] float2 liquidRefraction(float2 pos, float2 size, float time, float2 center, float amount) {
    float2 ctr = center * size;
    float2 d = pos - ctr;
    float dist = length(d);
    float wave = sin(dist * 0.09 - time * 11.0) * exp(-dist * 0.010) * amount;
    float2 dir = dist > 0.001 ? d / dist : float2(0.0);
    return pos + dir * wave;
}

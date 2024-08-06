//
//  Shaders.metal
//  Doku
//
//  Created by Ege Çam on 6.08.2024.
//

using namespace metal;
#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>

[[ stitchable ]] half4 noise(float2 position, half4 currentColor, float time) {
    float value = fract(sin(dot(position + time, float2(12.9898, 78.233))) * 43758.5453);
    return half4(value, value, value, 1) * currentColor.a;
}

//
//  Shaders.metal
//  RefractionAndFun
//
//  Created by Maciek Czarnik on 13/02/2024.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    float3 position [[ attribute(0) ]];
    float3 normal   [[ attribute(1) ]];
} VertexInput;

typedef struct {
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 modelViewMatrix;
    float4x4 projectionMatrix;
    float4x4 viewProjectionMatrix;
    float4x4 modelViewProjectionMatrix;
} VertexUniforms;

typedef struct {
  float4 position [[position]];
} CustomVertexData;

vertex CustomVertexData vertexFunction(
  VertexInput in [[stage_in]],
  constant VertexUniforms &uniforms [[buffer(2)]]
) {
  return CustomVertexData {
    .position = uniforms.modelViewProjectionMatrix * float4(in.position, 1)
  };
}

typedef struct {
  float2 resolution;
} FragmentUniforms;

fragment float4 fragmentFunction(
  CustomVertexData in [[stage_in]],
  constant FragmentUniforms &uniforms [[buffer(0)]],
  texture2d<float, access::sample> backgroundTexture [[texture(0)]]
) {
  float2 resolution = float2(backgroundTexture.get_width(), backgroundTexture.get_height());
  float2 uv = in.position.xy / resolution;

  constexpr sampler s;
  const float4 backgroundSample = backgroundTexture.sample(s, uv);
  return backgroundSample;
}

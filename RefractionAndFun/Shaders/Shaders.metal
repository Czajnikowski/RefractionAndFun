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
    float4x4 inverseModelViewProjectionMatrix;
    float4x4 inverseViewMatrix;
    float3x3 normalMatrix;
    float4 viewport;
    float3 worldCameraPosition;
} VertexUniforms;

typedef struct {
  float4 position [[position]];
  float3 eye;
  float3 surfaceNormal;
} CustomVertexData;

vertex CustomVertexData vertexFunction(
  VertexInput in [[stage_in]],
  constant VertexUniforms &uniforms [[buffer(2)]]
) {
  float4 modelPosition = float4(in.position, 1);
  return CustomVertexData {
    .position = uniforms.modelViewProjectionMatrix * modelPosition,
    .eye = normalize((uniforms.modelMatrix * modelPosition).xyz - uniforms.worldCameraPosition),
    .surfaceNormal = normalize(in.normal * uniforms.normalMatrix)
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
  float rIoR = 1.29768;
  float gIoR = 1.3;
  float bIoR = 1.3054;
  
  float2 resolution = float2(backgroundTexture.get_width(), backgroundTexture.get_height());
  float2 uv = in.position.xy / resolution;
  
  float3 rRefraction = refract(in.eye, in.surfaceNormal, 1.0 / rIoR);
  float3 gRefraction = refract(in.eye, in.surfaceNormal, 1.0 / gIoR);
  float3 bRefraction = refract(in.eye, in.surfaceNormal, 1.0 / bIoR);
  
  float3x2 refractedUV = float3x2(
    uv - rRefraction.xy,
    uv - gRefraction.xy,
    uv - bRefraction.xy
  );
  
  constexpr sampler s;

  const float dispersionSampleCount = 10;

  float3 color = 0;
  for (float dispersionSampleIndex = 0; dispersionSampleIndex < dispersionSampleCount; dispersionSampleIndex++) {
    const float dispersionOffset = dispersionSampleIndex / dispersionSampleCount * 0.01;
    
    color.r += backgroundTexture.sample(s, refractedUV[0] + dispersionOffset).r;
    color.g += backgroundTexture.sample(s, refractedUV[1] + dispersionOffset).g;
    color.b += backgroundTexture.sample(s, refractedUV[2] + dispersionOffset).b;
  }
  
  color /= dispersionSampleCount;
  
  return float4(color, 1);
}

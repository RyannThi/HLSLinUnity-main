Shader "PUCMyShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalTex("Texture", 2D) = "white" {}
        _Specular("Specular", Range(-2,2)) = 1
        _NormalStrength("Normal Strength", Range(-2,2)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
 
        Pass
        {
            HLSLPROGRAM 
                #pragma vertex vert
                #pragma fragment frag
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

                texture2D _MainTex;
                float4 _MainTex_ST;
                SamplerState sampler_MainTex;

                texture2D _NormalTex;
                SamplerState sampler_NormalTex;

                float _Specular;
                float4 _NormalStrength;

                struct AppData
                {
                    float4 position : POSITION;
                    float2 uv       : TEXCOORD0;
                    half3 normal   : NORMAL;
                };
                struct VertexData
                {
                    float4 positionVAR : SV_POSITION;
                    float2 uvVAR       : TEXCOORD0;
                    half3 normalVAR   : NORMAL;
                };
                
 
                VertexData vert(AppData appData)
                {
                    VertexData newVertexData;
 
                    newVertexData.positionVAR = TransformObjectToHClip(appData.position.xyz);
                    newVertexData.uvVAR = appData.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                    newVertexData.normalVAR = TransformObjectToWorldNormal(appData.normal);
 
                    return newVertexData;
                }

                float4 frag(VertexData vData) : SV_TARGET
                {
                    float4 color = _MainTex.Sample(sampler_MainTex, vData.uvVAR);

                    float4 normalMap = _NormalTex.Sample(sampler_NormalTex, half2(vData.uvVAR.x + _Time.x, vData.uvVAR.y));
                    float4 normalMap2 = _NormalTex.Sample(sampler_NormalTex, half2(vData.uvVAR.x, vData.uvVAR.y + _Time.x) * 0.7);

                    normalMap *= normalMap2;

                    half3 normal = vData.normalVAR * normalMap.xzy * _NormalStrength;

                    float3 viewDir = normalize(_WorldSpaceCameraPos - vData.positionVAR);

                    Light light = GetMainLight();

                    float intensity = dot(light.direction, normal);

                    float specular = max(0, dot(normalize(light.direction), normalMap));

                    //color *= intensity;
                    color += half4(light.color, 1) * saturate(specular) * _Specular;

                    return color;
                }
 
 
            ENDHLSL
        }
    }
}
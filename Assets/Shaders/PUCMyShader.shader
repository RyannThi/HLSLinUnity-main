Shader "PUCMyShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalTex("Texture", 2D) = "white" {}
        _Specular("Specular", Range(-2,2)) = 1
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

                    float3 viewDir = normalize(_WorldSpaceCameraPos - vData.positionVAR);

                    Light light = GetMainLight();
                    float intensity = dot(light.direction, vData.normalVAR);

                    float specular = dot(normalize(viewDir + light.direction), vData.normalVAR);

                    color += half4(light.color, 1) * saturate(specular) * _Specular;

                    return color * intensity;
                }
 
 
            ENDHLSL
        }
    }
}
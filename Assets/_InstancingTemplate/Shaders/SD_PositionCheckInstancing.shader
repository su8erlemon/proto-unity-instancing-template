Shader "Custom/SD_PositionCheckInstancing"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        
        _SmoothTex ("SmoothTex (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5

        _MetalTex ("MetalTex (RGB)", 2D) = "white" {}
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _OcclusionTex ("OcclusionTex", 2D) = "white" {}
        _OcclusionScale ("OcclusionScale", Range(0,1)) = 1.0

        _EmissionTex ("EmissionTex", 2D) = "white" {}
        _Emissioness ("Emissioness", Float) = 0.0
        _BaseEmissioness ("_BaseEmissioness", Float) = 0.0

        [Normal]_NormalTex ("NormalTex (RGB)", 2D) = "bump" {}
        _NormalScale ("NormalScale", Float) = 1.0
        
        [Normal]_NormalTex2 ("NormalTex2 (RGB)", 2D) = "bump" {}
        _NormalScale2 ("NormalScale2", Float) = 1.0

        _ParticleTime ("ParticleTime", Float) = 0.0

		_Scale("Scale", Range(0,10)) = 0.0

    }
    
    SubShader
    {
        // Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
        Tags { "RenderType"="Opaque" }
        LOD 200
        Cull Off

        // Blend SrcAlpha OneMinusSrcAlpha 

        CGPROGRAM

		#include "UnityCG.cginc"
        #include "Assets/CjLib/Shader/Math/Quaternion.cginc"

        // Physically based Standard lighting model, and enable shadows on all light types
        // #pragma surface surf StandardTranslucent fullforwardshadows vertex:vert addshadow
        // #pragma surface surf Standard fullforwardshadows vertex:vert addshadow alpha
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow 
        // #pragma multi_compile_instancing
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 5.0

        #ifdef SHADER_API_D3D11
            StructuredBuffer<float3> _PositionBuffer;
        #endif

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalTex2;
			float4 vertex;
            float index;
            float alpha;
            UNITY_FOG_COORDS(1)
        };

        struct appdata {
            float4 vertex : POSITION;
            float4 tangent : TANGENT;
            float3 normal : NORMAL;
            float4 texcoord : TEXCOORD0;
            float4 texcoord1 : TEXCOORD1;
            float4 texcoord2 : TEXCOORD2;
            float4 texcoord3 : TEXCOORD3;
        #if defined(SHADER_API_XBOX360)
            half4 texcoord4 : TEXCOORD4;
            half4 texcoord5 : TEXCOORD5;
        #endif
            fixed4 color : COLOR;
            UNITY_VERTEX_INPUT_INSTANCE_ID
            uint index : SV_InstanceID;
            uint id : SV_VertexID;
        };

        sampler2D _MainTex;
        sampler2D _OcclusionTex;
        sampler2D _NormalTex;
        sampler2D _NormalTex2;
        sampler2D _MetalTex;
        sampler2D _SmoothTex;
        sampler2D _EmissionTex;
		sampler2D _Thickness;

        half _Glossiness;
        half _Emissioness;
        half _BaseEmissioness;
        half _Metallic;
        float _OcclusionScale;
        float _NormalScale;
        float _NormalScale2;

        fixed4 _Color;
        float _ParticleTime;

		float _Scale;

        float3 _WorldPosition;
        float4 _WorldRotation;

       
        float inoutStep(float minValue, float maxValue, float value){
            return ( value < minValue ) ? smoothstep(0.0,1.0,1.0 - ((minValue - value) / minValue)) : smoothstep(0.0,1.0, 1.0 - ((value-maxValue) / (1.0 - maxValue)));
        }


        float4 modify(float4 pos, float index) {
          
            float4 p = pos;

            #ifdef SHADER_API_D3D11
                p.xyz *= 0.1;
                p.xyz += _PositionBuffer[index].xyz;
                p.xyz = quat_rot(_WorldRotation,p.xyz);
                p.xyz += _WorldPosition.xyz;
            #endif
            
            return float4(p.xyz,pos.w);
        }
        
        void vert (inout appdata v, out Input o) {
        
            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_INITIALIZE_OUTPUT(Input, o);

            // instancing unique ID
            float index = v.index;
            
            float4 pos = modify(v.vertex, index);
            float4 tangent = v.tangent;
            float4 normal = float4(v.normal.xyz,1.0);
            float3 binormal = normalize(cross(normal, tangent));

            float delta = 0.001;
            float4 posT = modify(v.vertex + tangent * delta, index);
            float4 posB = modify(v.vertex + float4(binormal,1.0) * delta, index);

            float4 modifiedTangent = posT - pos;
            float4 modifiedBinormal = posB - pos;
            v.normal = normalize(cross(modifiedTangent, modifiedBinormal));            
            v.vertex = pos;
    
            o.vertex = v.vertex;
            o.index = v.index;
            o.alpha = 1.0;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;;

            o.Normal =  UnpackScaleNormal ( tex2D (_NormalTex, IN.uv_MainTex), _NormalScale);
            o.Normal += UnpackScaleNormal ( tex2D (_NormalTex2, IN.uv_NormalTex2), _NormalScale2);
            o.Occlusion = tex2D (_OcclusionTex, IN.uv_MainTex).r*_OcclusionScale;
            o.Metallic = tex2D (_MetalTex, IN.uv_MainTex) * _Metallic;
            o.Smoothness = tex2D (_SmoothTex, IN.uv_MainTex) * _Glossiness;
            o.Emission = _BaseEmissioness + tex2D (_EmissionTex, IN.uv_MainTex) * _Emissioness;

            o.Alpha = IN.alpha;

        }
        ENDCG
    }
    FallBack "Diffuse"
}
//Snow shader using texture paint in runtime and displacement over a tesselation of a plane.
Shader "Custom/snowShader"
{
    Properties
    {
        _Tess ("Tessellation", Range(1,512)) = 512

        _SnowColor ("SnowColor", Color) = (1,1,1,1)
        _SnowTex ("Snow (RGB)", 2D) = "white" {}
        _SnowAO ("Snow Ambient Oclusion", 2D) = "White" {}

        _GroundColor ("GroundColor", Color) = (1,1,1,1)
        _GroundTex ("Ground (RGB)", 2D) = "white" {}
        _GroundAO ("Ground Ambient Oclusion", 2D) = "White" {}
        _AountAO("AO multiplier", Range(0, 10)) = 0

        _Splat ("SplatMap", 2D) = "black" {}

        _BumpMap ("Bump Map", 2D) = "bump" {}

        _Displacement ("Displacement", Range(0, 1.0)) = 0.3
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 500

        CGPROGRAM

        #pragma surface surf Standard addshadow fullforwardshadows vertex:disp tessellate:tessDistance nolightmap

        #pragma target 5.0
        #include "Tessellation.cginc"

        struct appdata {
            float4 vertex : POSITION;
            float4 tangent : TANGENT;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;
        };

        float _Tess;

        float4 tessDistance (appdata v0, appdata v1, appdata v2) {
            float minDist = 1.0;
            float maxDist = 20.0;
            return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
        }

        sampler2D _Splat;
        float _Displacement;

        void disp (inout appdata v)
        {
            if(v.normal.y > 0.5){
                //Calcula el displacement de la capa R de la textura RGB
                float dr = tex2Dlod(_Splat, float4(v.texcoord.xy,0,0)).r * _Displacement;
                //Calcula el displacement de la capa G de la textura RGB
                float dg = tex2Dlod(_Splat, float4(v.texcoord.xy,0,0)).g * _Displacement / 4;

                //Aplica el displacement de la deformacion
                v.vertex.xyz += v.normal * dg;
                v.vertex.xyz -= v.normal * dr;

                v.vertex.xyz += v.normal * _Displacement; //Displace the vertex upwards to have the collider on the bottom.
            }
        }


        sampler2D _SnowTex;
        fixed4 _GroundColor;
        sampler2D _SnowAO;

        sampler2D _GroundTex;
        fixed4 _SnowColor;
        sampler2D _GroundAO;

        struct Input
        {
            float2 uv_GroundTex;
            float2 uv_GroundAO;

            float2 uv_SnowTex;
            float2 uv_SnowAO;

            float2 uv_Splat;

            float2 uv_BumpMap;
        };

        half _Glossiness;
        half _Metallic;
        half _AountAO;

        sampler2D _BumpMap;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            half amount = tex2Dlod(_Splat, float4(IN.uv_Splat,0,0)).r;
            fixed4 c = lerp(tex2D (_SnowTex, IN.uv_SnowTex) * _SnowColor, tex2D (_GroundTex, IN.uv_GroundTex) * _GroundColor, amount);

            fixed4 Occ = lerp(tex2D (_SnowAO, IN.uv_SnowAO), tex2D (_GroundAO, IN.uv_GroundAO), _AountAO);

            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;

            o.Alpha = Occ.a;
            //o.Occlusion = Occ.r;
            o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
        }
        ENDCG
    }
    FallBack "Diffuse"
}

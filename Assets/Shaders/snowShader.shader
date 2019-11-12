//Snow shader using texture paint in runtime and displacement over a tesselation of a plane.
Shader "Custom/snowShader"
{
    Properties
    {
        _Tess ("Tessellation", Range(1,128)) = 128

        _SnowColor ("SnowColor", Color) = (1,1,1,1)
        _SnowTex ("Snow (RGB)", 2D) = "white" {}
        _SnowAO ("Snow Ambient Oclusion", 2D) = "White" {}

        _GroundColor ("GroundColor", Color) = (1,1,1,1)
        _GroundTex ("Ground (RGB)", 2D) = "white" {}
        _GroundAO ("Ground Ambient Oclusion", 2D) = "White" {}
        _AountAO("AO multiplier", Range(0, 10)) = 0

        _Splat ("SplatMap", 2D) = "white" {}

        _BumpMap ("Bump Map", 2D) = "bump" {}

        _Displacement ("Displacement", Range(0, 1.0)) = 0.3


        _Distortion ("Distortion", Range(0,1)) = 0.0
        _Scale ("Scale", Range(0,1)) = 0.0
        _Ambient ("Ambient", Range(0,1)) = 0.0
        
        _Power ("Power", Range(0,1)) = 0.0
        _Attenuation ("Attenuation", Range(0,1)) = 0.0

        _LocalThickness("Local Thickness", 2D) = "white" {}

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

        CGPROGRAM

        #pragma surface surf StandardTranslucent addshadow fullforwardshadows vertex:disp tessellate:tessDistance nolightmap

        #pragma target 4.6
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
            float maxDist = 15.0;
            return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
        }

        sampler2D _Splat;
        float _Displacement;

        void disp (inout appdata v)
        {
            //if(v.normal.y > 0.5){
                //Calcula el displacement de la capa R de la textura RGB
                float dr = tex2Dlod(_Splat, float4(v.texcoord.xy,0,0)).r * _Displacement;
                
                //Calcula el displacement de la capa G de la textura RGB
                float dg = tex2Dlod(_Splat, float4(v.texcoord.xy,0,0)).g * _Displacement / 4;

                //Aplica el displacement de la deformacion
                v.vertex.xyz += v.normal * dg;
                v.vertex.xyz -= v.normal * dr;

                //Displace the vertex upwards to have the collider on the bottom.   
                v.vertex.xyz += v.normal * _Displacement;
            //}
        }


        sampler2D _SnowTex;
        fixed4 _GroundColor;
        sampler2D _SnowAO;

        sampler2D _GroundTex;
        fixed4 _SnowColor;
        sampler2D _GroundAO;

        sampler2D _LocalThickness;

        struct Input
        {
            float2 uv_GroundTex;
            float2 uv_GroundAO;

            float2 uv_SnowTex;
            float2 uv_SnowAO;

            float2 uv_Splat;

            float2 uv_BumpMap;

            float2 uv_LocalThickness;
        };

        half _Distortion;
        half _Scale;
        half _Ambient;
        half _Power;
        half _Attenuation;

        fixed4 thickness;


        #include "UnityPBSLighting.cginc"
        inline fixed4 LightingStandardTranslucent(SurfaceOutputStandard s, fixed3 viewDir, UnityGI gi)
        {
            // Original colour
            fixed4 pbr = LightingStandard(s, viewDir, gi);
            
            // --- Translucency ---
            float3 L = gi.light.dir;
            float3 V = viewDir;
            float3 N = s.Normal;
            
            float3 H = normalize(L + N * _Distortion);
            float VdotH = pow(saturate(dot(V, -H)), _Power) * _Scale;
            float3 I = _Attenuation * (VdotH + _Ambient) * thickness;
            
            pbr.rgb = pbr.rgb + gi.light.color * I;

            return pbr;
        }
        
        void LightingStandardTranslucent_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
        {
            LightingStandard_GI(s, data, gi);		
        }

        half _AmountAO;

        sampler2D _BumpMap;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            half amount = tex2Dlod(_Splat, float4(IN.uv_Splat,0,0)).r;

            fixed4 c = lerp(tex2D (_SnowTex, IN.uv_SnowTex) * _SnowColor, tex2D (_GroundTex, IN.uv_GroundTex) * _GroundColor, amount);

            fixed4 Occ = lerp(tex2D (_SnowAO, IN.uv_SnowAO), tex2D (_GroundAO, IN.uv_GroundAO), _AmountAO);

            o.Albedo = c.rgb;
            o.Alpha = Occ.a;
            o.Occlusion = Occ.r;
            thickness = 1 / tex2D (_LocalThickness, IN.uv_LocalThickness).r;
            o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
        }
        ENDCG
    }
    FallBack "Diffuse"
}

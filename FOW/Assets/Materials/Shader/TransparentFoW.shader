Shader "Custom/TransparentFoW" { 
	Properties { 
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_ShadowIntensity ("Shadow Intensity", Range (0, 1)) = 0.6
	} 
	SubShader { 


		Tags {
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent"
		}
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard alpha fullforwardshadows approxview
		#pragma target 3.0

		float4 _Color;
		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutputStandard o) {
 
			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			if (tex.a < 0.2)
            {
               discard;
            }
			o.Albedo = tex.rgb;
			o.Alpha = tex.a;

		}
		ENDCG

//		Pass {
//            ZWrite On
//            ColorMask 0
//        }

		// Shadow Pass : Adding the shadows (from Directional Light)
		// by blending the light attenuation
		Pass {
			Name "ShadowPass"
			Tags {"LightMode" = "ForwardBase"}
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM 
//			// Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members lightDir)
			#pragma exclude_renderers d3d11 xbox360

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma fragmentoption ARB_fog_exp2
			#pragma fragmentoption ARB_precision_hint_fastest

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
 
			struct v2f { 
				float2 uv : TEXCOORD1;
				float4 pos : SV_POSITION;
				float3 lightDir : COLOR;
				LIGHTING_COORDS(3,4)
			};
 
 			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float _ShadowIntensity;
 
			v2f vert (appdata_full v)
			{
				v2f o;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.lightDir = ObjSpaceLightDir( v.vertex );
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}

			fixed4 frag (v2f i) : COLOR
			{ 
				float atten = LIGHT_ATTENUATION(i);
				fixed4 col =  tex2D(_MainTex, i.uv) * _Color;
				//fixed4 c = fixed4(0,0,0,0);
				col.a = (1-atten) * _ShadowIntensity * col.a; 
				//return c;
				return col;
			}
			ENDCG
		}
 
	}
 
	FallBack "Diffuse"
}
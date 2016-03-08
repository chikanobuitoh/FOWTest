Shader "Custom/FoWStandard" {
	Properties {
		_Color ("MaterialColor", Color) = (1,1,1,1)
		_AmbColor ("ShadowColor", Color) = (0,0,0,0)
		_WrapAmount ("ShadowPow", Range (1.0, 0.5)) = 0.5 
		_MainTex ("MainTexture (RGB)", 2D) = "white" {}
		//_Glossiness ("Smoothness", Range(0,1)) = 0.5
		//_Metallic ("Metallic", Range(0,1)) = 0.0
		[HideInInspector] _ShadowTex("Shadow", 2D) = "black" {}
		[HideInInspector] _FieldZero("areaZero",Vector) = (1,1,1,1) 
		[HideInInspector] _FieldWide("areaField",Vector) = (1,1,1,1)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass{
		 	Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma fragmentoption ARB_fog_exp2
            #pragma fragmentoption ARB_precision_hint_fastest 
            #pragma target 3.0

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			//Material Tex
			sampler2D _MainTex;
			fixed4 _MainTex_ST;

			//FoW Mask
			sampler2D _ShadowTex;
			fixed4 _FieldZero;
			fixed4 _FieldWide;

			//Lighting
			fixed4 _Color;
			fixed4 _AmbColor;
			fixed _WrapAmount;
			uniform fixed4 _LightColor0;

			struct v2f
			{
				fixed4 vertex : SV_POSITION;
				fixed2 uv : TEXCOORD0;
				fixed3 worldPos : TEXCOORD1;
				fixed3 viewDir : TEXCOORD2;
				fixed3 lightDir : TEXCOORD3;
				fixed3 normalDir : TEXCOORD4;
				LIGHTING_COORDS(5, 6)
				UNITY_FOG_COORDS(1)
			};

			//Lambert
            inline fixed4 WrappedLight( fixed3 lightDir, fixed3 normalDir,fixed viewDir, fixed4 color, fixed atten, fixed wrapAmount)
           	{
                #ifndef USING_DIRECTIONAL_LIGHT
                 	lightDir = normalize(lightDir);
                #endif

                fixed4 c;
                fixed diffuse = dot(normalDir,lightDir) * wrapAmount + (1 - wrapAmount);
                c.rgb = color.rgb * _Color.rgb * (diffuse * atten * 2);
                c.a = 0; // diffuse passes by default don't contribute to overbright

                return c;
            }
								
			v2f vert (appdata_tan v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				o.normalDir = v.normal;
                o.viewDir  = ObjSpaceViewDir(v.vertex);
                o.lightDir = ObjSpaceLightDir(v.vertex);

  				o.worldPos = mul(_Object2World, v.vertex).xyz;
                UNITY_TRANSFER_FOG(o,o.vertex);
				TRANSFER_VERTEX_TO_FRAGMENT(o);

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
                fixed4 col = tex2D(_MainTex, i.uv);

                //Lighting
                fixed4 AmbientShadow = WrappedLight( i.lightDir, i.normalDir,i.viewDir,_LightColor0, LIGHT_ATTENUATION(i), _WrapAmount);
                col = col * AmbientShadow + _AmbColor * (1 - AmbientShadow);

                //Set FoW Mask
				fixed3 dots = (fixed3(i.worldPos.x,i.worldPos.z,0) - _FieldZero) * _FieldWide;
				fixed4 shadow = tex2D(_ShadowTex,dots.xy);
				col = col * (1 - shadow.a);
				col.a = 1.0;

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);

				return col;
			}
			ENDCG
		}

		//Standard Shader
//		CGPROGRAM
//		#pragma surface surf Standard fullforwardshadows
//		#pragma target 3.0
//
//		sampler2D _MainTex;
//		sampler2D _ShadowTex;
//
//		struct Input {
//			float2 uv_MainTex;
//			fixed3 worldPos;
//		};
//
//		half _Glossiness;
//		half _Metallic;
//		fixed4 _Color;
//		fixed4 _FieldZero;
//		fixed4 _FieldWide;
//
//		void surf (Input IN, inout SurfaceOutputStandard o) {
//			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
//
//			fixed3 dots = (fixed3(IN.worldPos.x,IN.worldPos.z,0) - _FieldZero) * _FieldWide;
//
//			fixed4 shadow = tex2D(_ShadowTex,dots.xy);
//			c = c * (1 - shadow.a);
//
//			o.Albedo = c ;
//			o.Metallic = _Metallic;
//			o.Smoothness = _Glossiness;
//			o.Alpha = 1.0;
//		}
//		ENDCG

	}
	FallBack "Diffuse"
}

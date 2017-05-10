Shader "Hidden/VRComfortMode"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BGTexL("Texture", 2D) = "white" {}
		_BGTexR("Texture", 2D) = "white" {}
		_StartFade("Distance in pixels before we start fading", Float) = 0.0
		_FinishFade("Distance in pixels before we finish fading", Float) = 0.0
		_EyeOffset("(Vive) How much to offset mask?", Float) = 0.0
	}
		SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			Float _StartFade;
			Float _FinishFade;
			Float _EyeOffset;
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
			};

			v2f vert (appdata_img v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord.xy;
				o.uv2 = v.texcoord.xy;

				return o;
			}

			sampler2D _MainTex;
			sampler2D _BGTexL;
			sampler2D _BGTexR;
			half4 _MainTex_ST;
			half4 _BGTexL_ST;
			half4 _BGTexR_ST;
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(i.uv, _MainTex_ST));
				fixed4 colBGL = tex2D(_BGTexL, UnityStereoScreenSpaceUVAdjust(i.uv2, _BGTexL_ST));
				fixed4 colBGR = tex2D(_BGTexR, UnityStereoScreenSpaceUVAdjust(i.uv2, _BGTexR_ST));
				fixed4 colBG = lerp(colBGL, colBGR, unity_StereoEyeIndex);
				half2 coords = i.uv;
				coords = (coords - .5)*2.0;
				coords.x = coords.x + _EyeOffset;
				float2 origin = float2(0, 0);
				float d = distance(coords, origin);
				float fadeProgress = saturate((d - _StartFade) / (_FinishFade - _StartFade));
				fixed4 c = lerp(col, colBG, fadeProgress);
	
				return c;
			}
			ENDCG
		}
	}
}

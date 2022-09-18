// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ToonShader/CelShader_limtex"
{
	Properties
	{
		_Maintex("Maintex", 2D) = "white" {}
		_MainColor("MainColor", Color) = (1,0.9103774,0.9103774,0)
		_SSSTex("SSSTex", 2D) = "white" {}
		_LimTex("LimTex", 2D) = "white" {}
		_FirstShadowThre("FirstShadowThre", Range( 0 , 1)) = 0.5
		_FirstShadowSmoothoffset("FirstShadowSmoothoffset", Range( 0 , 1)) = 0
		_FirstShadowColor("FirstShadowColor", Color) = (0.1509434,0.1509434,0.1509434,0)
		_SceondShadowThre("SceondShadowThre", Range( 0 , 1)) = 0.5
		_SecondShadowColor("SecondShadowColor", Color) = (0,0,0,0)
		_Specgloss("Specgloss", Range( 1 , 30)) = 5.647059
		_Specolor("Specolor", Color) = (0,0,0,0)
		_SpecMulti("SpecMulti", Range( 1 , 20)) = 1
		[Toggle]_RimToggle("RimToggle", Float) = 0
		[KeywordEnum(normal,halflambert,backlight)] _Rimtype("Rimtype", Float) = 0
		_RimScale("RimScale", Range( 0.01 , 11)) = 0
		_RimColor("RimColor", Color) = (0.6415094,0.6415094,0.6415094,0)
		_Rimoffset("Rimoffset", Range( 0 , 1)) = 0.482353
		_OutlineColor("OutlineColor", Color) = (0,0,0,0)
		_OutlineWidth("OutlineWidth", Range( 0 , 1)) = 0
		[Toggle]_ShadowhlightToggle("ShadowhlightToggle", Float) = 1
		[HDR]_EmissionColor("EmissionColor ", Color) = (0,0,0,0)
		_EmissionMult("EmissionMult", Range( 0 , 11)) = 0
		_Inline("Inline", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float outlineVar = _OutlineWidth;
			v.vertex.xyz += ( v.normal * outlineVar );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Emission = _OutlineColor.rgb;
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		#pragma shader_feature _RIMTYPE_NORMAL _RIMTYPE_HALFLAMBERT _RIMTYPE_BACKLIGHT
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float3 worldPos;
			float4 vertexColor : COLOR;
			float3 viewDir;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _RimToggle;
		uniform sampler2D _SSSTex;
		uniform float4 _SSSTex_ST;
		uniform sampler2D _Maintex;
		uniform float4 _Maintex_ST;
		uniform float4 _FirstShadowColor;
		uniform float4 _SecondShadowColor;
		uniform float _SceondShadowThre;
		uniform sampler2D _LimTex;
		uniform float4 _LimTex_ST;
		uniform float4 _MainColor;
		uniform float _FirstShadowThre;
		uniform float _FirstShadowSmoothoffset;
		uniform float _Specgloss;
		uniform float4 _Specolor;
		uniform float _SpecMulti;
		uniform float _ShadowhlightToggle;
		uniform float4 _EmissionColor;
		uniform float _EmissionMult;
		uniform float _Inline;
		uniform float _Rimoffset;
		uniform float _RimScale;
		uniform float4 _RimColor;
		uniform float _OutlineWidth;
		uniform float4 _OutlineColor;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += 0;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_SSSTex = i.uv_texcoord * _SSSTex_ST.xy + _SSSTex_ST.zw;
			float2 uv_Maintex = i.uv_texcoord * _Maintex_ST.xy + _Maintex_ST.zw;
			float4 temp_output_15_0 = ( tex2D( _SSSTex, uv_SSSTex ) * tex2D( _Maintex, uv_Maintex ) * _FirstShadowColor );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult3 = dot( ase_worldNormal , ase_worldlightDir );
			float halflambert20 = ( ( ( dotResult3 * 0.5 ) + 0.5 ) * ase_lightAtten );
			float2 uv_LimTex = i.uv_texcoord * _LimTex_ST.xy + _LimTex_ST.zw;
			float4 tex2DNode50 = tex2D( _LimTex, uv_LimTex );
			float ShadowMask54 = ( tex2DNode50.g * i.vertexColor.r );
			float4 lerpResult49 = lerp( ( temp_output_15_0 * _SecondShadowColor ) , temp_output_15_0 , step( _SceondShadowThre , ( ( halflambert20 + ShadowMask54 ) * 0.5 ) ));
			float RemapMask85 = (( ShadowMask54 > 0.5 ) ? ( ( ShadowMask54 * 1.2 ) - 0.1 ) :  ( ( ShadowMask54 * 1.25 ) - 0.125 ) );
			float smoothstepResult152 = smoothstep( _FirstShadowThre , ( _FirstShadowThre + _FirstShadowSmoothoffset ) , ( ( halflambert20 + RemapMask85 ) * 0.5 ));
			float4 lerpResult10 = lerp( temp_output_15_0 , ( tex2D( _Maintex, uv_Maintex ) * _MainColor ) , smoothstepResult152);
			float4 lerpResult59 = lerp( lerpResult49 , lerpResult10 , step( 0.09 , ShadowMask54 ));
			float3 normalizeResult106 = normalize( ( i.viewDir + ase_worldlightDir ) );
			float dotResult108 = dot( normalizeResult106 , ase_worldNormal );
			float shadowwithoutHlight151 = smoothstepResult152;
			float4 tex2DNode163 = tex2D( _Maintex, uv_Maintex );
			float4 temp_output_171_0 = ( ( lerpResult59 + ( tex2DNode50.r * step( ( 1.0 - tex2DNode50.b ) , pow( dotResult108 , _Specgloss ) ) * _Specolor * _SpecMulti * lerp(1.0,shadowwithoutHlight151,_ShadowhlightToggle) ) + ( tex2DNode163 * tex2DNode163.a * _EmissionColor * _EmissionMult ) ) * saturate( ( tex2DNode50.a + _Inline ) ) );
			float dotResult123 = dot( i.viewDir , ase_worldNormal );
			#if defined(_RIMTYPE_NORMAL)
				float staticSwitch150 = 1.0;
			#elif defined(_RIMTYPE_HALFLAMBERT)
				float staticSwitch150 = halflambert20;
			#elif defined(_RIMTYPE_BACKLIGHT)
				float staticSwitch150 = ( 1.0 - shadowwithoutHlight151 );
			#else
				float staticSwitch150 = 1.0;
			#endif
			c.rgb = lerp(temp_output_171_0,( temp_output_171_0 + ( pow( ( 1.0 - saturate( ( dotResult123 + _Rimoffset ) ) ) , _RimScale ) * _RimColor * staticSwitch150 ) ),_RimToggle).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				half4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				surfIN.vertexColor = IN.color;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17000
-144;257;1906;681;3282.551;673.3492;4.974907;True;True
Node;AmplifyShaderEditor.CommentaryNode;53;-331.0695,1142.828;Float;False;950.4998;456.5999;ShadowMask;4;54;52;50;51;阴影遮罩ShadowMask;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;50;-155.0696,1190.828;Float;True;Property;_LimTex;LimTex;3;0;Create;True;0;0;False;0;None;28a3468066b033e448adc25b1c396ca0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;51;-91.06958,1398.828;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;196.9302,1318.828;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;69;-1580.876,-384.8831;Float;False;1293.428;662.0965;RemapMask/对limTex.g x vertex.r的值进行重映射;16;85;71;84;72;70;81;80;82;78;83;79;74;76;75;77;73;remap重映射;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;340.9305,1334.828;Float;False;ShadowMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;19;-1508.844,317.602;Float;False;1217.422;611.6746;半兰伯特漫反射;10;7;5;6;4;3;1;2;20;18;17;半兰伯特漫反射;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-963.0396,118.0966;Float;False;Constant;_Float9;Float 9;8;0;Create;True;0;0;False;0;1.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;2;-1425.59,730.6772;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;73;-1532.14,-77.33161;Float;False;54;ShadowMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;-981.0396,30.09672;Float;False;54;ShadowMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-1536.14,21.6684;Float;False;Constant;_Float6;Float 6;8;0;Create;True;0;0;False;0;1.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;1;-1412.058,420.7948;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-775.0396,29.09671;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1131.671,711.0491;Float;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;3;-1134.717,529.381;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-1374.14,103.6684;Float;False;Constant;_Float7;Float 7;8;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-802.0396,195.0967;Float;False;Constant;_Float8;Float 8;8;0;Create;True;0;0;False;0;0.125;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-1328.14,-48.33159;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-971.14,479.7844;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;76;-1174.14,21.6684;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-943.7102,677.7853;Float;False;Constant;_Float1;Float 1;0;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;81;-615.0396,112.0966;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-1370.035,-314.2342;Float;False;54;ShadowMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;83;-914.5629,-101.2908;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-1255.813,-204.582;Float;False;Constant;_Float5;Float 5;8;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;17;-785.9913,744.0679;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-809.2361,530.6732;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;84;-660.3771,-84.8194;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCCompareGreater;71;-727.9138,-286.182;Float;False;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-643.5801,596.1372;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;44;853.2606,7.262996;Float;False;859.7781;640.839;非固定阴影：亮部or第一层阴影颜色;8;10;63;9;64;62;21;61;152;非固定阴影：亮部or第一层阴影颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;-519.7725,-268.4129;Float;False;RemapMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-513.8408,512.3442;Float;False;halflambert;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;102;-442.1743,1787.824;Float;False;1866.444;650.2085;高光spec;16;113;112;114;109;118;110;108;106;107;105;103;104;119;157;158;159;高光spec;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;952.9525,315.4316;Float;False;20;halflambert;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;956.3211,426.5986;Float;False;85;RemapMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;1164.165,405.2895;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;103;-298.1744,1867.824;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;155;1304.874,537.1782;Float;False;Property;_FirstShadowSmoothoffset;FirstShadowSmoothoffset;5;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;104;-298.1744,2027.824;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;45;829.0272,674.5488;Float;False;901.9731;581.4946;固定阴影选择：第一层阴影颜色or第二层阴影颜色;8;68;67;66;65;49;48;46;47;固定阴影选择：第一层阴影颜色or第二层阴影颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;9;1201.349,283.6027;Float;False;Property;_FirstShadowThre;FirstShadowThre;4;0;Create;True;0;0;False;0;0.5;0.56;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;1110.004,511.4013;Float;False;Constant;_Float3;Float 3;8;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;120;1778.131,1777.744;Float;False;1912.42;908.6765;边缘光Rim;16;150;149;148;147;146;131;127;132;129;128;124;134;123;133;121;122;边缘光Rim;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;105;-26.17455,1963.824;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;913.0713,1053.761;Float;False;54;ShadowMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;39;-277.7409,-15.2621;Float;True;Property;_Maintex;Maintex;0;0;Create;True;0;0;False;0;None;c062bf6b2d228c648a96aa4176935b00;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;153;1546.874,493.1782;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;23;-78.97056,150.12;Float;False;819.9445;439.2;第一层阴影颜色;4;25;15;13;11;第一层阴影颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;910.3124,944.5742;Float;False;20;halflambert;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;1291.165,421.2895;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;41;-80.57648,668.5309;Float;False;617;361;第二层阴影颜色;2;42;43;第二层阴影颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.SmoothstepOpNode;152;1542.874,311.178;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;1131.915,1020.452;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;22;-26.35712,-421.1687;Float;False;517;491;亮部;3;16;12;14;亮部;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;13;277.067,197.2424;Float;True;Property;_SSSTex;SSSTex;2;0;Create;True;0;0;False;0;None;ba653e77dda22c146b1b5c16582430c6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;122;1939.892,2053.78;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;121;1933.892,1893.78;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;11;289.6835,423.7145;Float;False;Property;_FirstShadowColor;FirstShadowColor;6;0;Create;True;0;0;False;0;0.1509434,0.1509434,0.1509434,0;0.9339623,0.9031239,0.9031239,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;68;1120.915,1139.452;Float;False;Constant;_Float4;Float 4;8;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;25;-47.53335,315.8575;Float;True;Property;_TextureSample0;Texture Sample 0;5;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;106;117.8256,1979.824;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;107;101.8256,2059.824;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;60;1767.368,434.4395;Float;False;534.2;444.4999;固定阴影or非固定阴影区域;4;58;59;56;57;固定阴影or非固定阴影区域;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;595.7727,321.1137;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;151;1762.483,292.1381;Float;False;shadowwithoutHlight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;133;2145.358,2192.074;Float;False;Property;_Rimoffset;Rimoffset;16;0;Create;True;0;0;False;0;0.482353;0.62;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;108;309.8257,1979.824;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;123;2183.892,1993.78;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;882.5093,834.5455;Float;False;Property;_SceondShadowThre;SceondShadowThre;7;0;Create;True;0;0;False;0;0.5;0.34;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;42;21.42352,773.5309;Float;False;Property;_SecondShadowColor;SecondShadowColor;8;0;Create;True;0;0;False;0;0,0,0,0;0.7924528,0.6990032,0.6990032,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;17.62009,-310.336;Float;True;Property;_MainTex;MainTex;2;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;110;357.8255,2107.825;Float;False;Property;_Specgloss;Specgloss;9;0;Create;True;0;0;False;0;5.647059;6;1;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;1310.915,1059.452;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;165;-32.61055,-504.7813;Float;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.ColorNode;12;41.5922,-100.1977;Float;False;Property;_MainColor;MainColor;1;0;Create;True;0;0;False;0;1,0.9103774,0.9103774,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;158;1005.506,2356.268;Float;False;151;shadowwithoutHlight;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;1780.635,645.9006;Float;False;54;ShadowMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;134;2342.358,2061.074;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;1783.906,500.6674;Float;False;Constant;_Float2;Float 2;8;0;Create;True;0;0;False;0;0.09;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;118;567.8251,1879.824;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;48;1279.071,896.2209;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;339.4235,768.5309;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;166;1651.817,-466.222;Float;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.CommentaryNode;172;811.6863,1350.057;Float;False;568;282;内描边控制方法1;3;170;168;169;内描边控制方法1;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;160;1883.689,-175.2392;Float;False;874.4719;432.8183;自发光;4;164;163;162;161;自发光;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;331.9686,-146.7088;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;157;951.3768,2261.901;Float;False;Constant;_Float10;Float 10;20;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;109;565.8251,1995.824;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;146;2938.723,2552.748;Float;False;151;shadowwithoutHlight;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;159;1104.937,2159.908;Float;False;Property;_ShadowhlightToggle;ShadowhlightToggle;19;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;114;757.8251,1915.824;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;124;2437.891,1993.78;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;10;1270.865,58.78855;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;112;661.8251,2139.825;Float;False;Property;_Specolor;Specolor;10;0;Create;True;0;0;False;0;0,0,0,0;0.5251399,0.5283019,0.490922,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;163;1920.491,-109.5;Float;True;Property;_TextureSample1;Texture Sample 1;20;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;56;1983.384,597.9625;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;162;2102.798,79.58109;Float;False;Property;_EmissionColor;EmissionColor ;20;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,4.99339,61.58491,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;161;2330.799,151.5811;Float;False;Property;_EmissionMult;EmissionMult;21;0;Create;True;0;0;False;0;0;0.7;0;11;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;611.8256,2336.824;Float;False;Property;_SpecMulti;SpecMulti;11;0;Create;True;0;0;False;0;1;1;1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;169;836.9086,1516.686;Float;False;Property;_Inline;Inline;22;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;49;1453.419,757.2076;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;178;1422.76,1366.022;Float;False;350;176;内描边控制方法2;2;177;176;内描边控制方法2;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;1141.826,1867.824;Float;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;164;2537.768,-51.16268;Float;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;147;3155.219,2366.487;Float;False;Constant;_Float11;Float 11;25;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;129;2575.891,1931.78;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;59;2133.644,540.1979;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;149;3254.723,2578.748;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;128;2584.891,2204.779;Float;False;Property;_RimScale;RimScale;14;0;Create;True;0;0;False;0;0;3.4;0.01;11;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;148;3124.17,2466.264;Float;False;20;halflambert;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;176;1452.138,1405.745;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;127;2894.891,1952.78;Float;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;132;3018.498,2192.824;Float;False;Property;_RimColor;RimColor;15;0;Create;True;0;0;False;0;0.6415094,0.6415094,0.6415094,0;0.1915717,0.7113376,0.990566,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;177;1622.76,1416.022;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;111;2340.146,953.3269;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;150;3373.944,2352.911;Float;False;Property;_Rimtype;Rimtype;13;0;Create;True;0;0;False;0;0;0;2;True;;KeywordEnum;3;normal;halflambert;backlight;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;3299.032,1958.148;Float;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;171;2355.779,1209.272;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;145;2857.967,1296.76;Float;False;Property;_OutlineWidth;OutlineWidth;18;0;Create;True;0;0;False;0;0;0.001;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;144;2829.467,1117.06;Float;False;Property;_OutlineColor;OutlineColor;17;0;Create;True;0;0;False;0;0,0,0,0;0.1981132,0.08317016,0.1689504,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;136;2614.731,1281.394;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;170;1175.236,1442.36;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;168;996.057,1384.397;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;135;2668.61,990.392;Float;False;Property;_RimToggle;RimToggle;12;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OutlineNode;143;3049.217,1100.578;Float;False;0;True;None;0;0;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3480.491,542.4043;Float;False;True;6;Float;ASEMaterialInspector;0;0;CustomLighting;ToonShader/CelShader_limtex;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0.05;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;52;0;50;2
WireConnection;52;1;51;1
WireConnection;54;0;52;0
WireConnection;82;0;78;0
WireConnection;82;1;80;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;74;0;73;0
WireConnection;74;1;75;0
WireConnection;4;0;3;0
WireConnection;4;1;5;0
WireConnection;76;0;74;0
WireConnection;76;1;77;0
WireConnection;81;0;82;0
WireConnection;81;1;79;0
WireConnection;83;0;76;0
WireConnection;6;0;4;0
WireConnection;6;1;7;0
WireConnection;84;0;81;0
WireConnection;71;0;70;0
WireConnection;71;1;72;0
WireConnection;71;2;83;0
WireConnection;71;3;84;0
WireConnection;18;0;6;0
WireConnection;18;1;17;0
WireConnection;85;0;71;0
WireConnection;20;0;18;0
WireConnection;62;0;21;0
WireConnection;62;1;61;0
WireConnection;105;0;103;0
WireConnection;105;1;104;0
WireConnection;153;0;9;0
WireConnection;153;1;155;0
WireConnection;63;0;62;0
WireConnection;63;1;64;0
WireConnection;152;0;63;0
WireConnection;152;1;9;0
WireConnection;152;2;153;0
WireConnection;66;0;46;0
WireConnection;66;1;65;0
WireConnection;25;0;39;0
WireConnection;106;0;105;0
WireConnection;15;0;13;0
WireConnection;15;1;25;0
WireConnection;15;2;11;0
WireConnection;151;0;152;0
WireConnection;108;0;106;0
WireConnection;108;1;107;0
WireConnection;123;0;121;0
WireConnection;123;1;122;0
WireConnection;14;0;39;0
WireConnection;67;0;66;0
WireConnection;67;1;68;0
WireConnection;165;0;39;0
WireConnection;134;0;123;0
WireConnection;134;1;133;0
WireConnection;118;0;50;3
WireConnection;48;0;47;0
WireConnection;48;1;67;0
WireConnection;43;0;15;0
WireConnection;43;1;42;0
WireConnection;166;0;165;0
WireConnection;16;0;14;0
WireConnection;16;1;12;0
WireConnection;109;0;108;0
WireConnection;109;1;110;0
WireConnection;159;0;157;0
WireConnection;159;1;158;0
WireConnection;114;0;118;0
WireConnection;114;1;109;0
WireConnection;124;0;134;0
WireConnection;10;0;15;0
WireConnection;10;1;16;0
WireConnection;10;2;152;0
WireConnection;163;0;166;0
WireConnection;56;0;57;0
WireConnection;56;1;58;0
WireConnection;49;0;43;0
WireConnection;49;1;15;0
WireConnection;49;2;48;0
WireConnection;113;0;50;1
WireConnection;113;1;114;0
WireConnection;113;2;112;0
WireConnection;113;3;119;0
WireConnection;113;4;159;0
WireConnection;164;0;163;0
WireConnection;164;1;163;4
WireConnection;164;2;162;0
WireConnection;164;3;161;0
WireConnection;129;0;124;0
WireConnection;59;0;49;0
WireConnection;59;1;10;0
WireConnection;59;2;56;0
WireConnection;149;0;146;0
WireConnection;176;0;50;4
WireConnection;176;1;169;0
WireConnection;127;0;129;0
WireConnection;127;1;128;0
WireConnection;177;0;176;0
WireConnection;111;0;59;0
WireConnection;111;1;113;0
WireConnection;111;2;164;0
WireConnection;150;1;147;0
WireConnection;150;0;148;0
WireConnection;150;2;149;0
WireConnection;131;0;127;0
WireConnection;131;1;132;0
WireConnection;131;2;150;0
WireConnection;171;0;111;0
WireConnection;171;1;177;0
WireConnection;136;0;171;0
WireConnection;136;1;131;0
WireConnection;170;0;50;4
WireConnection;170;1;169;0
WireConnection;170;2;168;0
WireConnection;168;0;50;4
WireConnection;168;1;169;0
WireConnection;135;0;171;0
WireConnection;135;1;136;0
WireConnection;143;0;144;0
WireConnection;143;1;145;0
WireConnection;0;13;135;0
WireConnection;0;11;143;0
ASEEND*/
//CHKSM=D4EB36940973CDF1F595CE4346A4F02029EDE832
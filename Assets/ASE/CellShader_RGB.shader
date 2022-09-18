// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ToonShader/CelShader_rgb"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Maintex("Maintex", 2D) = "white" {}
		_MainColor("MainColor", Color) = (1,0.9103774,0.9103774,0)
		_SSSTex("SSSTex", 2D) = "white" {}
		_FirstShadowThre("FirstShadowThre", Range( 0 , 1)) = 0.5
		_FirstShadowSmooth("FirstShadowSmooth", Range( 0 , 1)) = 0
		_FirstShadowColor("FirstShadowColor", Color) = (0.1509434,0.1509434,0.1509434,0)
		_SceondShadowThre("SceondShadowThre", Range( 0 , 1)) = 0.5
		_SecondShadowColor("SecondShadowColor", Color) = (0,0,0,0)
		_Specgloss("Specgloss", Range( 1 , 30)) = 5.647059
		_Specolor("Specolor", Color) = (0,0,0,0)
		_SpecMulti("SpecMulti", Range( 1 , 20)) = 0
		[Toggle]_RimToggle("RimToggle", Float) = 0
		[KeywordEnum(normal,halflambert,backlight)] _Rimtype("Rimtype", Float) = 0
		_RimScale("RimScale", Range( 0.01 , 11)) = 0
		_RimColor("RimColor", Color) = (0,0,0,0)
		_Rimoffset("Rimoffset", Range( 0 , 1)) = 0.482353
		_R("R", 2D) = "white" {}
		_G("G", 2D) = "white" {}
		_B("B", 2D) = "white" {}
		[Toggle]_ShadowhlightToggle("ShadowhlightToggle", Float) = 1
		[HDR]_EmissionColor("EmissionColor ", Color) = (0,0,0,0)
		_EmissionMult("EmissionMult", Range( 0 , 11)) = 0
		_OutlineColor("OutlineColor", Color) = (0,0,0,0)
		_OutlineWidth("OutlineWidth", Range( 0 , 1)) = 0
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
		

		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" }
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

		uniform sampler2D _SSSTex;
		uniform float4 _SSSTex_ST;
		uniform float _RimToggle;
		uniform sampler2D _Maintex;
		uniform float4 _Maintex_ST;
		uniform float4 _FirstShadowColor;
		uniform float4 _SecondShadowColor;
		uniform float _SceondShadowThre;
		uniform sampler2D _G;
		uniform float4 _G_ST;
		uniform float4 _MainColor;
		uniform float _FirstShadowThre;
		uniform float _FirstShadowSmooth;
		uniform sampler2D _R;
		uniform float4 _R_ST;
		uniform sampler2D _B;
		uniform float4 _B_ST;
		uniform float _Specgloss;
		uniform float4 _Specolor;
		uniform float _SpecMulti;
		uniform float _ShadowhlightToggle;
		uniform float4 _EmissionColor;
		uniform float _EmissionMult;
		uniform float _Rimoffset;
		uniform float _RimScale;
		uniform float4 _RimColor;
		uniform float _Cutoff = 0.5;
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
			float4 tex2DNode13 = tex2D( _SSSTex, uv_SSSTex );
			float2 uv_Maintex = i.uv_texcoord * _Maintex_ST.xy + _Maintex_ST.zw;
			float4 temp_output_15_0 = ( tex2DNode13 * tex2D( _Maintex, uv_Maintex ) * _FirstShadowColor );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult3 = dot( ase_worldNormal , ase_worldlightDir );
			float halflambert20 = ( ( ( dotResult3 * 0.5 ) + 0.5 ) * ase_lightAtten );
			float2 uv_G = i.uv_texcoord * _G_ST.xy + _G_ST.zw;
			float ShadowMask54 = ( tex2D( _G, uv_G ).g * i.vertexColor.r );
			float4 lerpResult49 = lerp( ( temp_output_15_0 * _SecondShadowColor ) , temp_output_15_0 , step( _SceondShadowThre , ( ( halflambert20 + ShadowMask54 ) * 0.5 ) ));
			float RemapMask85 = (( ShadowMask54 > 0.5 ) ? ( ( ShadowMask54 * 1.2 ) - 0.1 ) :  ( ( ShadowMask54 * 1.25 ) - 0.125 ) );
			float smoothstepResult183 = smoothstep( _FirstShadowThre , ( _FirstShadowThre + _FirstShadowSmooth ) , ( ( RemapMask85 + halflambert20 ) * 0.5 ));
			float4 lerpResult10 = lerp( temp_output_15_0 , ( tex2D( _Maintex, uv_Maintex ) * _MainColor ) , smoothstepResult183);
			float4 lerpResult59 = lerp( lerpResult49 , lerpResult10 , step( 0.09 , ShadowMask54 ));
			float2 uv_R = i.uv_texcoord * _R_ST.xy + _R_ST.zw;
			float2 uv_B = i.uv_texcoord * _B_ST.xy + _B_ST.zw;
			float3 normalizeResult106 = normalize( ( i.viewDir + ase_worldlightDir ) );
			float dotResult108 = dot( normalizeResult106 , ase_worldNormal );
			float shadowwithoutHlight149 = smoothstepResult183;
			float4 tex2DNode154 = tex2D( _Maintex, uv_Maintex );
			float4 temp_output_111_0 = ( lerpResult59 + ( tex2D( _R, uv_R ).r * step( ( 1.0 - tex2D( _B, uv_B ).b ) , pow( dotResult108 , _Specgloss ) ) * _Specolor * _SpecMulti * lerp(1.0,shadowwithoutHlight149,_ShadowhlightToggle) ) + ( tex2DNode154 * tex2DNode154.a * _EmissionColor * _EmissionMult ) );
			float dotResult123 = dot( i.viewDir , ase_worldNormal );
			#if defined(_RIMTYPE_NORMAL)
				float staticSwitch189 = 1.0;
			#elif defined(_RIMTYPE_HALFLAMBERT)
				float staticSwitch189 = halflambert20;
			#elif defined(_RIMTYPE_BACKLIGHT)
				float staticSwitch189 = ( 1.0 - shadowwithoutHlight149 );
			#else
				float staticSwitch189 = 1.0;
			#endif
			c.rgb = lerp(temp_output_111_0,( temp_output_111_0 + ( pow( ( 1.0 - saturate( ( dotResult123 + _Rimoffset ) ) ) , _RimScale ) * _RimColor * staticSwitch189 ) ),_RimToggle).rgb;
			c.a = 1;
			clip( tex2DNode13.a - _Cutoff );
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
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
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
1931;134;1906;853;2924.505;1746.959;5.131692;True;True
Node;AmplifyShaderEditor.CommentaryNode;53;-353.0288,1101.054;Float;False;950.4998;456.5999;ShadowMask;4;54;52;51;147;阴影遮罩ShadowMask;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;147;-241.2792,1158.6;Float;True;Property;_G;G;18;0;Create;True;0;0;False;0;None;c9fb51dea8005104eb757a3641ce7bb5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;51;-147.0289,1362.054;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;122.9709,1278.054;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;19;-1656.569,313.6095;Float;False;1217.422;611.6746;半兰伯特漫反射;10;7;5;6;4;3;1;2;20;18;17;半兰伯特漫反射;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;69;-1728.601,-388.8755;Float;False;1293.428;662.0965;RemapMask/对limTex.g x vertex.r的值进行重映射;16;85;71;84;72;70;81;80;82;78;83;79;74;76;75;77;73;remap重映射;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;318.9712,1293.054;Float;False;ShadowMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-1679.865,-81.32407;Float;False;54;ShadowMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;-1128.765,26.10427;Float;False;54;ShadowMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-1110.765,114.1041;Float;False;Constant;_Float9;Float 9;8;0;Create;True;0;0;False;0;1.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;2;-1573.315,726.6848;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;1;-1559.783,416.8023;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;75;-1683.865,17.67595;Float;False;Constant;_Float6;Float 6;8;0;Create;True;0;0;False;0;1.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-1521.865,99.67595;Float;False;Constant;_Float7;Float 7;8;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-922.7651,25.10426;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-949.7651,191.1042;Float;False;Constant;_Float8;Float 8;8;0;Create;True;0;0;False;0;0.125;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;3;-1282.443,525.3885;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1279.396,707.0566;Float;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-1475.865,-52.32404;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1091.436,673.7928;Float;False;Constant;_Float1;Float 1;0;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;76;-1321.865,17.67595;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;81;-762.7651,108.1041;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-1118.865,475.7919;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-1403.538,-208.5744;Float;False;Constant;_Float5;Float 5;8;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;84;-808.1026,-88.81185;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;17;-938.7167,747.0754;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-956.9616,526.6808;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;83;-1062.288,-105.2833;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-1517.76,-318.2267;Float;False;54;ShadowMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCCompareGreater;71;-875.6393,-290.1745;Float;False;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-791.3056,592.1448;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;-667.498,-272.4054;Float;False;RemapMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-661.5663,508.3517;Float;False;halflambert;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;44;853.2606,7.262996;Float;False;829.8782;635.939;非固定阴影：亮部or第一层阴影颜色;10;183;185;184;9;10;63;64;62;21;61;非固定阴影：亮部or第一层阴影颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;952.9525,315.4316;Float;False;85;RemapMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;102;-343.9532,1621.783;Float;False;1866.444;650.2085;高光spec;16;113;112;114;109;118;110;108;106;107;105;103;104;119;150;152;151;高光spec;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;956.3211,426.5986;Float;False;20;halflambert;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;1094.004,510.4013;Float;False;Constant;_Float3;Float 3;8;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;185;1253.664,570.3868;Float;False;Property;_FirstShadowSmooth;FirstShadowSmooth;5;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;104;-199.9533,1861.783;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;9;1180.149,277.4027;Float;False;Property;_FirstShadowThre;FirstShadowThre;4;0;Create;True;0;0;False;0;0.5;0.56;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;103;-199.9533,1701.783;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;120;1642.492,1635.089;Float;False;1960.035;866.7131;边缘光Rim;16;189;186;131;132;188;127;187;129;128;124;134;133;123;121;122;190;边缘光Rim;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;1151.165,400.2895;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;45;829.0272,674.5488;Float;False;901.9731;581.4946;固定阴影选择：第一层阴影颜色or第二层阴影颜色;8;68;67;66;65;49;48;46;47;固定阴影选择：第一层阴影颜色or第二层阴影颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;1277.165,458.2895;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;23;-78.97056,150.12;Float;False;819.9445;439.2;第一层阴影颜色;4;25;15;13;11;第一层阴影颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;121;1798.253,1751.125;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;184;1538.664,538.3868;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;910.3124,944.5742;Float;False;20;halflambert;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;105;72.04657,1797.783;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;39;-370.0464,-21.41581;Float;True;Property;_Maintex;Maintex;1;0;Create;True;0;0;False;0;None;c062bf6b2d228c648a96aa4176935b00;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;913.0713,1053.761;Float;False;54;ShadowMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;122;1804.253,1911.125;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;68;1120.915,1139.452;Float;False;Constant;_Float4;Float 4;8;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;183;1520.664,367.3868;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;22;-26.35712,-421.1687;Float;False;517;491;亮部;3;16;12;14;亮部;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;25;-47.53335,315.8575;Float;True;Property;_TextureSample0;Texture Sample 0;5;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;106;216.0467,1813.783;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;107;200.0467,1893.783;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;123;2048.253,1851.125;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;11;289.6835,423.7145;Float;False;Property;_FirstShadowColor;FirstShadowColor;6;0;Create;True;0;0;False;0;0.1509434,0.1509434,0.1509434,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;66;1131.915,1020.452;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;41;-80.57648,668.5309;Float;False;617;361;第二层阴影颜色;2;42;43;第二层阴影颜色;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;13;277.067,197.2424;Float;True;Property;_SSSTex;SSSTex;3;0;Create;True;0;0;False;0;None;ba653e77dda22c146b1b5c16582430c6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;133;2009.719,2049.42;Float;False;Property;_Rimoffset;Rimoffset;16;0;Create;True;0;0;False;0;0.482353;0.66;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;108;408.0468,1813.783;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;110;456.0467,1941.784;Float;False;Property;_Specgloss;Specgloss;9;0;Create;True;0;0;False;0;5.647059;6;1;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;149;1718.273,324.3468;Float;False;shadowwithoutHlight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;882.5093,834.5455;Float;False;Property;_SceondShadowThre;SceondShadowThre;7;0;Create;True;0;0;False;0;0.5;0.34;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;42;21.42352,773.5309;Float;False;Property;_SecondShadowColor;SecondShadowColor;8;0;Create;True;0;0;False;0;0,0,0,0;0.7924528,0.6990032,0.6990032,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;1310.915,1059.452;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;17.62009,-310.336;Float;True;Property;_MainTex;MainTex;2;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;134;2206.719,1918.42;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;155;-11.02501,-525.8325;Float;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.CommentaryNode;60;1843.25,532.8028;Float;False;534.2;444.4999;固定阴影or非固定阴影区域;4;58;59;56;57;固定阴影or非固定阴影区域;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;595.7727,321.1137;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;12;41.5922,-100.1977;Float;False;Property;_MainColor;MainColor;2;0;Create;True;0;0;False;0;1,0.9103774,0.9103774,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;148;273.3368,1619.189;Float;True;Property;_B;B;19;0;Create;True;0;0;False;0;None;dbcccd0033fe42241b54e8baf24ed854;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;57;1859.788,599.0306;Float;False;Constant;_Float2;Float 2;8;0;Create;True;0;0;False;0;0.09;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;152;1078.355,2101.351;Float;False;Constant;_Float10;Float 10;20;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;150;1132.484,2195.718;Float;False;149;shadowwithoutHlight;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;118;666.0463,1713.783;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;109;664.0463,1829.783;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;331.9686,-146.7088;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;156;1732.901,-503.1518;Float;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SaturateNode;124;2302.252,1851.125;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;1856.517,744.2639;Float;False;54;ShadowMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;153;1812.657,-331.3367;Float;False;874.4719;432.8183;自发光;4;154;157;158;159;自发光;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;339.4235,768.5309;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;187;2852.926,2358.271;Float;False;149;shadowwithoutHlight;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;48;1279.071,896.2209;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;154;1849.459,-265.5975;Float;True;Property;_TextureSample1;Texture Sample 1;20;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;159;2259.766,-4.516436;Float;False;Property;_EmissionMult;EmissionMult;22;0;Create;True;0;0;False;0;0;1;0;11;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;190;3069.422,2172.01;Float;False;Constant;_Float11;Float 11;25;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;158;2031.766,-76.51643;Float;False;Property;_EmissionColor;EmissionColor ;21;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,4.99339,61.58491,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;188;3168.926,2384.271;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;3038.373,2271.787;Float;False;20;halflambert;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;151;1231.915,1999.358;Float;False;Property;_ShadowhlightToggle;ShadowhlightToggle;20;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;56;2059.266,696.3258;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;49;1453.419,757.2076;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;146;971.0335,1561.547;Float;True;Property;_R;R;17;0;Create;True;0;0;False;0;None;e3289bae03a3e4f4fbd1b2e8af52c803;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;10;1368.232,123.7003;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;129;2440.252,1789.125;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;114;856.0463,1749.783;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;112;768.0463,1938.784;Float;False;Property;_Specolor;Specolor;10;0;Create;True;0;0;False;0;0,0,0,0;0.5251399,0.5283019,0.490922,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;128;2449.252,2062.125;Float;False;Property;_RimScale;RimScale;14;0;Create;True;0;0;False;0;0;0.1;0.01;11;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;646.471,2120.522;Float;False;Property;_SpecMulti;SpecMulti;11;0;Create;True;0;0;False;0;0;1;1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;132;2796.859,2054.17;Float;False;Property;_RimColor;RimColor;15;0;Create;True;0;0;False;0;0,0,0,0;0.1915717,0.7113376,0.990566,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;127;2759.252,1810.125;Float;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;59;2221.374,668.1823;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;1347.047,1714.783;Float;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;189;3288.147,2158.434;Float;False;Property;_Rimtype;Rimtype;13;0;Create;True;0;0;False;0;0;0;2;True;;KeywordEnum;3;normal;halflambert;backlight;Create;False;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;157;2466.735,-207.2602;Float;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;3251.393,1842.493;Float;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;111;2402.146,970.3269;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;144;2829.467,1117.06;Float;False;Property;_OutlineColor;OutlineColor;23;0;Create;True;0;0;False;0;0,0,0,0;0.1981132,0.08317016,0.1689504,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;145;2857.967,1296.76;Float;False;Property;_OutlineWidth;OutlineWidth;24;0;Create;True;0;0;False;0;0;0.001;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;136;2526.731,1216.394;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OutlineNode;143;3049.217,1100.578;Float;False;0;True;None;0;0;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;135;2668.61,990.392;Float;False;Property;_RimToggle;RimToggle;12;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3287.491,464.2149;Float;False;True;6;Float;ASEMaterialInspector;0;0;CustomLighting;ToonShader/CelShader_rgb;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0.05;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;52;0;147;2
WireConnection;52;1;51;1
WireConnection;54;0;52;0
WireConnection;82;0;78;0
WireConnection;82;1;80;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;74;0;73;0
WireConnection;74;1;75;0
WireConnection;76;0;74;0
WireConnection;76;1;77;0
WireConnection;81;0;82;0
WireConnection;81;1;79;0
WireConnection;4;0;3;0
WireConnection;4;1;5;0
WireConnection;84;0;81;0
WireConnection;6;0;4;0
WireConnection;6;1;7;0
WireConnection;83;0;76;0
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
WireConnection;63;0;62;0
WireConnection;63;1;64;0
WireConnection;184;0;9;0
WireConnection;184;1;185;0
WireConnection;105;0;103;0
WireConnection;105;1;104;0
WireConnection;183;0;63;0
WireConnection;183;1;9;0
WireConnection;183;2;184;0
WireConnection;25;0;39;0
WireConnection;106;0;105;0
WireConnection;123;0;121;0
WireConnection;123;1;122;0
WireConnection;66;0;46;0
WireConnection;66;1;65;0
WireConnection;108;0;106;0
WireConnection;108;1;107;0
WireConnection;149;0;183;0
WireConnection;67;0;66;0
WireConnection;67;1;68;0
WireConnection;14;0;39;0
WireConnection;134;0;123;0
WireConnection;134;1;133;0
WireConnection;155;0;39;0
WireConnection;15;0;13;0
WireConnection;15;1;25;0
WireConnection;15;2;11;0
WireConnection;118;0;148;3
WireConnection;109;0;108;0
WireConnection;109;1;110;0
WireConnection;16;0;14;0
WireConnection;16;1;12;0
WireConnection;156;0;155;0
WireConnection;124;0;134;0
WireConnection;43;0;15;0
WireConnection;43;1;42;0
WireConnection;48;0;47;0
WireConnection;48;1;67;0
WireConnection;154;0;156;0
WireConnection;188;0;187;0
WireConnection;151;0;152;0
WireConnection;151;1;150;0
WireConnection;56;0;57;0
WireConnection;56;1;58;0
WireConnection;49;0;43;0
WireConnection;49;1;15;0
WireConnection;49;2;48;0
WireConnection;10;0;15;0
WireConnection;10;1;16;0
WireConnection;10;2;183;0
WireConnection;129;0;124;0
WireConnection;114;0;118;0
WireConnection;114;1;109;0
WireConnection;127;0;129;0
WireConnection;127;1;128;0
WireConnection;59;0;49;0
WireConnection;59;1;10;0
WireConnection;59;2;56;0
WireConnection;113;0;146;1
WireConnection;113;1;114;0
WireConnection;113;2;112;0
WireConnection;113;3;119;0
WireConnection;113;4;151;0
WireConnection;189;1;190;0
WireConnection;189;0;186;0
WireConnection;189;2;188;0
WireConnection;157;0;154;0
WireConnection;157;1;154;4
WireConnection;157;2;158;0
WireConnection;157;3;159;0
WireConnection;131;0;127;0
WireConnection;131;1;132;0
WireConnection;131;2;189;0
WireConnection;111;0;59;0
WireConnection;111;1;113;0
WireConnection;111;2;157;0
WireConnection;136;0;111;0
WireConnection;136;1;131;0
WireConnection;143;0;144;0
WireConnection;143;1;145;0
WireConnection;135;0;111;0
WireConnection;135;1;136;0
WireConnection;0;10;13;4
WireConnection;0;13;135;0
WireConnection;0;11;143;0
ASEEND*/
//CHKSM=5561A79E4CF2FA657C0BBE7CED180B75AAF8FA0C
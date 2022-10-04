// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Scan"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_RimMin("RimMin", Range( -1 , 1)) = 0
		_RimMax("RimMax", Range( 0 , 2)) = 0
		_InnerColor("InnerColor", Color) = (0,0,0,0)
		_RimColor("RimColor", Color) = (0,0,0,0)
		_RimIntensity("RimIntensity", Float) = 0
		_FlowEmiss("FlowEmiss", 2D) = "white" {}
		_Speed("Speed", Vector) = (0,0,0,0)
		_FlowIntensity("FlowIntensity", Float) = 0.5
		_TexPower("TexPower", Float) = 0
		_InnerAlpha("InnerAlpha", Float) = 0
		_FlowTilling("FlowTilling", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha One
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldNormal;
			float3 viewDir;
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float4 _InnerColor;
		uniform float4 _RimColor;
		uniform float _RimIntensity;
		uniform float _RimMin;
		uniform float _RimMax;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _TexPower;
		uniform float _FlowIntensity;
		uniform sampler2D _FlowEmiss;
		uniform float2 _FlowTilling;
		uniform float2 _Speed;
		uniform float _InnerAlpha;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldNormal = i.worldNormal;
			float dotResult8 = dot( ase_worldNormal , i.viewDir );
			float clampResult10 = clamp( dotResult8 , 0.0 , 1.0 );
			float smoothstepResult22 = smoothstep( _RimMin , _RimMax , ( 1.0 - clampResult10 ));
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float clampResult56 = clamp( ( smoothstepResult22 + pow( tex2D( _MainTex, uv_MainTex ).r , _TexPower ) ) , 0.0 , 1.0 );
			float4 lerpResult27 = lerp( _InnerColor , ( _RimColor * _RimIntensity ) , clampResult56);
			float4 FinalRimColor68 = lerpResult27;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult39 = (float2(ase_worldPos.x , ase_worldPos.y));
			float3 objToWorld42 = mul( unity_ObjectToWorld, float4( float3(0,0,0), 1 ) ).xyz;
			float2 appendResult44 = (float2(objToWorld42.x , objToWorld42.y));
			float4 tex2DNode31 = tex2D( _FlowEmiss, ( ( ( appendResult39 - appendResult44 ) * _FlowTilling ) + ( _Speed * _Time.y ) ) );
			float4 FlowColor63 = ( _FlowIntensity * tex2DNode31 );
			o.Emission = ( FinalRimColor68 + FlowColor63 ).rgb;
			float FinalRimAlpha69 = clampResult56;
			float FlowAlpha65 = ( _FlowIntensity * tex2DNode31.a );
			float clampResult48 = clamp( ( FinalRimAlpha69 + _InnerAlpha + FlowAlpha65 ) , 0.0 , 1.0 );
			o.Alpha = clampResult48;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
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
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
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
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
355;81;1053;554;8553.664;55.62677;6.297423;True;True
Node;AmplifyShaderEditor.CommentaryNode;67;-3640.46,1592.989;Inherit;False;2685.961;1593.78;流光;18;50;31;49;51;65;63;33;34;36;37;62;41;44;42;43;39;38;60;流光;0,1,0.2965517,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;70;-3631.885,-685.45;Inherit;False;2722.498;1948.049;Comment;17;26;24;23;27;25;29;56;30;55;53;22;2;54;82;83;84;86;边缘光;0,0.2551723,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;83;-3623.406,0.626709;Inherit;False;613.322;457.1209;Comment;4;10;6;8;7;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;43;-3608.685,2422.203;Inherit;False;Constant;_Vector0;Vector 0;10;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;7;-3598.184,279.7476;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;42;-3406.685,2419.203;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;38;-3529.282,2078.222;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;6;-3606.406,60.62671;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;8;-3369.898,192.8264;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;44;-3171.685,2444.203;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;39;-3272.923,2099.956;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;10;-3214.084,193.139;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;82;-2951.391,129.0007;Inherit;False;229;161;1-Value;1;11;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;37;-2584.123,2897.927;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;62;-2620.34,2406.179;Inherit;False;Property;_FlowTilling;FlowTilling;12;0;Create;True;0;0;0;False;0;False;0,0;2,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;41;-2897.825,2251.518;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;34;-2576.949,2754.448;Inherit;False;Property;_Speed;Speed;8;0;Create;True;0;0;0;False;0;False;0,0;0,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.OneMinusNode;11;-2893.391,183.0007;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-3005.699,974.9958;Inherit;False;Property;_TexPower;TexPower;10;0;Create;True;0;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-2650.794,261.5976;Inherit;False;Property;_RimMin;RimMin;2;0;Create;True;0;0;0;False;0;False;0;0.2;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2654.065,343.1179;Inherit;False;Property;_RimMax;RimMax;3;0;Create;True;0;0;0;False;0;False;0;1.5;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-2453.162,2391.384;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;2;-3214.083,738.058;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;0;False;0;False;-1;None;be8f19aec22965b418fd04de4f9f5f25;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-2379.007,2766.545;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;22;-2392.178,188.2763;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;-2230.859,2410.516;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;53;-2766.63,789.5954;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;31;-1913.89,2260.037;Inherit;True;Property;_FlowEmiss;FlowEmiss;7;0;Create;True;0;0;0;False;0;False;-1;None;adc10745c1b069148b3531cbd4dcab6a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;50;-1609.28,2301.84;Inherit;False;Property;_FlowIntensity;FlowIntensity;9;0;Create;True;0;0;0;False;0;False;0.5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-2133.094,231.4912;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2728.536,-178.2577;Inherit;False;Property;_RimIntensity;RimIntensity;6;0;Create;True;0;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;26;-2782.174,-361.1445;Inherit;False;Property;_RimColor;RimColor;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.1146194,0.2017301,0.7794118,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-1378.835,2450.998;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;79;-1503.936,178.3153;Inherit;False;274;166;Comment;1;69;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;25;-2770.436,-550.9033;Inherit;False;Property;_InnerColor;InnerColor;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.001730105,0.07099391,0.2352941,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;56;-1983.606,215.1217;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-2436.027,-304.7844;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;27;-1560.149,-255.142;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-1380.193,2094.987;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-1241.458,2457.838;Inherit;False;FlowAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;77;-1610.149,-305.142;Inherit;False;467.2759;209;Comment;1;68;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;88;-246.0666,473.2663;Inherit;False;626.6847;375.8794;Comment;5;72;59;66;47;48;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-1453.936,228.3153;Inherit;False;FinalRimAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;-1366.873,-240.3683;Inherit;False;FinalRimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-196.0666,733.1457;Inherit;False;65;FlowAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-187.7934,627.3918;Inherit;False;Property;_InnerAlpha;InnerAlpha;11;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;-187.6451,523.2663;Inherit;False;69;FinalRimAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-1207.353,2098.894;Inherit;False;FlowColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;87;-257.8774,33.0806;Inherit;False;479.9402;306.7194;Comment;3;64;45;71;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-207.8774,223.8;Inherit;False;63;FlowColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;74.2644,570.0828;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;-188.726,83.0806;Inherit;False;68;FinalRimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;70.0629,89.87669;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;84;-1995.95,651.0778;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;48;209.6181,551.0987;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;656.1123,181.2159;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Scan;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;True;0;Custom;0.5;True;True;0;True;Custom;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;8;5;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;85;-2045.95,601.0778;Inherit;False;306;257;边缘光控制函数;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;86;-2704.065,138.2763;Inherit;False;500.887;320.8416;对比度控制;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;78;-2832.174,-600.9033;Inherit;False;558.147;538.6456;Comment;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;80;-3264.083,688.058;Inherit;False;674.4529;402.9378;Comment;0;;1,1,1,1;0;0
WireConnection;42;0;43;0
WireConnection;8;0;6;0
WireConnection;8;1;7;0
WireConnection;44;0;42;1
WireConnection;44;1;42;2
WireConnection;39;0;38;1
WireConnection;39;1;38;2
WireConnection;10;0;8;0
WireConnection;41;0;39;0
WireConnection;41;1;44;0
WireConnection;11;0;10;0
WireConnection;60;0;41;0
WireConnection;60;1;62;0
WireConnection;36;0;34;0
WireConnection;36;1;37;0
WireConnection;22;0;11;0
WireConnection;22;1;23;0
WireConnection;22;2;24;0
WireConnection;33;0;60;0
WireConnection;33;1;36;0
WireConnection;53;0;2;1
WireConnection;53;1;54;0
WireConnection;31;1;33;0
WireConnection;55;0;22;0
WireConnection;55;1;53;0
WireConnection;51;0;50;0
WireConnection;51;1;31;4
WireConnection;56;0;55;0
WireConnection;29;0;26;0
WireConnection;29;1;30;0
WireConnection;27;0;25;0
WireConnection;27;1;29;0
WireConnection;27;2;56;0
WireConnection;49;0;50;0
WireConnection;49;1;31;0
WireConnection;65;0;51;0
WireConnection;69;0;56;0
WireConnection;68;0;27;0
WireConnection;63;0;49;0
WireConnection;47;0;72;0
WireConnection;47;1;59;0
WireConnection;47;2;66;0
WireConnection;45;0;71;0
WireConnection;45;1;64;0
WireConnection;48;0;47;0
WireConnection;0;2;45;0
WireConnection;0;9;48;0
ASEEND*/
//CHKSM=0858F336CB2697F94539777F585674F80D47171C
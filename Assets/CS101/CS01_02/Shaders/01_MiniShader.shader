Shader "CS02/MiniShader" //Shader的真正名字  可以是路径式的格式
{
	/*材质球参数及UI面板
	https://docs.unity3d.com/cn/current/Manual/SL-Properties.html
	https://docs.unity3d.com/cn/current/ScriptReference/MaterialPropertyDrawer.html
	https://zhuanlan.zhihu.com/p/93194054
	*/
	Properties 
	{
		//默认为空，所以要拖张贴图进来
		_MainTex ("Texture贴图", 2D) = "" {}
		//
		_Float("Float浮点数", Float) = 0.0
		//
		_Slider("Slider滑动", Range(0.0,1.0)) = 0.07
		//
		_Vector("Vector数组", Vector) = (.34, .85, .92, 1) 
	}
	/*
	这是为了让你可以在一个Shader文件中写多种版本的Shader，但只有一个会被使用。
	提供多个版本的SubShader，Unity可以根据对应平台选择最合适的Shader
	或者配合LOD机制一起使用。
	一般写一个即可
	*/
	SubShader
	{
		/*
		标签属性，有两种：一种是SubShader层级，一种在Pass层级
		https://docs.unity3d.com/cn/current/Manual/SL-SubShaderTags.html
		https://docs.unity3d.com/cn/current/Manual/SL-PassTags.html
		*/
		Tags { "RenderType"="Opaque" } 

		/*
		Pass里面的内容Shader代码真正起作用的地方，
		一个Pass对应一个真正意义上运行在GPU上的完整着色器(Vertex-Fragment Shader)
		一个SubShader里面可以包含多个Pass，每个Pass会被按顺序执行
		*/
		Pass 
		{
			// Shader代码从这里开始
			CGPROGRAM  
			//指定一个名为"vert"的函数为顶点Shader
			#pragma vertex vert 
			//指定一个名为"frag"函数为片元Shader
			#pragma fragment frag 
			//引用Unity内置的文件，很方便，有很多现成的函数提供使用
			#include "UnityCG.cginc"  
			

			//https://docs.unity3d.com/Manual/SL-VertexProgramInputs.html
			struct a2v  //CPU向顶点Shader提供的模型数据
			{
				//冒号后面的是特定语义词，告诉CPU需要哪些类似的数据
				//模型空间顶点坐标
				float4 vertex : POSITION; 
				//第一套UV——主纹理
				half2 texcoord0 : TEXCOORD0; 
				//第二套UV——光照贴图
				half2 texcoord1 : TEXCOORD1; 
				//第二套UV——动态光照
				half2 texcoord2 : TEXCOORD2; 
				//模型最多只能有4套UV——自定义
				half2 texcoord4 : TEXCOORD3;  

				//顶点颜色
				half4 color : COLOR; 
				//顶点法线
				half3 normal : NORMAL; 
				//顶点切线(模型导入Unity后自动计算得到)
				half4 tangent : TANGENT; 
			};

			struct v2f  //自定义数据结构体，顶点着色器输出的数据，也是片元着色器输入数据
			{
				float4 pos : SV_POSITION; //输出裁剪空间下的顶点坐标数据，给光栅化使用，必须要写的数据
				float2 uv : TEXCOORD0; //自定义数据体
				//注意跟上方的TEXCOORD的意义是不一样的，上方代表的是UV，这里可以是任意数据。
				//插值器：输出后会被光栅化进行插值，而后作为输入数据，进入片元Shader
				//最多可以写16个：TEXCOORD0 ~ TEXCOORD15。
				float3 normal : TEXCOORD1;
			};

			/*
			Shader内的变量声明，如果跟上面Properties模块内的参数同名，就可以产生链接
			*/
			//Unity内置变量：https://docs.unity3d.com/560/Documentation/Manual/SL-UnityShaderVariables.html
			//Unity内置函数：https://docs.unity3d.com/560/Documentation/Manual/SL-BuiltinFunctions.html
			//在CG中定义sampler2D用以对应Properties属性内的2D纹理属性，在unity编辑器中显示即为一张纹理图片
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			//顶点Shader
			v2f vert (a2v v)
			{
				v2f o;

				//MVP矩阵变换
				//用MVP矩阵变换获取到 模型实际上在屏幕内出现的坐标以及内容
				//模型空间转世界空间
				// 世界空间坐标 = 矩阵乘法（ 模型空间到世界空间的置换矩阵，模型的顶点数据）
				float4 pos_world = mul(unity_ObjectToWorld, v.vertex);
				// 世界空间转相机空间
				float4 pos_view = mul(UNITY_MATRIX_V, pos_world);
				//转到裁剪空间
				float4 pos_clip = mul(UNITY_MATRIX_P, pos_view);
				//获取到裁剪空间坐标
				//o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				//o.pos = UnityObjectToClipPos(v.vertex);
				o.pos = pos_clip;


				//用顶点的UV和材质球的tiling和offset做运算，
				//确保材质球里面的缩放和偏移设置是正确的
				//o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv = v.texcoord0 * _MainTex_ST.xy + _MainTex_ST.zw;

				//法线不改动直接用模型的
				o.normal = v.normal;

				//返回顶点结构
				return o;
			}
			//片元Shader
			half4 frag (v2f i) : SV_Target //SV_Target表示为：片元Shader输出的目标地（渲染目标）
			{
				//fixed4 col = tex2D(_MainTex, i.uv);
				half4 col = float4(i.uv,0.0,0.0);
				return col;
			}
			ENDCG // Shader代码从这里结束
		}
	}
}

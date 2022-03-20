Shader "Custom/5-2"
{
    Properties
    {
        _Color("Color Tint",Color)=(1,1,1,1)
    }
    SubShader
    {
        Pass
       {
            CGPROGRAM
            //����
            #pragma vertex vert
            //ƬԪ
            #pragma fragment frag
            //
            uniform fixed4 _Color;
            //
            struct a2v{
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float4 texcoord: TEXCOORD0;
            };

            struct v2f{
                float4 pos: SV_POSITION;
                fixed3 color: COLOR0;
                };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.color=v.normal *0.5 +fixed3(0.5,0.5,0.5);
                return o;
            }
            //
            fixed4 frag(v2f i):SV_Target{
                fixed3 c=i.color;
                c*=_Color.rgb;
                return fixed4(c,1);
            }
            ENDCG

        }
    }
    FallBack "Diffuse"
}

Shader "TN/ParticleSetting"
{
    Properties
    {
        [Header(Properties)]
        _X_Speed ("X_Speed", Float ) = 0
        _Y_Speed ("Y_Speed", Float ) = 0
        [MaterialToggle] _SceneUV ("SceneUV", Float ) = 0
        _MainTex ("MainTex", 2D) = "white" {}
        [HDR] _MainColor ("MainColor", Color) = (0.5,0.5,0.5,1)
        [MaterialToggle] _Fresnel ("Fresnel", Float ) = 0
        _Fresnel_Range ("Fresnel_Range", Range(0, 5)) = 1
        _Fresnel_Intensity ("Fresnel_Intensity", Range(0, 5)) = 1
        [HDR]_Fresnel_Color ("Fresnel_Color", Color) = (0.5,0.5,0.5,1)
/////interupte uv:
        [Header(Interupte UV)]
        [MaterialToggle] _InterupteToggle ("InterupteToggle", Float ) = 0
        _InterupteTex("interupteTex",2D) = "white"{}
        _InterupteValue("interupteValue",Range(0,1)) = 0
/////Desaturate:
        [Header(Desaturate)]
        [MaterialToggle] _desaturate ("Desaturate", Float ) = 0
        [HDR]_desaturateColor("DesaturateColor",Color)=(1,1,1,1)
/////ReColor_Gradient:
        [Header(ReColor_Gradient)]
        [MaterialToggle] _colorGradient("ColorGradient(need to use Desaturate)",Float) = 0
        _GradientValue("GradientValue",Range(0,1)) = 0.5
        [HDR] _color1("BrightColor",Color) = (1,1,1,1)
        [HDR] _color2("DarkColor",Color) = (0.5,0.5,0.5,1)
/////UVTile:
        [Header(Sequence For Trail)]
        [MaterialToggle] _UseUVtile("UseUVTile",Float) = 0
        _UVtileXY ("UVTile",Vector) = (0,0,0,0)
        _UVtileSpd ("UVTileSpd" , Float) = 0
/////UVRotator:
        [Header(UV Rotator)]
        [MaterialToggle] _UseUVRotator ("UseUVRotator", Float) = 0
        _UVRotator_Angle ("Rotator" , Float) = 0
/////Facing:
        [Header(FaceColor)]
        [MaterialToggle] _UseFacing ("UseFacing?",Float) = 0
        [HDR] _BackColor ("BackColor" ,Color) = (0.5,0.5,0.5,1)
/////Alpha Texture:
        [Header(Alpha Tex(Need UV0 Custom.z))]
        [MaterialToggle] _UseAlphaTex ("UseAlphaTex?",Float) = 0
        _AlphaTexture("AlphaTexture",2D)="white"{}
        _AlphaTexture_Step("AlphaTexture_Step",Range(0,0.5)) = 0
/////Decal Shader:
        [Header(Decal(Need open SceneUV and Depth Cam))]
        [MaterialToggle] _UseDecal ("UseDecal?" , Float) = 0
        _NormalClipThreshold("NormalClip",Range(0,0.3)) = 0.1
/////Blend Settings:
        [Header(Blend Settings)]
        [Enum(UnityEngine.Rendering.BlendMode)] _SourceBlend ("SrcBlend",Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _DestBlend ("DestBlend",Float) = 0
        [Enum(Off,0,Front,1,Back,2)] _Cull("CullMask",Float) = 0
        [Enum(Off,0,On,1)] _ZWrite("Zwrite",Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("ZTest",Float) = 2
/////Stencil Settings:
        [Header(Stencil Settings)]
        _Ref ("Ref",Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _Comp ("Comparison",Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _Pass ("Pass ",Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _Fail ("Fail ",Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _ZFail ("ZFail ",Float) = 0
    }
    SubShader
    {
    Tags{
        "RenderPipeline"="UniversalPipeline"
        "RenderType"="Particle" 
        "Queue"="Transparent"
        }
    Stencil {
             Ref [_Ref]          //0-255
             Comp [_Comp]     //default:always
             Pass [_Pass]   //default:keep
             Fail [_Fail]      //default:keep
             ZFail [_ZFail]     //default:keep
        }
    Pass{
        Name "TN_Particle"
        Tags{   
            // LightMode: <None> 
            }
///// Render Setting:
            Blend [_SourceBlend] [_DestBlend]
            Cull [_Cull]
            ZWrite [_ZWrite]
            ZTest [_ZTest]

            HLSLPROGRAM
///// Pragmas:
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            //#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            //#pragma multi_compile_instancing
            //#pragma instancing_options procedural:vertInstancingSetup
            //#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl
            struct VertexInput{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 vertexColor : COLOR;
                float4 uv : TEXCOORD0;
                //UNITY_VERTEX_INPUT_INSTANCE_ID
			};
            struct VertexOutput{
                float4 pos : SV_POSITION;
                float4 posWorld : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float4 projPos : TEXCOORD2;
                float4 vertexColor : COLOR;
                float4 uv : TEXCOORD3;
                float3 ray : TEXCOORD4;
                //float3 yDir : TEXCOORD5;
			};
///// Declare:
            Texture2D _MainTex , _InterupteTex , _AlphaTexture , _CameraDepthTexture ;
            SamplerState  linear_repeat_sampler ; 
            float _X_Speed , _Y_Speed , _Fresnel_Range , _Fresnel_Intensity , _Fresnel , _SceneUV , _InterupteValue , _InterupteToggle , _desaturate , _colorGradient , _GradientValue , _UseUVtile , _UVtileSpd , _UseFacing , _UseUVRotator , _UVRotator_Angle , _UseAlphaTex , _AlphaTexture_Step , _NormalClipThreshold , _UseDecal , _UseVertexExtrude;
            float4 _MainColor , _Fresnel_Color , _desaturateColor , _color1 , _color2 , _UVtileXY , _BackColor , _MainTex_ST , _InterupteTex_ST , _AlphaTexture_ST , _CameraDepthTexture_ST ;
/////   InverseLerp func :
            float InverseLerp(float a , float b , float c){ 
                return saturate((c-a)/(b-a));
			}
/////   Vert:
            VertexOutput vert (VertexInput v ){
                VertexOutput o = (VertexOutput)0;
                //UNITY_SETUP_INSTANCE_ID(v);
                //UNITY_TRANSFER_INSTANCE_ID(v,o);
                o.normal = TransformObjectToWorldNormal(v.normal); 
                o.vertexColor = v.vertexColor;
                o.uv = v.uv ;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.posWorld = mul(unity_ObjectToWorld,v.vertex);
                o.ray = 0;
                //o.yDir = 0;
                if(_SceneUV){
                    o.projPos = ComputeScreenPos(o.pos);
                    //COMPUTE_EYEDEPTH(o.projPos.z);
                }
                else{
                     o.projPos = v.uv;
                }
                if(_UseDecal){
                    o.ray = TransformWorldToView(v.vertex.xyz) * float3(1,1,-1);
                    //o.yDir = mul((float3x3)unity_ObjectToWorld,float3(0,1,0));
				} 
                return o;
            }
            float4 frag(VertexOutput o, float facing : VFACE) : SV_Target{ 
                o.normal = normalize(o.normal);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz-o.posWorld.xyz);
/////////Facing:
                float3 FaceColor = 1;
                if(_UseFacing){ FaceColor = (facing >= 0 ? _BackColor.rgb : 1); }
                //float isFrontFace = ( facing >= 0 ? 1 : 0 );
                //float faceSign = ( facing >= 0 ? 1 : -1 );
/////////UVTile:
                float UVTile_TimeSpeed , UVTile_X , UVTile_Y= 0 ; float2 UVTile =0;
                if(_UseUVtile){
                    UVTile_TimeSpeed = trunc(_Time.g *  _UVtileSpd);
                    UVTile = float2 (1,1) / float2 (_UVtileXY.x,_UVtileXY.y);
                    UVTile_X = floor(UVTile_TimeSpeed * UVTile.x);
                    UVTile_Y = 1-( UVTile_TimeSpeed - _UVtileXY.y * UVTile_X);
                }
/////////SceneUV :
                float2 SceneUV = o.projPos.xy / o.projPos.w; 
                if(_InterupteToggle){
                    float2 InterupteUV = o.projPos.xy / o.projPos.w;
                    InterupteUV += float2(_X_Speed,_Y_Speed)*_Time.g;
                    float4 InterupteTex = _InterupteTex.Sample(linear_repeat_sampler,TRANSFORM_TEX( InterupteUV , _InterupteTex ));//tex2D(_InterupteTex,TRANSFORM_TEX(InterupteUV,_InterupteTex));
                    SceneUV = lerp( SceneUV , InterupteTex.rg , _InterupteValue );
                }
                else{
                    SceneUV += float2(_X_Speed,_Y_Speed)*_Time.g;
                }
                if(_UseUVtile){
                    SceneUV = (SceneUV+float2(UVTile_X,UVTile_Y)) * UVTile;
                }
/////////UV Rotator:
                float UVRotator_cos , UVRotator_sin = 0;
                if(_UseUVRotator){
                    UVRotator_cos = cos(_UVRotator_Angle * _Time.g);
                    UVRotator_sin = sin(_UVRotator_Angle * _Time.g);
                    float2 Pivot = float2(0.5,0.5);
                    SceneUV = mul( SceneUV - Pivot , float2x2( UVRotator_cos , -UVRotator_sin , UVRotator_sin , UVRotator_cos))+ Pivot;
                }
/////////Fresnel :
                float3 fresnel = pow(saturate(1-max(0,(dot(viewDir,o.normal)))),_Fresnel_Range);
                float3 fresnel_Color = fresnel * _Fresnel_Color.rgb *_Fresnel_Intensity;
/////////Decal: 
                if(_UseDecal){
                    //vertInstancingSetup();
                    float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, linear_repeat_sampler , SceneUV);
				    float viewDepth = Linear01Depth(depth,_ZBufferParams) * _ProjectionParams.z;
                    float3 viewPos = o.ray * viewDepth / o.ray.z ; 
                    float4 worldPos = mul (unity_CameraToWorld , float4(viewPos,1 ) ) ;
                    float3 objectPos = mul (unity_WorldToObject , worldPos).xyz;
                    //return float4(objectPos.xyz,1);
                    //objectPos = UnityObjectToWorldPos(float4(objectPos,0));
                    clip(float3(0.5,0.5,0.5) - abs(objectPos));
                    //float3 worldNormal = tex2D(_CameraGBufferTexture2,SceneUV).rgb*2-1;
                    //float3 yDir = normalize(o.yDir) ;
                    //clip(dot( yDir , worldNormal ) - _NormalClipThreshold );
                    SceneUV = objectPos.xz + 0.5;
                }
/////////FinalColor :
                float4 MainTex = _MainTex.Sample(linear_repeat_sampler,TRANSFORM_TEX( SceneUV , _MainTex));//tex2D(_MainTex,TRANSFORM_TEX(SceneUV,_MainTex));
/////////Desaturate:
                if(_desaturate){
                    float MainTex_desatured = dot(MainTex.rgb,float3(0.3,0.59,0.11));
                    MainTex.rgb = MainTex_desatured.rrr;
                    if(_colorGradient){
                        float TexColor_Smoothstep = InverseLerp(_GradientValue,1,MainTex_desatured);  //smoothstep(MainTex.rgb+0.4 , MainTex.rgb , _GradientValue);
                        float3 BrightColor = MainTex.rgb * TexColor_Smoothstep * _color1.rgb ;
                        float3 DarkColor = MainTex.rgb * (1-TexColor_Smoothstep) * _color2.rgb;
                        MainTex.rgb = BrightColor+DarkColor;
                    }
                    else{
                       MainTex.rgb = MainTex.rgb*_desaturateColor.rgb;
                    }
                }
/////////Alpha:
                float4 AlphaTexture = 1;
                float Alpha =  MainTex.a*o.vertexColor.a ; 
                if(_UseAlphaTex){
                    AlphaTexture = _AlphaTexture.Sample(linear_repeat_sampler , o.uv.xy); //tex2D(_AlphaTexture,TRANSFORM_TEX(o.uv,_AlphaTexture));
                    Alpha *= saturate(InverseLerp( _AlphaTexture_Step , 1-_AlphaTexture_Step , AlphaTexture.r)+o.uv.z);  
				}
/////////FinalColor:
                float3 MainTex2 = MainTex.rgb*_MainColor.rgb*o.vertexColor.rgb+ fresnel_Color;
                if(_Fresnel){
                    return float4(MainTex2*FaceColor,Alpha);
                }
                else{
                     return float4(MainTex.rgb*_MainColor.rgb*o.vertexColor.rgb*FaceColor ,  Alpha);
                }
            }
            ENDHLSL
	    }
    }
}

Shader "Tessellation/ViewTessellation"
{
    Properties
    {
		_TessellationUniform("Tessellation Uniform", Range(1, 64)) = 1
		_TessellationEdgeLength("Tessellation Edge Length", Range(0.1, 100)) = 5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
			#pragma target 4.6


		    #pragma vertex vert
			#pragma hull hull
			#pragma domain domain
			#pragma geometry geo
			#pragma fragment frag
			#pragma shader_feature _TESSELLATION_EDGE

			#include "UnityCG.cginc"
			#include "CustomTessellation.cginc"

			[maxvertexcount(3)]
			void geo(triangle v2f IN[3], inout TriangleStream<geometryOutput> stream) {

				geometryOutput g0, g1, g2;
				g0 = VertexOutput(IN[0]);
				g1 = VertexOutput(IN[1]);
				g2 = VertexOutput(IN[2]);

				stream.Append(g0);
				stream.Append(g1);
				stream.Append(g2);
			}

			fixed4 frag(geometryOutput i, fixed facing : VFACE) : SV_Target
			{
				return 1;
			}
            ENDCG
        }
    }
}

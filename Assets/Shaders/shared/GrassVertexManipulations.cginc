float4 positionVertexInWorld(GrassBlade grassBlade, float4 positionOS) {
    // generate a translation matrix to move the vertex
    float4x4 translationMatrix = getTranslation_Matrix(grassBlade.position);
    float4x4 rotationMatrix = getRotationY_Matrix(grassBlade.rotationY);
    float4x4 transformationMatrix = mul(translationMatrix, rotationMatrix);

    // translate the object pos to world pos
    float4 worldPosition = mul(unity_ObjectToWorld, positionOS);
    // then use the matrix to translate and rotate it
    worldPosition = mul(transformationMatrix, worldPosition);

    return worldPosition;
}

float4 applyWind(GrassBlade grassBlade, float2 uv, float4 worldPosition, float3 windDirection, float windForce) {
    float3 displaced = worldPosition.xyz + (normalize(windDirection) * windForce * grassBlade.windNoise);
    float4 displacedByWind = float4(displaced, 1);

    // base of the grass needs to be static on the floor
    return lerp(worldPosition, displacedByWind, uv.y);
}

float4 positionGrassVertexInHClipPos(
    StructuredBuffer<GrassBlade> GrassBladesBuffer,
    uint instance_id,
    out GrassBlade grassBlade,
    float4 positionOS,
    float2 uv,
    float3 windDirection,
    float windForce
) {
    // get the instanced grass blade
    grassBlade = GrassBladesBuffer[instance_id];

    float4 worldPosition = positionVertexInWorld(grassBlade, positionOS);
    worldPosition = applyWind(grassBlade, uv, worldPosition, windDirection, windForce);

    // translate the world pos to clip pos
    return UnityWorldToClipPos(worldPosition);
}

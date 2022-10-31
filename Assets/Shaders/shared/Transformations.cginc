// https://en.wikipedia.org/wiki/Matrix_multiplication
// https://www.brainvoyager.com/bv/doc/UsersGuide/CoordsAndTransforms/SpatialTransformationMatrices.html
float4x4 getTranslation_Matrix(float3 origin){

    // (
    //     1, 0, 0, origin.x,
    //     0, 1, 0, origin.y,
    //     0, 0, 1, origin.z,
    //     0, 0, 0, 1,
    // )
    // mul
    // (
    //     x,
    //     y,
    //     z,
    //     1
    // )
    // =
    // (
    //     origin.x + x,
    //     origin.y + y,
    //     origin.z + z,
    //     1
    // )

    return float4x4(
        1, 0, 0, origin.x,
        0, 1, 0, origin.y,
        0, 0, 1, origin.z,
        0, 0, 0, 1
    );
}

// https://en.wikipedia.org/wiki/Matrix_multiplication
// https://www.brainvoyager.com/bv/doc/UsersGuide/CoordsAndTransforms/SpatialTransformationMatrices.html
float4x4 getRotationZ_Matrix(float thetaZ){

    float c = cos(thetaZ);
    float s = sin(thetaZ);

    return float4x4(
        c, -s, 0, 0,
        s, c, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    );
}

float4x4 getTransformation_Matrix(float3 origin, float thetaZ) {
    return mul(getTranslation_Matrix(origin), getRotationZ_Matrix(thetaZ));
}

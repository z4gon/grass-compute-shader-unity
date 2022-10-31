using UnityEngine;

public static class GrassFactory
{
    const float Height = 0.2f;
    const float Width = Height / 12;
    const int StepsCount = 4;
    const float StepHeight = Height / StepsCount;
    const float HalfWidth = Width / 2;

    // Start is called before the first frame update
    public static Mesh GetGrassBladeMesh()
    {
        var mesh = new Mesh();

        // define the vertices
        mesh.vertices = new Vector3[] {
            // step 0
            new Vector3(-HalfWidth, 0, 0),
            new Vector3(HalfWidth, 0, 0),

            // step 1
            new Vector3(-HalfWidth * 0.9f, StepHeight, 0.005f),
            new Vector3(HalfWidth * 0.9f, StepHeight, 0.005f),

            // step 2
            new Vector3(-HalfWidth * 0.8f, 2 * StepHeight, 0.01f),
            new Vector3(HalfWidth * 0.8f, 2 * StepHeight, 0.01f),

            // step 3
            new Vector3(-HalfWidth * 0.6f, 3 * StepHeight, 0.025f),
            new Vector3(HalfWidth * 0.6f, 3 * StepHeight, 0.025f),

            // step 4
            new Vector3(0, 4 * StepHeight, 0.05f)
        };

        // define the normals
        Vector3[] normalsArray = new Vector3[mesh.vertices.Length];
        System.Array.Fill(normalsArray, new Vector3(0, 0, -1));
        mesh.normals = normalsArray;

        mesh.uv = new Vector2[] {
            // step 0
            new Vector2(0, 0),
            new Vector2(1, 0),

            // step 1
            new Vector2(0, 0.25f),
            new Vector2(1, 0.25f),

            // step 2
            new Vector2(0, 0.5f),
            new Vector2(1, 0.5f),

            // step 3
            new Vector2(0, 0.75f),
            new Vector2(1, 0.75f),

            // step 4
            new Vector2(0.5f, 1f),
        };

        mesh.SetIndices(
            // counter clock wise so the normals make sense
            indices: new int[]{
                // step 0
                0,1,2,
                2,1,3,

                // step 1
                2,3,4,
                4,3,5,

                // step 2
                4,5,6,
                6,5,7,

                // step 3
                6,7,8,
            },
            topology: MeshTopology.Triangles,
            submesh: 0
        );

        return mesh;
    }

    public static void RaycastGrassBlades(
        Transform transform,
        MeshFilter meshFilter,
        float maxExtent,
        float density,
        out Bounds bounds,
        out int grassBladesCount,
        out GrassBlade[] grassBlades
    )
    {
        var meshBounds = meshFilter.sharedMesh.bounds;

        bounds = new Bounds(
            transform.position,
            new Vector3(
                System.Math.Min(meshBounds.extents.x, maxExtent),
                meshBounds.extents.y,
                System.Math.Min(meshBounds.extents.z, maxExtent)
            )
        );

        var grassBladesCountX = bounds.extents.x * 2 * density;
        var grassBladesCountY = bounds.extents.y * 2 * density;

        grassBladesCount = (int)(grassBladesCountX * grassBladesCountY);

        grassBlades = new GrassBlade[grassBladesCount];

        for (var i = 0; i < grassBlades.Length; i++)
        {
            var grassBlade = grassBlades[i];

            var localPos = new Vector3(
                x: Random.Range(-bounds.extents.x, bounds.extents.x),
                y: 0,
                z: Random.Range(-bounds.extents.z, bounds.extents.z)
            );

            RaycastHit hit;
            var didHit = Physics.Raycast(
                origin: transform.TransformPoint(localPos) + (transform.up * 20),
                direction: -transform.up,
                hitInfo: out hit
            );

            if (didHit)
            {
                localPos.y = hit.point.y;
            }

            grassBlade.position = transform.TransformPoint(localPos);

            grassBlades[i] = grassBlade;
        }
    }
}

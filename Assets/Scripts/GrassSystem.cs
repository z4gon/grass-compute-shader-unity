using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
public class GrassSystem : MonoBehaviour
{
    public Material Material;
    public ComputeShader ComputeShader;
    public float Density = 1f;
    public float MaxExtent = 5f;
    public Vector2 NoiseTiling = new Vector2(10, 10);
    public Vector3 WindDirection = new Vector3(0, 0, 1);
    public float WindForce = 0.05f;
    public float WindVelocity = 2f;

    private GrassBlade[] _grassBlades;
    private ComputeBuffer _grassBladesBuffer;

    private int _kernelIndex;
    private uint _threadGroupsCountX;

    // for Graphics.DrawMeshInstancedIndirect
    private ComputeBuffer _argsBuffer;
    private Bounds _bounds;
    private Mesh _mesh;
    private int _grassBladesCount;

    private bool _isInitialized = false;

    // Start is called before the first frame update
    void Start()
    {
        _mesh = GrassFactory.GetGrassBladeMesh();

        InitializeGrassBlades();
        InitializeGrassBladesBuffer();
        InitializeIndirectArgsBuffer();
        InitializeThreadGroupsSize();

        _isInitialized = true;
    }

    private void InitializeGrassBlades()
    {
        GrassFactory.RaycastGrassBlades(
            transform: transform,
            meshFilter: GetComponent<MeshFilter>(),
            maxExtent: MaxExtent,
            density: Density,
            bounds: out _bounds,
            grassBladesCount: out _grassBladesCount,
            grassBlades: out _grassBlades
        );

        ComputeShader.SetFloat("GrassBoundsX", _bounds.extents.x);
        ComputeShader.SetFloat("GrassBoundsY", _bounds.extents.y);
    }

    private void InitializeGrassBladesBuffer()
    {
        var grassBladeMemorySize = (3 + 1) * sizeof(float);

        _grassBladesBuffer = new ComputeBuffer(
            count: _grassBlades.Length,
            stride: _grassBlades.Length * grassBladeMemorySize
        );

        _grassBladesBuffer.SetData(_grassBlades);

        _kernelIndex = ComputeShader.FindKernel("SimulateGrass");

        // this will let compute shader access the buffers
        ComputeShader.SetBuffer(_kernelIndex, "GrassBladesBuffer", _grassBladesBuffer);

        // this will let the surface shader access the buffer
        Material.SetBuffer("GrassBladesBuffer", _grassBladesBuffer);
    }

    private void InitializeIndirectArgsBuffer()
    {
        _bounds = new Bounds(center: Vector3.zero, size: Vector3.one * 1000);

        const int _argsCount = 5;

        _argsBuffer = new ComputeBuffer(
            count: 1,
            stride: _argsCount * sizeof(uint),
            type: ComputeBufferType.IndirectArguments
        );

        // for Graphics.DrawMeshInstancedIndirect
        // this will be used by the vertex/fragment shader
        // to get the instance_id and vertex_id
        var args = new int[_argsCount] {
            (int)_mesh.GetIndexCount(submesh: 0),       // indices of the mesh
            _grassBladesCount,                          // number of objects to render
            0,0,0                                       // unused args
        };

        _argsBuffer.SetData(args);
    }

    private void InitializeThreadGroupsSize()
    {
        // calculate amount of thread groups
        uint threadGroupSizeX;
        ComputeShader.GetKernelThreadGroupSizes(_kernelIndex, out threadGroupSizeX, out _, out _);
        _threadGroupsCountX = (uint)_grassBlades.Length / threadGroupSizeX;
    }

    // Update is called once per frame
    void Update()
    {
        if (!_isInitialized)
        {
            return;
        }

        ComputeShader.SetFloat("Time", Time.time);
        ComputeShader.SetInt("NoiseColumns", (int)System.Math.Floor(NoiseTiling.x));
        ComputeShader.SetInt("NoiseRows", (int)System.Math.Floor(NoiseTiling.y));
        ComputeShader.SetFloat("WindVelocity", WindVelocity);
        ComputeShader.Dispatch(_kernelIndex, (int)_threadGroupsCountX, 1, 1);

        Material.SetVector("WindDirection", WindDirection);
        Material.SetFloat("WindForce", WindForce);

        Graphics.DrawMeshInstancedIndirect(
            mesh: _mesh,
            submeshIndex: 0,
            material: Material,
            bounds: _bounds,
            bufferWithArgs: _argsBuffer
        );
    }

    void OnDestroy()
    {
        if (_grassBladesBuffer != null)
        {
            _grassBladesBuffer.Release();
        }

        if (_argsBuffer != null)
        {
            _argsBuffer.Release();
        }
    }

    void DrawWindGizmo()
    {
        Gizmos.color = Color.white;
        var origin = transform.position + (Vector3.up * 2);
        Gizmos.DrawSphere(origin, 0.1f);
        Gizmos.DrawLine(origin, origin + WindDirection);
    }

    void OnDrawGizmosSelected()
    {
        DrawWindGizmo();

        if (!_isInitialized)
        {
            return;
        }

        // // Gizmos.DrawSphere(new Vector3(1, 0, 1), 0.1f);
        // for (var i = 0; i < _grassBlades.Length; i++)
        // {
        //     // Debug.Log($"grassBlade.position {_grassBlades[i].position}");
        //     Gizmos.DrawSphere(_grassBlades[i].position, 0.01f);
        // }
    }
}

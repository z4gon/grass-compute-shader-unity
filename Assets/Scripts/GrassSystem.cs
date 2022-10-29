using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
public class GrassSystem : MonoBehaviour
{
    public Material Material;
    public ComputeShader ComputeShader;
    public float Density = 1f;

    private GrassBlade[] _grassBlades;
    private ComputeBuffer _grassBladesBuffer;

    private int _kernelIndex;

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

        _isInitialized = true;
    }

    private void InitializeGrassBlades()
    {
        _bounds = GetComponent<MeshFilter>().sharedMesh.bounds;

        var grassBladesCountX = _bounds.extents.x * 2 * Density;
        var grassBladesCountY = _bounds.extents.y * 2 * Density;

        _grassBladesCount = (int)(grassBladesCountX * grassBladesCountY);

        _grassBlades = new GrassBlade[_grassBladesCount];
    }

    private void InitializeGrassBladesBuffer()
    {
        var grassBladeMemorySize = (3) * sizeof(float);

        _grassBladesBuffer = new ComputeBuffer(
            count: _grassBlades.Length,
            stride: _grassBlades.Length * grassBladeMemorySize
        );

        _grassBladesBuffer.SetData(_grassBlades);

        _kernelIndex = ComputeShader.FindKernel("SimulateGrass");

        // this will let compute shader access the buffers
        ComputeShader.SetBuffer(_kernelIndex, "GrassBlades", _grassBladesBuffer);

        // this will let the surface shader access the buffer
        Material.SetBuffer("GrassBlades", _grassBladesBuffer);
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

    // Update is called once per frame
    void Update()
    {
        if (!_isInitialized)
        {
            return;
        }

        ComputeShader.SetFloat("Time", Time.time);
        ComputeShader.Dispatch(_kernelIndex, _grassBlades.Length, 1, 1);
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
}

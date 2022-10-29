using UnityEngine;

public class GrassSystem : MonoBehaviour
{
    public Material Material;
    public ComputeShader ComputeShader;
    public float Density = 1f;
    public Bounds Bounds;

    private ComputeBuffer _grassBladesBuffer;

    private int _kernelIndexSetupGrassBlades;
    private int _kernelIndexSimulateGrassBlades;

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

        InitializeGrassBladesBuffer();
        InitializeIndirectArgsBuffer();

        _isInitialized = true;
    }

    private void InitializeGrassBladesBuffer()
    {
        // var vertexMemorySize = (3 + 3) * sizeof(float);

        // _initialVerticesBuffer = new ComputeBuffer(_vertices.Length, _vertices.Length * vertexMemorySize);
        // _deformedVerticesBuffer = new ComputeBuffer(_vertices.Length, _vertices.Length * vertexMemorySize);

        // _initialVerticesBuffer.SetData(_vertices);
        // _deformedVerticesBuffer.SetData(_vertices);

        // _kernelIndex = ComputeShader.FindKernel("DeformVertices");

        // // this will let compute shader access the buffers
        // ComputeShader.SetBuffer(_kernelIndex, "InitialVertices", _initialVerticesBuffer);
        // ComputeShader.SetBuffer(_kernelIndex, "DeformedVertices", _deformedVerticesBuffer);

        // // this will let the surface shader access the buffer
        // Material.SetBuffer("DeformedVertices", _deformedVerticesBuffer);
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
            (int)_mesh.GetIndexCount(0),                // indices of the mesh
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

        // ComputeShader.SetFloat("Time", Time.time);
        // ComputeShader.SetFloat("Radius", Radius);
        // ComputeShader.SetFloat("Velocity", Velocity);
        // ComputeShader.Dispatch(_kernelIndex, _vertices.Length, 1, 1);
        // Graphics.DrawMeshInstancedIndirect(
        //     mesh: Mesh,
        //     submeshIndex: 0,
        //     material: Material,
        //     bounds: _bounds,
        //     bufferWithArgs: _argsBuffer
        // );
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

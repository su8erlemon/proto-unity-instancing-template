using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class PositionCheckInstancing : MonoBehaviour
{

    public int instancingNum = 1000;
    public Mesh instancingMesh;
    public Material instancingMat;
    
    private ComputeBuffer _argsBuffer;
    private uint[] _args = new uint[5] { 0, 0, 0, 0, 0 };

    private Vector4 _worldRotation = new Vector4();
    
    void Start()
    {     
        _argsBuffer = new ComputeBuffer(1, _args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        _args[0] = (instancingMesh != null) ? (uint)instancingMesh.GetIndexCount(0) : 0;
        _args[1] = (uint)instancingNum;
        _argsBuffer.SetData(_args);
    }

    void OnDestroy()
    {
         if( _argsBuffer != null)_argsBuffer.Release();
    }

    void Update()
    {   
        
        _worldRotation.x = transform.rotation.x; 
        _worldRotation.y = transform.rotation.y; 
        _worldRotation.z = transform.rotation.z; 
        _worldRotation.w = transform.rotation.w; 

        instancingMat.SetVector("_WorldPosition",transform.position);
        instancingMat.SetVector("_WorldRotation",_worldRotation);
        instancingMat.SetBuffer("_PositionBuffer", PositionCalcManager.instance.buffer);

        /*
            public static void DrawMeshInstancedIndirect(
                Mesh mesh, 
                int submeshIndex, 
                Material material, 
                Bounds bounds, 
                ComputeBuffer bufferWithArgs, 
                int argsOffset = 0, 
                MaterialPropertyBlock properties = null, 
                Rendering.ShadowCastingMode castShadows = ShadowCastingMode.On, 
                bool receiveShadows = true, 
                int layer = 0, 
                Camera camera = null, 
                Rendering.LightProbeUsage lightProbeUsage = LightProbeUsage.BlendProbes, 
                LightProbeProxyVolume lightProbeProxyVolume = null
            );
        */
        // render boxes
        Graphics.DrawMeshInstancedIndirect(
            instancingMesh, 
            0, 
            instancingMat, 
            new Bounds(Vector3.zero, new Vector3(100.0f, 100.0f, 100.0f)), 
            _argsBuffer,
            0,
            null,
            ShadowCastingMode.Off, // On // TwoSided // ShadowsOnly
            false,
            8 // layer 
        );

    }
    
}
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Runtime.InteropServices;
public class PositionCalcManager : MonoBehaviour
{
    public static PositionCalcManager instance;
    private const int NUM = 1000;

    public ComputeShader computeShader;

    private ComputeBuffer _buffer;
    public ComputeBuffer buffer
    {
        get { return _buffer; }
    }

    private int _kernelID;
    
    void Awake()
    {   
        instance = this;
        int size = Marshal.SizeOf(new Vector3());

        _buffer = new ComputeBuffer(NUM, size);
        _kernelID = computeShader.FindKernel("CSMain");
        computeShader.SetBuffer(_kernelID, "Result", _buffer);

    }

    void Update()
    {   
        computeShader.SetBuffer(_kernelID, "Result", _buffer);        
        computeShader.SetFloat("_Time", Time.realtimeSinceStartup);
        computeShader.Dispatch(_kernelID, 256, 1, 1);
    }

    void OnDestroy(){
        if(_buffer != null)_buffer.Release();
    }
    

}


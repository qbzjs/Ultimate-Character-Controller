using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LayerTest : MonoBehaviour
{
    public GameObject Cube;

    // Start is called before the first frame update
    void Start()
    {
        SetGameObjectLayer(Cube, "TestLayer");

        SetCameraCullingMask("TestLayer");
    }

    /// <summary>
    /// ͨ������������ò�
    /// </summary>
    /// <param name="go"></param>
    /// <param name="layerName"></param>
    private void SetGameObjectLayer(GameObject go, string layerName)
    {
        int layer = LayerMask.NameToLayer(layerName);

        Debug.Log(GetType() + "/SetGameObjectLayer()/ layer : " + layer);

        SetGameObjectLayer(go, layer);
    }

    /// <summary>
    /// ͨ�����������ò�
    /// </summary>
    /// <param name="go"></param>
    /// <param name="layer"></param>
    private void SetGameObjectLayer(GameObject go, int layer)
    {
        go.layer = layer;
    }


    /// <summary>
    /// ͨ������������� Camera CullingMask
    /// </summary>
    /// <param name="layerName"></param>
    private void SetCameraCullingMask(string layerName)
    {
        int layer = LayerMask.NameToLayer(layerName);
        SetCameraCullingMask(layer);
    }

    /// <summary>
    /// ͨ������������ Camera CullingMask
    /// </summary>
    /// <param name="layer"></param>
    private void SetCameraCullingMask(int layer)
    {
        Camera.main.cullingMask = 1 << layer;
    }

}

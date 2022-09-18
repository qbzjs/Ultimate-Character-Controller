using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CreateMeshTest : MonoBehaviour
{
    // �������� ģ�Ϳռ䶥������
    Vector3[] vertices =
    {
		// Front
		// point[1]
		new Vector3(-2.0f, 5.0f, -2.0f),//[0]
		// point[2]
		new Vector3(-2.0f, 0.0f, -2.0f),//[1]
		// point[3]
		new Vector3(2.0f, 0.0f, -2.0f),//[2]
		// point[4]
		new Vector3(2.0f, 5.0f, -2.0f),//[3]

		// Left  
		new Vector3(-2.0f, 5.0f, -2.0f),//[4]
		new Vector3(-2.0f, 0.0f, -2.0f),//[5]
		new Vector3(-2.0f, 0.0f, 2.0f),//[6]
		new Vector3(-2.0f, 5.0f, 2.0f),//[7]
    
		// Back
		new Vector3(-2.0f, 5.0f, 2.0f),//[8]
		new Vector3(-2.0f, 0.0f, 2.0f),//[9]
		new Vector3(2.0f, 0.0f, 2.0f),//[10]
		new Vector3(2.0f, 5.0f, 2.0f),//[11]
         
		// Right  
		new Vector3(2.0f, 5.0f, 2.0f),//[12]
		new Vector3(2.0f, 0.0f, 2.0f),//[13]
		new Vector3(2.0f, 0.0f, -2.0f),//[14]
		new Vector3(2.0f, 5.0f, -2.0f),//[15]

		// Top
		new Vector3(-2.0f, 5.0f, 2.0f),//[16]
		new Vector3(2.0f, 5.0f, 2.0f),//[17]
		new Vector3(2.0f, 5.0f, -2.0f),//[18]
		new Vector3(-2.0f, 5.0f, -2.0f),//[19]
    
		// Bottom
		new Vector3(-2.0f, 0.0f, 2.0f),//[20]
		new Vector3(2.0f, 0.0f, 2.0f),//[21]
		new Vector3(2.0f, 0.0f, -2.0f),//[22]
		new Vector3(-2.0f, 0.0f, -2.0f),//[23]
	};


    // ��������
    int[] triangles =
    {
		// Front
		2,1,0,
        0,3,2,
        
		// Left
		4,5,6,
        4,6,7,
        
		// Back
		9,11,8,
        9,10,11,
        
		// Right
		12,13,14,
        12,14,15,
        
		// Top
		16,17,18,
        16,18,19,
        
		// Buttom
		21,23,22,
        21,20,23,
    };


	// UV����
	Vector2[] uvs =
	{
		// point[1]
		new Vector2(0.0f, 1.0f),
		// point[2]
		new Vector2(0.0f, 0.0f),
		// point[3]
		new Vector2(1.0f, 0.0f),
		// point[4]
		new Vector2(1.0f, 1.0f),
		                   
		// Left
		new Vector2(1.0f, 1.0f),
		new Vector2(1.0f, 0.0f),
		new Vector2(0.0f, 0.0f),
		new Vector2(0.0f, 1.0f),
		                   
		// Back
		new Vector2(1.0f, 1.0f),
		new Vector2(1.0f, 0.0f),
		new Vector2(0.0f, 0.0f),
		new Vector2(0.0f, 1.0f),
		                   
		// Right
		new Vector2(1.0f, 1.0f),
		new Vector2(1.0f, 0.0f),
		new Vector2(0.0f, 0.0f),
		new Vector2(0.0f, 1.0f),
		                   
		// Top
		new Vector2(0.0f, 1.0f),
		new Vector2(1.0f, 1.0f),
		new Vector2(1.0f, 0.0f),
		new Vector2(0.0f, 0.0f),

		// Bottom
		new Vector2(0.0f, 0.0f),
		new Vector2(1.0f, 0.0f),
		new Vector2(1.0f, 1.0f),
		new Vector2(0.0f, 1.0f),
	};


	// Start is called before the first frame update
	void Start()
    {
		// �½�һ��Mesh
		Mesh mesh = new Mesh();
		// �ù��������ݳ�ʼMesh
		mesh.vertices = vertices;
		mesh.triangles = triangles;
		mesh.uv = uvs;
		// �����Ǹ��ݶ������ݼ��������,�������޸��궥���,��Ҫ����һ�·���
		mesh.RecalculateNormals();
		// �������õ�Mesh�滻��
		gameObject.GetComponent<MeshFilter>().mesh = mesh;
	}

    // Update is called once per frame
    void Update()
    {

    }
}

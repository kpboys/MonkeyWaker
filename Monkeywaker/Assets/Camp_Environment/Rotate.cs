using UnityEngine;

public class Rotate : MonoBehaviour
{
    [SerializeField] private Vector3 _axis = Vector3.forward;
    
    void Update()
    {
        transform.localRotation *= Quaternion.Euler(_axis * Time.deltaTime);
    }
}

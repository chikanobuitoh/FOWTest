using UnityEngine;
using System.Collections;
using UnityStandardAssets.CrossPlatformInput;

public class PlayerMove : MonoBehaviour {

	public float Speed = 0.05f;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
		float move_x = CrossPlatformInputManager.GetAxis ("Horizontal")*Speed;
		float move_y = CrossPlatformInputManager.GetAxis ("Vertical")*Speed;
		transform.position += new Vector3(move_x,0,move_y);
	}

	void Jump(){
		Application.Quit();
	}
}

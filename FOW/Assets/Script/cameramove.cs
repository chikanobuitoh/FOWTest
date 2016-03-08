using UnityEngine;
using System.Collections;

public class cameramove : MonoBehaviour {

	public GameObject Player;

	// Update is called once per frame
	void Update () {
		Vector3 Temp = Player.transform.position;
		transform.position = new Vector3 (Temp.x, Temp.y +0.5f, Temp.z);
	}
}

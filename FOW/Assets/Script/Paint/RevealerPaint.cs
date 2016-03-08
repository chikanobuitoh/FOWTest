using UnityEngine;

public class RevealerPaint : MonoBehaviour
{
	public int radius = 3;
	[HideInInspector]
	public float[] _Circle;
	[HideInInspector]
	public bool moveflag;

	static Vector3 backPos;

	private void Start()
	{
		InitCircle ();
		backPos = transform.position;
		moveflag = true;
		FoWPaint.Instance.RegisterRevealer(this);
	}

	private void InitCircle(){
		_Circle = new float[(radius*2+1)*(radius*2+1)];

		Vector3 centerPos = new Vector3 (radius, radius, 0);// x yともにradiusをセンターに
		Vector3 currentPos = new Vector3(0,0,0);

		int circleNum = 0;
		for (int y = 0; y <= radius * 2; y++) {
			currentPos.y = y;
			for (int x = 0; x <= radius * 2; x++) {
				currentPos.x = x;
				float dat = Mathf.Clamp01 (Vector3.Distance (centerPos, currentPos) / (radius + 1));
				_Circle[circleNum] = Mathf.Floor (Mathf.Pow(dat,6) * 10f) * 0.1f;
				circleNum++;
			}
		}
	}

	private void Update()
	{
		if (backPos != transform.position) {
			moveflag = true;	
		}
		backPos = transform.position;
	}

	public bool getMoveFlag(){
		return moveflag;
	}

	public void resetMove()
	{
		moveflag = false;
	}

}
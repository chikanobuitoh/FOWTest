using UnityEngine;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// Manages the fog of war.
/// Generates the texture with the alpha "holes" for visable units.
/// Will also disable other players unity that are no longer visable. (todo)
/// </summary>
public class FogOfWarManager : MonoBehaviour
{
	#region Private
	[SerializeField]
	private float fieldSize = 12;
	[SerializeField]
	private float fieldHeight = 4;

	/// <summary>
	/// The size of the texture in BOTH x and y.
	/// Should be a power of 2.
	/// </summary>
	[SerializeField]
	private int _textureSize = 256;
	[SerializeField]
	private Color _fogOfWarColor;
	[SerializeField]
	private LayerMask _fogOfWarLayer;
	
	private Texture2D _texture;
	private Color[] _pixels;
	private List<Revealer> _revealers;
	private float timeleft = 0.1f;
	private static FogOfWarManager _instance;

	#endregion
	
	#region Public
	/// <summary>
	/// Note this is NOT a singleton!
	/// This just needs to be globally accessable AND still be a MonoBehaviour.
	/// </summary>
	public static FogOfWarManager Instance
	{
		get
		{
			return _instance;
		}
	}
	#endregion
	
	private void Awake()
	{
		_instance = this;
//		if (!SystemInfo.supportsComputeShaders)
//		{
//			Debug.LogWarning("No Compute Shader support!");
//		}

		//Set FoWTexture
		makeFoWTexture ();

		//Make Eye Caster
		_revealers = new List<Revealer>();

		//Init Param
		init ();
	}

	public void RegisterRevealer(Revealer revealer)
	{
		_revealers.Add(revealer);
	}

	private void makeFoWTexture(){
		var renderer = GetComponent<Renderer>();
		Material fogOfWarMat = null;
		if (renderer != null)
		{
			fogOfWarMat = renderer.material;
		}

		if (fogOfWarMat == null)
		{
			Debug.LogError("Material for Fog Of War not found!");
			return;
		}

		_texture = new Texture2D(_textureSize, _textureSize, TextureFormat.RGBA32, false);
		_texture.wrapMode = TextureWrapMode.Clamp;

		_pixels = _texture.GetPixels();
		ClearPixels();

		fogOfWarMat.mainTexture = _texture;
		//Materal Set
		transform.root.gameObject.GetComponent<Projector>().material.SetTexture(
			"_ShadowTex",_texture);
	}

	private void init()
	{
		
		//Pixels init
		for (var i = 0; i < _pixels.Length; i++)
		{
			_pixels[i] = _fogOfWarColor;
		}

		//System Position init
		//Height Set
		transform.root.position = new Vector3(transform.root.position.x,fieldHeight,transform.root.position.z);
		//Rotation Set
		transform.root.rotation = new Quaternion(1,0,0,1);
		transform.localEulerAngles = new Vector3 (0,180,180);
		//Sieze Set
		transform.root.gameObject.GetComponent<Projector>().orthographicSize = fieldSize/2;
		transform.localScale = new Vector3 (fieldSize, fieldSize, 1);
	}

	private void ClearPixels()
	{
		//init Texture
		float Temp;

		for (var i = 0; i < _pixels.Length; i++)
		{
			Temp = _pixels [i].a;
			if ((Temp != 1.0f)&&(Temp < 0.7f)) {
				Temp = 0.7f;	
			}
			_pixels[i].a = Temp;
		}
	}
	
	/// <summary>
	/// Sets the pixels in _pixels to clear a circle.
	/// </summary>
	/// <param name="originX">in pixels</param>
	/// <param name="originY">in pixels</param>
	/// <param name="radius">in unity units</param>
	private void CreateCircle(int originX, int originY, int radius,float[] _Circle)
	{
		float Temp,TempCol;
		int circleNum = 0;

		for (var y=-radius; y<= radius; y++) {
			for(var x = -radius;x <= radius;x++){
				Temp = _Circle[circleNum];
				TempCol = _pixels[ (originY + y) * _textureSize + originX + x].a;
				_pixels [(originY + y) * _textureSize + originX + x].a = Mathf.Clamp (TempCol - (1.0f - Temp), 0.0f, 1.0f);
				circleNum++;
			}
		}
	}

	private void setCol(){
		foreach (var revealer in _revealers)
		{
			if (revealer.getMoveFlag()) {

				//Clear befor position
				ClearPixels();

				//Draw Circle
				RaycastHit hit;
				if (Physics.Raycast (revealer.transform.position, new Vector3 (0, 1, 0), out hit, 1000, _fogOfWarLayer.value)) {
				
					var translatedPos = hit.textureCoord;
					var pixelPosX = Mathf.RoundToInt (translatedPos.x * _textureSize);
					var pixelPosY = Mathf.RoundToInt (translatedPos.y * _textureSize);

					CreateCircle (pixelPosX, pixelPosY, revealer.radius, revealer._Circle);
					revealer.resetMove ();
				}
			}
		}
		_texture.SetPixels(_pixels);
		_texture.Apply(false);
	}

	private void Update()
	{
		timeleft -= Time.deltaTime;
		if (timeleft <= 0.0f) {
			timeleft = 0.1f;
			setCol ();
		}
	}
}
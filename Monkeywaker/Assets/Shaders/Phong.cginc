//  Add shader properties to control these uniforms
float3 _SpecColor;             //   type: Color         defalut: (1,1,1,1) 
float _Shininess;              //   type: Range(1,100)  defalut: 10         
float _SpecularStrength;       //   type: Range(0,1)    defalut: 1
float _DiffuseShadowIntensity; //   type: Range(0, 1)   defalut: 0.5


//  Calculates the vectors used in the light calculations
//* l: Unit vector from world position to light world position
//* n: Fragment normal in object space
//* v: Unit vector from world position to cameras world position
//* r: light unit vector reflected over fragment normal
void PhongVectors (v2f i, out float3 l, out float3 n, out float3 v, out float3 r)
{
    l = normalize(_WorldSpaceLightPos0); //! This only works with directional light rn
	n = normalize(i.normal); 
	v = normalize(_WorldSpaceCameraPos - i.worldPos); 
	r = reflect(-l, n);
}


//  Calculates and returns the ambient light on the fragment
//* surfaceColor: the albedo / diffuse of the fragment (Do not confuse with the diffuse light from Phong diffuse)
float3 Phong_A (fixed4 surfaceColor)
{
    float3 ambient = UNITY_LIGHTMODEL_AMBIENT * surfaceColor.rgb;
    return ambient;
}

//  Calculates and returns the diffuse light on the fragment
//* surfaceColor: the albedo / diffuse of the fragment (Do not confuse with the diffuse light from Phong diffuse)
float3 Phong_D (fixed4 surfaceColor, float3 l, float3 n)
{
    float diffuseMask = 1 - (1 - dot(l,n)) * _DiffuseShadowIntensity;
	float3 diffuse = _LightColor0 * surfaceColor * diffuseMask;
    return diffuse;
}

//  Calculates and returns the specular light on the fragment
//* surfaceColor: the albedo / diffuse of the fragment (Do not confuse with the diffuse light from Phong diffuse)
float3 Phong_S (fixed4 surfaceColor, float3 l, float3 n, float3 v, float3 r)
{
    float3 specular = _LightColor0 * surfaceColor * pow(max(0, dot(r,v)), _Shininess) * max(0, dot(l,n));
    specular *= _SpecularStrength;
    return specular;
}

//  Calculates the vectors used in the light calculations
//* surfaceColor: the albedo / diffuse of the fragment (Do not confuse with the diffuse light from Phong diffuse)
float3 Phong_DS (fixed4 surfaceColor, float3 l, float3 n, float3 v, float3 r)
{
    return Phong_D(surfaceColor, l, n) + Phong_S(surfaceColor, l, n, v, r);
}

//  Calculates the vectors used in the light calculations
//* surfaceColor: the albedo / diffuse of the fragment (Do not confuse with the diffuse light from Phong diffuse)
float3 Phong_ADS (fixed4 surfaceColor, float3 l, float3 n, float3 v, float3 r)
{
    return Phong_A(surfaceColor) + Phong_D(surfaceColor, l, n) + Phong_S(surfaceColor, l, n, v, r);
}
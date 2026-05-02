package funkin.backend.shaders;

import openfl.Assets;

class CustomShader extends FunkinShader {
	public var path:String = "";

	public function new(name:String, glslVersion:String = null) {
		if (glslVersion == null)
			glslVersion = Flags.DEFAULT_GLSL_VERSION;

		var fragShaderPath = Paths.fragShader(name);
		var vertShaderPath = Paths.vertShader(name);

		var fragCode:String = Assets.exists(fragShaderPath)
			? Assets.getText(fragShaderPath)
			: null;

		var vertCode:String = Assets.exists(vertShaderPath)
			? Assets.getText(vertShaderPath)
			: null;

		fileName = name;
		fragFileName = fragShaderPath;
		vertFileName = vertShaderPath;

		path = fragShaderPath;

		if (fragCode != null && fragCode.trim() != "")
		{
			fragCode = fixShader(fragCode, true);
		}

		if (vertCode != null && vertCode.trim() != "")
		{
			vertCode = fixShader(vertCode, false);
		}

		if ((fragCode == null || fragCode.trim() == "")
			&& (vertCode == null || vertCode.trim() == ""))
		{
			Logs.error('Shader "$name" couldn\'t be found.');
		}

		super(fragCode, vertCode, glslVersion);
	}

	private function fixShader(code:String, isFragment:Bool):String
{
	code = StringTools.replace(code, "\r\n", "\n");

	if (!code.contains("#pragma header"))
	{
		code = "#pragma header\n\n" + code;
	}

	if (!code.contains("precision mediump float"))
	{
		code =
			"#ifdef GL_ES\n" +
			"precision mediump float;\n" +
			"#endif\n\n" +
			code;
	}

	code = StringTools.replace(
		code,
		"texture2D(",
		"flixel_texture2D("
	);

	code = StringTools.replace(
		code,
		"texture(",
		"flixel_texture2D("
	);

	code = StringTools.replace(
		code,
		"openfl_TextureCoordv.xy",
		"clamp(openfl_TextureCoordv, 0.001, 0.999)"
	);

	code = StringTools.replace(
		code,
		"openfl_TextureCoordv",
		"clamp(openfl_TextureCoordv, 0.001, 0.999)"
	);
	
	if (!code.contains("void main"))
	{
		if (isFragment)
			code += "\nvoid main(){ gl_FragColor = vec4(1.0); }";
		else
			code += "\nvoid main(){ }";
	}

	return code;
    }
}

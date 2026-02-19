@tool
extends EditorExportPlugin
## Runs post-export-web.sh after a Web export so index.png and icon.png are copied and index.html is patched.

var _export_path: String = ""
var _is_web_export: bool = false

func _get_name() -> String:
	return "PostExportWeb"

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, _flags: int) -> void:
	_export_path = path
	_is_web_export = path.get_extension() == "html" or "web" in path.to_lower()

func _export_end() -> void:
	if not _is_web_export:
		return
	var root: String = ProjectSettings.globalize_path("res://").replace("res://", "").replace("\\\\", "/").trim_suffix("/")
	var script_path: String = root.path_join("post-export-web.sh")
	if not FileAccess.file_exists(script_path):
		push_warning("PostExportWeb: post-export-web.sh niet gevonden op " + script_path)
		return
	var args: Array = [script_path]
	var out: Array = []
	var err: int = OS.execute("bash", args, out, true, false)
	if err != 0:
		push_warning("PostExportWeb: script exit code %d. Output: %s" % [err, str(out)])
	else:
		print("PostExportWeb: post-export-web.sh succesvol uitgevoerd (index.png, icon.png, index.html patch).")

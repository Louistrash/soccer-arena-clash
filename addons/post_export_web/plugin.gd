@tool
extends EditorPlugin
## Registreert de Post Export Web export plugin.

var _export_plugin: EditorExportPlugin

func _enter_tree() -> void:
	_export_plugin = load("res://addons/post_export_web/export_plugin.gd").new()
	add_export_plugin(_export_plugin)

func _exit_tree() -> void:
	remove_export_plugin(_export_plugin)

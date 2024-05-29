extends WorldEnvironment

var weather_states = [
	{
		"name": "Cloudy",
		"sky": {
			"shader_parameter/day_top_color": Color(0.1, 0.6, 1.0),
			"shader_parameter/day_bottom_color": Color(0.4, 0.8, 1.0),
			"shader_parameter/clouds_cutoff": 0.3,
			"shader_parameter/clouds_weight": 0.0
		},
		"env": {
			"glow_bloom": 0.0
		},
		"chain": [
			1, 2
		]
	},
	{
		"name": "Clear",
		"sky": {
			"shader_parameter/day_top_color": Color(0.1, 0.6, 1.0),
			"shader_parameter/day_bottom_color": Color(0.4, 0.8, 1.0),
			"shader_parameter/clouds_cutoff": 0.5,
			"shader_parameter/clouds_weight": 0.0
		},
		"env": {
			"glow_bloom": 0.0
		},
		"chain": [
			0, 3
		]
	},
	{
		"name": "Rain",
		"sky": {
			"shader_parameter/day_top_color": Color(0.06, 0.36, 0.6),
			"shader_parameter/day_bottom_color": Color(0.24, 0.48, 0.6),
			"shader_parameter/clouds_cutoff": 0.25,
			"shader_parameter/clouds_weight": 0.85
		},
		"env": {
			"glow_bloom": 0.0
		},
		"chain": [
			0, 1
		]
	},
	{
		"name": "Hot",
		"sky": {
			"shader_parameter/day_top_color": Color(0.1, 0.6, 1.0),
			"shader_parameter/day_bottom_color": Color(0.4, 0.8, 1.0),
			"shader_parameter/clouds_cutoff": 1,
			"shader_parameter/clouds_weight": 0.0
		},
		"env": {
			"glow_bloom": 1.0
		},
		"chain": [
			0, 1
		]
	}
]

@export_range(0, 3) var weather := 0:
	set(value):
		weather = clamp(value, 0, 3)
		var tween = get_tree().create_tween()
		tween.set_parallel()
		var preset = weather_states[weather]
		for i in preset["sky"]:
			tween.tween_property(environment.sky.sky_material, "%s" % i, preset["sky"][i], 10.0)
		for i in preset["env"]:
			tween.tween_property(environment, "%s" % i, preset["env"][i], 10.0)


func _ready() -> void:
	setup_timer()


func setup_timer() -> void:
	get_tree().create_timer(randi_range(600, 1200)).timeout.connect(random_weather)


func random_weather() -> void:
	var chain = weather_states[weather]["chain"]
	weather = chain[randi_range(0, chain.size() - 1)]
	setup_timer()

extends Node2D


@export var maxWorkers = 8
var workers = 8

@export var maxSprits = 1
var spirits = 0

var resources = {
	"Beer": 0,
	"Food": 0,
	"Faith": 0,
	"Knowledge": 0
	}

var maxCap = 100

@onready var faith_progress_bar = $UI/Panel/MarginContainer/HBoxContainer/Faith/ProgressBar
@onready var beer_progress_bar = $UI/Panel/MarginContainer/HBoxContainer/Beer/ProgressBar
@onready var food_progress_bar = $UI/Panel/MarginContainer/HBoxContainer/Food/ProgressBar
@onready var knowledge_progress_bar = $UI/Panel/MarginContainer/HBoxContainer/Knowledge/ProgressBar
@onready var monk_lable = $UI/Panel/MarginContainer/HBoxContainer/Monks/HBoxContainer/MonkLable
@onready var spirit_lable = $UI/Panel/MarginContainer/HBoxContainer/Spirits/HBoxContainer/SpiritLable


func _ready():
	faith_progress_bar.max_value = maxCap
	beer_progress_bar.max_value = maxCap
	food_progress_bar.max_value = maxCap
	knowledge_progress_bar.max_value = maxCap

func _physics_process(delta):
	update_progress_bars()

func update_progress_bars():
	faith_progress_bar.value = resources.get("Faith", 0) 
	beer_progress_bar.value = resources.get("Beer", 0)
	food_progress_bar.value = resources.get("Food", 0)
	knowledge_progress_bar.value = resources.get("Knowledge", 0)
	monk_lable.text = str(workers, " / ", maxWorkers)
	spirit_lable.text = str(spirits, " / ", maxSprits)


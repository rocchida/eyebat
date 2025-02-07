class_name Loadable extends Resource

@export var name : String
var data
var push
var pull

func init(pull_func,push_func):
    push = push_func
    pull = pull_func




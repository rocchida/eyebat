extends Resource
class_name  StatStatus

enum stats {ATK, DEF, WIL, RES, SPD}
@export var stat : stats = stats.ATK
@export_range (1, 100) var percent_affected : int

extends Resource
class_name  StatStatus

enum stats {ATK, DEF, MANA, RES, SPD, MAGIC}
@export var stat : stats = stats.ATK
@export_range (0, 1) var percent_affected : float

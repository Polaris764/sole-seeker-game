extends CanvasLayer

var OriginTable = [] setget ,updateLabel
var ActionDictionary = {}

func areaLeft(interactionOrigin):
	OriginTable.erase(interactionOrigin)
	ActionDictionary.erase(interactionOrigin)
	updateLabel()

func updateLabel():
	if OriginTable.size() > 0:
		self.visible = true
		$Label.text = String(ActionDictionary[OriginTable[0]]["controls"]) + " to " + ActionDictionary[OriginTable[0]]["desc"]
	else:
		self.visible = false

func updateButton(interactionControls,interactionDesc,interactionOrigin,interactionAction):
	OriginTable.insert(0,interactionOrigin)
	ActionDictionary[interactionOrigin] = {"action":interactionAction,"desc":interactionDesc,"controls":interactionControls}
	updateLabel()

func _physics_process(_delta):
	if OriginTable.size() > 0 and Input.is_action_just_pressed(ActionDictionary[OriginTable[0]]["action"]):
		OriginTable[0].interacted()

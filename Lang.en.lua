local b = {}
b["LOADED"] = "Restacker Loaded"
b["SRC_ITEM"] = "Move Item: <<1>>"
b["DST_ITEM"] = "Dest Item: <<1>>"
b["EVALUATION"] = "Restacker Evaluation:"
b["RESTACK_AVAILABLE"] = "...Available for restacking <<1>>: <<2>>"
b["RESTACKING"] = "    Restacked stacks of <<2>> of <<1>>"
b["MOVED_FROM_1_TO_2"] = "Moved <<2[$d unit/$d units]>> of <<1>> to the bank"
b["MOVED_FROM_2_TO_1"] = "Moved <<2[$d unit/$d units]>> of <<1>> from the bank"
b["CMD_DESC"] = 
	"Restacker Command Interface:\n"..
	" /rs restack: Restacks your bag"..
	" /rs evaluate: Restacks your bag"..
	" /rs inv: Prints out your inventory"
b["CMD_ERR"] = "Restacker Error: /rs <<1>>"

Restacker.langBundle["en"] = b

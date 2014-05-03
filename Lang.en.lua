local b = {}
b["LOADED"] = "Restacker Loaded"
b["SRC_ITEM"] = "Move Item: <<1>>"
b["DST_ITEM"] = "Dest Item: <<1>>"
b["EVALUATION"] = "Restacker Evaluation:"
b["RESTACK_AVAILABLE"] = "    Available for restacking <<1>>: <<2>>"
b["RESTACKING"] = "    Restacking duplicate stacks of <<1>>: <<2>>"
b["CMD_DESC"] = 
	"Restacker Command Interface:\n"..
	" /rs restack: Restacks your bag"..
	" /rs evaluate: Restacks your bag"..
	" /rs inv: Prints out your inventory"
b["CMD_ERR"] = "Restacker Error: /rs <<1>>"

Restacker.langBundle["en"] = b

local b = {}
b["BAG"] = "Bag: <<1>>"
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
	" /rs restack: Restacks your inventory\n"..
	" /rs show <inv||bank>: Prints out your bag contents\n"
b["CMD_ERR"] = "Restacker Error: /rs <<1>>"
b["RESTACK_INV"] = "Restack Inventory"
b["RESTACK_BNK"] = "Restack Bank"
b["STACK_INV_BNK"] = "Stack from Inventory to Bank"
b["STACK_BNK_INV"] = "Stack from Bank to Inventory"
b["NOTHING_MOVED"] = "No stacks moved"

-- Option Pabel Strings
b["OP:TITLE"] = "Restacker"
b["OP:GENERAL"] = "General Settings"
b["OP:ANNOUNCE_TRANSFERS_LB"] = "Announce item transfers"
b["OP:ANNOUNCE_TRANSFERS_TT"] = "Announce when items are restacked"
b["OP:AUTO_BANK_TRANSFER_LB"] = "Action to take on opening Bank"
b["OP:AUTO_BANK_TRANSFER_TT"] = "Contols if automatic stacking will be performed when the bank is opened"
b["OP:ABT_I2B"] = "Transfer from Inventory to Bank"
b["OP:ABT_B2I"] = "Transfer from Bank to Inventory"
b["OP:ABT_NONE"] = "No not Transfer Items"
b["OP:AUTO_TRADE_TRANSFER_LB"] = "Action to take on completing a trade"
b["OP:AUTO_TRADE_TRANSFER_TT"] = "Contols if automatic stacking will be performed when trade is completed"
b["OP:DEBUG"] = "Debug Settings"
b["OP:DEBUG_LB"] = "Show Debug Messages"
b["OP:DEBUG_TT"] = "Print debug messages to the chat window"
Restacker.langBundle["en"] = b

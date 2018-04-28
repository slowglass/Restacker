local b = Slowglass.Restacker.langBundle

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
b["RS_OP_TITLE"] = "Restacker"

-- General Settings section
b["RS_OP_GENERAL"] = "General Settings"
b["RS_OP_ANNOUNCE_TRANSFERS_LABEL"] = "Announce item transfers"
b["RS_OP_ANNOUNCE_TRANSFERS_TOOLTIP"] = "Announce when items are restacked"
b["RS_OP_AUTO_BANK_TRANSFER_LABEL"] = "Action to take on opening Bank"
b["RS_OP_AUTO_BANK_TRANSFER_TOOLTIP"] = "Contols if automatic stacking will be performed when the bank is opened"
b["RS_OP_ABT_I2B_CHOICE"] = "Transfer from Inventory to Bank"
b["RS_OP_ABT_B2I_CHOICE"] = "Transfer from Bank to Inventory"
b["RS_OP_ABT_NONE_CHOICE"] = "Do not Transfer Items"
b["RS_OP_AUTO_STACK_ON_TRADE_LABEL"] = "Action to take on completing a trade"
b["RS_OP_AUTO_STACK_ON_TRADE_TOOLTIP"] = "Contols if automatic stacking will be performed when trade is completed"
-- Debug Section
b["RS_OP_DEBUG"] = "Debug Settings"
b["RS_OP_DEBUG_LABEL"] = "Show Debug Messages"
b["RS_OP_DEBUG_TOOLTIP"] = "Print debug messages to the chat window"


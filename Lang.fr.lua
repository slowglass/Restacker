-- French Lang bundle
-- Translation by Google :)
local b = {}
b["BAG"] = "Sac: <<1>>"
b["LOADED"] = "Ré empileur Loaded"
b["SRC_ITEM"] = "Déplacez article: <<1>>"
b["DST_ITEM"] = "Destinations article: <<1>>"
b["EVALUATION"] = "Évaluation de ré empileur:"
b["RESTACK_AVAILABLE"] = "...Disponible pour réempilage <<1>>: <<2>>"
b["RESTACKING"] = "    Piles restacked de <<2>> de <<1>>"
b["MOVED_FROM_1_TO_2"] = "Proposé <<2[$d unité/$d unités]>> de <<1>> à la banque"
b["MOVED_FROM_2_TO_1"] = "Proposé <<2[$d unité/$d unités]>> de <<1>> de la banque"
b["CMD_DESC"] = 
	"Restacker Command Interface:\n"..
	" /rs restack: Restacks your bag"..
	" /rs evaluate: Restacks your bag"..
	" /rs inv: Prints out your inventory"
b["CMD_ERR"] = "Restacker Error: /rs <<1>>"
b["RESTACK_INV"] = "Réempilez en inventaire"
b["RESTACK_BNK"] = "Réempilez en Banque"
b["STACK_INV_BNK"] = "Empilez de l'inventaire à la Banque"
b["STACK_BNK_INV"] = "Empilez de la Banque à l'inventaire"
b["NOTHING_MOVED"] = "Pas de piles déplacés"

Restacker.langBundle["fr"] = b

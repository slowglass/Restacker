-- French Lang bundle by Xie
local b = Slowglass.Restacker.langBundle
b["BAG"] = "Sac: <<1>>"
b["LOADED"] = "Restacker Chargé"
b["SRC_ITEM"] = "Déplacer article: <<1>>"
b["DST_ITEM"] = "Destinations article: <<1>>"
b["EVALUATION"] = "Évaluation du Restacker:"
b["RESTACK_AVAILABLE"] = "...Disponible pour réempilage <<1>>: <<2>>"
b["RESTACKING"] = "    Piles réempilées de <<2>> de <<1>>"
b["MOVED_FROM_1_TO_2"] = "Déplacée(s) <<2[$d unité/$d unités]>> de <<1>> à la banque"
b["MOVED_FROM_2_TO_1"] = "Déplacée(s) <<2[$d unité/$d unités]>> de <<1>> de la banque"
b["CMD_DESC"] = 
	"Restacker Command Interface:\n"..
	" /rs restack: Restacks your inventory\n"..
	" /rs show <inv||bank>: Prints out your inventory\n"
b["CMD_ERR"] = "Restacker Error: /rs <<1>>"
b["RESTACK_INV"] = "Réempiler en inventaire"
b["RESTACK_BNK"] = "Réempiler en Banque"
b["STACK_INV_BNK"] = "Empiler de l'inventaire à la Banque"
b["STACK_BNK_INV"] = "Empiler de la Banque à l'inventaire"
b["NOTHING_MOVED"] = "Pas de pile déplacée"

-- Option Pabel Strings
b["OP:TITLE"] = "Restacker"
-- General Settings section
b["OP:GENERAL"] = "Paramètres"
b["OP:ANNOUNCE_TRANSFERS_LABEL"] = "Notification des items transférés"
b["OP:ANNOUNCE_TRANSFERS_TOOLTIP"] = "Notification lors du réempilage"
b["OP:AUTO_BANK_TRANSFER_LABEL"] = "Action à l'ouverture de la Banque"
b["OP:AUTO_BANK_TRANSFER_TOOLTIP"] = "Sélectionner l'empilage automatique à exécuter lorsque la Banque est ouverte"
b["OP:ABT_I2B_CHOICE"] = "Transfert de l'Inventaire à la Banque"
b["OP:ABT_B2I_CHOICE"] = "Transfert de la Banque à l'Inventaire"
b["OP:ABT_NONE_CHOICE"] = "Ne Rien Transférer"
b["OP:AUTO_TRADE_TRANSFER_TOOLTIP"] = "Empilage auto après échange"
--b["OP:AUTO_TRADE_TRANSFER_TT"] =
-- Debug Section
b["OP:DEBUG"] = "Paramètre Debug"
b["OP:DEBUG_LABEL"] = "Afficher les Messages Debug"
b["OP:DEBUG_TOOLTIP"] = "Afficher les Messages Debug dans la fenêtre de Chat"

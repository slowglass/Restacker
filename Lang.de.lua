-- German Lang bundle Dunkare
local b = Slowglass.Restacker.langBundle
b["BAG"] = "Tasche"
b["LOADED"] = "Restacker geladen"
b["SRC_ITEM"] = "Gegenstand: <<1>>"
b["DST_ITEM"] = "Ziel: <<1>>"
b["EVALUATION"] = "Restacker Auswertung:"
b["RESTACK_AVAILABLE"] = "...gefundene Stapel  <<1>>: <<2>>"
b["RESTACKING"] = "<<2>> <<1>> wurden zusammengefügt"
b["MOVED_FROM_1_TO_2"] = " <<2[$d Einheit/$d Einheiten]>> von <<1>> wurden in die Bank verschoben"
b["MOVED_FROM_2_TO_1"] = " <<2[$d Einheit/$d Einheiten]>> von <<1>> wurden aus der Bank genommen"
b["CMD_DESC"] = 
	"Restacker Kommandos:\n"..
	" /rs restack: Fügt Stapel im Inventar zusammen\n"..
	" /rs show <inv||bank>: Druckt ihre tasche inhalt\n"
b["CMD_ERR"] = "Restacker Fehler: /rs <<1>>"
b["RESTACK_INV"] = "Umstapeln in Bestand"
b["RESTACK_BNK"] = "Umstapeln in Bank"
b["STACK_INV_BNK"] = "Bewegen stapelbar Artikel aus meinem Inventar an die Bank"
b["STACK_BNK_INV"] = "Bewegen stapelbaren Gegenstände von der Bank an meinem Inventar"
b["NOTHING_MOVED"] = "Keine Stapel verschoben"


-- Option Pabel Strings
b["OP:TITLE"] = "Restacker"
-- General Settings section
b["OP:GENERAL"] = "Allgemeine Einstellungen"
b["OP:ANNOUNCE_TRANSFERS_LABEL"] = "Anmelden Umbuchungen"
b["OP:ANNOUNCE_TRANSFERS_TOOLTIP"] = "Announce when items are restacked"
b["OP:AUTO_BANK_TRANSFER_LABEL"] = "Kündigen Sie, wenn Elemente umgestapelt werden"
b["OP:AUTO_BANK_TRANSFER_TOOLTIP"] = "Contols wenn die automatische Stapel wird durchgeführt, wenn die Bank geöffnet werden"
b["OP:ABT_I2B_CHOICE"] = "Transfer von meinem Inventar an die Bank"
b["OP:ABT_B2I_CHOICE"] = "Überweisung von der Bank an die Bestands"
b["OP:ABT_NONE_CHOICE"] = "Überweisung von der Bank an meinem Inventar"
b["OP:AUTO_TRADE_TRANSFER_LABEL"] = "Die Aktion, die auf den Abschluss eines Handels nehmen"
b["OP:AUTO_TRADE_TRANSFER_TOOLTIP"] = "Contols wenn die automatische Stapel wird durchgeführt, wenn der Handel abgeschlossen sein"
-- Debug Section
b["OP:DEBUG"] = "Debug-Einstellungen"
b["OP:DEBUG_LABEL"] = "Debug Nachrichten anzeigen"
b["OP:DEBUG_TOOLTIP"] = "Drucken Debug-Nachrichten in den Chat-Fenster"

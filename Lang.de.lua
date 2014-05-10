-- German Lang bundle Dunkare
local b = {}
b["BAG"] = "Tasche"
b["LOADED"] = "Restacker geladen"
b["SRC_ITEM"] = "Gegenstand: <<1>>"
b["DST_ITEM"] = "Ziel: <<1>>"
b["EVALUATION"] = "Restacker Auswertung:"
b["RESTACK_AVAILABLE"] = "...gefundene Stapel  <<1>>: <<2>>"
b["RESTACKING"] = "<<2>> <<1>> wurden zusammengefügt"
b["MOVED_FROM_1_TO_2"] = " <<2[$d einheit/$d einheiten]>> von <<1>> wurden in die Bank verschoben"
b["MOVED_FROM_2_TO_1"] = " <<2[$d einheit/$d einheiten]>> von <<1>> wurden aus der Bank genommen"
b["CMD_DESC"] = 
	"Restacker Kommandos:\n"..
	" /rs restack: Fügt Stapel im Inventar zusammen"..
	" /rs evaluate: Fügt Stapel im Inventar zusammen"..
	" /rs inv: Zeigt eine Zusammenfassung des Inventars an"
b["CMD_ERR"] = "Restacker Fehler: /rs <<1>>"
b["RESTACK_INV"] = "Umstapeln in Bestand"
b["RESTACK_BNK"] = "Umstapeln in Bank"
b["STACK_INV_BNK"] = "Stapel aus dem Bestand der Bank"
b["STACK_BNK_INV"] = "Stapel von der Bank zum Bestand"
b["NOTHING_MOVED"] = "Keine Stapel verschoben"

Restacker.langBundle["de"] = b
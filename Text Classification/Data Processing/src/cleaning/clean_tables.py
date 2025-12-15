# -*- coding: utf-8 -*-
"""
Created on Mon Jan 30 15:06:59 2023

@author: mokuneva
"""

import re

def clean_tables(text):
    
    """
    This function removes tables.
    """
    
    # Remove tables using regular expressions
    text = re.sub("""Im einzelnen ergaben sich (?:auf den Arebitstag bezogen )?folgende (?:wertmäßige )?Veränderungen.{0,}|
    |Lebenshaltungspreise Veränderung(?:en)? zu.{0,}|
    |Die Kfz-Zulassungszahlen im Monats- und Jahresvergleich.{0,}|
    |Im einzelnen ergab sich folgende Entwicklung.{0,}|
    |Entwicklung des Außenwerts der D-Mark .{0,}|
    |Im einzelnen gab es folgende (?:Entwicklung|Veränderungen).{0,}|
    |Im Vergleich zum Zeitraum Januar/Februar des Vorjahres traten.{0,}|
    |Im einzelnen kam es zu folgenden Veränderungen.{0,}|
    |Nachfolgend der Jahresvergleich im Detail.{0,}|
    |Exporte \d{4} nach Ländern.{0,}|
    |Veränderung in Prozent.{0,}|
    |Weltautomobilproduktion \(in Millionen Wagen\).{0,}|
    |Ist Entwurf.{0,}|
    |Zahl der Verkehrstoten im Jahr.{0,}|
    |In den Autonomen Republiken kam es zu folgenden Ergebnissen.{0,}|
    |(?:Die Neuzulassungen im)(?! April 1995 liegen jedoch über| Inland| Gesamtjahr)(?:.{0,})|
    |Im einzelnen stellte der ADAC folgende.{0,}|
    |ibm rueckten um.{0,}|
    |Die Besitzumschreibungen im.{0,}|
    |Dabei ergaben sich folgende Veränderungen.{0,}|
    |\: Jan\. \+ Feb\..{0,}|
    |ibm verloren bei einem umsatz.{0,}|
    |Gewinne der Bundesbank seit.{0,}|
    |Jahr Reingewinn.{0,}|
    |Der Degab-Prognose liegen.{0,}|
    |Einfuhren nach Ländern.{0,}|
    |Die Kfz-Neuzulassungen in Deutschland insgesamt.{0,}|
    |Die zehn wichtigsten Rohöllieferanten.{0,}|
    |Im Einzelnen gab es.{0,}|
    |Derzeit kostet in den Reiseländern.{0,}|
    |(?:Stoltenberg gab bekannt)(?:.{0,})(?:Ingbert geschlossen\.)|
    |(?:HOCHRECHNUNG\:)(?:.{0,})(?:\(1987\: 79\,5\))|
    |(?:HOCHRECHNUNGEN\:)(?:.{0,})(?:1\,0 / -)|
    |(?:Das vorläufige amtliche Endergebnis\:)(?:.{0,})(?=Bei der zwölften Wahl|SPD-Chef|Die Wahlbeteiligung)|
    |Das vorläufige amtliche Endergebnis\:.{0,}|
    |(?<=deutlich nachgelassen haben)(?:\: März \+ April.{0,})|
    |Im Vorjahresvergleich ergibt sich im einzelnen.{0,}|
    |Gegenüber dem Vorjahr ergab sich im einzelnen.{0,}|
    |Im Jahresvergleich gab es folgende Veränderungen.{0,}|
    |\. Veränderungen in Prozent\:.{0,}|
    |Dazu die Übersicht \(Angaben in Prozent\).{0,}|
    |zu den meistgehandelsten titeln zaehlten pepsico.{0,}|
    |(?:\(Achtung\: )?Der Wirtschaftsausblick in tabellarischer Form.{0,}|
    |(?:Die Pkw-Neuzulassungen im)(?! Inland)(?:.{0,})|
    |(?:In Schleswig-Holstein wird langfristig)(?:.{0,})(?=Stoltenberg wies darauf hin)|
    |(?:Beim Umfang der Teilstreitkräfte ergibt sich)(?:.{0,})(?:Marine\.)|
    |(?:Schleswig-Holstein wird endgültig)(?:.{0,})(?:Zivilangestellte haben\.)|
    |(?:In Schleswig-Holstein wird auf sieben)(?:.{0,})(?:Soldaten verfügen\.)|
    |Die Kfz-Besitzumschreibungen.{0,}|
    |Die Kfz-Zulassungen im.{0,}|
    |der tse-300-composite-index ermaessigte sich.{0,}|
    |Die Umschreibungen im.{0,}|
    |(?:Nach den Hochrechnungen ergibt sich)(?:.{0,})(?=Bremens Regierungschef|Der bremische Regierungschef)|
    |(?:HOCHRECHUNGEN\:)(?:.{0,})(?=Bremens Bürgermeister)|
    |(?:Die Kfz-Neuzulassungen im)(?! alten)(?:.{0,})|
    |sie schlossen um.{0,}|
    |Im einzelnen ergaben sich folgende prozentuale Veränderungen.{0,}|
    |von einzelnen werten fielen.{0,}|
    |gefragt waren fahrzeugwerte.{0,}|
    |Die zehn wichtigsten Erdöllieferanten.{0,}|
    |Im Vergleich zum entsprechenden Vorjahreszeitraum ergaben sich.{0,}|
    |Die wichtigsten Daten(?:\:| =).{0,}|
    |(?:Mit insgesamt)(?:.{0,})(?=Seiters verwies)|
    |Neue Unternehmen an der Börse.{0,}|
    |Die Fahrzeug-Besitzumschreibungen im.{0,}|
    |Im einzelnen ergeben sich folgende Veränderungen.{0,}|
    |Der genaue Stand der Zahlungen.{0,}|
    |Welt-Automobilproduktion \(in Millionen.{0,}|
    |In den letzten beiden Monaten 1991.{0,}|
    |OPEC-Länder neue Obergrenze.{0,}|
    | ual verloren.{0,}|
    |Die vom KBA korrigierten Neuzulassungen.{0,}|
    |Die Simulation ergab folgende Sitzverteilungen.{0,}|
    |(?:Die übrigen Flüchtlinge kamen)(?:.{0,})(?=Aus den Staaten)|
    |Liste der zehn größten (?:US-Industriekonzerne|US-Unternehmen).{0,}|
    |Stand der Hochrechnungen gegen.{0,}|
    |(?:Die Hochrechnungen gegen)(?:.{0,})(?=Die Wahlbeteiligung)|
    |Die Hochrechnungen gegen.{0,}|
    |(?:Etablierte Parteien\:)(?:.{0,})(?=Übereinstimmend)|
    |Vorläufige amtliche Endergebnisse\:.{0,}|
    |Im einzelnen gab es folgende prozentuale Veränderungen.{0,}|
    |Die zehn wichtigsten Erdölliefernaten.{0,}|
    |\: Februar und März \d{4}.{0,}|
    |Hier einige ausgewählte Ergebnisse.{0,}|
    |\b\w+\s\d{4} Indexstand.{0,}|
    |Außer Jugoslawien teilt sich die Zahl.{0,}|
    |Die folgende Übersicht zeigt.{0,}|
    |Im Vergleich zum Vorjahr ergaben sich.{0,}|
    |Dabei wurden im einzelnen.{0,}|
    |\. Bruttoinlandsprodukt der Bundesländer.{0,}|
    |Die Flüchtlinge werden nach folgendem Schlüssel.{0,}|
    |Im einzelen kam es zu.{0,}|
    |In der Statistik der bereinigten Ausgaben.{0,}|
    |Preisindices Lebenshaltung Veränderung.{0,}|
    |Nach Angaben seines Ministeriums sieht die Lehrstellensituation in den neuen Bundesländern.{0,}|
    |Tabelle der Rohöllieferanten.{0,}|
    |Dabei kam es zu folgenden Veränderungen.{0,}|
    |\(Bereits gelaufen.{0,}|
    |(?:Die wichtigsten darunter sind)(?:.{0,})(?=Damit laufen gegenwärtig)|
    |(?:Im Einzelnen wurden folgende)(?:.{0,})(?=Wie OPEC)|
    |(?:Die Liste der Herkunftsländer führt)(?:.{0,})(?=Von den Flüchtlingen)|
    |Veränderung des realen Bruttoinlandsprodukts.{0,}|
    |Lebenshaltungpreise Veränderung.{0,}|
    |(?:An der Spitze der Herkunftsländer)(?:.{0,})(?=Wie das Ministerium weiter)|
    |In den alten Bundesländern stieg die Zahl der Arbeitslosen gegenüber.{0,}|
    |(?<=\.)(?:[ A-Za-zÄÖÜßäöü0-9]*)(?:Lebenshaltungspreise/Ost.{0,})|
    |Lebenshaltungspreise/West.{0,}|
    |Zuwachs reales Bruttoinlandsprodukt Lebenshaltungspreise.{0,}|
    |J\.P\. Morgan wurden um 3-1/4.{0,}|
    |(?:Bei Überschreiten der zulässigen)(?:.{0,})(?=Darüber hinaus)|
    |Welt Automobilproduktion \(.{0,}|
    |Der ADAC hat die Preise.{0,}|
    |Die zehn größten Rohöllieferanten.{0,}|
    |Jüngere Wahlergebnisse in.{0,}|
    |(?:Die Zahlen im Einzelnen\:)(?:.{0,})(?=Die größten)|
    |Insolvenzentwicklung in Europa \d{4}.{0,}|
    |Von der Bundesbank aus dem Zahlungsverkehr.{0,}|
    |Eine Übersicht der Preise.{0,}|
    |Die Arbeitslosigkeit verringerte sich in.{0,}|
    |Im Vorjahresvergleich ergab sich folgende Entwicklung.{0,}|
    |BIP im [\d]\. Halbjahr \d{4} \(.{0,}|
    |Die Prognosen der Fernsehanstalten.{0,}|
    |Die sieben Präsidenten der Deutschen.{0,}|
    |Hebestätze \d{4} in \d{1,2} Großstädten.{0,}|
    |BIP in den ersten drei Quartalen.{0,}|
    |S p a r p a k e t.{0,}|
    |(?:Die PDS wurde landesweit )(?:.{0,})(?=Statistisches Landesamt)|
    |(?:BRANDENBURG [0-9])(?:.{0,})(?=Brandenburg wird)|
    |(?:MECKLENBURG-VORPOMMERN [0-9])(?:.{0,})(?=Zeitgleich)|
    |(?:THÜRINGEN [0-9])(?:.{0,})(?=Wichtigstes)|
    |Zum Vergleich\: Prozent-Ergebnisse.{0,}|
    |(?:NIEDERSACHSEN [0-9])(?:.{0,})(?=Der Wahlreigen)|
    |(?:SACHSEN-ANHALT [0-9])(?:.{0,})(?=In Sachsen-Anhalt)|
    |(?:SACHSEN [0-9])(?:.{0,})(?=Der Freistaat)|
    |Die von der Bundesbank errechneten.{0,}|
    |Im Vergleich zum entsprechenden Vorjahreszeitraum ergab sich im.{0,}|
    |Im einzelnen lauten Bezahltkurse.{0,}|
    |Für Aktien werden folgende Bezahltkurse.{0,}|
    |(?:Aus dem Handel werden)(?:.{0,})(?=Der Rentenmarkt)|
    |(?:Bei Kokain wuchs)(?:.{0,})(?=Der Drogenbeauftragte)|
    |(?:Für Aktien werden unter)(?:.{0,})(?=Schwach veranlagt)|
    |Für Aktien werden unter.{0,}|
    |Hier einige Beispiele\. Dabei ist.{0,}|
    |Hier einige Beispiele für besonders hohe Preissteigerungen.{0,}|
    |Für Aktien nennt der Handel.{0,}|
    |Für Aktien werden u\.a\. folgende.{0,}|
    |Hier die Veränderungen gegenüber.{0,}|
    |Für Aktien werden aus dem Handel.{0,}|
    |Hier die regionale Verteilung.{0,}|
    |Für Aktien werden gegen.{0,}|
    |Dazu werden aus dem Handel.{0,}|
    |Aktien sind aktuell zu folgenden.{0,}|
    |(?:Die letzten Wahlen in Baden)(?:.{0,})(?=Rheinland-Pfalz\: CDU hofft)|
    |(?:Die letzten Wahlen in Rheinland-Pfalz)(?:.{0,})(?=Saarland\: Stimmungstest für)|
    |(?:Die letzten Wahlen im Saarland)(?:.{0,})(?=Mecklenburg-Vorpommern\: Kommunalwahl als)|
    |(?:Die letzten Wahlen in Mecklenburg-Vorpommern)(?:.{0,})(?=Thüringen\: Kommunalwahlkampf)|
    |(?:Die letzten Wahlen in Thüringen)(?:.{0,})(?=Sachsen\: OB-Wahlen)|
    |(?:Die letzten Wahlen in Sachsen)(?:.{0,})(?=Sachsen-Anhalt\:)|
    |(?:Die letzten Wahlen in Sachsen)(?:.{0,})(?:PDS 12\,7 5\,3 5\,3)|
    |(?:Die letzten Wahlen in Hamburg)(?:.{0,})(?=Folgt Länder elf)|
    |(?:Die letzten Wahlen in Baden)(?:.{0,})(?=Folgt Kommunen zwei)|
    |(?:Die letzten Wahlen in Rheinland-Pfalz)(?:.{0,})(?=Folgt Kommunen drei)|
    |(?:Die letzten Wahlen im Saarland)(?:.{0,})(?=Folgt Kommunen vier)|
    |(?:Die letzten Wahlen in Mecklenburg-Vorpommern)(?:.{0,})(?=Folgt Kommunen fünf)|
    |(?:Die letzten Wahlen in Thüringen)(?:.{0,})(?=Folgt Kommunen sechs)|
    |(?:Die letzten Wahlen in Sachsen)(?:.{0,})(?=Folgt Kommunen sieben)|
    |(?:Die letzten Wahlen in Sachsen)(?:.{0,})(?:PDS 12\,7 12\,0 5\,3)|
    |(?:Und so ging die Europawahl)(?:.{0,})(?=Baden-Württemberg\:)|
    |(?:Die letzten Wahlen in Baden-Württemberg)(?:.{0,})(?=Bayern erwartet)|
    |(?:Die letzten Wahlen in Bayern)(?:.{0,})(?=Hessen können)|
    |(?:Die leztzten Wahlen in Hessen)(?:.{0,})(?=Rheinland-Pfalz\:)|
    |(?:Die letzten Wahlen in Rheinland-Pfalz)(?:.{0,})(?=Saarland\:)|
    |(?:Die letzten Wahlen im Saarland)(?:.{0,})(?=Nordrhein-Westfalen\:)|
    |(?:Die letzten Wahlen in Nordrhein-Westfalen)(?:.{0,})(?=Niedersachsen\:)|
    |(?:Die letzten Wahlen in Niedersachsen)(?:.{0,})(?=Bremen\:)|
    |(?:Die letzten Wahlen in Bremen)(?:.{0,})(?=Schleswig-Holstein denkt)|
    |(?:Die letzten Wahlen in Schleswig-Holstein)(?:.{0,})(?=Thüringen\:)|
    |(?:Die letzten Wahlen in Thüringen)(?:.{0,})(?=Sachsen-Anhalt\: Europwahl)|
    |(?:Die letzten Wahlen in Sachsen-Anhalt)(?:.{0,})(?=Sachsen will)|
    |(?:Die letzten Wahlen in Sachsen )(?:.{0,})(?=Mecklenburg-Vorpommern will in Europa)|
    |(?:Die letzten Wahlen in Mecklenburg-Vorpommern)(?:.{0,})(?=Berlin\:)|
    |(?:Die letzten Wahlen in Gesamtberlin)(?:.{0,})(?=Brandenburg versteht)|
    |(?:Die letzten Wahlen in Brandenburg)(?:.{0,})(?:REP 2\,1)|
    |Die letzten Wahlen in Sachsen-Anhalt im Vergleich.{0,}|
    |Das vorläufige Endergebins.{0,}|
    |Das vorläufige Endergebnis der Europawahl.{0,}|
    |Für Aktien wurden aus dem Handel.{0,}|
    |\. 1994 1995 1996 Bruttoinlandsprodukt.{0,}|
    |Commerzbank-Aktienindex vom.{0,}|
    |Die zehn größten deutschen Unternehmen.{0,}|
    |Die Pkw-Zulassungen der zehn.{0,}|
    |Hier die Veränderungen in Prozent.{0,}|
    |Die Besitzumschreibungen.{0,}|
    |Die Veränderungen in Prozent\:.{0,}|
    |Allein 7 134 Verträge.{0,}|
    |Hochrechnung Sachsen Brandenburg.{0,}|
    |Im folgenden eine von der SPD zusammengestellte Tabelle.{0,}|
    |Im folgenden eine Liste.{0,}|
    |Im folgenden eine Auswahl seiner Klassiker.{0,}|
    |Die Ergebnisse im Einzelnen \(.{0,}|
    |Die Ergebnisse im Einzelnen\: -.{0,}|
    |Die Ergebnisse im Einzelnen\: Geschäftsordnung.{0,}|
    |Die Ergebnisse im Einzelnen\: Die CDU.{0,}|
    |(?:Die Ergebnisse im Einzelnen)(?:.{0,})(?=Die Atomkatastrophe)|
    |(?:Die Ergebnisse im Einzelnen)(?:.{0,})(?=Bundeskanzlerin Angela Merkel \(CDU\))|
    |Die Ergebnisse im Einzelnen\: CDU/CSU.{0,}|
    |Am Abend wurde folgendes.{0,}|
    |Für Aktien wurden unter anderem.{0,}|
    |(?:MECKLENBURG-VORPOMMERN\:)(?:.{0,})(?=Ministerpräsident Berndt Seite)|
    |(?:THÜRINGEN\:)(?:.{0,})(?=Aller Voraussicht|Nach ersten Einschätzungen)|
    |(?:SAARLAND\: (?!Der stellvertretende))(?:.{0,})(?=Der stellvertretende)|
    |(?:Dabei geben die Hochrechnungen)(?:.{0,})(?=Die Stimmengewinne)|
    |MECKLENBURG-VORPOMMERN\: Für die CDU lautet.{0,}|
    |Eil \!\!\!\!\! Vorläufiges amtliches Endergebnis der Münchner.{0,}|
    |Achtung Disposition.{0,}|
    |Vorläufiges amtliches Endergebnis \(in Klammern.{0,}|
    |DIE WAHLERGEBNISSE.{0,}|
    |(?<!\[)(?:Vorläufiges amtliches Endergebnis der Landtagswahl.{0,})|
    |(?:Test\: ){0,1}(?:Vorläufiges amtliches Endergebnis Bundestagswahl.{0,})|
    |(?:\(Eil \) ){0,1}(?:Vorläufiges amtliches Endergebnis Landtagswahl.{0,})|
    |Vorläufiges amtliches Endergebnis Abgeordnetenhaus.{0,}|
    |(?:Die Mandate im Bundesparlament mit)(?:.{0,})(?=Bei Verfassungsänderungen)|
    |(?:Das amtliche Endergebnis der Europawahl(?:en){0,1} (?!vom 13\.).{0,})|
    |Die CDU erhält 42 Sitze.{0,}|
    |Gegen \d{2}\.\d{2} Uhr \(Ortszeit\) am \b\w+\b ergab sich.{0,}|
    |Das endgültige Ergebnis wird erst in zehn Tagen.{0,}|
    |(?:Das amtliche Endergebnis für Sachsen)(?:.{0,})(?=In Sachsen hatte die)|
    |\[Landeswahlleiter\]\:.{0,}|
    |\(Internet\: Zuständiges.{0,}|
    |Die neuen Preise der Grundversionen.{0,}|
    |Die Kfz-Neuzulassungen für Deutschland.{0,}|
    |\(Amica e\.V\..{0,}|
    |Die 15 größten deutschen Reiseveranstalter.{0,}|
    |Die Sonderabgabe für den.{0,}|
    |Außenwert der D-Mark \(.{0,}|
    |\(Achtung\: Zum Euro hat dpa.{0,}|
    |(?:Ecu-Wert am \d{1,2}\. \b\w+\b)(?: \d{4}){0,1}(?:\:.{0,})|
    |Für Aktien werden im einzelnen u\.a\..{0,}|
    |(?<=korrigiert)(?:\: Verwendung des BIP.{0,})|
    |Die Neuzulassungen \d{4} im einzelnen.{0,}|
    |Die Besitzumschreibungen \d{4} in Deutschland im einzelnen.{0,}|
    |Die Veränderungen im einzelnen\:.{0,}|
    |Leistungsbilanz der Bundesrepublik Deutschland.{0,}|
    |(?:Von den 2 768 821 gültigen Landesstimmen)(?:.{0,})(?=Nach Angaben)|
    |Kaufkraft der Urlaubs-D-Mark.{0,}|
    |\. Wahlberechtigte\: \d{1}.{0,}|
    |Das komplette vorläufige amtliche Endergebnis.{0,}|
    |Für Aktien wurden zu Beginn u\.a\. folgende.{0,}|
    |Im Vergleich der Aufträge in den beiden.{0,}|
    |Zur Rechtsstellung der Abgeordneten empfiehlt die.{0,}|
    |In den einzelnen Bereichen ergaben sich.{0,}|
    |Ende des Jahres waren \d{2}.{0,}|
    |Im einzelnen ergaben sich dabei.{0,}|
    |Wahlausgang und Sitzverteilung im Oberhaus.{0,}|
    |Pkw\, Kombis und Wohnmobile.{0,}|
    |Im einzelen ergaben sich zum Vorjahr folgende.{0,}|
    |Im Monat \b\w+\b ergaben sich zum Vorjahr folgende.{0,}|
    |(?:ECU-Wert am \d{1,2}\. \b\w+\b)(?: \d{4}){0,1}(?:\:.{0,})|
    |Von den insgesamt 14 500 zusätzlichen außerbetrieblichen.{0,}|
    |Gegenüber dem Vorjahresstand ergaben sich.{0,}|
    |(?:Die Hochrechungen von ARD)(?:.{0,})(?=Im neuen Abgeordnetenhaus)|
    |Stand der Hochrechnungen um.{0,}|
    |Die Kfz-Neuzulassungen von.{0,}|
    |(?:Tabelle Inflationsrate |TABELLE INFLATIONSRATE ){0,1}(?:Preise für die Lebenshaltung in der Bundesrepublik.{0,})|
    |\(Bundesministerium für Gesundheit\,.{0,}|
    |Tabellarische Übersicht\:.{0,}|
    |Das von Innenminister Caspar Einem.{0,}|
    |(?:Die Prognose in Zahlen)(?: =){0,1}(?: \d{4}.{0,})|
    |Vortag\. 29\.12\. 28\.12\. 27\.12\. Dänenkrone.{0,}|
    |Die Kfz-Bestandszahlen am.{0,}|
    |Im einzelnen ergaben sich folgende Veränderungsraten.{0,}|
    |Die wichtigsten zehn Rohöl-Lieferanten.{0,}|
    |Von der EU-Kommission ermittelte[r]{0,1} Ecu-Wert.{0,}|
    |Die Hochrechnungen von ARD und ZDF nach dem Stand von.{0,}|
    |Der von der EU-Kommission ermittelte ECU-Wert.{0,}|
    |01\.04\. 29\.03\. Dänenkrone.{0,}|
    |Die folgende Tabelle enthält.{0,}|
    |12\.04\. 11\.04\. Dänenkrone.{0,}|
    |Stromhandel im europäischen Verbundnetz.{0,}|
    |In Berlin hat die PDS jetzt.{0,}|
    |(?:Die Mandate im Abgeordnetenhaus)(?:.{0,})(?=Im November)|
    |Im einzelnen ergaben sich nun.{0,}|
    |Die Marktanteile der Hersteller nach Umsätzen.{0,}|
    |DM\. 13\.06\. 12\.06\. Dänenkrone.{0,}|
    |15\.07\. 12\.07\. Dänenkrone.{0,}|
    |Hier der Vergleich.{0,}|
    |Die Wohngeldberechnung erfolgt.{0,}|
    |Dabei ergaben sich im einzelnen.{0,}|
    |Tarifliche Sonderzahlung in Prozent.{0,}|
    |Im einzelnen gab es dabei.{0,}|
    |Im einzelnen ist jetzt vorgesehen\: -.{0,}|
    |Im einzelnen kommen ab Juli folgende Neuregelungen auf die Autofahrer zu\: -.{0,}|
    |Im einzelnen gilt folgende Besteuerung\:.{0,}|
    |Es folgten Ford \(26 500\).{0,}|
    |Die meisten der neuen Pkw stellten.{0,}|
    |Die deutschen Kfz-Neuzulassungen.{0,}|
    |Die Finanzminister der Bundesrepublik\:.{0,}|
    |März \+ Apr\..{0,}|
    |(?:\(){0,1}(?:Spendenkonten\:)(?:.{0,})(?=Der Mainzer Bischof)|
    |(?:\(){0,1}(?:Spendenkonten\:.{0,})|
    |Im Jahr 1980 lag dieser Wert.{0,}|
    |Hier der Vorjahresvergleich der Monate.{0,}|
    |Im Vergleich zu Juli und August.{0,}|
    |Die neuen und alten \(in Klammern.{0,}|
    |Die November-Zulassungszahlen.{0,}|
    |Die Schlußkurse der wichtigsten.{0,}|
    |Folgende Wettbewerber treten.{0,}|
    |Im Vorjahresvergleich kam es.{0,}|
    |Ende des Jahres lebten.{0,}|
    |Die Kfz-Neuzulassungen \d{4}.{0,}|
    |Die Zahlen im einzelnen Fahrzeugart.{0,}|
    |Die deutschen Kfz-Zulassungszahlen.{0,}|
    |Die Kfz-Zulassungszahlen für.{0,}|
    |Die Kfz-Ummeldungen für.{0,}|
    |Dabei ergab sich im einzelnen.{0,}|
    |Die Kfz-Zulassungszahlen im.{0,}|
    |Die Länder mit der stärksten.{0,}|
    |Im folgenden die Kaufkraft.{0,}|
    |Die zehn größten europäischen Veranstalter.{0,}|
    |Die 20 wichtigsten Länder für.{0,}|
    |Übersicht Westdeutschland\:.{0,}|
    |Und so sehen die jüngsten Ergebnisse.{0,}|
    |(?:Die Hochrechnungen der Institute)(?:.{0,})(?=Die SPD kam)|
    |Die Hochrechnungen der Institute.{0,}|
    |Im September angemeldete Autos der zehn führenden Pkw-Marken.{0,}|
    |Nach Angaben der IG Metall liegen für die regionalen Tarifverhandlungen folgende Termine vor.{0,}|
    |Die Zulassungen der zehn führenden.{0,}|
    |Die bisherigen Landtagswahlen in Hessen Beteil.{0,}|
    |Weitere Länder mit rückläufigen Absatzzahlen.{0,}|
    |Im folgenden die Veränderungen im.{0,}|
    |Januar-Zulassungen der zehn führenden.{0,}|
    |Die zehn wichtigsten Länder für.{0,}|
    |Öffentliche Finanzen im Euro-Währungsgebiet.{0,}|
    |Die März-Zulassungen.{0,}|
    |Die Entwicklung des Dow-Jones-Index.{0,}|
    |Die deutschen April-Zulassungen.{0,}|
    |Berlin/Brandenburg Projekte.{0,}|
    |Schlußkurse von Hannover.{0,}|
    |Im Jahresvergleich kam es.{0,}|
    |(?:Nachfolgend die größten)(?:.{0,})(?=Ein Teil von)|
    |Die Mai-Neuzulassungen der zehn.{0,}|
    |Der deutsche Außenhandel \d{4}.{0,}|
    |Sozialhilfeausgaben der Bundesländer je Einwohner.{0,}|
    |Deutsche Ausfuhren nach Zielgebieten.{0,}|
    |Danach folgten Bayern.{0,}|
    |Dabei kam es im einzelnen zu folgenden Veränderungen.{0,}|
    |Exporte in die wichtigsten Zielländer.{0,}|
    |Die neue Gewichtung der Dax-Werte.{0,}|
    |Wachtumsprognose des IWF\:.{0,}|
    |Die deutschen August-Zulassungen der zehn ersten.{0,}|
    |Mit der Eingliederung von Cyprus.{0,}|
    |Oktober-Anmeldungen der in Deutschland führenden.{0,}|
    |In der Tabelle bedeutet.{0,}|
    |Preise für die Lebenshaltung der privaten Haushalte in Deutschland Veränderung.{0,}|
    |Im Einzelnen ergaben sich folgende Veränderungen.{0,}|
    |Im einzelnen die folgenden Veränderungen.{0,}|
    |Preise für die Lebenshaltung aller privaten Haushalte in Deutschland Januar.{0,}|
    |Die Neuanmeldungen der führenden.{0,}|
    |Durchschnittlicher Zahlungsverzug\:.{0,}|
    |Im Einzelnen ergaben sich im Jahresvergleich.{0,}|
    |Im Vergleich der zwei Monate.{0,}|
    |Ausgaben im Reiseverkehr 1998.{0,}|
    |Im Vorjahresvergleich der zusammengefassten.{0,}|
    |Die Wirtschaftsentwicklung in den einzelnen Ländern im.{0,}|
    |Deutsche Erdölimporte im ersten Halbjahr.{0,}|
    |Danach sähen die Fristen für einige ausgewählte Güter.{0,}|
    |Deutsche September-Zulassungen der führenden.{0,}|
    |Kaufkraftparitäten der Urlaubs-Mark\:.{0,}|
    |Nunmehr sieht die Liste ausgewählter Güter.{0,}|
    |Der Vertrag von Nizza sieht nun folgende.{0,}|
    |Die zehn führenden Pkw-Hersteller.{0,}|
    |Die zehn größten Lieferländer.{0,}|
    |Tabelle\: Drogentodesfälle.{0,}|
    |Der Vorjahresvergleich der beiden zusammengefassten Monate.{0,}|
    |Die inländischen Pkw-Absatzzahlen.{0,}|
    |\(Deutscher Anwaltverein\, Littenstr.{0,}|
    |Die Pilotenstreiks sind für den.{0,}|
    |Die Liste der Vermissten im Einzelnen.{0,}|
    |Die Liste der Vermissten aufgeschlüsselt nach Bundesländern.{0,}|
    |Nach der KBA-Statistik weist VW.{0,}|
    |Die zehn wichtigsten Welthandelsländer im.{0,}|
    |Rang 2001 Bilanz\-.{0,}|
    |(?:Die jüngsten Umfrage-Ergebnisses)(?:.{0,})(?=Die Bundestagswahl)|
    |(?:WAHL-UMFRAGEN)(?:.{0,})(?=WAHL-SPRUCH)|
    |WAHLKAMPF-FOTO\:.{0,}|
    |Tabelle für die einzelnen Landesparlamente.{0,}|
    |Mitgliederentwicklung in den acht DGB-Gewerkschaften\:.{0,}|
    |Einfuhr von Rohöl nach Ursprungsländern.{0,}|
    |Die endgültigen Zahlen\:.{0,}|
    |Die größten Steigerungsraten weisen.{0,}|
    |(?:Im Einzelnen gelten folgende emissionsbezogenen)(?:.{0,})(?=In den übrigen)|
    |LETTLAND\: 2004.{0,}|
    |(?:FRANKREICH\: |\~ |PORTUGAL\: |Vorläufige Ergebnisse der EU-Wahlen in Luxemburg\: |BELGIEN\: |Die Ergebnisse der Europawahl 2004 in Italien |GROSSBRITANNIEN\: |GRIECHENLAND\: |IRLAND\: ){0,1}(?:2004 \(1999\) Sitze \(1999\).{0,})|
    |(?:ZYPERN |LETTLAND\: |UNGARN\: |SLOWENIEN\: |SLOWAKEI\: |LITAUEN\: |TSCHECHIEN\: ){0,1}(?:2004 Sitze.{0,})|
    |Die Polizeiaufgebote im Überblick\:.{0,}|
    |(?:WAHL-UMFRAGEN)(?:.{0,})(?=WAHL-ZAHL)|
    |Die zehn Bestplatzierten des BTI.{0,}|
    |(?:Die Sitzverteilung\:)(?:.+?)(?=Damit kommt)|
    |(?:Damit werden die Mandate)(?:.+?)(?=Nach diesem)|
    |(?:Die Veranstalter zählten in Berlin)(?:.+?)(?=\«Wir haben)|
    |Liste der Spender\:.{0,}""", " ", text)
    
    return(text)
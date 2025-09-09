# -*- coding: utf-8 -*-
"""
Created on Wed May 19 15:22:27 2021

@author: jbaer
"""

import re

def clean_dpa_articles(text):
    """
    This function removes information that is unlikely to be relevant for sentiment and topic
    analysis.
    """

    # Remove unnecessary strings from the text with the replace() method 
    to_replace = ['ROUNDUP:', 
                  'Der Beitrag lag dpa in redaktioneller Fassung vor.',
                  'Bei   Rückfragen  steht  Ihnen',
                  'Weitere Informationen erhalten Sie unter:',
                  '(Der Beitrag wurde dpa vorab in redaktioneller Fassung übermittelt.)',
                  'dpa vs ot', 'dpa ds is', 'dpa as is', 'dpa cb ot', 'dpa cb ak','(...)', 
                  'dpa-AFX Broker - die Trader News im dpa-AFX ProFeed',
                  'dpa-AFX Broker - die Trader s von dpa-AFX',
                  '(Der Beitrag wurde dpa in redaktioneller Fassung übermittelt. )',
                  'NEW', 'New', 'Ende-F e a t u r e', 'F e a t u r e']

    for string in to_replace:
    
        text = text.replace(string, ' ')

    # Remove unnecessary strings from the text with regular expressions
    text = re.sub('''<.{1,15}?>|<[A-Z]{2}[0-9]+>|# dpa-Notizblock.{20,}|
    |(?:#{0,2}\s{0,2}(?:dpa){0,1}-{0,1}\s{0,1}[Nn]otizblock ){0,1}(?:## Internet.{0,})|
    |# Notizblock.{0,}|
    |# dpa-notizblock.{0,}|
    |dpa hpd.{0,}|
    |\(Kontakt\: [^)]+\)\.{0,1}|Kontakt\: söp.*|Kontakt\: College.*|Kontakt\: \<mailto.*|Kontakt\: Prof\..*|             
    |Diese Meldung finden Sie auch unter.{10,}|Die englische Originalmeldung finden Sie unter.{10,}|
    |Bitte beachten Sie die englische Originalmeldung.{10,}|
    |Originaltext:.{100,}|.{100,}Die gesamte korrigierte Mitteilung lautet:|Rückfragehinweis:.{10,}|
    |dpa-AFX Broker - die Trader News im dpa-AFX ProFeed.{10,}|
    |dpa-AFX Broker - die Trader News von dpa-AFX.{10,}|
    |dpa-AFX Broker - die Trader News von dpa-AFX.*|
    |Datum der Analyse.{5,}|
    |Für weitere Informationen wenden Sie sich bitte an:.{10,}|
    |Debitos GmbH newsroom:.{5,}|
    |.{20,}Inhalt der Mitteilung ist der Emittent verantwortlich.|
    |(?:Von \w{1,20} \w{1,20}, )(?:dpa-AFX|dpa)|
    |\({0,1}Achtung:Zusammenfassung bis.{5,}|
    |(?:\(Eil \) HÖRFUNK-NACHRICHTEN.*?---- )(?=Geiseln)|
    |dpa jd.{0,}|
    |Ja Nein Ent- Abgeg\..{0,}|
    |Größere Standorte / wegfallende Dienstposten.{0,}|
    |Der Regierung gehören folgende Minister an.{0,}|
    |Ziele und Erwartungen in den Ländern ---.{0,}|
    |Zinsniveau Verhalten der EZB.{0,}|
    |Berechtigt -- ---.{0,}| 
    |-{2,}\s+Peter.{0,}|
    |Die Veänderungen im einzelnen\:.{0,}|
    |Mit freundlichen Grüßen Redaktion.{0,}|
    |Im Vergleich zum Zeitraum Juni/Juli des Vorjahres.{0,}|
    |Die Verteilung der Sitze in den Regionalparlamenten.{0,}|
    |[-]{2,}|
    |(?:dpa (?:yy){0,1}zz.*?)(?:[=]{2,}.*?)(?:[=]{2,})|
    |Achtung\. Zum zehnten Jahrestag.*|
    |Hier die Ersparnisse bei der Einkommensteuer nach Gruppen.*|
    |[=]{2,}|
    |(?<!ein )(?<!am )(?<!per )(?<!ihr )(?<!ins )(?<!und )(?<!zum )(?<!über )(?<!aufs )(?<!nur )(?<!via )(?<!pro )(?<!oder )(?:Telefon|Tel\.)(?:\:[^a-zA-Z«]+)|
    |(?<!per )(?<!ein )(?<!einem )(?<!Kohl-)(?<!gefälschten )(?:Fax:[^a-zA-ZÜÄÖüäö]+)|
    |\({0,1}\+\d{2}\s[^a-zA-Z]+|
    |This announcement is distributed by.{1,}|
    |Diese Mitteilung enthält bestimmte in die Zukunft gerichtete Aussagen.{1,}|
    |\(Achtung: Neue Zusammenfassung.{2,}|
    |\(Achtung: Zusammenfassung (?:mit|bis).{2,}|
    |\(Achtung: Sie erhalten eine Zusammenfassung\).{0,}|   
    |\(Achtung: Folgt Zusammenfassung.{2,}|
    |\(Achtung: Folgt weitere Zusammenfassung.{2,}|
    |VWD/ap-dj.{0,}|
    |VWD/\d{2}.{0,}|
    |vwd/dj.{0,}|
    |vwd/\d{2}.{0,}|
    |vwd//.{0,}|
    |vwd/ap-dj.{0,}|
    |(?:\(Az\:)(?:[^)]{1,})(?:(?<!Bundeskriminalamts \(BKA)\))|
    |(?:\(Az\: 1 BvR 370/07)(?=\. Das Gericht erklärte)|
    |(?:\(Az\.\:)(?:[^)]{1,})(?:\))|
    |dpa hb.{0,}|
    |(?:dpa eh)(?!er)(?:.{0,})|
    |dpa bg.{0,}|
    |(?:\(A c h t u n g\:)(?:.{0,})(?:Januar 2230\))|
    |(?:A c h t u n g\:)(?:.{0,})(?:28\.4\. 2130)|
    |(?:A c h t u n g\:)(?:.{0,})(?:zu \«Mehmet\»\.|zu Koalition\.)|
    |(?:A c h t u n g\:)(?:.{0,})(?:Neufassung\:)|
    |\({0,1}A c h t u n g\:.{0,}|
    |dpa hh.{0,}|
    |(?:\(Wiederholung[^)]+?)(?:[^)]{1,})(?:Aktenzeichen\:[^)]+?\))|
    |(?:\(OLG Koblenz)(?:[^)]{1,})(?:\))|
    |(?:\(LG München)(?:[^)]{1,})(?:\))|
    |(?:\(Beschluss vom[^)]+?)(?:[^)]{1,})(?:Aktenzeichen:[^)]+?\)\.)|
    |(?:Das Urteil vom)(?:[^)]{1,})(?:Aktenzeichen:.+?\.)|
    |(?:\: \(Aktenzeichen\:)(?:[^)]+?)(?:\.\.\.)|
    |(?:\(\s{0,1}Aktenzeichen\:)(?:[^)]{1,})(?:\))|
    |(?:Aktenzeichen\:)(?:.{0,})(?=Nach dem Zivilrecht)|
    |(?:- Aktenzeichen\:)(?:.{0,})(?:\d{4}\.)|
    |(?<!«)(?<!ZDF-Magazin )Aktenzeichen\:.{0,}|
    |(?:\(\s{0,1}Achtung\:)(?:[^)]{1,})(?:\))|
    |(?:\(\s{0,1}URL\:)(?:[^)]{1,})(?:\))|
    |(?:\(\s{0,1}Internet\:)(?:[^)]{1,})(?:\))|  
    |dpa wj.{0,}|
    |dpa pf.{0,}|
    |dpa dk.{0,}|
    |(?:dpa rt kb)(?:.{0,})(?:Debatte sechs)|
    |(?:dpa ke kb)(?:.{0,})(?:Debatte zwei)|
    |(?: [Ff]olgt [Dd]ebatte )(?:zwei |drei |vier |fünf |sechs |sieben |acht |neun |zehn |elf |zwölf |13 |14 |15 |16 |17 |18 )(?:und Schluß ){0,1}(?:\(Solms\) ){0,1}(?:dpa ku|dpa ke|dpa dr|dpa js|dpa rf|dpa rt|dpa he|dpa hö|dpa rx|dpa hs|dpa wb|dpa li|dpa sm|dpa ta|dpa ct)(?:.+?)(?<!\(Berichtigung - )(?:Debatte |Deabtte )(?:zwei |drei |vier |fünf |sechs |sieben |acht |neun |zehn |elf |zwölf |13 |14 |15 |16 |17 |18 )(?:und Schluß){0,1}|
    |dpa ku(?!rz|rsiert).{0,}|
    |(?:\(\s{0,1}Rechtssachen)(?:[^)]{1,})(?:\))|
    |dpa bb.{0,}|
    |dpa bl(?!eib| el 160710|ieb|ockt).{0,}|
    |(?:\(\s{0,1}Der Beitrag)(?:[^)]{1,})(?:\))''', ' ', text)
    
    ### List with explanations for each pattern: ###
    # Stock symbols:                                       <.{1,15}?>
    #                                                      <[A-Z]{2}[0-9]+>  
    # Additional information intended for the author:      # dpa-Notizblock.{20,} 
    #                                                      (?:#{0,2}\s{0,2}(?:dpa){0,1}-{0,1}\s{0,1}[Nn]otizblock ){0,1}(?:## Internet.{0,})
    #                                                      # Notizblock.{0,}
    #                                                      # dpa-notizblock.{0,}
    # Reference to an article containing the same text:    Diese Meldung finden Sie auch unter.{10,}   
    # Link to the original article in English:             Bitte beachten Sie die englische Originalmeldung.{10,}
    #                                                      Die englische Originalmeldung finden Sie unter.{10,}                  
    # Uncorrected version of the original article:         Originaltext:.{100,}
    #                                                      .{100,}Die gesamte korrigierte Mitteilung lautet:'  
    # Inquiry note:                                        Rückfragehinweis:.{10,}  
    # Reference to other stock-related articles:           dpa-AFX Broker - die Trader News im dpa-AFX ProFeed.{10,}
    #                                                      dpa-AFX Broker - die Trader News von dpa-AFX.{10,}
    #                                                      Die englische Originalmeldung finden Sie unter folgendem Link:.{10,}  
    # Date of the study mentioned in the article:          Datum der Analyse.{5,}    
    # Reference to additional information:                 Für weitere Informationen wenden Sie sich bitte an:.{10,}     
    # Reference to Debitos:                                Debitos GmbH newsroom:.{5,}    
    # Reference to the issuer:                             .{20,}Inhalt der Mitteilung ist der Emittent verantwortlich.   
    # Reference to the author(s):                          (?:Von \w{1,20} \w{1,20}, )(?:dpa-AFX|dpa)    
    # Reference to the summary:                            \({0,1}Achtung:Zusammenfassung bis.{5,}    
    # Unnecessary hyphens and equality signs:              [-]{2,}
    #                                                      [=]{2,}      
    # Telefon and fax numbers:                             (?<!ein )(?<!am )(?<!per )(?<!ihr )(?<!ins )(?<!und )(?<!zum )(?<!über )(?<!aufs )(?<!nur )(?<!via )(?<!pro )(?<!oder )(?:Telefon|Tel\.)(?:\:[^a-zA-Z«]+)
    #                                                      (?<!per )(?<!ein )(?<!einem )(?<!Kohl-)(?<!gefälschten )(?:Fax:[^a-zA-ZÜÄÖüäö]+)
    #                                                      \({0,1}\+\d{2}\s[^a-zA-Z]+ 
    # Reference to the distributer:                        This announcement is distributed by.{1,}  
    # Reference to additional information:                 Diese Mitteilung enthält bestimmte in die Zukunft gerichtete Aussagen.{1,}   
    # Reference to contact information:                    \(Kontakt\: [^)]+\)\.{0,1}|Kontakt\: söp.*|Kontakt\: College.*|Kontakt\: \<mailto.*|Kontakt\: Prof\..*  
    # Reference to an article summary:                     \(Achtung: Neue Zusammenfassung.{2,}
    #                                                      \(Achtung: Zusammenfassung (?:mit|bis).{2,}
    #                                                      \(Achtung: Folgt weitere Zusammenfassung.{2,}
    #                                                      \(Achtung: Sie erhalten eine Zusammenfassung\).{0,}
    # Reference to a news agency:                          VWD/ap-dj.{0,}
    #                                                      VWD/\d{2}.{0,}
    #                                                      vwd/dj.{0,}
    #                                                      vwd/\d{2}.{0,}
    #                                                      vwd//.{0,}
    #                                                      vwd/ap-dj.{0,}
    #                                                      dpa hb.{0,}
    #                                                      (?:dpa eh)(?!er)(?:.{0,})
    #                                                      dpa bg.{0,}
    #                                                      dpa hh.{0,}
    #                                                      dpa wj.{0,}
    #                                                      dpa pf.{0,}
    #                                                      dpa dk.{0,}
    #                                                      dpa ku(?!rz|rsiert).{0,}
    #                                                      dpa bb.{0,}
    #                                                      dpa bl(?!eib| el 160710|ieb|ockt).{0,}
    #                                                      dpa jd.{0,}
    #                                                      dpa hpd.{0,}
    # Reference to the case number at the court:           (?:\(Az\:)(?:[^)]{1,})(?:(?<!Bundeskriminalamts \(BKA)\))
    #                                                      (?:\(Az\: 1 BvR 370/07)(?=\. Das Gericht erklärte)
    #                                                      (?:\(Wiederholung[^)]+?)(?:[^)]{1,})(?:Aktenzeichen\:[^)]+?\))
    #                                                      (?:\(OLG Koblenz)(?:[^)]{1,})(?:\))
    #                                                      (?:\(LG München)(?:[^)]{1,})(?:\))
    #                                                      (?:\(Beschluss vom[^)]+?)(?:[^)]{1,})(?:Aktenzeichen:[^)]+?\)\.)
    #                                                      (?:Das Urteil vom)(?:[^)]{1,})(?:Aktenzeichen:.+?\.)
    #                                                      (?:\: \(Aktenzeichen\:)(?:[^)]+?)(?:\.\.\.) 
    #                                                      (?:\(\s{0,1}Aktenzeichen\:)(?:[^)]{1,})(?:\))
    #                                                      (?:Aktenzeichen\:)(?:.{0,})(?=Nach dem Zivilrecht)
    #                                                      (?:- Aktenzeichen\:)(?:.{0,})(?:\d{4}\.)
    #                                                      (?<!«)(?<!ZDF-Magazin )Aktenzeichen\:.{0,}
    #                                                      (?:\(Az\.\:)(?:[^)]{1,})(?:\))
    # Reference to additional information:                 (?:\(A c h t u n g\:)(?:.{0,})(?:Januar 2230\))
    #                                                      (?:A c h t u n g\:)(?:.{0,})(?:28\.4\. 2130)
    #                                                      (?:A c h t u n g\:)(?:.{0,})(?:zu \«Mehmet\»\.|zu Koalition\.)
    #                                                      (?:A c h t u n g\:)(?:.{0,})(?:Neufassung\:)
    #                                                      \({0,1}A c h t u n g\:.{0,}
    #                                                      (?:\(\s{0,1}Achtung\:)(?:[^)]{1,})(?:\))
    #                                                      (?:\(\s{0,1}Der Beitrag)(?:[^)]{1,})(?:\))
    # Reference to the website:                            (?:\(\s{0,1}URL\:)(?:[^)]{1,})(?:\))
    #                                                      (?:\(\s{0,1}Internet\:)(?:[^)]{1,})(?:\))
    # Reference to internal notes separating several
    # parts of the article:
    #                                                      (?:dpa rt kb)(?:.{0,})(?:Debatte sechs)
    #                                                      (?:dpa ke kb)(?:.{0,})(?:Debatte zwei)
    #                                                      (?: [Ff]olgt [Dd]ebatte )(?:zwei |drei |vier |fünf |sechs |sieben |acht |neun |zehn |elf |zwölf |13 |14 |15 |16 |17 |18 )(?:und Schluß ){0,1}(?:\(Solms\) ){0,1}(?:dpa ku|dpa ke|dpa dr|dpa js|dpa rf|dpa rt|dpa he|dpa hö|dpa rx|dpa hs|dpa wb|dpa li|dpa sm|dpa ta|dpa ct)(?:.+?)(?<!\(Berichtigung - )(?:Debatte |Deabtte )(?:zwei |drei |vier |fünf |sechs |sieben |acht |neun |zehn |elf |zwölf |13 |14 |15 |16 |17 |18 )(?:und Schluß){0,1}
    # Reference to a legal case:
    #                                                      (?:\(\s{0,1}Rechtssachen)(?:[^)]{1,})(?:\))    
    # Reference to the voting results:                     Ja Nein Ent- Abgeg\..{0,}
    #                                                      Berechtigt -- ---.{0,}
    # Summary of German military base closures:            Größere Standorte / wegfallende Dienstposten.{0,}  
    # The list of ministers in the Spanish government:     Der Regierung gehören folgende Minister an.{0,}
    # Overview of political party priorities:              Ziele und Erwartungen in den Ländern ---.{0,}
    # Summary of the ECB's level of attentiveness:         Zinsniveau Verhalten der EZB.{0,}
    # Reference to the contact information:                -{2,}\s+Peter.{0,}
    #                                                      Mit freundlichen Grüßen Redaktion.{0,}
    #                                                      (?:dpa (?:yy){0,1}zz.*?)(?:[=]{2,}.*?)(?:[=]{2,})
    # The table:                                           Die Veänderungen im einzelnen\:.{0,}
    #                                                      Im Vergleich zum Zeitraum Juni/Juli des Vorjahres.{0,}
    #                                                      Die Verteilung der Sitze in den Regionalparlamenten.{0,}
    #                                                      Hier die Ersparnisse bei der Einkommensteuer nach Gruppen.*
    # Reference to additional information:                 (?:\(Eil \) HÖRFUNK-NACHRICHTEN.*?---- )(?=Geiseln)
    # Announcements of upcoming news:                      Achtung\. Zum zehnten Jahrestag.*
    return(text)
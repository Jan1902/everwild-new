# Everwild – Konzept und Entscheidungen

Stand: 2026-10-14. „Everwild“ ist ein Arbeitstitel (siehe Offene Punkte).

Dieses Dokument hält fest, was entschieden ist, was noch offen ist und wie die Arbeit aufgeteilt wird. Es wird bei jeder neuen Entscheidung aktualisiert.

## 1. Vision

Everwild ist ein ruhiges, isometrisches Explorationsspiel für Mobile. Der Spieler reist durch kleine, in sich geschlossene Welten, löst Aufgaben für ihre Bewohner und entdeckt die verborgenen Verbindungen zwischen ihnen. Jede Welt ist ein Puzzleteil eines größeren Geheimnisses, und jedes Portal öffnet ein Stück mehr von dem, was einst eins war.

Leitgefühl: Alles war einmal eins und ist jetzt getrennt. Der Spieler bewegt sich wie in einem Déjà-vu. NPCs erkennen ihn, Dinge hängen zusammen, Welten fühlen sich vertraut und zugleich falsch an.

## 2. Ursprüngliche Ideenliste (Jan)

- Welten 20x20
- Jede Welt hat ein eigenes Thema mit Design und Musik
- Versteckte Portale zwischen den Welten
- Portale mit Bedingungen (Rätsel)
- NPCs mit Quests und Rätseln
- Items mit Hinweisen
- Quests und Items schalten Features wie das Notizbuch frei
- Notizbuch mit gelernten Verbindungen, abstrakt dargestellt
- Teilweise identische Welten mit kleinen Veränderungen, die sich anders oder komisch anfühlen
- Aktionen können andere Welten beeinflussen
- Quests und Aktionen reparieren Welten
- Beobachten, Ruhen oder Ähnliches als Mechanik
- Eine Welt ist irgendwie falsch. Man kann in die Erinnerung der Welt gehen und muss dann die jetzige Welt so manipulieren, dass sie wie früher ist

## 3. Story-Grundgerüst

### Entschieden (Jan)

1. **Die heile Welt (Tutorial):** Das Spiel beginnt in der normalen, intakten Welt: eine kleine Welt, etwa ein kleines Dorf. Der Spieler erledigt ein bis zwei kleine Aufgaben für einen NPC (z. B. einen alten Mann) und lernt dabei die Spielmechaniken.
2. **Der Bruch:** Etwas passiert. Die Welt zerreißt in falsche, kaputte Einzelteile. Nichts ist mehr wie vorher.
3. **Das Erwachen:** Der Spieler wacht irgendwo auf. Alles wirkt anders, die Musik ist komisch, die Farben sind komisch.
4. **Das eigentliche Spiel:** Der Spieler macht die Welt Stück für Stück wieder zu dem, was sie war. Hier beginnt das Rätseln.

### NPCs (Jan)

- Der alte Mann aus dem Tutorial taucht in der kaputten Welt immer mal wieder auf, darf aber nicht zu präsent sein. Andere NPCs tauchen genauso wieder auf.
- Die NPCs erinnern sich teils gar nicht, teils nur in Fetzen an den Spieler.
- Man merkt ihnen an, dass sie verändert sind.
- **Nicht mit NPCs überladen.** Wenige Figuren, auch im Tutorial.
- **Fremde, die den Spieler kannten:** Es gibt NPCs, die der Spieler nicht kennt, die ihn aber einmal gekannt haben. Sie stehen für die alte Welt jenseits dessen, was der Spieler im Tutorial selbst gesehen hat.

### Folgerungen (von Jan bestätigt)

- **Das Tutorial ist die erste Erinnerung.** Der Spieler hat die heile Welt selbst erlebt und weiß deshalb, wie sie aussehen soll. Die Mechanik „Erinnerung vs. Jetzt“ braucht so keine Erklärung.
- **Das erste kaputte Bruchstück ist ein Teil des Tutorial-Dorfs.** Der Spieler erkennt es wieder und merkt sofort, was falsch ist. Spätere Bruchstücke zeigen Teile der Welt, die er vorher nie gesehen hat, und werden dadurch schwerer.
- **Das Tutorial-Dorf hat nur wenige Bewohner:** der alte Mann und ein bis zwei weitere, die man später wiedererkennen kann.
- **Die alte Welt ist größer als das Tutorial:** Der Spieler hat nur einen kleinen Ausschnitt selbst gesehen. Den Rest erfährt er aus den Bruchstücken, aus Erinnerungen der Welten und von NPCs, die ihn kannten.
- **Erinnerung der NPCs als Fortschrittsanzeige:** Je weiter ein Bruchstück repariert ist, desto mehr erinnern sich seine Bewohner. Ihre Dialoge ändern sich mit dem Zustand der Welt.
- **Das Tutorial legt Musik und Farben als Referenz fest:** Leitmotiv und Farbpalette der heilen Welt sind das, was in den Bruchstücken zerbrochen ist und sich beim Reparieren wieder zusammensetzt.

### Der Riss und das Notizbuch gehören dem ganzen Spiel (Jan, 2026-10-12)

- **Der Riss bleibt rätselhaft und übergreifend.** Er ist das Ereignis hinter dem gesamten Spiel, nicht hinter einem einzelnen Abschnitt. Die Geschichte eines Abschnitts (das Dorf mit Mühlenhügel und Quelle) darf ihn nicht erklären oder auflösen. Sie erzählt, was der Riss dort angerichtet hat und was die Leute dort verloren haben, und gibt höchstens ein Bruchstück der großen Frage preis.
- **Das Notizbuch ist übergreifend.** Es begleitet den Spieler durch alle Abschnitte und gehört nicht zur Geschichte eines Dorfs. Was es ist und woher es kommt, ist Teil der großen Geschichte.
- Ein Entwurf, der beides in die Geschichte des Dorfs zog (der Spieler als Laternenanzünder, der Riss als Folge einer ausgefallenen Runde, das Notizbuch als Rundenbuch), ist deshalb verworfen.

### Kapitel (Jan, 2026-10-12)

Das Spiel besteht aus Kapiteln. Jedes hat eine Datei in `docs/chapters/`, die Geschichte, Orte, Figuren, Rätsel und Zusammenhänge beschreibt: lesbarer Text zum Diskutieren und feste Blöcke für alles, was eindeutig sein muss. Aus ihr werden Welten, Texte und der Bedarf an Bildern und Musik abgeleitet. Der Aufbau der Datei steht in ihrer Lesehilfe.

Die Figuren nennen das große Ereignis **„der Riss“** (englisch „the Rift“). Der Name ist vorläufig.

### Erstes Kapitel: das Tal

Die verbindliche Fassung steht in `docs/chapters/valley.md`. In Kürze:

- **Fünf Stücke im Kreis:** Dorf (mit dem Haus des Alten), Mühlenhügel, Quelle, Weiher, Warte. Bögen verbinden sie. Vorwärts trägt ein Bogen nur, wenn die Laterne seines Stücks brennt, und er überspringt Stücke, die nicht im Notizbuch stehen.
- **Der Riss kam am Abend, und es ist Abend geblieben.** Das Wehr an der Quelle ist zu, weil der Morgen nie kam. Der Wind weht falsch, solange die Mühle nicht richtig läuft, und bläst jede Flamme aus, die nicht im Windschatten steht.
- **Jeder hat etwas verloren:** der Alte den Weg zum großen Licht auf der Warte, der Müller seine Kurbel, die Fischerin den Heimweg, die Frau am Bach ihren Abendweg. Das Kind am Abhang führt das Verweilen ein.
- **Der Spieler bringt das Tal wieder in Gang** und zündet am Ende das große Licht an, weil der Alte nicht mehr hinaufkommt. Von oben sieht man dahinter weitere dunkle Stücke.
- **Über den Riss erfährt er nur fünf Bruchstücke,** eines je Figur, und sie passen nicht zusammen.
- **Das Kapitel beginnt mit dem Abend vor dem Riss:** Der Spieler zündet im heilen Dorf die Laternen an und zieht dem Alten die Spieluhr auf.

Das Kapitel entstand zuerst als Probefassung, in der alles Neue mit einfachen Flächen gezeichnet war. Jan hat sie im Spiel beurteilt, danach wurden Bilder und Musik generiert. So soll es bei jedem Kapitel laufen.

## 4. Spieldesign

### Entschieden

- **Kernmechanik „Erinnerung vs. Jetzt“:** Die Erinnerung ist der Zielzustand einer Welt, die Gegenwart der Ist-Zustand. Der Spieler schließt die Differenz. Alle anderen Mechaniken ordnen sich darum an.
- **Fast identische Welten:** Eine Basiswelt plus gezielte Abweichungen. Das trägt das Déjà-vu-Gefühl und erzeugt viel Inhalt mit wenig Aufwand.
- **Fortschritt über Wissen statt Items:** Das Notizbuch als Verbindungsgraph ist der eigentliche Fortschritt (Richtung Outer Wilds, Tunic).
- **Kein Kampf, keine Stats:** Es ist ein Explorations-Puzzle, kein klassisches RPG.
- **„Verweilen“:** Wer an bestimmten Orten stehen bleibt, sieht mehr: die Erinnerung scheint durch, NPC-Routinen werden sichtbar, Portale zeigen sich. Kein Zeitdruck.
- **Verweilen ist selten und hat einen Ort (Jan, 2026-10-12):** Die Erinnerung zeigt sich nicht überall und nicht von Anfang an. In der ersten Fassung erschien sie nach wenigen Sekunden an jeder Stelle; das war zu stark und kam zu früh. Sie ist an Orte gebunden, und die Geschichte erklärt, warum es dort geht. Beispiel: Eine Figur steht am Abhang und erzählt, dass sie jeden Tag dort steht und manchmal das Gefühl hat, sich an die Welt von früher zu erinnern. Stellt sich der Spieler daneben und wartet, scheint langsam die alte Welt durch. Der Spieler lernt das Verweilen so von einer Figur, nicht durch Zufall.
- **Keine Sackgassen:** Alles ist umkehrbar, kein Zustand ist unlösbar. Das gilt besonders für Aktionen, die andere Welten beeinflussen, und wird automatisch geprüft (siehe Testen).

### Die Reparatur-Schleife (Jan)

Eine Welt wird nicht auf einen Schlag repariert, sondern in Schritten. Jeder Schritt verändert etwas Sichtbares oder Hörbares und öffnet den nächsten.

Beispielablauf:

1. Die Welt ist falsch: Dinge stehen falsch herum, Wind und Bäume wehen in die falsche Richtung, die Haustür führt an einen anderen Ort.
2. Der Spieler ändert einzelne Dinge: verschiebt einen Stein, geht über eine Brücke, legt einen versteckten Schalter um, sammelt etwas auf.
3. Daraufhin verändert sich etwas: Die Haustür führt jetzt tatsächlich ins Haus.
4. Im Haus spricht er mit einem NPC, der Tipps gibt. Auf deren Basis verändert er etwas im Haus.
5. Wenn er wieder hinausgeht, weht der Wind richtig herum und die Musik klingt schon normaler.

Daraus folgt:

- **Aktionen des Spielers:** verschieben, betreten/überqueren, schalten, aufsammeln, sprechen, dazu das Verweilen.
- **Innenräume:** Häuser sind eigene kleine Räume innerhalb einer Welt.
- **Schrittweise Rückmeldung:** Jede Teilreparatur ist sofort spürbar (Wind, Farbe, Musik, Verhalten). Die Musik wird stufenweise normaler, nicht erst am Ende.
- **Ursache und Wirkung liegen oft an verschiedenen Orten:** Was man im Haus ändert, wirkt draußen.

### Ergänzungen (von Jan bestätigt)

- **Falsche Türen und Portale sind dieselbe Mechanik:** Eine Tür, die an den falschen Ort führt, ist eine falsch verdrahtete Verbindung. Reparieren heißt, sie richtig zu verdrahten. Dasselbe gilt im Großen für die Portale zwischen den Welten.
- **Zusammenspiel mit der Erinnerung:** Die Erinnerung zeigt, *was* falsch ist. Die Reparatur-Schleife ist der Weg, *wie* man es richtigstellt. Der Spieler manipuliert die Fehler meist nicht direkt, sondern über Umwege.
- **Jede Welt hat eine feste Zahl von Fehlern**, z. B. vier bis sechs. Jeder behobene Fehler bringt eine Musikstimme und ein Stück Farbe zurück.

### Woher das Gefühl „falsche Welt“ kommt

Drei Hebel, alle gezielt steuerbar:

1. **Abweichungen an Objekten:** Etwas fehlt, ist gespiegelt, steht woanders, ein Schatten fällt in die falsche Richtung.
2. **Atmosphäre:** Licht, Farbstich, Nebel; Musik, die leicht verstimmt ist oder der eine Stimme fehlt.
3. **Verhalten:** Wind und Bäume wehen in die falsche Richtung, Wasser fließt bergauf, eine Tür führt an einen anderen Ort, ein NPC erinnert sich nur in Fetzen, eine Animation läuft rückwärts.

Grundregel: Jeder sichtbare Unterschied zwischen zwei Varianten einer Welt ist Absicht. Es darf keine zufälligen Unterschiede geben, sonst sucht der Spieler nach Bedeutung, wo keine ist.

### Damit das Spiel fesselt (Jan, 2026-10-14)

Das Tal sah gut aus und spielte sich, packte aber nicht; es fühlte sich trocken und planlos an. Die Gründe: Das Ziel des Kapitels (das große Licht) erfährt man erst spät, der Spieler arbeitet eine Kette von Besorgungen ab, statt selbst Unterschiede zu erkennen, das Notizbuch läuft als sauberes Register nebenher, Belohnungen fehlen oder sind leise, und alle Figuren klingen gleich. Entschieden ist:

- **Das Notizbuch ist ein Rätsel, nicht ein Register.** Der Spieler setzt Gedanken selbst zusammen, indem er Notizen aufeinanderzieht; daraus entsteht eine Einsicht, die etwas im Spiel öffnet. Die Bedienung ist auf dem Handy einfach. Irren gibt es vorerst nicht: Was nicht zusammenpasst, fällt sofort zurück.
- **Das Notizbuch ist chaotischer.** Halbe Sätze, Fragen, Gekritzel statt eines geordneten Verzeichnisses. Chaotisch ist der Inhalt, nicht die Bedienung.
- **Eine Karte der Weltstücke im Notizbuch.** Die Stücke als Inseln, die Bögen als Pfeile. Was fehlt, ist zu sehen: Ein Bogen, der ein vergessenes Stück überspringt, zeigt mit einem Fragezeichen zurück. Das Stück kommt erst auf die Karte, wenn der Spieler es aus seinen Notizen erschlossen hat.
- **Der Prolog wird länger und ist das Tutorial.** Mehr Inhalt, kurze Hinweise im Bild zu Laufen, Sprechen und Benutzen. Der Spieler sieht darin das heile Dorf so, dass er Abweichungen später selbst wiedererkennt.
- **Der Aufbruch des Alten ist eine Szene.** Man sieht, wohin er geht. Will der Spieler ihm folgen und geht durch die Tür, kommt der Riss.
- **Die große Geschichte erzählt in Staffeln.** Am Ende eines Kapitels glaubt der Spieler, es zu verstehen; dann kommt ein einziger Hinweis, der ins nächste führt. Es wird viele Kapitel geben, deshalb darf das Tal nur einen kleinen Teil preisgeben.
- **Mehr Belohnung.** Jeder Fortschritt soll sich lohnen, sicht- und hörbar. Das Ende eines Kapitels ist ein großer Moment mit Szene und Erkenntnis.
- **Figuren mit mehr Charakter.** Sie bewegen sich und sind animiert, statt still zu stehen, und jede hat eine Brabbelstimme (eigener Klang und Rhythmus, keine Sprachausgabe). Das passt zum Reden in Bruchstücken und ist unabhängig von der Sprache.
- **Die Schieber am Wehr fliegen raus.** Drei Schieber nach der Erinnerung einzustellen wirkt fehl am Platz und ist langweilig. Die Quelle braucht ein anderes Rätsel.

#### Zum Anspielen gebaut (2026-10-14)

Jan wollte die Punkte oben ausprobieren, bevor viel Inhalt entsteht. Gebaut ist je Punkt so viel, dass er im Prolog und im Dorf einmal echt vorkommt; der Rest des Tals spielt sich wie zuvor. Was dabei entschieden wurde, ohne dass Jan es schon gesehen hat (Claude, zum Beurteilen):

- **Der Spieler findet sein Buch nach dem Riss (Jan, 2026-10-14).** Ein erster Versuch gab es ihm schon im Prolog vom Alten; das nahm den Moment, in dem man das Buch findet und die eigene Handschrift sieht. Jetzt liegt es neben ihm im Gras, wenn er aufwacht: „Es ist meine Handschrift. Was heute Abend war, steht schon darin“, die Abendrunde (durchgestrichen) und der Weg des Alten, und ein Zettel, an den er sich nicht erinnert: „Er geht hinauf. Ich soll nachkommen. Wenn oben das Licht –“. Im Haus des Alten liegt es nicht mehr; das hätte die erste Einsicht (Windschatten, um die Tür zu öffnen) hinter die Tür gesperrt. Das Kind redet erst vom Verweilen, wenn der Spieler das Buch dabeihat. Ohne Buch lässt sich nichts zusammendenken.
- **Das Buch zeigt, was man bei sich hat (Jan, 2026-10-14):** unter der Karte, „Bei mir:“ in Handschrift, was man je bekommen hat; was man wieder abgegeben hat, ist durchgestrichen.
- **Auch die eigene Figur atmet**, wenn sie steht, wie die anderen (Jan, 2026-10-14).
- **Wer feststeckt, wird zum Buch geschickt (Jan, 2026-10-14):** Jan fand die Kurbel nicht, weil er nicht darauf kam, die beiden Hälften im Buch zusammenzuziehen. Jetzt sagt sich die Figur am Schrank, sobald sie beide kennt, dass das vielleicht im Buch zusammengehört, und im Buch zeigt der durchscheinende Finger wieder, was zusammenpasst, wenn es eine Weile offen ist, ohne dass ein Gedanke entsteht.
- **Einsichten.** Zieht der Spieler einen Zettel auf einen anderen und gehören sie zusammen, wird eine Einsicht aufgeschrieben (`"from"` in `data/notes.json`, `Session.combine()`); die beiden Zettel liegen dann unter ihr. Was nicht zusammenpasst, schüttelt sich und springt zurück. Bis der Spieler zum ersten Mal einen Zettel gezogen hat, zeigt ein durchscheinender Finger, wie es geht. Einsichten öffnen etwas, und die Lösbarkeitsprüfung kennt das Denken als Zug. Drei gibt es bisher: der Windschatten (ohne ihn rollt kein Heuwagen vor eine Laterne), wohin der Bogen im Dorf führt (ohne sie trägt er nirgendwohin) und wem die Kurbel gehört (ohne sie findet sich nichts im Schrank).
- **Bögen führen nur dorthin, wohin man will.** Die Regel „Bögen kennen nur, was im Notizbuch steht“ gilt jetzt auch für den Bogen im Dorf: Er trägt, aber der Spieler weiß nicht wohin, bis er den Gedanken gefasst hat.
- **Die Karte** steht auf der linken Seite des Buchs (`data/map.json`): Inseln mit Namen und einem Punkt je Fehler, Pfeile für Bögen, gestrichelt mit „?“ für einen Bogen, dessen Ziel unbekannt ist, und für einen, der etwas überspringt. Ein Stück, das der Spieler erschlossen hat, erscheint mit einem Schein.
- **Die Szene beim Aufbruch:** Der Alte steht nach der Spieluhr auf, geht aus dem Haus, über die Brücke und durch den Bogen. Oben am Himmel geht ein fernes Licht an. Danach ist der Spieler allein im Haus; geht er ihm nach, kommt der Riss. Der Riss beginnt mit einem kurzen Aufleuchten, hell wie mittags, wie es das Kind später sagt. Ob der Alte oben ankam, bleibt offen. Szenen sind Daten (`data/scenes.json`), eine Regel spielt sie mit `{"scene": id}`.
- **Hinweise im Bild** gibt es nur im Prolog: ein Finger, der leise auf das tippt, was als Nächstes zu tun ist (die Figur, das Notizbuch, die Tür, die Laternen, die Spieluhr). Er erscheint erst, wenn eine Weile nichts geschieht, und verschwindet beim nächsten Tipp (`hints` in der Weltdatei).
- **Verweil-Stellen sind zu sehen:** Wo Stehenbleiben eine Erinnerung zeigen würde, schimmert der Boden warm, Lichtpunkte steigen auf; wer dort wartet, sieht es dichter werden.
- **Lebendige Figuren:** Sie atmen, wenden sich dem Spieler zu, wippen beim Sprechen und schauen sich ab und zu um. Am Abend vor dem Riss gehen die Frau und das Kind kleine Wege (`stroll` in der Weltdatei); nach dem Riss stehen sie still an ihrem Platz der Erinnerung, und erst wenn ihr Stück heil ist, gehen sie wieder. Der Alte hat Laufbilder (zwei generierte Bögen), die anderen gleiten mit einem kleinen Wippen.
- **Brabbelstimmen** sind errechnet, nicht generiert (`tools/sound_effects.py`): je Figur acht gesungene Silben mit eigener Tonhöhe und Farbe, eine Silbe alle paar Buchstaben. Die eigene Figur hat keine Stimme. **Jan, 2026-10-14: klingen wie ein Roboter, nicht wie ein Mensch.** Sie sind abgeschaltet (`Sounds.BABBLE`), bis es eine bessere Stimme gibt.
- **Figuren drehen sich mit einem kleinen Hüpfer** statt das Bild durch null zu stauchen; das Stauchen zeigte sie als flache Bilder, beim Kind besonders (Jan, 2026-10-14).
- **Die Spieluhr klingt genau richtig (Jan, 2026-10-14)** und bleibt so.
- **Klänge haben einen eigenen Bus und Regler** („Klänge“ auf der Pause-Seite). Errechnet sind auch: eine Flamme, die fängt (mit Funken im Bild), Einsicht, Fehlgriff, Umblättern, ein Stück wird heil.
- **Die Spieluhr spielt.** Ihre Melodie ist errechnet (eine Spieluhr lässt sich gut nachbauen) und wird im Raum zur Musik, sobald sie aufgezogen ist (`music_if` in der Weltdatei). Sie ist ein Vorschlag für das Leitmotiv; zu den generierten Stücken passt sie noch nicht.
- **Ein Stück wird heil:** Das Licht schwillt stärker an, ein Klang ertönt und Lichtpunkte steigen über das ganze Bild, erst nachdem gesagt ist, was gesagt wird.

## 5. Stil und Weltaufbau

### Entschieden

- **Stil:** Gemalt und illustrativ, mittlerer Detailgrad. Objekte müssen einzeln klar erkennbar sein. Kein Fotorealismus, keine überladenen Bilder.
- **Richtung:** Old Man's Journey, Carto, The Gardens Between.
- **Eher schlicht:** Der erste Test-Sprite (Laterne mit Holzmaserung, Nieten, Rost) war Jan zu detailliert. Materialien werden über Farbe und Form angedeutet, nicht über Textur. Die Stilvorgabe für alle Bild-Prompts steht zentral in `tools/style.py`.
- **Welt als schwebendes Diorama:** Jede Welt ist ein Bruchstück. Die Stücke können sich im Notizbuch sichtbar zusammensetzen.
- **Aufbau in Ebenen:**
  - *Untergrund:* ein gemaltes Bild pro Welt, in allen Varianten pixelgleich.
  - *Objekte:* etwa 30 bis 60 einzeln generierte Sprites pro Welt im selben Stil, gezielt gesetzt, verschoben oder weggelassen.
  - *Stimmung:* Licht und Farbe per Shader, pro Variante regelbar.
- **Wiederverwendung:** Objekte tauchen bewusst in anderen Welten wieder auf (dieselbe Laterne in einer fremden Welt).
- **Raster:** 20x20 Felder als unsichtbares Logikraster über dem Bild.
- **Querformat:** Das Spiel läuft im Querformat (1920x1080 als Basis, dreht sich mit dem Gerät in beide Querlagen). Es hilft der Immersion, und im Hochformat bliebe zu viel leerer Platz.
- **Kaum UI:** Die Welt füllt den Bildschirm. Bedienelemente sind auf das Nötigste reduziert.
- **Kamera:** Ausschnitt von rund 8 bis 10 Feldern, Herauszoomen für den Überblick. Komplett herausgezoomt wäre ein Feld auf dem Handy nur etwa 50 Pixel breit.

### Verworfen

- **Grafik rein per Code:** konsistent, aber zu steril für ein Spiel, das von Atmosphäre lebt.
- **„Falsche“ Variante per Bild-Editing des Gesamtbildes:** Bildmodelle verändern dabei unbeabsichtigt Kleinigkeiten im ganzen Bild. Das verletzt die Grundregel aus Abschnitt 4.
- **Welten aus hunderten Einzelkacheln:** Bildmodelle halten Stil und Rasterpassung über so viele Kacheln nicht zuverlässig.

## 6. Musik und Ton

- **Ein Stück pro Welt**, erzeugt mit einem Musikgenerator.
- **Gemeinsames Leitmotiv:** In jeder Welt ist es zerbrochen und setzt sich beim Reparieren zusammen.
- **„Falsche“ Varianten:** leicht verstimmt oder mit fehlender Stimme, per Code aus den Spuren gemischt.
- **Stufenweise Reparatur:** Die Musik wird mit jeder Teilreparatur normaler. Dafür braucht jedes Stück getrennte Spuren (Stems), die einzeln ein- und ausgeblendet oder verstimmt werden können. Das ist eine Anforderung an die Wahl des Musikgenerators.
- Kommerzielle Nutzungsrechte und API-Zugang müssen vor der Wahl des Anbieters geprüft werden.

## 7. Generierungsmodelle (Recherche vom 2026-10-11)

Preise und Bedingungen ändern sich schnell. Vor einem Abo oder einem Release die Anbieterseiten erneut prüfen. Noch nichts davon ist von Jan entschieden; es sind Claudes Empfehlungen.

### Bild

| Modell | Stärke für uns | Schwäche | Preis |
|---|---|---|---|
| **OpenAI GPT Image 2.5** (`sunburst` für präzises Editing, `flare` für schnelle Generierung) | Transparenter Hintergrund direkt aus dem Modell, mehrere Referenzbilder, bis 4K | Preis nur tokenbasiert angegeben ($30 pro 1 Mio. Bild-Output-Tokens), Kosten pro Bild nicht geprüft | offen |
| **Google Nano Banana 2.1** | Bis zu 14 Referenzbilder, günstig, bis 4K | Transparenz nicht dokumentiert (Freistellen als Extraschritt), unsichtbares SynthID-Wasserzeichen in jedem Bild | $0,034 (1K), $0,05 (2K), $0,113 (4K) |
| **Recraft V4.1** | Eigener Stil aus Referenzbildern als wiederverwendbare Stil-ID, Freistellen als API-Aufruf | Nutzungsrechte nicht geprüft | $0,035 pro Bild, Freistellen $0,01 |
| **Scenario** | Eigenes Stilmodell, trainiert auf 15 bis 50 eigenen Bildern | Lohnt erst, wenn der Stil feststeht; Preise widersprüchlich | ab $0,004 pro Bild laut Anbieter |
| **PixelLab / Retro Diffusion** | Spezialisten für Pixel-Art inklusive Lauf-Animationen in 4 oder 8 Richtungen | Nur Pixel-Art, maximal etwa 400x400 | etwa $0,01 pro Bild |

Ausgeschieden: Midjourney (keine offizielle API).

**Empfehlung:** Den Stiltest mit GPT Image 2.5 und Nano Banana 2.1 nebeneinander fahren, dazu PixelLab oder Retro Diffusion für die Pixel-Art-Vergleichsvariante. Transparenz ist für die Objekt-Ebene entscheidend, deshalb ist GPT Image der Favorit. Scenario oder Recraft kommen erst ins Spiel, wenn der Stil feststeht und die Konsistenz über viele Objekte nicht reicht.

**Erprobt am 2026-10-11 mit GPT Image 2.5 (`sunburst`):**

- Ein Bild kostet rund 5 Cent (1024x1024 in hoher Qualität), das Bodenbild in 2560x1440 rund 7 Cent.
- **Bodenbild aus Lageplan:** `tools/world_plan.py` zeichnet aus der Weltdatei einen flachen Lageplan in der Projektion des Spiels. Das Modell malt ihn aus und hält sich dabei fast pixelgenau an die Vorlage, sodass das Bild ohne Nacharbeit unter dem Logikraster liegt.
- **Stil-Konsistenz:** Fünf Objekte, einzeln erzeugt mit dem Bodenbild als Stilreferenz, passen in Stil, Perspektive und Licht zueinander und zum Boden.
- **Transparenz:** Hintergründe sind sauber freigestellt. Die Deckkraft im Objekt ist nicht ganz voll und wird von `tools/crop_sprites.py` gestreckt.
- **Schwäche:** Proportionen lassen sich über den Prompt nur grob steuern. Die Brücke wurde zu lang und zu schmal für den ein Feld breiten Bach.

### Musik

| Modell | Stärke für uns | Schwäche | Preis |
|---|---|---|---|
| **ElevenLabs Music v2.5** | API, bis 5 Minuten, WAV, instrumental, Aufbau über „Composition Plans“ steuerbar, Stem-Trennung in 2, 4 oder 6 Spuren, mit lizenzierten Daten trainiert | Spielelizenz an Umsatzgrenzen gebunden (siehe unten) | etwa $0,15 pro Minute, Quellen widersprechen sich |
| **Google Lyria 3.5** | Sehr günstig, API, WAV | Keine Stems, SynthID-Wasserzeichen, Länge nur „ein paar Minuten“, Nutzungsrechte nicht geprüft | $0,08 pro Stück |
| **Mureka** | Stem-Trennung in 5 oder 12 Spuren per API | Trainingsdaten nicht offengelegt, Rechtslage unsicherer | 5 Spuren $0,06 pro Stück |

Ausgeschieden: Suno (keine offizielle API, Download-Limits), Udio (kein Export mehr).

**Empfehlung:** ElevenLabs Music.

**Lizenz ElevenLabs:** Auf den normalen Bezahlplänen ist kommerzielle Nutzung in einem „Indie Game“ erlaubt. Das ist ein Spiel mit weniger als $500.000 Umsatz seit Release, dessen Entwickler im letzten Geschäftsjahr weniger als $1.000.000 mit Spielen umgesetzt hat. Darüber braucht man innerhalb von 60 Tagen einen Enterprise-Plan. Ob die getrennten Stems dieselben Rechte haben wie das ganze Stück, steht in den Bedingungen nicht ausdrücklich.

**Zu den Stems:** Die Stem-Trennung stammt aus einer Suchzusammenfassung, nicht aus der geprüften Doku, und ihre Qualität bei ruhiger Ambient-Musik ist ungetestet. Ein Teil der „falschen“ Wirkung braucht keine Stems: Verstimmen, Filtern oder Rückwärtslaufen geht in Godot direkt auf dem ganzen Stück.

### Nutzungsrechte (geprüft am 2026-10-13, keine Rechtsberatung)

Tatsächlich benutzt sind: für alle Bilder OpenAI GPT Image über die API, für alle sechs Musikstücke Google Lyria über die Gemini API (nicht ElevenLabs, anders als oben empfohlen). Das Grollen des Risses, die übrigen Klänge, die Stimmen, die Spieluhr und das App-Symbol sind selbst errechnet oder aus eigenen Bildern zusammengesetzt. Die Handschrift im Notizbuch ist Caveat von Google Fonts unter der SIL Open Font License 1.1 (Lizenztext in `assets/fonts/Caveat-OFL.txt`); sie darf mit dem Spiel weitergegeben und verkauft werden, nur nicht für sich allein.

- **Bilder (OpenAI):** Nach dem Services Agreement (Stand 1. Januar 2026) gehört die Ausgabe dem Kunden, OpenAI tritt eigene Rechte daran ab. Kommerzielle Nutzung ist damit erlaubt. Die Service Terms stellen API-Kunden von Ansprüchen Dritter wegen der Ausgabe frei, mit Ausnahmen (unter anderem, wenn die Ausgabe verändert oder mit Fremdem kombiniert wurde; unsere Bilder sind zugeschnitten und nachbearbeitet). Ausgaben sind nicht exklusiv.
- **Musik (Google Lyria):** Die Zusatzbedingungen der Gemini API (Stand 23. März 2026) sagen, dass Google kein Eigentum an erzeugten Inhalten beansprucht und der Nutzer für deren Verwendung verantwortlich ist. Eine ausdrückliche Erlaubnis zur kommerziellen Nutzung und eine Freistellung stehen dort nicht. Jedes Stück trägt ein unhörbares SynthID-Wasserzeichen. Wer Nutzer im EWR bedient, darf nur die bezahlte Stufe der API verwenden.
- **Schutz der eigenen Inhalte:** Rein generierte Bilder und Musik sind nach heutigem Stand in Deutschland nur geschützt, soweit ein Mensch sie erkennbar gestaltet hat; die Gerichte sind sich über die Schwelle nicht einig. Andere könnten einzelne Bilder oder Stücke also womöglich übernehmen, ohne dass sich das verbieten lässt. Code, Texte und Weltdateien sind davon nicht betroffen.
- **Offen:** ob der Google-Schlüssel auf der bezahlten Stufe lief (Jan), die genauen Store-Regeln zur Kennzeichnung generierter Inhalte zum Zeitpunkt der Veröffentlichung, und vor einem öffentlichen Verkauf ein Blick einer Fachperson auf die Musik-Bedingungen.

### Benötigte Zugänge

- OpenAI-API-Key
- Google-AI-Studio-API-Key
- ElevenLabs-Bezahlplan mit API-Zugang (ab „Starter“)
- Optional für die Pixel-Art-Variante: PixelLab oder Retro Diffusion

Keys gehören in eine lokale `.env`-Datei, die nicht ins Repository kommt.

## 8. Technik

### Entschieden

- **Engine: Godot 4.** Exportiert nativ nach Android und iOS. Szenen und Skripte sind lesbare Textdateien, alles läuft per Kommandozeile, auch headless.
- **Spiellogik strikt getrennt vom Rendering** und deterministisch, damit komplette Durchläufe ohne Grafik simulierbar sind.
- **Welten, Dialoge und Rätsel als Datendateien**, nicht im Code verdrahtet.
- **Code auf Englisch:** Quellcode, Kommentare, Datei- und Ordnernamen sowie die Schlüssel in Datendateien sind englisch. Dieses Konzept und die Abstimmung mit Jan bleiben deutsch.
- **Stimmung als Regler:** Jede Welt hat eine heile und eine falsche Stimmung (`mood`, `mood_wrong` in der Weltdatei). Regler sind Windrichtung, Fließrichtung und Stand des Wassers, Schattenrichtung, Sättigung, Farbstich, Dunst, Helligkeit der Lichter sowie Tonhöhe und Dämpfung der Musik. Das Spiel blendet stufenlos zwischen beiden über. Die Effekte selbst macht die Engine per Shader, nicht das Bild.
- **Falsche Musik leiert (Jan, 2026-10-13):** Die erste Fassung klang nicht falsch genug. Die falschen Stimmungen liegen jetzt tiefer und dumpfer, und Musik, die neben der richtigen Tonhöhe liegt, schwankt zusätzlich um sie herum wie ein Band, das ungleichmäßig läuft, umso stärker, je weiter sie daneben liegt. Mit der Tonhöhe kommt auch der ruhige Lauf zurück.
- **Ein offener Weg leuchtet von selbst:** Das Licht in einem offenen Bogen folgt nicht der Stimmung der Welt wie das der Laternen. Es ist heller, größer und atmet langsam, damit man auch im dunklen, kaputten Stück sieht, dass der Bogen trägt. Es geht nicht schlagartig an, sondern steigt über knapp zwei Sekunden; die Flamme einer Laterne fängt in einer halben Sekunde (`shimmer` in `data/sprites.json`).
- **Eine Aufgabe je Gespräch (Jan, 2026-10-13):** Eine Figur gibt nicht zwei Aufgaben auf einmal. Der Müller spricht zuerst nur von der Kurbel; von der Wetterfahne und seinem Platz erst, wenn die Mühle rückwärts läuft. Bis dahin lässt sich die Fahne nicht drehen und sein Platz zeigt keine Erinnerung.
- **Der Wasserstand ist ein Regler (Jan, 2026-10-13):** Neben der Fließrichtung hat das Wasser einen Stand (`level`, 1 voll, 0 trocken). Sinkt er, legt ein Shader das Bett frei, vom Ufer nach innen: Ein schmaler Bach ist längst trocken, wenn in der Mitte eines Weihers noch Wasser steht. Der Boden bleibt dabei dasselbe Bild. Das Wehr an der Quelle bringt den Stand in Dorf, Quelle und Weiher zurück.
- **Die App beginnt mit einer Blende (Jan, 2026-10-13):** Der Startbildschirm der Engine, der Hinweis auf Kopfhörer und die erste Blende haben dieselbe dunkle Farbe. Das Spiel kommt daraus langsam hervor, statt hart einzusetzen.
- **Ein neues Spiel beginnt mit einer Blende:** Das Bild wird dunkel und kommt zurück, die Musik setzt neu ein. Ohne das sah ein Neubeginn im Haus des Alten aus, als sei nichts geschehen.
- **Das App-Symbol kommt aus dem Spiel:** die schwebende Warte mit einem offenen, leuchtenden Bogen unter einem Abendhimmel, zusammengesetzt aus vorhandenen Bildern, nicht eigens generiert.
- **Was den Besitzer wechselt, wird gezeigt (Jan, 2026-10-13):** Steckt die Figur etwas ein oder gibt sie etwas ab, steht das als blasse Randnotiz in der Ecke des Dialogfelds, neben dem Namen: „+ Kurbel“ oder „− Kurbel“, solange der Satz dazu zu sehen ist. Der Text allein hat nicht klargemacht, dass man die Kurbel jetzt hat. Ein eigenes Schild am oberen Rand war zu aufdringlich und sah nach Inventar aus, das es nicht gibt. Das gilt für jede Regel mit `give` oder `take`, auf die ein `say` folgt.
- **Der Wehrwärter an der Quelle (Jan, 2026-10-13):** Die Quelle war ein Stück zum Durchlaufen, und für den Hinweis auf die Warte lief man vom Weiher bis zum Alten ins Dorf zurück. Jetzt steht am Wehr ein Wehrwärter. Ihm fällt die Warte ein, sobald der Spieler vom großen Licht erzählt, er gibt den Docht und sagt, dass es nur übers Wasser dorthin geht. Der Bogen zur Warte steht deshalb am Ufer der Fischerin, hinter der Bootsfahrt. Der Alte behält sein Bruchstück vom Riss und verweist ans Wehr. Sein Rätsel sind drei Schieber über dem Wehr: Wer neben ihm verweilt, sieht, wie sie am Morgen standen, und stellt sie selbst so ein. Das ist die erste Erinnerung, die einen Zustand zum Ablesen zeigt statt eines Platzes. Erst wenn sie stehen, gibt das Rad des Wehrs nach; damit ist die Quelle nicht mehr mit einem Tipp heil. Halb gestellte Schieber fallen zurück, wenn der Spieler die Quelle verlässt (das hält auch die Zahl der Spielzustände klein).
- **Kein Schritt, der erst einmal schadet (Jan, 2026-10-13):** Das Wehr ließ sich sofort öffnen und meldete die Quelle als heil, obwohl das Wasser dann den einzigen Weg zum Weiher versperrte und man es wieder schließen musste. Ein Schritt, der zu früh nur schadet, ist gesperrt, bis er Sinn ergibt, und die Figur sagt, warum sie ihn lässt. Das Wehr öffnet sich erst, wenn die Fischerin von ihrem Licht erzählt hat und die Laterne auf der Insel brennt; der Grund kommt damit aus ihrem Gespräch und nicht aus einem Selbstgespräch am Wehr.
- **Figuren haben einen Abendplatz und einen Platz der Erinnerung (Jan, 2026-10-13):** Die kaputte Welt soll deutlicher von der alten abweichen, als nur im Gefühl; nach einem großen Bruch und langer Zeit stand alles an derselben Stelle, sogar die Figuren. Erster Schritt: Vor dem Riss leben die Figuren ihren Abend an einem eigenen Platz. Nach dem Riss stehen sie dort, wo für sie etwas zurückkommt, und wo man neben ihnen verweilen kann. Wird ihr Stück heil, kehren sie an den Abendplatz zurück; das ist der sichtbare Lohn des Heilwerdens. Häuser werden nicht umgestellt: Der gemalte Boden führt zu ihren Türen, und zu viele Abweichungen ohne Aufgabe verletzen die Grundregel, dass jeder Unterschied Absicht ist.
- **Der Wind ist zu sehen, und Heuwagen statt Steine (Jan, 2026-10-13):** Dass ein Stein eine Laterne vor dem Wind schützt, erklärte sich nicht: Er war dafür sichtlich zu klein. Jetzt steht dort ein beladener Heuwagen, der hoch genug ist und glaubhaft rollt (zuerst als gezeichneter Platzhalter beurteilt, dann als ein Bild generiert). Der Wind selbst zieht als feine Streifen durchs Bild, in Richtung und Stärke der Stimmung; hinter Wagen und Häusern liegt ihr Windschatten, dort gibt es keine Streifen. Der richtige Wind der heilen Welt ist nur halb so deutlich wie der falsche.
- **Spiegeln als Daten:** Ein Objekt mit `"mirrored": true` wird gespiegelt gezeigt, ohne neues Bild.
- **Eine Welt, zwei Fassungen:** Die Weltdatei beschreibt die heile Fassung. Die kaputte Fassung ist eine Liste von Abweichungen an einzelnen Objekten (`broken`). Der Boden ist dadurch immer derselbe.
- **Fehler bestimmen die Stimmung:** Jede Welt nennt ihre Fehler (`faults`) mit der Bedingung, wann sie behoben sind, und den Reglern, die sie zurückbringen. Regler, die keinem Fehler gehören, folgen dem Anteil der offenen Fehler. Innenräume teilen die Stimmung ihrer Welt.
- **Regeln als Daten:** Was beim Benutzen eines Objekts, beim Betreten einer Zelle oder beim Verweilen passiert, steht als Regel mit Bedingungen und Folgen in der Weltdatei. Folgen dürfen in andere Welten reichen. Türen und Portale sind Regeln mit einem Ziel.
- **Ein zentraler Spielspeicher:** Ort der Figur, Fakten, Abweichungen der Objekte je Welt, Gegenstände und Notizen. Er wird nach jeder Änderung lokal gespeichert.
- **Lösbarkeit wird durchgespielt:** Ein Prüfer geht alle Zustände durch, die das Spiel annehmen kann, und meldet jeden, aus dem es nicht mehr zu Ende gespielt werden kann.
- **Verweilen zeigt die Erinnerung:** Bleibt die Figur an einem Ort der Erinnerung stehen, erscheint langsam, was gerade anders ist, durchscheinend so, wie es einmal war, und Farbe und Musik nähern sich der heilen Welt. Ein Tipp beendet das. So zeigt die Erinnerung, was falsch ist, ohne eigene Schaltfläche. Wo das geht, steht als Daten in der Weltdatei (siehe Abschnitt 4, „Verweilen ist selten und hat einen Ort“).
- **Die Erinnerung zeigt nur einen Teil, und nur etwas richtiger (Jan, 2026-10-12):** Ein Ort der Erinnerung (`memories` in der Weltdatei) nennt den Ausschnitt der Welt, der durchscheint. Eine Verweil-Regel mit der Folge `remember` legt fest, wo die Figur dafür stehen muss. Im Ausschnitt erscheint, was dort anders ist, durchscheinend so, wie es war, und nur dort nähern sich die Farben der heilen Welt, mit weichem Rand. Die Musik hat keinen Ort und neigt sich als Ganzes ein wenig. Das bleibt, bis sich die Figur wieder bewegt. Die Erinnerung ändert nichts am Spielstand.
- **Wo nichts mehr anders ist, gibt es keine Erinnerung (Jan, 2026-10-13):** Hat die Welt keinen offenen Fehler mehr und ist im Ausschnitt nichts mehr anders als früher, zeigt das Verweilen dort nichts. Eine Verweil-Regel mit `remember` feuert dann nicht, auch ihre übrigen Folgen nicht. Der Steg am Weiher zeigt deshalb weiter das ferne Licht, solange es nicht brennt, obwohl der Weiher schon heil ist.
- **Das Notizbuch ist ein aufgeschlagenes Buch** (ein generiertes Bild): links die Karte, rechts die Zettel in Handschrift (Caveat, frei unter der SIL Open Font License). Ein Tipp öffnet einen Zettel zum Lesen, Ziehen legt ihn woanders hin oder auf einen anderen. Es nimmt jede Berührung, solange es offen ist (außer am Pause-Knopf und während jemand spricht).
- **Das Buch hat Seiten (Jan, 2026-10-14):** Die Zettel sammelten sich unten aus der Seite heraus, wo man sie nicht mehr sah. Jetzt liegen acht auf einer Seite; Pfeile am Fuß der Seite oder ein Wischen quer darüber blättern, ein roter Pfeil zeigt eine Seite mit Neuem. Ein Zettel, den man am Rand der Seite festhält, blättert um, damit sich Zettel verschiedener Seiten zusammenziehen lassen. Das Buch öffnet auf der letzten Seite, dort liegt das Neueste.
- **Die Karte zeigt die Weltstücke als kleine Bilder ihres Bodens** statt gezeichneter Inseln (Jan, 2026-10-14).
- **Solange das Buch offen ist, bleibt die Figur stehen** (Jan, 2026-10-14): Lief sie weiter, konnte hinter dem Buch ein Gespräch beginnen, das sich nicht wegtippen ließ. Spricht doch jemand, nimmt der Dialog die Berührungen.
- **Figuren aus Bildbögen:** Ein Bildmodell liefert zu einem Standbild einen Bogen mit vier Schritt-Bildern derselben Figur, wenn es das Standbild als Vorlage bekommt. Ein Skript schneidet den Bogen und richtet die Bilder an Kopf und Füßen aus. Zwei Ansichten (vorn, hinten) reichen, gespiegelt ergeben sie alle vier Laufrichtungen.
- **Welten reagieren aufeinander:** Regeln mit dem Auslöser `always` feuern von selbst, sobald ihre Bedingungen gelten, auch wenn die Ursache in einer anderen Welt liegt (die Mühle dreht sich, also treibt das Floß an der Quelle zurück).
- **Bewegte Teile aus zwei Bildern:** Die Mühlenflügel sind ein eigenes, von vorn gemaltes Bild, das die Engine in die Wandebene legt und dreht.
- **Texte je Sprache:** Alle sichtbaren Texte stehen in Sprachdateien (Deutsch und Englisch), Regeln nennen nur Schlüssel.
- **Regeln werden geprüft, bevor sie laufen:** Ein Prüfer liest alle Regeln, Fehler und Startfolgen und meldet jeden Schlüssel und jeden Namen, den das Spiel nicht kennt. Ohne ihn wirkt ein Tippfehler still: Eine falsch geschriebene Bedingung gilt nie, eine falsch geschriebene Folge tut nichts. Die Prüfung läuft im Test und beim Start eines Debug-Baus.
- **Erreichbarkeit gehört zur Logik:** Ein Objekt lässt sich nur von einer Zelle aus benutzen, von der es erreichbar ist. Das entscheidet die Spiellogik, nicht die Ansicht.
- **Bildmaße als Daten:** Wie ein Bild in der Welt sitzt, steht in einer Datendatei, die das Spiel und die Bildwerkzeuge gemeinsam lesen.
- **Oberfläche mit Godots eigenen Mitteln:** Dialog, Notizbuch und Startbildschirm bestehen aus Controls mit einem gemeinsamen Theme. Was offen ist, fängt alle Tipps ab, damit keiner zusätzlich in der Welt ankommt. Nur der erste Finger zählt.
- **Ein unlesbarer Spielstand wird aufgehoben:** Kann das Spiel einen Stand nicht lesen, legt es ihn beiseite und beginnt neu, statt ihn zu überschreiben. Änderungen an Welten oder Objekten, die es nicht mehr gibt, fallen beim Laden weg.
- **Eine heile Welt gibt sich zu erkennen (Jan, 2026-10-13):** Ist der letzte Fehler einer Welt behoben, meldet die Spiellogik das. Ein Schriftzug („… ist wieder heil“) war fehl am Platz und ist gestrichen. Stattdessen zeigt es die Welt selbst: Die Stimmung ist ganz zurück, die Figuren stehen wieder an ihren Abendplätzen, warmes Licht schwillt kurz über das Bild, und beim ersten Mal, das der Spieler im heilen Stück ist, sagt dort jemand, dass es plötzlich wie früher ist und dass er sich erinnert (`whole_says` in der Weltdatei; wo niemand lebt, sagt es die eigene Figur). Wurde ein Stück aus der Ferne heil, kommt der Satz bei der Rückkehr. Im Notizbuch zeigt jedes Weltstück weiterhin einen Punkt je Fehler.
- **Eine Pause-Seite, sonst nichts:** Ein kleiner Knopf oben links hält das Spiel an und öffnet eine Seite mit Lautstärke der Musik, Sprache, „Neu beginnen“ (mit Rückfrage) und „Weiter“. Die Zurück-Geste des Handys öffnet dieselbe Seite, eine zweite verlässt das Spiel. Es gibt bewusst keinen Knopf „Spiel verlassen“ (auf dem Handy verlässt man eine App über das System) und nur einen einzigen, automatisch gespeicherten Spielstand: In einem Spiel ohne Sackgassen braucht es keine Stände zum Zurückspringen, und der spätere Abgleich mit Google Play bleibt einfach. Lautstärke und Sprache liegen in einer eigenen Datei und überdauern ein neues Spiel.
- **Ein Ortswechsel hat eine Reihenfolge (Jan, 2026-10-12):** Was eine Regel vor dem Wechsel sagt, wird erst zu Ende gehört; was sie danach sagt, kommt bei der Ankunft. Der Wechsel selbst ist eine kurze Blende oder, wenn die Regel ein Fahrzeug nennt, eine sichtbare Fahrt. Ein Schnitt mitten im Satz hat verwirrt.
- **Der Riss ist eine Szene (Jan, 2026-10-13):** Tritt der Spieler am Abend aus der Tür, wackelt das Bild immer stärker, die Musik wird langsamer und tiefer und verklingt, es grollt, und das Bild wird dunkel. Nach einer Weile kehrt das Licht langsam zurück: Die Figur liegt im kaputten Dorf am Weg, sagt, was sie spürt, und steht dann auf. Erst danach lässt sie sich wieder steuern. Die Regel nennt dafür am Ortswechsel `"as": "quake"`; den Ablauf selbst macht die Ansicht. Das Grollen ist aus Rauschen errechnet, nicht generiert.
- **Das Ende steht in der Spieldatei:** `data/game.json` nennt die Bedingung, unter der das Spiel zu Ende ist (`complete_if`). Die Lösbarkeitsprüfung sucht den Weg dorthin. Ohne die Angabe ist das Spiel zu Ende, wenn keine Welt mehr einen offenen Fehler hat; das taugt nicht mehr, seit das Spiel im heilen Dorf beginnt.
- **Was noch kein Bild hat, wird gezeichnet:** Ein Objekt ohne Bild und eine Welt ohne Bodenbild erscheinen als einfache Flächen. So lässt sich Inhalt im Spiel beurteilen, bevor er generiert wird.
- **Alte Spielstände passen nicht zu neuen Kapiteln:** Mit dem Tal hat der Spielstand die Formatversion 2 bekommen, mit dem Notizbuch als Rätsel die 3 (alten Ständen fehlen Notizen, von denen Wege jetzt abhängen). Ältere Stände werden beiseitegelegt, das Spiel beginnt neu.
- **Test-Hilfen nur in Debug-Bauten:** Kommandozeilen-Argumente und die Tasten zum Ausprobieren wirken in einem Release-Bau nicht.

### Verworfen

- **Web-Stack (TypeScript, Phaser/PixiJS, Capacitor):** für Claude am einfachsten zu testen, aber kein natives Gefühl und schwächer bei Atmosphäre.
- **Unity:** Industriestandard für dieses Genre, aber stark auf Klicks im Editor ausgelegt und mit Lizenzmodell.

### Vorhandene Werkzeuge (Jans Rechner, Windows 11)

Node 26, Python 3.14, Git, Docker, Cargo, `adb`.

### Fehlt noch

- Godot 4
- API-Keys für Bild- und Musikmodelle (siehe Abschnitt 7)
- Für den Android-Build: JDK und Android SDK
- Für iOS: Mac und Apple-Developer-Account

## 9. Arbeitsteilung

### Claude

Die gesamte kreative und aufwändige Arbeit:

- **Welten und Rätsel:** Entwurf als Daten, automatische Prüfung auf Lösbarkeit.
- **Story und Dialoge:** Story-Bibel (Geheimnis, Welten, Figuren, Verbindungen), Dialoge als Daten.
- **Grafik:** Prompts schreiben, generieren, ansehen, aussortieren, nachbearbeiten (Zuschnitt, Palettenangleichung), Shader.
- **Musik:** Prompts schreiben, Varianten generieren, Spuren mischen.
- **Code und Tests.**

### Jan

- Richtung und Geschmacksentscheidungen.
- Alles, was Claude nicht beurteilen kann: Spielgefühl, Touch-Ergonomie, ob ein Rätsel Spaß macht.
- Musik und Ton nach Gehör auswählen. Claude kann nicht hören und nur Pegel und Spektrum prüfen.
- Accounts, API-Keys und Budget bereitstellen.

## 10. Testen

- **Logik:** Durchläufe ohne Grafik, headless in Godot.
- **Lösbarkeit:** Ein Solver prüft für jede Welt und jede Kombination von Weltzuständen, dass sie lösbar ist und keine Sackgasse entsteht.
- **Optik:** Godot rendert Screenshots im Handy-Format, Claude sieht sie sich an.
- **Echtes Gerät:** Screenshots und Eingaben per `adb` auf einem Android-Handy.

## 11. Offene Punkte

- **Name:** „Everwild“ hieß ein angekündigtes Spiel von Rare/Microsoft. Für einen Release braucht es einen anderen Namen.
- **Stil-Konsistenz:** Für fünf Objekte und ein Bodenbild bestätigt (Abschnitt 7). Offen ist, ob sie über 30 und mehr Objekte und über mehrere Welten hält.
- **Verdeckung:** Hohe Objekte wie Häuser verdecken Wege und die Figur dahinter. Braucht eine Lösung, etwa Objekte durchscheinend machen, wenn die Figur dahinter steht.
- **Figuren-Animation:** Der schwierigste Teil bei generierter Grafik. Lösung offen (wenige Frames, kleine Figur).
- **Modellauswahl:** Recherchiert (Abschnitt 7), aber noch nicht entschieden. Die Nutzungsrechte der tatsächlich benutzten Dienste (OpenAI für Bilder, Google Lyria für Musik) sind geprüft, siehe Abschnitt 7. Ungeprüft sind die Stem-Trennung von ElevenLabs und ihre Lizenz, falls die Musik später in Schichten entstehen soll.
- **Story:** Das Grundgerüst steht (Abschnitt 3). Offen sind: was den Bruch auslöst, wer der Spieler ist und warum ihn Fremde kennen (hat er selbst etwas vergessen?), ob der alte Mann beim Bruch eine Rolle spielt, wie das Spiel endet und welche Bruchstücke es gibt.
- **Umfang:** Anzahl der Welten für eine erste Version.

## 12. Nächste Schritte

1. ~~Bild- und Musikmodelle recherchieren~~ (erledigt, siehe Abschnitt 7). Jan entscheidet über die Auswahl.
2. Godot 4 installieren, API-Keys einrichten.
3. **Stiltest:** eine kleine Welt in zwei bis drei Stilrichtungen (darunter eine Pixel-Art-Variante zum Vergleich), jeweils mit ihrer „falschen“ Fassung. Jan sieht sie sich auf dem Handy an und entscheidet.
4. **Durchstich:** eine Welt plus ihre falsche Variante, ein Erinnerungs-Rätsel, ein Portal, ein NPC, das Notizbuch, ein Musikstück. Inhalt: das Tutorial-Dorf als heile Welt und dasselbe Dorf als erstes kaputtes Bruchstück, mit dem alten Mann als NPC.
5. Erst danach Inhalt in die Breite bauen.

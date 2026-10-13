# Everwild – Konzept und Entscheidungen

Stand: 2026-10-12. „Everwild“ ist ein Arbeitstitel (siehe Offene Punkte).

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
- **Stimmung als Regler:** Jede Welt hat eine heile und eine falsche Stimmung (`mood`, `mood_wrong` in der Weltdatei). Regler sind Windrichtung, Fließrichtung des Wassers, Schattenrichtung, Sättigung, Farbstich, Dunst, Helligkeit der Lichter sowie Tonhöhe und Dämpfung der Musik. Das Spiel blendet stufenlos zwischen beiden über. Die Effekte selbst macht die Engine per Shader, nicht das Bild.
- **Spiegeln als Daten:** Ein Objekt mit `"mirrored": true` wird gespiegelt gezeigt, ohne neues Bild.
- **Eine Welt, zwei Fassungen:** Die Weltdatei beschreibt die heile Fassung. Die kaputte Fassung ist eine Liste von Abweichungen an einzelnen Objekten (`broken`). Der Boden ist dadurch immer derselbe.
- **Fehler bestimmen die Stimmung:** Jede Welt nennt ihre Fehler (`faults`) mit der Bedingung, wann sie behoben sind, und den Reglern, die sie zurückbringen. Regler, die keinem Fehler gehören, folgen dem Anteil der offenen Fehler. Innenräume teilen die Stimmung ihrer Welt.
- **Regeln als Daten:** Was beim Benutzen eines Objekts, beim Betreten einer Zelle oder beim Verweilen passiert, steht als Regel mit Bedingungen und Folgen in der Weltdatei. Folgen dürfen in andere Welten reichen. Türen und Portale sind Regeln mit einem Ziel.
- **Ein zentraler Spielspeicher:** Ort der Figur, Fakten, Abweichungen der Objekte je Welt, Gegenstände und Notizen. Er wird nach jeder Änderung lokal gespeichert.
- **Lösbarkeit wird durchgespielt:** Ein Prüfer geht alle Zustände durch, die das Spiel annehmen kann, und meldet jeden, aus dem es nicht mehr zu Ende gespielt werden kann.
- **Verweilen zeigt die Erinnerung:** Bleibt die Figur an einem Ort der Erinnerung stehen, erscheint langsam, was gerade anders ist, durchscheinend so, wie es einmal war, und Farbe und Musik nähern sich der heilen Welt. Ein Tipp beendet das. So zeigt die Erinnerung, was falsch ist, ohne eigene Schaltfläche. Wo das geht, steht als Daten in der Weltdatei (siehe Abschnitt 4, „Verweilen ist selten und hat einen Ort“).
- **Die Erinnerung zeigt nur einen Teil, und nur etwas richtiger (Jan, 2026-10-12):** Ein Ort der Erinnerung (`memories` in der Weltdatei) nennt den Ausschnitt der Welt, der durchscheint. Eine Verweil-Regel mit der Folge `remember` legt fest, wo die Figur dafür stehen muss. Im Ausschnitt erscheint, was dort anders ist, durchscheinend so, wie es war, und nur dort nähern sich die Farben der heilen Welt, mit weichem Rand. Die Musik hat keinen Ort und neigt sich als Ganzes ein wenig. Das bleibt, bis sich die Figur wieder bewegt. Die Erinnerung ändert nichts am Spielstand.
- **Wo nichts mehr anders ist, gibt es keine Erinnerung (Jan, 2026-10-13):** Hat die Welt keinen offenen Fehler mehr und ist im Ausschnitt nichts mehr anders als früher, zeigt das Verweilen dort nichts. Eine Verweil-Regel mit `remember` feuert dann nicht, auch ihre übrigen Folgen nicht. Der Steg am Weiher zeigt deshalb weiter das ferne Licht, solange es nicht brennt, obwohl der Weiher schon heil ist.
- **Das Notizbuch scrollt:** Liste und Eintrag sind je eine Spalte, die sich per Wischen nach oben und unten bewegt, wenn sie länger ist als die Seite. Ein schmaler Balken am Rand zeigt, wie weit es geht.
- **Figuren aus Bildbögen:** Ein Bildmodell liefert zu einem Standbild einen Bogen mit vier Schritt-Bildern derselben Figur, wenn es das Standbild als Vorlage bekommt. Ein Skript schneidet den Bogen und richtet die Bilder an Kopf und Füßen aus. Zwei Ansichten (vorn, hinten) reichen, gespiegelt ergeben sie alle vier Laufrichtungen.
- **Welten reagieren aufeinander:** Regeln mit dem Auslöser `always` feuern von selbst, sobald ihre Bedingungen gelten, auch wenn die Ursache in einer anderen Welt liegt (die Mühle dreht sich, also treibt das Floß an der Quelle zurück).
- **Bewegte Teile aus zwei Bildern:** Die Mühlenflügel sind ein eigenes, von vorn gemaltes Bild, das die Engine in die Wandebene legt und dreht.
- **Texte je Sprache:** Alle sichtbaren Texte stehen in Sprachdateien (Deutsch und Englisch), Regeln nennen nur Schlüssel.
- **Regeln werden geprüft, bevor sie laufen:** Ein Prüfer liest alle Regeln, Fehler und Startfolgen und meldet jeden Schlüssel und jeden Namen, den das Spiel nicht kennt. Ohne ihn wirkt ein Tippfehler still: Eine falsch geschriebene Bedingung gilt nie, eine falsch geschriebene Folge tut nichts. Die Prüfung läuft im Test und beim Start eines Debug-Baus.
- **Erreichbarkeit gehört zur Logik:** Ein Objekt lässt sich nur von einer Zelle aus benutzen, von der es erreichbar ist. Das entscheidet die Spiellogik, nicht die Ansicht.
- **Bildmaße als Daten:** Wie ein Bild in der Welt sitzt, steht in einer Datendatei, die das Spiel und die Bildwerkzeuge gemeinsam lesen.
- **Oberfläche mit Godots eigenen Mitteln:** Dialog, Notizbuch und Startbildschirm bestehen aus Controls mit einem gemeinsamen Theme. Was offen ist, fängt alle Tipps ab, damit keiner zusätzlich in der Welt ankommt. Nur der erste Finger zählt.
- **Ein unlesbarer Spielstand wird aufgehoben:** Kann das Spiel einen Stand nicht lesen, legt es ihn beiseite und beginnt neu, statt ihn zu überschreiben. Änderungen an Welten oder Objekten, die es nicht mehr gibt, fallen beim Laden weg.
- **Eine heile Welt gibt sich zu erkennen:** Ist der letzte Fehler einer Welt behoben, meldet die Spiellogik das, und das Spiel markiert den Moment: Der Name der Welt erscheint kurz als Schriftzug („Der Mühlenhügel ist wieder heil“), und steht der Spieler in dieser Welt, schwillt warmes Licht über das Bild. Das gilt auch, wenn die Ursache in einer anderen Welt lag. Im Notizbuch zeigt jedes Weltstück einen Punkt je Fehler, gefüllt, sobald er behoben ist. Die Punkte sagen, wie viel noch nicht stimmt, aber nicht was.
- **Eine Pause-Seite, sonst nichts:** Ein kleiner Knopf oben links hält das Spiel an und öffnet eine Seite mit Lautstärke der Musik, Sprache, „Neu beginnen“ (mit Rückfrage) und „Weiter“. Die Zurück-Geste des Handys öffnet dieselbe Seite, eine zweite verlässt das Spiel. Es gibt bewusst keinen Knopf „Spiel verlassen“ (auf dem Handy verlässt man eine App über das System) und nur einen einzigen, automatisch gespeicherten Spielstand: In einem Spiel ohne Sackgassen braucht es keine Stände zum Zurückspringen, und der spätere Abgleich mit Google Play bleibt einfach. Lautstärke und Sprache liegen in einer eigenen Datei und überdauern ein neues Spiel.
- **Ein Ortswechsel hat eine Reihenfolge (Jan, 2026-10-12):** Was eine Regel vor dem Wechsel sagt, wird erst zu Ende gehört; was sie danach sagt, kommt bei der Ankunft. Der Wechsel selbst ist eine kurze Blende oder, wenn die Regel ein Fahrzeug nennt, eine sichtbare Fahrt. Ein Schnitt mitten im Satz hat verwirrt.
- **Das Ende steht in der Spieldatei:** `data/game.json` nennt die Bedingung, unter der das Spiel zu Ende ist (`complete_if`). Die Lösbarkeitsprüfung sucht den Weg dorthin. Ohne die Angabe ist das Spiel zu Ende, wenn keine Welt mehr einen offenen Fehler hat; das taugt nicht mehr, seit das Spiel im heilen Dorf beginnt.
- **Was noch kein Bild hat, wird gezeichnet:** Ein Objekt ohne Bild und eine Welt ohne Bodenbild erscheinen als einfache Flächen. So lässt sich Inhalt im Spiel beurteilen, bevor er generiert wird.
- **Alte Spielstände passen nicht zu neuen Kapiteln:** Mit dem Tal hat der Spielstand die Formatversion 2 bekommen. Ältere Stände werden beiseitegelegt, das Spiel beginnt neu.
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
- **Modellauswahl:** Recherchiert (Abschnitt 7), aber noch nicht entschieden. Ungeprüft sind: Kosten pro Bild bei GPT Image 2.5, Nutzungsrechte an den Bildern bei allen Bildanbietern, die Stem-Trennung von ElevenLabs und ihre Lizenz.
- **Story:** Das Grundgerüst steht (Abschnitt 3). Offen sind: was den Bruch auslöst, wer der Spieler ist und warum ihn Fremde kennen (hat er selbst etwas vergessen?), ob der alte Mann beim Bruch eine Rolle spielt, wie das Spiel endet und welche Bruchstücke es gibt.
- **Umfang:** Anzahl der Welten für eine erste Version.

## 12. Nächste Schritte

1. ~~Bild- und Musikmodelle recherchieren~~ (erledigt, siehe Abschnitt 7). Jan entscheidet über die Auswahl.
2. Godot 4 installieren, API-Keys einrichten.
3. **Stiltest:** eine kleine Welt in zwei bis drei Stilrichtungen (darunter eine Pixel-Art-Variante zum Vergleich), jeweils mit ihrer „falschen“ Fassung. Jan sieht sie sich auf dem Handy an und entscheidet.
4. **Durchstich:** eine Welt plus ihre falsche Variante, ein Erinnerungs-Rätsel, ein Portal, ein NPC, das Notizbuch, ein Musikstück. Inhalt: das Tutorial-Dorf als heile Welt und dasselbe Dorf als erstes kaputtes Bruchstück, mit dem alten Mann als NPC.
5. Erst danach Inhalt in die Breite bauen.

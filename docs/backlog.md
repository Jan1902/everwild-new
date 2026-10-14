# Backlog

Alles, was noch zu bauen oder zu klären ist. Entscheidungen zum Spiel selbst stehen in `concept.md`, hier steht nur die Arbeit.

Die Reihenfolge innerhalb eines Abschnitts ist die vorgeschlagene Reihenfolge der Umsetzung. Erledigtes wird gelöscht, nicht abgehakt (die Historie steht in Git).

## Fundament

Spielspeicher, Regeln je Welt, Stimmung aus dem Zustand, Lösbarkeitsprüfung und lokale Speicherung stehen. Es fehlt:

1. **Speicherung in Google Play.** Spielstand über Google Play Games (Saved Games) sichern und zwischen Geräten abgleichen, mit Regel für Konflikte zwischen lokalem und entferntem Stand.
2. **Alte Spielstände nach Änderungen am Inhalt.** Ein Stand mit anderer Formatversion wird beiseitegelegt und das Spiel beginnt neu; eine Umwandlung alter Stände gibt es noch nicht. Ändert sich eine Welt, liegen alte Abweichungen ungeprüft über der neuen Fassung (nur verschwundene Welten und Objekte fallen weg). Braucht vor dem ersten Bau für andere Spieler eine Inhaltsversion und eine Regel, was mit einem Stand aus einer älteren Fassung geschieht.
3. **Strengere Prüfung des Codes.** Regeln, Folgen und Bedingungen sind weiterhin untypisierte Dictionaries (geprüft von `RuleCheck`). Offen sind strengere GDScript-Warnungen in `project.godot`, ein Formatierer oder Linter (gdtoolkit) und ein Testlauf, der vor jedem Commit von selbst startet.
4. **Kapiteldatei prüfen lassen.** Die Blöcke in `docs/chapters/valley.md` liest noch kein Werkzeug. Gedacht ist eines, das sie durchspielt (keine Sackgasse, jeder Hinweis rechtzeitig, kein Schritt überspringbar, Spielzeit) und mit den Regeln der Weltdateien vergleicht. Bis dahin müssen Datei und Welten von Hand übereinstimmen.
5. **Lösbarkeitsprüfung beschleunigen.** Sie braucht für das Tal inzwischen gut eine Minute (knapp 16000 Zustände, seit Wehrwärter und Schieber dazugekommen sind) und läuft bei jedem Test mit. Wächst der Inhalt, braucht sie einen eigenen Lauf oder eine Suche, die unabhängige Schritte nicht in jeder Reihenfolge durchgeht.
6. **Weltdateien werden von Hand gepflegt.** Die Dateien des Tals sind einmalig aus einem Skript entstanden und stehen deshalb mit einer Regel je Zeile da. Ein Werkzeug, das sie aus der Kapiteldatei erzeugt, gibt es nicht.

## Spielinhalt

### Werkzeugkasten

`docs/toolbox.md` ist ein Entwurf: Leitplanken, Bausteine, 17 Regeln für Rätsel mit Beispielen aus dem Tal, Ablauf vom Einfall zum Kapitel, Prüflisten und eine erste Durchsicht des Tals.

1. **Jan sieht den Entwurf durch** und beantwortet die fünf offenen Fragen an seinem Ende (Schwierigkeit, Hinweise in Stufen, drei Hinweise, Breite, fehlende Leitplanken).
2. **Prüfbare Regeln in ein Werkzeug.** Viele Regeln sind als „prüfbar“ markiert. Zusammen mit dem Prüfer für die Kapiteldatei (Fundament, Punkt 4) ergibt das ein Werkzeug, das Kapiteldatei und Welten gegen den Werkzeugkasten prüft und das Abhängigkeitsdiagramm zeichnet.
   Ein Fall dafür ist beim Versetzen der Heuwagen aufgefallen: Liegt der Zielplatz eines Wagens direkt neben seinem jetzigen Platz, kann die Figur genau dort stehen, und der Tipp bewirkt dann nichts. Die Lösbarkeitsprüfung hat es gefunden; besser wäre eine Meldung der Regelprüfung, die sagt, woran es liegt.
3. **Blinder Spieltester.** Ein Agent ohne Kenntnis der Lösung spielt das Tal über Bildschirmfotos und Tipps und führt das Protokoll aus dem Werkzeugkasten. Probe: Findet er, was Jan am 13.10. gefunden hat?
4. **Rollen für Agents** erst danach: ein Autor, der Kapitel entwirft und baut, und der blinde Tester, mit Jan an drei festen Stellen.
5. **Was die Durchsicht des Tals ergeben hat,** steht in Abschnitt 9 des Werkzeugkastens. Das Größte: Das Tal ist fast eine einzige Kette, und wichtige Hinweise hängen an je einer Figur.

### Umbau, damit das Spiel fesselt

Die Entscheidungen stehen in `concept.md` („Damit das Spiel fesselt“). Zum Anspielen gebaut sind (2026-10-14, Abschnitt „Zum Anspielen gebaut“ dort): das Buch aus dem Prolog mit Karte, Zetteln und drei Einsichten, die Szene beim Aufbruch des Alten mit dem fernen Licht, das Aufleuchten beim Riss, Hinweise im Bild im Prolog, sichtbare Verweil-Stellen, lebendige Figuren mit Abendwegen, Brabbelstimmen, eigene Klänge, die Melodie der Spieluhr und ein stärkerer Moment, wenn ein Stück heil wird.

1. **Jan spielt den Anfang an** (Prolog und Dorf, bis durch den Bogen) und urteilt: Fühlt sich das Zusammenziehen gut an, auch mit dem Daumen? Ist das Buch zu ordentlich oder zu chaotisch? Trägt die Szene, ist sie zu lang (rund 25 Sekunden)? Sind die Hinweise zu früh, zu spät, zu deutlich? Klingen Stimmen, Klänge und Spieluhr (Claude kann nicht hören)? Bleibt es dabei, dass der Spieler sein Buch vom Alten bekommt?
2. **Was beim Bauen aufgefallen ist und offen bleibt:**
   - Das ferne Licht der Szene ist ein gezeichneter Schein, jetzt kleiner; die Szene dauert noch rund 18 Sekunden.
   - Der Alte, die Frau und das Kind haben Laufbilder; Müller, Fischerin und Wehrwärter gehen bisher nirgends hin und brauchen keine.
   - Die Spieluhr spielt eine errechnete Melodie, die mit den generierten Stücken nichts zu tun hat. Wird sie das Leitmotiv, müssten die Stücke sie aufnehmen.
3. **Rätsel des Tals umbauen:** Abweichungen selbst erkennen statt abholen, mehrere Fäden zugleich statt einer Kette. Erster Schritt ist getan: Im Dorf laufen Haus und Bogen jetzt nebeneinander. Weitere Einsichten für Mühlenhügel, Quelle und Weiher, und die Pfeile mit „?“ auf der Karte (Quelle und Weiher überspringen ein Stück) brauchen je eine Einsicht, die sie auflöst.
4. **Ende des Kapitels:** Szene, Erkenntnis und ein Hinweis aufs nächste Kapitel. Vorschlag: Das große Licht fängt Feuer, die Kamera zieht auf, die Stücke schließen sich auf der Karte zum Ring, und weit draußen antwortet ein zweites Licht; auf der Karte erscheint ein Pfeil aus dem Tal hinaus mit „?“. Die Bausteine (Szenen, fernes Licht, Karte) sind da.
5. **Stimmen der Figuren.** Zum Ausprobieren hat der Alte sechs generierte wortlose Laute, einer zu Beginn jeder Zeile. Gefällt es Jan, bekommen Frau, Kind, Müller, Fischerin und Wehrwärter ihre (`tools/voice_sounds.py`, je eine Stimme und Anweisung).
6. **Schieber am Wehr ersetzen.** Das Rätsel ist gestrichen (Jan); die Quelle braucht ein neues, das zum Ort passt. Vorschlag: Der Wehrwärter öffnet erst, wenn es Morgen ist, und woran man hier den Morgen erkennt, setzt der Spieler im Buch zusammen.
7. **Blindtest** mit zwei oder drei Leuten, sobald 1 und 3 stehen.

### Das Tal

Das erste Kapitel (`docs/chapters/valley.md`) ist von Anfang bis Ende spielbar: der Abend vor dem Riss, Dorf, Mühlenhügel, Quelle, Weiher, Warte. Jan hat die Probefassung mit Platzhaltern für gut befunden; seitdem hat es eigene Bilder und Musik.

1. **Jans Urteil einholen.** Vor allem: Trägt die Geschichte, sind die Rätsel zu leicht oder zu undurchsichtig, dauert es lang genug? Die offenen Punkte stehen am Ende der Kapiteldatei.
2. **Was Jan nach dem ersten Durchspielen der alten Fassung bemängelt hat, am Tal prüfen:**
   - Wissen gehört zu Figuren (jeder Hinweis nennt in der Kapiteldatei, wer ihn glaubhaft geben kann).
   - Kein Überspringen von Schritten, die für die Geschichte zählen. Die Frau am Bach ist jetzt nötig (ihr Heuwagen gehört zur ersten Einsicht).
   - Figuren reagieren genau auf den Zustand, auch auf Teilzustände.
   - Figuren verwirrter und mysteriöser, Hinweise nicht als Anweisung.
   - Mehr Widerstand, das Notizbuch soll nötig sein.
3. **Bilder und Musik des Tals beurteilen.** Zwei Bodenbilder, vierzehn Objektbilder und zwei Musikstücke sind generiert und eingebaut. Jan beurteilt Stil und Klang. Die Maße der neuen Bilder (`data/sprites.json`) sind nach Augenmaß gesetzt. Die Spieluhr hat noch keinen Klang.
4. **Niedriges Wasser beurteilen (Jan).** Wo der Stand gesunken ist, liegt jetzt das Bett frei: Der Bach im Dorf und unterhalb des Wehrs ist trocken, im Weiher bleiben Pfützen. Offen ist der Geschmack: Farbe des Betts, wie viel Wasser im Weiher bleibt (`level` in `mood_wrong`), und dass das Wasser beim Öffnen des Wehrs in zweieinhalb Sekunden zurückkehrt wie jede Stimmung.
5. **Den Riss als Szene beurteilen (Jan).** Die Szene steht: Das Bild wackelt immer stärker, die Musik läuft herunter, es grollt, das Bild wird dunkel und nach einer Weile langsam wieder hell, und die Figur liegt am Weg und steht auf, wenn sie zu sich gekommen ist. Offen ist das Gefühl: Stärke und Dauer des Wackelns, die Länge der Dunkelheit, und vor allem das Grollen, das aus Rauschen errechnet ist (`tools/quake_sound.py`) und das Claude nicht hören kann. Die liegende Figur ist das umgekippte Standbild; ein eigenes Bild fehlt.
6. **Man bleibt oft stecken (Jan, erstes Anspielen).** Bisher hing es an drei Stellen, die behoben sind: Ein Stein rollte hinter einen Baum, der Platz des Müllers war nicht zu finden (jetzt gilt überall: neben die Figur stellen und warten), und wie man an die Kurbel kommt, war unklar (jetzt sagt der Alte, dass er sie verlegt hat, und man findet sie im Schrank). Offen bleibt das Muster dahinter:
   - Wo man verweilen kann und dass gerade etwas geschieht, zeigt jetzt ein Schimmer am Boden; ob er deutlich genug ist, zeigt das Spielen.
   - Jeder Schritt muss über alles gehen, was ein Spieler naheliegend versucht (die Figur ansprechen statt das Ding antippen und umgekehrt).
   - Sagt eine Figur zweimal dasselbe, obwohl der Spieler inzwischen mehr weiß, wirkt das wie eine Sackgasse.
   - Jan hat das Dorf erst mit Erklärung gelöst. Der Windschatten erklärte sich nicht von selbst. Seitdem sind die Steine Heuwagen und der Wind ist sichtbar; ob das reicht, zeigt das nächste Durchspielen. Das zweite Antippen des Wagens erklärt sich weiterhin nicht.
7. **Sonderfälle in der Ansicht.** Das Notizbuch auf dem Tisch, das ferne Licht am Weiher und die Zeichnungen für Objekte ohne Bild stehen als Sonderfälle je Objektart in `ObjectView`.
8. **Wehrwärter und Schieber an der Quelle.** Beide sind gezeichnete Platzhalter und haben noch keine Bilder (Wehrwärter eines, Schieber zwei: oben und unten; erst wenn Jan sie freigibt). Jan hat weder die Texte gelesen noch das Rätsel gespielt: Ist die Stellung in der Erinnerung gut genug abzulesen, ist es zu leicht? Dem Wehrwärter fehlen ein Bruchstück vom Riss und ein Abendplatz.

### Weitere Punkte

1. **Laufanimation abstimmen.** Die Figur hat je Ansicht (vorn, hinten, jeweils auch gespiegelt) ein Standbild und vier Schritt-Bilder aus einem generierten Bogen (`tools/walk_images.py`). Offen ist, ob vier Bilder flüssig genug wirken, ob Tempo (7 Bilder je Sekunde) und Schrittweite zusammenpassen und ob der Schatten mitlaufen soll (er zeigt immer das Standbild). NPCs stehen still.
2. **Antworten zur Auswahl.** Figuren sprechen, der Spieler antwortet nie. Falls gewünscht, braucht der Dialog Auswahl.
3. **Notizbuch ausbauen.** Karte und Zettel stehen (siehe oben). Die Verknüpfungen (`links` in `data/notes.json`) zeigt das neue Buch nicht mehr; sie dienen nur noch der Planung. Offen: ob Bruchstücke über den Riss sich am Ende eines Kapitels zu etwas zusammensetzen lassen, und wie das Buch nach einer langen Pause sagt, wo man war.
4. **Verweilen abstimmen.** Das Kind am Abhang führt es ein, vier weitere Orte nutzen es. Wo es geht, schimmert jetzt der Boden (`MemorySpots`). Offen ist das Gefühl: Wartezeit (3,5 s), wie langsam die Erinnerung kommt (3 s), wie deutlich Schimmer und Erinnerung sein dürfen, wie weit sich die Musik neigt und ob sie ein eigenes Geräusch bekommt.
5. **Der Moment „Welt ist heil“ abstimmen.** Wird der letzte Fehler einer Welt behoben, schwillt warmes Licht über das Bild, die Figuren stehen wieder an ihren Abendplätzen, und jemand im Stück sagt, dass es wie früher ist. Offen ist das Gefühl: Stärke und Dauer des Lichts, der Wortlaut der vier Sätze, ob der Moment einen Klang bekommt. Der Alte, der Müller und die Fischerin haben noch keinen Abendplatz. Das Ende des Kapitels hat noch keinen eigenen Moment.
6. **Rückmeldung bei Interaktionen.** Wer etwas einsteckt oder abgibt, sieht das jetzt als Randnotiz im Dialogfeld („+ Kurbel“). Sonst sieht man bisher nicht, was sich benutzen lässt und ob ein Tipp etwas bewirkt hat. Was die Figur bei sich trägt, lässt sich nirgends nachsehen. Offen ist, wie deutlich das sein darf, ohne das Entdecken zu verderben.
7. **Geführte Szenen.** Szenen sind Daten (`data/scenes.json`, abgespielt von `Cutscene`): gehen, in etwas hineingehen, verblassen, eine Figur erscheinen lassen, in eine andere Welt blenden, die Kamera führen, ein fernes Licht, warten. Die erste ist der Aufbruch des Alten. Es fehlt: Sprechen innerhalb einer Szene, eine Regel, wie sich eine Szene überspringen lässt, und Rückblicke in die heile Fassung einer Welt. Die Fahrt im Boot ist weiterhin schlicht (die Figuren stehen vor dem Boot statt darin, es fährt in gerader Linie), der Riss eine fest gebaute Szene (`"as": "quake"`).

## Rahmen

1. **Titelbildschirm.** Der Startbildschirm mit dem Hinweis auf Kopfhörer steht und erscheint nur beim allerersten Start; die Pause-Seite mit Lautstärke, Sprache und „Neu beginnen“ steht auch. Es fehlt ein Titel, sobald der Name feststeht.
2. **Pause-Seite ergänzen.** Klänge haben jetzt einen eigenen Bus („Sounds“) und Regler. Wird die Sprache gewechselt, während ein Dialog offen ist, bleiben dessen schon begonnene Zeilen in der alten Sprache.
3. **Android weiter prüfen.** Der Testbau läuft auf Jans Handy einwandfrei, auch die Oberfläche aus Controls, die Pause-Seite und die Zurück-Geste. Das App-Symbol steht (`tools/app_icon.py`, aus Bildern des Spiels zusammengesetzt); auf dem Handy hat es noch niemand gesehen. Offen sind andere Bildschirmformate: Die Knöpfe in den Ecken sitzen fest 36 Pixel vom Rand und beachten den sicheren Bereich des Bildschirms (Kamera-Aussparung, runde Ecken) nicht.
4. **Renderer vergleichen.** Das Spiel läuft mit „mobile“ (Vulkan). Für reines 2D auf Android ist „compatibility“ üblicher. Einmal auf dem Handy nebeneinander ansehen.

## Grafik und Ton

2. **Dialogfeld und Notizbuch.** Beide nutzen die Standardschrift von Godot und schlichte Flächen. Brauchen eine Schrift und Gestaltung, die zum gemalten Stil passen.
3. **Raum einrichten.** Der Raum hat gemalten Boden und Wände, einen Tisch und einen Schrank. Für Rätsel im Haus fehlen Dinge, mit denen man etwas tun kann.
4. **Verdeckung durch hohe Objekte.** Häuser und Bäume verdecken die Figur und Wege. Braucht eine Lösung (durchscheinen, Umriss oder Regeln für die Platzierung).
5. **Bodenbilder einpassen.** Das Bildmodell hält sich nicht immer genau an den Plan (der Raum kam 3 % größer und etwas höher heraus). Bisher wird die Lage von Hand an den gemalten Ecken ausgerichtet. Bei mehr Welten lohnt ein Schritt im Werkzeug, der das selbst misst.
6. **Schatten auf Höhenunterschieden.** Der Schatten der Laterne fällt über Brücke und Bach, als wäre alles flach.
7. **Gespiegelte Objekte.** Das gemalte Licht sitzt nach dem Spiegeln auf der falschen Seite. Für die heile Welt eigene Varianten statt Spiegelung, die Spiegelung bleibt den falschen Welten vorbehalten.
8. **Sichtbaren Wind abstimmen.** Dichte, Deckkraft und Länge der Streifen, die Länge des Windschattens und ob Häuser ihn auch werfen sollen (`src/view/wind_view.gd`). Am Mühlenhügel, wo es windstill ist, gibt es keine Streifen.
9. **Geräusche.** Errechnet gibt es: Stimmen, Flamme, Einsicht, Fehlgriff, Umblättern, Heilwerden, Spieluhr (`tools/sound_effects.py`). Es fehlen Schritte je Untergrund, Wasser, Wind und ein Klang für einfache Tipps.
10. **Musik in Schichten.** Stücke je Welt, die sich mit der Reparatur schrittweise zusammensetzen, statt nur Tonhöhe und Filter zu ändern. Modellwahl und Lizenz sind noch offen.

## Zu klären

- Name: „Everwild“ ist durch Rare belegt und bleibt Arbeitstitel. Ein eigener Name muss stehen, bevor der Eintrag im Play Store angelegt wird (die Paket-ID lässt sich danach nicht mehr ändern).
- Bleibt `.vscode/settings.json` im Repository?
- Soll die Figur stehen bleiben, wenn beim Betreten einer Zelle ein Dialog aufgeht? Bisher läuft sie weiter zum Ziel, während der Text erscheint.
- Umfang der ersten Fassung: wie viele Kapitel.

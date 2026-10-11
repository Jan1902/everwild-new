# Backlog

Alles, was noch zu bauen oder zu klären ist. Entscheidungen zum Spiel selbst stehen in `concept.md`, hier steht nur die Arbeit.

Die Reihenfolge innerhalb eines Abschnitts ist die vorgeschlagene Reihenfolge der Umsetzung. Erledigtes wird gelöscht, nicht abgehakt (die Historie steht in Git).

## Fundament

Spielspeicher, Regeln je Welt, Stimmung aus dem Zustand, Lösbarkeitsprüfung und lokale Speicherung stehen. Es fehlt:

1. **Speicherung in Google Play.** Spielstand über Google Play Games (Saved Games) sichern und zwischen Geräten abgleichen, mit Regel für Konflikte zwischen lokalem und entferntem Stand.

## Spielinhalt

1. **Richtige Spielfigur.** Sprite statt Platzhalter, Laufanimation in den nötigen Richtungen, passender Schatten. Offen ist der Weg dorthin (siehe `concept.md`, Offene Punkte). Braucht Bildgenerierung.
2. **NPCs.** Figuren als Objekte der Welt mit Sprite, Standort und Zustand. Wenige, dafür mit Gewicht. Sie erinnern sich je nach Spielstand gar nicht, in Fetzen oder ganz.
3. **Dialoge mit den NPCs.** Dialoge als Daten mit Bedingungen auf den Spielspeicher und Folgen (Hinweis ins Notizbuch, Gegenstand, Zustandsänderung). Anzeige mit wenig UI.
4. **Mehrere Welten und Portale.** Laden und Wechseln von Welten, Türen und Portale als dieselbe Mechanik: ein Ziel, das vom Zustand abhängt (die Haustür führt erst nach der Reparatur ins Haus). Übergang mit Blende und Musikwechsel.
5. **Notizbuch.** Sammelt Erinnerungen, Weltstücke und Hinweise und zeigt die abstrakten Beziehungen zwischen ihnen (was gehört zu welcher Welt, was hängt womit zusammen). Ersetzt eine Questliste.
6. **Erinnerung gegen Jetzt.** Die Kernmechanik: die heile Fassung einer Welt als Erinnerung ansehen und mit dem Jetzt vergleichen.
7. **Verweilen.** Stehen bleiben und beobachten deckt Dinge auf, die man im Gehen nicht sieht.
8. **Tutorial-Dorf als fertiger Abschnitt.** Heile Fassung mit den Aufgaben für den alten Mann, der Bruch, das Aufwachen, die kaputte Fassung mit vier bis sechs Fehlern. Die drei Fehler, die das Dorf jetzt hat (Stein vor der Brücke, Stein im Osten mit gespiegeltem Baum, dunkle Laternen), sind nur ein Probelauf für die Mechanik, und das Spiel beginnt vorläufig direkt im kaputten Dorf.
9. **Rückmeldung bei Interaktionen.** Man sieht bisher nicht, was sich benutzen lässt und ob ein Tipp etwas bewirkt hat. Offen ist, wie deutlich das sein darf, ohne das Entdecken zu verderben.

## Rahmen

1. **Startbildschirm mit Hinweis.** Vor dem Spiel ein ruhiger Bildschirm: Die Atmosphäre ist ein wesentlicher Teil, deshalb die Empfehlung, in ruhiger Umgebung oder mit Kopfhörern zu spielen.
2. **Titel, Pause und Einstellungen.** Fortsetzen, neu beginnen, Lautstärke. So wenig wie möglich.
3. **Texte als Daten.** Alle sichtbaren Texte in Sprachdateien, damit Deutsch und Englisch möglich sind.
4. **Android-Export.** Bauen, auf einem echten Gerät starten, Touch und Leistung prüfen. Bisher ist nur die Maus getestet.

## Grafik und Ton

1. **Verdeckung durch hohe Objekte.** Häuser und Bäume verdecken die Figur und Wege. Braucht eine Lösung (durchscheinen, Umriss oder Regeln für die Platzierung).
2. **Brücke.** Das Sprite ist zu lang und zu schmal für den ein Feld breiten Bach. Neu generieren mit Formvorlage.
3. **Schatten auf Höhenunterschieden.** Der Schatten der Laterne fällt über Brücke und Bach, als wäre alles flach.
4. **Gespiegelte Objekte.** Das gemalte Licht sitzt nach dem Spiegeln auf der falschen Seite. Für die heile Welt eigene Varianten statt Spiegelung, die Spiegelung bleibt den falschen Welten vorbehalten.
5. **Geräusche.** Schritte je Untergrund, Wasser, Wind, Interaktionen.
6. **Musik in Schichten.** Stücke je Welt, die sich mit der Reparatur schrittweise zusammensetzen, statt nur Tonhöhe und Filter zu ändern. Modellwahl und Lizenz sind noch offen.

## Zu klären

- Name: „Everwild“ ist durch Rare belegt und bleibt Arbeitstitel. Ein eigener Name muss stehen, bevor der Eintrag im Play Store angelegt wird (die Paket-ID lässt sich danach nicht mehr ändern).
- Bleibt `.vscode/settings.json` im Repository?
- Umfang der ersten Fassung: wie viele Welten.

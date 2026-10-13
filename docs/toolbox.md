# Werkzeugkasten für Spielinhalte

Stand: 2026-10-13, **Entwurf zum Durchsehen**. Noch nichts hiervon ist von Jan bestätigt, außer wo „(Jan)“ dabeisteht.

Dieses Dokument sammelt, womit in Everwild Inhalte entstehen: die Bausteine, die es im Spiel gibt, die Regeln, nach denen Rätsel, Figuren und Welten gebaut werden, der Ablauf vom Einfall zum fertigen Kapitel und die Prüflisten dazu. Es fasst zusammen, was schon entschieden ist (`concept.md`, `chapters/valley.md`, Jans Rückmeldungen aus dem Spielen), und ergänzt es um bewährtes Wissen aus dem Spieldesign.

Woher eine Regel kommt, steht in Klammern dahinter:

- **(Jan)**: von Jan entschieden oder aus seiner Rückmeldung beim Spielen.
- **(Quelle)**: aus der Recherche, die Quelle steht am Ende.
- **(Vorschlag)**: von Claude abgeleitet, noch nicht besprochen.

Hinter jeder Regel steht außerdem, ob ein Werkzeug sie prüfen kann (**prüfbar**) oder ob sie ein Urteil braucht (**Urteil**).

## 1. Leitplanken

Was Everwild ist und was es nicht ist. Wer Inhalt entwirft, prüft zuerst, ob er hier hineinpasst.

1. **Alles war einmal eins und ist jetzt getrennt.** Der Spieler bewegt sich wie in einem Déjà-vu: Figuren kennen ihn, Dinge hängen zusammen, Welten wirken vertraut und zugleich falsch. (Jan)
2. **Erinnerung gegen Jetzt.** Die Erinnerung ist der Zielzustand, die Gegenwart der Ist-Zustand, der Spieler schließt die Differenz. Jede andere Mechanik ordnet sich darum. (Jan)
3. **Fortschritt ist Wissen.** Das Notizbuch ist der eigentliche Fortschritt, nicht ein Inventar. Gegenstände gibt es wenige, und es gibt keine Oberfläche dafür. (Jan)
4. **Kein Kampf, keine Werte, kein Zeitdruck, kein Scheitern.** (Jan)
5. **Keine Sackgassen.** Kein Zustand ist unlösbar. Das wird durchgespielt und geprüft. (Jan)
6. **Jeder sichtbare Unterschied ist Absicht.** Der Boden einer Welt ist in allen Fassungen derselbe; Unterschiede entstehen nur durch gezielt gesetzte Objekte, Shader und Verhalten. (Jan)
7. **Reparieren in Schritten.** Jeder Schritt verändert etwas Sichtbares oder Hörbares und öffnet den nächsten. Ursache und Wirkung liegen oft an verschiedenen Orten. (Jan)
8. **Wenige Figuren, die sich nur in Bruchstücken erinnern.** Je weiter ein Stück repariert ist, desto mehr wissen sie. (Jan)
9. **Der Riss bleibt rätselhaft.** Ein Kapitel erzählt, was er dort angerichtet hat, und gibt höchstens Bruchstücke der großen Frage preis. Das Notizbuch gehört dem ganzen Spiel. (Jan)
10. **Ruhig, gemalt, schlicht, kaum Oberfläche.** Die Welt füllt den Bildschirm. (Jan)

Dazu passt, was andere ruhige Spiele für sich festgehalten haben: Monument Valley hat bewusst auf Inventar, Dialogbäume und Scheitern verzichtet und schwere Rätsel gegen eine kurze, dichte Reise getauscht; jeder Bildschirm sollte für sich als Bild bestehen. Die Beschränkung auf wenige Mechaniken hat dort die Tiefe erst möglich gemacht. (Quelle)

## 2. Bausteine

Was es im Spiel gibt und woraus Inhalt gebaut wird. Etwas Neues, das hier nicht steht, braucht Code und eine Entscheidung.

### Was der Spieler tun kann

| Baustein | Was es ist | Wofür es taugt | Achtung |
|---|---|---|---|
| Laufen | Tipp auf eine Zelle. | Erkunden, Abstand als Tempo. | Lange Wege ohne Ereignis ziehen sich. |
| Benutzen | Tipp auf ein Objekt, die Figur läuft hin. | Fast jeder Schritt. | Jedes benutzbare Ding braucht in jedem Zustand eine Antwort (Regel 11). |
| Sprechen | Benutzen einer Figur. | Wissen, Hinweise, Ton. | Eine Aufgabe je Gespräch (Regel 3). |
| Verweilen | Neben einer Figur still stehen, dreieinhalb Sekunden. | Zeigt, wie es war. | Selten und an einen Ort gebunden; eine Figur führt es ein. |
| Weltwechsel | Bogen, Tür, Stufen, Boot. | Gliedert das Kapitel in Stücke. | Ein Bogen trägt nur mit Licht und kennt nur, was im Notizbuch steht. |

### Womit die Welt antwortet

| Baustein | Was es ist |
|---|---|
| Zustand eines Objekts | Zelle, Zustand, gespiegelt, versteckt. Mehr kann ein Objekt nicht. |
| Fernwirkung | Eine Regel `always` feuert von selbst, auch in einer anderen Welt (die Mühle dreht sich, das Floß treibt zurück). |
| Stimmung | Zehn Regler je Welt: Wind, Fließrichtung, Wasserstand, Schatten, Sättigung, Farbstich, Dunst, Licht, Tonhöhe, Dämpfung. Jeder Fehler bringt bestimmte Regler zurück. |
| Erinnerung | Ein Ausschnitt der Welt scheint durch, wie er war. |
| Notiz | Ein Eintrag im Notizbuch mit Verknüpfungen. Fehlende Verwandte erscheinen als Lücke. |
| Gegenstand | Wird getragen, selten, ohne eigene Oberfläche; eine Randnotiz im Dialog zeigt den Wechsel. |
| Moment | Wird ein Stück heil: warmes Licht, die Figuren kehren an ihre Abendplätze zurück, und jemand dort sagt, dass es wie früher ist. Kein Schriftzug. |
| Fahrt und Szene | Ein Weltwechsel als sichtbare Fahrt oder als feste Szene (der Riss). |

### Rätselmuster, die es schon gibt

Aus dem Tal. Jedes lässt sich in einem neuen Kapitel mit anderem Inhalt wiederverwenden, sollte dann aber gewendet werden (Regel 17).

- **Zwei Hälften.** Zwei Figuren wissen je die Hälfte: Der Müller hat etwas verliehen, der Alte hat etwas Geliehenes. Erst beide zusammen ergeben die Kurbel.
- **Schutz vor der Welt.** Etwas hält nur unter einer Bedingung, die man herstellen kann (die Laterne im Windschatten des Heuwagens).
- **Der Weg hängt am Zustand.** Trittsteine tragen nur bei niedrigem Wasser, das Boot nur bei hohem. Wer das Wasser ändert, tauscht einen Weg gegen einen anderen.
- **Ursache hier, Wirkung dort.** Das Wehr an der Quelle füllt den Bach im Dorf und den Weiher und lässt das Feld am Mühlenhügel wachsen.
- **Die Erinnerung zeigt die Stellung.** Wohin die Wetterfahne zeigte, sieht man nur am Platz des Müllers.
- **Licht öffnet.** Eine brennende Laterne lässt einen Bogen tragen oder eine Tür ins Haus führen.
- **Vergessene Orte.** Ein Stück, das nicht im Notizbuch steht, wird übersprungen.

## 3. Regeln für Rätsel

Jede Regel hat ein Beispiel aus dem Tal. Wo das Tal selbst dagegen verstößt, steht es dabei und in Abschnitt 9.

**Regel 1: Das Ziel ist klar.** Der Spieler weiß zu jeder Zeit, was in einem Stück nicht stimmt, auch wenn er noch nicht weiß, wie er es behebt. Die Punkte im Notizbuch sagen, wie viel noch falsch ist, die Erinnerung zeigt, was. (Quelle: Gilbert; Jan) Urteil.

**Regel 2: Das Problem kommt vor der Lösung.** Der Spieler findet zuerst die verschlossene Tür und dann den Schlüssel. Wer die Kurbel einsteckt, bevor er weiß, wofür, hat kein Aha, sondern einen Gegenstand. *Tal:* Der Schrank zeigt nur Decken, bis der Alte gesagt hat, dass er die Kurbel verlegt hat. (Quelle: Gilbert, „backwards puzzles“; Jan) Prüfbar: Jedes `gives: item` braucht ein `needs`, das die Kenntnis des Problems voraussetzt.

**Regel 3: Eine Aufgabe je Gespräch.** Eine Figur gibt nicht zwei Aufgaben auf einmal. *Tal:* Der Müller sprach von Kurbel und Wetterfahne zugleich; jetzt kommt die Fahne erst, wenn die Mühle rückwärts läuft. (Jan) Prüfbar: höchstens ein Hinweis je `talk`, der auf einen offenen Schritt zeigt.

**Regel 4: Kein Schritt, der zu früh nur schadet.** Ein Schritt, der im Moment nichts bringt und rückgängig gemacht werden muss, ist gesperrt, bis er Sinn ergibt, und die Figur sagt, warum sie ihn lässt. *Tal:* Das Wehr ließ sich sofort öffnen, meldete die Quelle als heil und versperrte dann den Weg zum Weiher. (Jan) Die Grausamkeitsskala für Textadventures nennt ein Spiel „barmherzig“, wenn man nie festsitzen kann; Everwild will darüber hinaus auch das *Gefühl* des Festsitzens vermeiden. (Quelle: Plotkin) Prüfbar: Die Lösbarkeitsprüfung kann melden, wenn ein Schritt die Menge der möglichen Fortschritte verkleinert, ohne einen Fehler dauerhaft zu beheben.

**Regel 5: Die Erinnerung zeigt, wohin etwas muss, und zwar deutlich.** Was beim Verweilen durchscheint, ist der Zustand, den der Spieler herstellen soll, und der Unterschied zum Jetzt muss auf einen Blick zu sehen sein. *Tal:* Der Wagen erschien neben dem Bogen statt im Windschatten und führte in die Irre, deshalb bleibt er in dieser Erinnerung jetzt, wo er ist; die Wetterfahne stand um 180 Grad verdreht und sah fast gleich aus. (Jan) Prüfbar zum Teil: Ein Werkzeug kann zählen, was im Ausschnitt durchscheint und ob es zu einem offenen Schritt gehört; ob der Unterschied *sichtbar* ist, braucht ein Bild.

**Regel 6: Drei Hinweise für jeden nötigen Schluss.** Zu allem, was der Spieler begreifen muss, um weiterzukommen, gibt es drei verschiedene Wege, es zu erfahren, etwa eine Figur, eine Erinnerung oder Notiz, und das, was man sieht. Einen übersieht er, einen deutet er falsch, der dritte trägt. Falsche Fährten braucht es nicht; Spieler legen sie sich selbst. (Quelle: Alexander, „Three Clue Rule“) *Tal:* Dass ein Stein die Flamme schützt, sagt bisher nur die Frau am Bach. Prüfbar: Jeder `step` nennt unter `hint` mindestens zwei, besser drei Quellen.

**Regel 7: Hinweise sind keine Anweisungen, werden aber deutlicher.** Figuren reden verwirrt und in Bruchstücken. (Jan) Damit niemand hängen bleibt, wird der Hinweis in Stufen deutlicher, und zwar in der Welt, nicht über einen Hilfe-Knopf: erst die Figur im Vorbeigehen, dann dieselbe Figur beim zweiten Ansprechen genauer, zuletzt das Selbstgespräch der eigenen Figur am Objekt. In der Welt verankerte Hinweise werden leicht überlesen; deshalb hält das Notizbuch fest, was gesagt wurde. (Quelle: Hinweissysteme) *Tal:* Die Figur am Wehr sagte direkt, was zuerst zu tun ist. Jetzt gibt sie nur wieder, was sie von der Fischerin weiß, und das Wehr öffnet sich erst nach deren Gespräch. Urteil; prüfbar ist nur, dass es je Schritt eine zweite Stufe gibt.

**Regel 8: Ereignisse hängen erkennbar zusammen.** Wenn etwas hier etwas dort bewirkt, muss der Spieler den Zusammenhang sehen können: vorher durch einen Hinweis, nachher durch den Schriftzug, eine Notiz oder einen Satz. Sonst wirkt die Welt willkürlich. (Quelle: Gilbert, „unconnected events“) *Tal:* Dreht sich die Mühle, treibt an der Quelle das Floß zurück. Dass der Wind es war, sagt nur ein Satz am Ufer. Urteil.

**Regel 9: Ein Rätsel hat einen Haken.** Ein gutes Rätsel legt eine naheliegende Annahme nahe, die scheitert, und die Einsicht besteht darin, sie fallen zu lassen. Es enthält nur, was es braucht, und fühlt sich im Nachhinein gerecht an. (Quelle: Brown) *Tal, gelungen:* Die Laterne lässt sich anzünden und geht aus; die Annahme „anzünden genügt“ scheitert. *Tal, schwach:* Wetterfahne und Steine sind inzwischen Schritte, keine Rätsel. Urteil.

**Regel 10: Mehrere Fäden zugleich, dann eine Engstelle.** Das Abhängigkeitsdiagramm eines Kapitels (Abschnitt 6) soll aus kleinen Rauten bestehen: Ein gelöster Schritt öffnet zwei oder drei neue, die wieder auf einen zulaufen. Ein Akt endet in einer Engstelle, die sich wie ein Abschluss anfühlt. Eine einzige lange Kette ist das Schlimmste, weil der Spieler an jeder Stelle feststeckt, an der er nicht weiterweiß. (Quelle: Gilbert) Prüfbar: Die Lösbarkeitsprüfung kennt je Zustand die Zahl der möglichen sinnvollen Schritte.

**Regel 11: Jeder naheliegende Versuch bekommt eine Antwort.** Tippt der Spieler das Ding an statt die Figur anzusprechen oder umgekehrt, geht es trotzdem weiter oder er bekommt wenigstens einen Satz, der in die richtige Richtung zeigt. Stilles Nichts liest sich als Fehler. (Quelle: Gilbert, „reward intent“; Jan: „Jeder Schritt muss über alles gehen, was ein Spieler naheliegend versucht.“) Prüfbar: Jedes Objekt mit einer Regel hat eine letzte Regel ohne Bedingung.

**Regel 12: Figuren reagieren auf den Stand, auch auf Teilstände.** Sagt eine Figur zweimal dasselbe, obwohl der Spieler inzwischen mehr weiß oder getan hat, wirkt das wie eine Sackgasse. (Jan) Prüfbar: Für jede Figur lässt sich auflisten, in welchen Zuständen sie denselben Text sagt.

**Regel 13: Jede Teilreparatur ist spürbar.** Wind, Farbe, Musik, Wasser oder Verhalten ändern sich sofort; was den Besitzer wechselt, wird gezeigt. (Jan) Prüfbar: Jeder Fehler bringt mindestens einen Regler zurück.

**Regel 14: Wissen gehört zu Figuren.** Jeder Hinweis nennt, wer ihn glaubhaft geben kann und warum gerade diese Figur das weiß. (Jan) Prüfbar: `knows` steht in der Tabelle der Figur.

**Regel 15: Was für die Geschichte zählt, lässt sich nicht überspringen.** (Jan) *Tal:* Die Frau am Bach muss man nie ansprechen. Prüfbar: Die Lösbarkeitsprüfung kann den kürzesten Weg mit dem gedachten vergleichen und melden, welche Gespräche und Erinnerungen darin fehlen.

**Regel 16: Der Spieler kommt mit Aufmerksamkeit durch.** Nichts verlangt Raten, Durchprobieren oder Wissen von außerhalb des Spiels. (Quelle: Gilbert, „arbitrary puzzles“) Prüfbar zum Teil: Ein Schritt, der sich durch wiederholtes Antippen ohne Wissen lösen lässt, ist ein Durchprobier-Rätsel.

**Regel 17: Einführen, üben, wenden, abschließen.** Eine neue Idee wird zuerst gefahrlos gezeigt, dann angewendet, dann in einer Lage gebraucht, in der sie anders wirkt als erwartet, und schließlich zusammengeführt. Danach darf sie ruhen. (Quelle: Hayashida, vier Schritte) *Tal, Verweilen:* Das Kind führt es ein, am Platz des Müllers zeigt es eine Stellung, am Steg zeigt es etwas Fernes, das auf ein vergessenes Stück weist, auf der Warte schließt es das Kapitel. Urteil.

## 4. Geschichte und Figuren

**Was ein Kapitel erzählt.** Jedes Kapitel hat einen Satz, der sagt, was der Riss dort angerichtet hat (im Tal: „Es ist Abend geblieben“), und daraus folgen seine Regeln der Welt. Jede Regel der Welt muss etwas im Spiel tun, sonst ist sie Kulisse. (Vorschlag)

**Was eine Figur braucht.** Fünf Angaben, bevor ein Wort Dialog entsteht:

1. Was sie verloren hat.
2. Wo sie jeden Tag steht und warum (dort kann man verweilen), und wo sie vor dem Riss ihren Abend lebte (dorthin kehrt sie zurück, wenn ihr Stück heil ist).
3. Was sie weiß und was nicht.
4. Wie sie den Spieler kennt.
5. Ihr Bruchstück über den Riss, das zu denen der anderen nicht passt.

**Die Umgebung erzählt mit.** Geschichte steckt nicht nur im Dialog, sondern in dem, was herumsteht und wie es steht. Jeder Eintrag in der Liste `broken` einer Welt ist ein Satz der Erzählung: das Boot im Schlamm, das Floß am falschen Ufer. Wer eine Abweichung setzt, fragt, was sie über diesen Abend sagt. (Quelle: Jenkins, „embedded narrative“)

**Dialog.**

- Kurz. Als Faustregel gelten in der Branche etwa 25 Wörter je Zeile, 40 als Obergrenze; jede Zeile hält den Spieler vom Spielen ab. (Quelle) Im Dialogfeld sind das höchstens drei Zeilen Text.
- Jede Zeile tut etwas: Sie gibt Wissen, zeigt die Figur oder ändert die Stimmung.
- Was die Figur fühlt, sagt sie nicht geradeheraus. Sie redet über die Decken im Schrank, nicht über ihr Vergessen.
- Der Ton des Alten ist nah an Demenz und bleibt zart. (aus `valley.md`)
- Ein Name erscheint erst, wenn die Figur sich an ihn erinnert. (aus `valley.md`)
- Die eigene Figur spricht knapp und sachlich mit sich selbst. Ihr Selbstgespräch ist die letzte Hinweisstufe (Regel 7).

**Was die große Geschichte offen hält.** Jedes Kapitel führt eine Liste dessen, was es preisgibt und was offen bleibt, damit kein Kapitel versehentlich den Riss erklärt. (Jan)

## 5. Welt und Bild

**Lesbarkeit vor Schmuck.** Was sich benutzen lässt, muss man erkennen können, ohne dass es markiert ist. Mittel dafür, in dieser Reihenfolge: Lage (es steht am Weg, an einem Ende, allein), Licht (es leuchtet oder ist auffällig dunkel), Bewegung (es schwankt, dreht sich, flackert), Form (es sieht aus wie etwas, das man bedient). Ausdrückliche Markierungen sind das letzte Mittel. (Quelle: Signifier) *Tal:* Der offene Bogen leuchtet jetzt in jeder Stimmung, weil man ihn im dunklen Stück nicht von einem geschlossenen unterscheiden konnte. (Jan)

**Was etwas bewirken soll, muss danach aussehen.** *Tal:* Ein kniehoher Stein sollte eine Laterne vor dem Wind schützen; das hat niemand geglaubt. Jetzt ist es ein beladener Heuwagen, und der Wind ist als Streifen in der Luft zu sehen, die hinter ihm abreißen. (Jan)

**Ein Ding führt sichtbar dorthin, wohin es führt.** *Tal:* Die Stufen standen auf der Wiese; jetzt sitzen sie im Bachbett am Rand des Stücks. (Jan)

**Landmarken.** Jedes Stück hat ein hohes, von überall sichtbares Ding, an dem man sich ausrichtet (Mühle, Wehr, das große Licht). (Quelle)

**Nichts Wichtiges hinter Hohem.** Bäume und Häuser verdecken die Figur. Bis es dafür eine Lösung gibt: Orte, an denen man stehen oder liegen muss, liegen frei. (Vorschlag; im Backlog offen)

**Vier bis sechs Fehler je Stück.** Jeder ist sichtbar oder hörbar und bringt einen Teil der Stimmung zurück. (Jan)

**Was kein Bild hat, wird gezeichnet.** Neuer Inhalt wird zuerst mit Platzhaltern beurteilt, erst danach werden Bilder und Musik generiert. (Jan)

**Touch.** Was man antippen soll, ist am Bildschirm mindestens etwa einen Zentimeter groß (das entspricht den 48 dp, die Android empfiehlt) und liegt nicht unter dem Daumen der anderen Hand oder unter den Knöpfen in den Ecken. (Vorschlag)

## 6. Tempo und Umfang

- **Ein Kapitel zielt auf 40 Minuten** beim ersten Durchspielen; der gedachte Weg nennt Minuten je Abschnitt. (aus `valley.md`)
- **Ein Rhythmus je Stück:** sehen, was falsch ist, verstehen, tun, belohnt werden. Die Belohnung ist die veränderte Welt, ein neuer Weg oder eine Erinnerung. Spieler brauchen das Gefühl stetigen Fortschritts durch neue Orte, Figuren oder Enthüllungen. (Quelle: Gilbert, „incremental reward“)
- **Neue Ziele tröpfeln.** Ein neues Ziel erscheint, bevor das alte schal wird, nicht alle auf einmal. (Quelle: Cozy-Design)
- **Ruhe braucht Textur.** Ein Weg ohne Aufgabe trägt nur, wenn Bild, Klang und Bewegung ihn tragen. *Tal:* Der Weg zur Warte am Ende sind vier Weltwechsel ohne Aufgabe; das kann ein Gang durch das heile Tal sein oder sich lang anfühlen. (Quelle; aus `valley.md`)
- **Jederzeit unterbrechbar.** Auf dem Handy enden Sitzungen ohne Vorwarnung. Der Stand wird nach jedem Schritt gespeichert, und das Notizbuch muss nach einer Pause sagen können, wo man war. (Vorschlag)
- **Hollywood-Zeit.** Nichts hängt an einer Uhr; die Welt wartet auf den Spieler. (Quelle: Gilbert; Jan: kein Zeitdruck)

## 7. Vom Einfall zum Kapitel

Der Ablauf, mit dem, was jeder Schritt hinterlässt, und den Stellen, an denen Jan entscheidet.

| Schritt | Ergebnis | Wer |
|---|---|---|
| 1. Kern | Ein Satz zum Riss in diesem Kapitel, die Regeln der Welt, die Figuren mit ihren fünf Angaben, was preisgegeben wird und was offen bleibt. | Claude entwirft, **Jan entscheidet** |
| 2. Abhängigkeiten | Das Diagramm, rückwärts vom Ende gebaut: Was braucht der letzte Schritt, was brauchen dessen Voraussetzungen. Geprüft auf Breite und Engstellen (Regel 10). | Claude |
| 3. Kapiteldatei | Orte, Wege, Schritte, Gespräche, Erinnerungen, Notizen als Blöcke, dazu der gedachte Weg mit Minuten. | Claude |
| 4. Prüfung am Schreibtisch | Die Prüflisten aus Abschnitt 8, Regel für Regel. | Claude, später ein eigener Prüfer |
| 5. Probefassung | Welten, Regeln und Texte mit Platzhaltern. Regelprüfung und Lösbarkeit laufen durch. | Claude |
| 6. Blindes Spielen | Jemand ohne Kenntnis der Lösung spielt und wird beobachtet (Abschnitt 8). | ein blinder Tester, Mensch oder Agent |
| 7. Urteil | Trägt die Geschichte, sind die Rätsel zu leicht oder zu undurchsichtig, wie lang hat es gedauert? | **Jan** |
| 8. Bild und Ton | Bilder und Musik, nur auf Anweisung und in der genannten Menge. | Claude generiert, **Jan urteilt** |
| 9. Feinschliff | Was beim Spielen mit Bild und Ton auffällt. | beide |

**Das Abhängigkeitsdiagramm.** Jeder Knoten ist ein Schritt oder ein Stück Wissen, jeder Pfeil heißt „braucht“, nicht „danach“. Man baut es vom Ende jeder Kette rückwärts. Ein gutes Diagramm besteht aus kleinen Rauten und endet je Akt in einer Engstelle. (Quelle: Gilbert) Die Blöcke der Kapiteldatei enthalten mit `needs` und `gives` schon alles dafür; ein Werkzeug kann das Diagramm daraus zeichnen.

## 8. Prüflisten

**P** heißt prüfbar durch ein Werkzeug, **U** braucht ein Urteil.

### Je Schritt

- [ ] P: Der Spieler kennt das Problem, bevor er die Lösung in der Hand hat (Regel 2).
- [ ] P: Mindestens zwei, besser drei Quellen unter `hint` (Regel 6).
- [ ] P: Der Schritt lässt sich nicht zu früh tun, wenn er dann nur schadet (Regel 4).
- [ ] P: Er verändert etwas Sichtbares oder Hörbares (Regel 13).
- [ ] U: Er hat einen Haken, oder er ist bewusst nur ein Schritt (Regel 9).
- [ ] U: Wer ihn zu früh oder falsch versucht, bekommt eine Antwort, die weiterhilft (Regel 11).

### Je Gespräch

- [ ] P: Höchstens eine Aufgabe (Regel 3).
- [ ] P: Das Wissen steht in der Tabelle der Figur (Regel 14).
- [ ] P: Es gibt einen eigenen Text für jeden Stand, in dem der Spieler mehr weiß als vorher (Regel 12).
- [ ] U: Keine Zeile über etwa 40 Wörter; kein Satz ist eine Anweisung.
- [ ] U: Es klingt nach dieser Figur und nach niemandem sonst.

### Je Erinnerung

- [ ] P: Eine Figur hat den Ort eingeführt und steht dort.
- [ ] P: Im Ausschnitt scheint nur durch, was der Spieler herstellen soll (Regel 5).
- [ ] U: Der Unterschied zum Jetzt ist auf einem Bildschirmfoto sofort zu sehen.

### Je Stück

- [ ] P: Vier bis sechs Fehler, jeder bringt einen Regler zurück.
- [ ] P: Kein Zustand ohne Ausweg; jeder Weg hinein hat einen Weg hinaus.
- [ ] P: Jedes benutzbare Objekt antwortet in jedem Zustand.
- [ ] U: Eine Landmarke; nichts Wichtiges hinter Hohem.
- [ ] U: Was sich benutzen lässt, erkennt man ohne Markierung.

### Je Kapitel

- [ ] P: Lösbar, ohne Sackgassen, in jeder Reihenfolge.
- [ ] P: Der kürzeste Weg überspringt kein Gespräch und keine Erinnerung, die für die Geschichte zählt (Regel 15).
- [ ] P: An den meisten Stellen sind zwei oder drei Schritte möglich, je Akt gibt es eine Engstelle (Regel 10).
- [ ] P: Die Liste „preisgegeben“ und „offen“ ist geführt; kein Text erklärt den Riss.
- [ ] U: Jede neue Idee wird eingeführt, geübt, gewendet und abgeschlossen (Regel 17).
- [ ] U: Rund 40 Minuten beim ersten Durchspielen.

### Spieltest

Was beobachtet wird, zählt mehr als das, was gesagt wird: Das Verhalten zeigt das Problem, die Rückmeldung nur das Symptom. (Quelle)

- **Blind.** Der Tester kennt weder Lösung noch Kapiteldatei und bekommt keine Hilfe.
- **Beobachten:** Wohin geht er zuerst? Wo hält er an? Was tippt er mehrmals an? Was versucht er, das nichts tut? Wo läuft er zurück? Was liest er im Notizbuch nach? Wie lange dauert jeder Abschnitt?
- **Lautes Denken** nur, wenn es um Bedienung und Verständlichkeit geht. Für Stimmung und Tempo stört es, weil es aus dem Spiel reißt. (Quelle)
- **Nach jeder Sitzung ändern, dann neu testen**, statt Befunde zu sammeln. Eine Sitzung ist eine Anekdote, ab etwa fünf zeigt sich ein Muster. (Quelle)
- **Protokoll je Befund:** Stelle, was der Tester tat, was er erwartete, was geschah, welche Regel es berührt.

**Was ein blinder Agent leisten kann.** Er spielt über Bildschirmfotos und Tipps, ohne die Weltdateien zu kennen, und führt dasselbe Protokoll. Er findet voraussichtlich Stellen, an denen man festhängt, Schritte, die nichts tun, Texte, die sich wiederholen, und Hinweise, die fehlen. Er findet nicht: ob etwas nervt, ob es sich gut anfühlt, ob es gut klingt, ob ein Rätsel Freude macht. Forschung zu spielenden KI-Agenten zeigt bisher vor allem, dass sie Abstürze und Logikfehler finden; ob sie auch Verständnisprobleme erkennen, ist kaum belegt. (Quelle) Das muss sich am Tal erst zeigen.

## 9. Das Tal, gemessen am Werkzeugkasten

Eine erste, ehrliche Durchsicht. Sie ersetzt nicht Jans Urteil.

**Was trägt**

- Die Laternen im falschen Wind sind ein Rätsel mit Haken (Regel 9).
- Die Kurbel über zwei Hälften des Wissens hält die Reihenfolge der Geschichte (Regeln 2 und 14).
- Das Verweilen wird eingeführt, geübt, gewendet und abgeschlossen (Regel 17).
- Das Wehr wirkt in vier Stücken; Ursache und Wirkung liegen auseinander (Leitplanke 7).
- Es gibt keine Sackgassen, und seit heute auch keine Schritte mehr, die zu früh schaden (Regeln 4 und 16).

**Wo es hakt**

- **Es ist fast eine einzige Kette (Regel 10).** Nach dem Dorf gibt es selten mehr als einen sinnvollen nächsten Schritt: Müller, Alter, Schrank, Mühle, Erinnerung, Fahne, Quelle, Stufen, Insel, Wehr, Fischerin, zurück ins Dorf, Warte. Parallel laufen nur Kleinigkeiten (die Laterne am Mühlenhügel, die Reihenfolge der Steine). Wer an einer Stelle nicht weiterweiß, hat nichts anderes zu tun.
- **Wetterfahne und Heuwagen sind Schritte, keine Rätsel (Regel 9).** Beide sind nach ein oder zwei Tipps erledigt. Das steht schon als offener Punkt in der Kapiteldatei.
- **Ein Hinweis statt drei (Regel 6).** Der Windschatten, das Verweilen und der Grund für das Wehr hängen jeweils an einer einzigen Figur.
- **Die Frau am Bach ist überspringbar (Regel 15).**
- **Hinweise haben keine Stufen (Regel 7).** Figuren sagen bei jedem Ansprechen dasselbe; die Figur am Wehr sagt es dafür sehr direkt.
- **Wenige Fehler (Abschnitt 5).** Quelle und Weiher haben drei, die Warte einen.
- **Der Weg zur Warte ist lang und leer (Abschnitt 6).**
- **Die erste Quelle ist ein Besuch ohne Tun.** Beim ersten Mal kann man dort nichts ausrichten, bevor die Mühle läuft.

## 10. Offene Fragen an Jan

1. **Wie schwer soll es sein?** Der Werkzeugkasten kann leichte Schritte und echte Rätsel beschreiben; das Mischungsverhältnis ist Geschmack. Dein Wunsch nach „mehr Widerstand“ und die heutigen Vereinfachungen (Wetterfahne, Wehr) ziehen in verschiedene Richtungen.
2. **Stufen bei Hinweisen (Regel 7):** Sollen Figuren beim zweiten Ansprechen deutlicher werden, oder widerspricht das dem Verwirrten und Mysteriösen?
3. **Drei Hinweise (Regel 6):** als feste Regel oder als Ziel?
4. **Breite (Regel 10):** Soll das Tal dafür umgebaut werden, oder gilt die Regel erst ab dem nächsten Kapitel?
5. **Fehlt eine Leitplanke**, die für dich selbstverständlich ist und hier nicht steht?

## 11. Quellen

Ein Teil der Recherche stützt sich auf Zusammenfassungen statt auf die Originale; das steht jeweils dabei.

- Ron Gilbert, „Why Adventure Games Suck“ (1989), zwölf Faustregeln: https://grumpygamer.com/why_adventure_games_suck/ (Original gelesen)
- Ron Gilbert, „Puzzle Dependency Charts“ (2014): https://grumpygamer.com/puzzle_dependency_charts/ (Original gelesen)
- Justin Alexander, „Three Clue Rule“: https://thealexandrian.net/wordpress/1118/roleplaying-games/three-clue-rule (Original gelesen; für Rollenspiel-Abenteuer geschrieben, hier übertragen)
- Andrew Plotkin, Zarfian Cruelty Scale: https://www.eblong.com/zarf/essays/cruelty.html und https://ifwiki.org/Cruelty_scale (über Zusammenfassung)
- Mark Brown, „What Makes a Good Puzzle?“ (Game Maker's Toolkit), Haken, Einsicht, Annahme: Notizen dazu unter https://notes.hamatti.org/gaming/puzzle-game-design (über Zusammenfassungen, das Video selbst nicht gesehen)
- Koichi Hayashida, vier Schritte im Leveldesign (Kishōtenketsu): https://www.mcvuk.com/development/video-nintendos-level-design-secrets-in-four-steps und https://kotaku.com/what-made-super-mario-3d-world-so-great-1691916400 (über Berichte)
- Henry Jenkins, „Game Design as Narrative Architecture“ (2004), erzählende Umgebung: https://courses.digitaldavidson.net/fms321/lab-2-narrative-architecture/ (über Kursnotizen)
- Ken Wong, „Designing Monument Valley: Less Game, More Experience“ (GDC): https://www.gdcvault.com/play/1021380/Designing-Monument-Valley-Less und https://ustwo.com/blog/monument-valley-out-now/ (über Zusammenfassungen)
- Alex Beachum und Loan Verneau, „Curiosity-Driven Exploration: The Design of Outer Wilds“ (GDC), Fortschritt über Wissen: https://gdconf.com/article/attend-gdc-and-learn-how-outer-wilds-nailed-curiosity-driven-game-design/ und https://medium.com/@cordialkobold/interview-with-alex-beachum-creative-director-of-outer-wilds-a01bb9631e20 (über Ankündigung und Interview)
- Hinweissysteme in Adventures, in der Welt verankerte Hinweise: https://intfiction.org/t/diegetic-hinting/69457 und https://www.pcgamer.com/uk/thimbleweed-park-gets-a-hint-system-and-player-character-dialogues (Forendiskussion und Bericht, keine gesicherte Lehre)
- Dialog, Kürze: https://www.gamedeveloper.com/game-platforms/8-key-principles-of-writing-effective-game-dialogue und https://bugnet.io/blog/how-to-write-game-dialogue-that-doesnt-drag (Praxisratgeber)
- Signale und Lesbarkeit: https://www.gamedeveloper.com/design/6-elements-of-visual-guidance (Praxisratgeber)
- Ruhige Spiele, Tempo: Daniel Cook u. a., „Cozy Games“: https://lostgarden.com/2018/01/24/cozy-games/ und https://urgametips.com/why-cozy-games-are-harder-to-make-than-they-look/ (über Zusammenfassungen)
- Spieltests: https://www.wayline.io/blog/indie-dev-playtesting-usability-testing (Blog eines Anbieters, als Praxisrat zu lesen) und https://kurzy.kpi.fei.tuke.sk/gamedev/en/lectures/testing.html (Vorlesungsunterlage zur RITE-Methode)
- Spielende KI-Agenten: https://arxiv.org/abs/2507.09490 und https://arxiv.org/html/2509.22170v1 (über Zusammenfassungen)

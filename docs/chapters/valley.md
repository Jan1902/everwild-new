# Kapitel: Das Tal

Stand: gebaut und bebildert (2026-10-12). Die Blöcke beschreiben, was die Weltdateien tun; ein Werkzeug, das die Blöcke selbst liest und durchspielt, gibt es noch nicht. Ziel: 40 Minuten beim ersten Durchspielen.

**Was das Kapitel von der großen Geschichte preisgibt:** fünf Bruchstücke davon, wie der Moment des Risses aussah. Sie passen nicht zusammen.

**Was offen bleibt:** was der Riss ist, wer der Spieler ist, warum das Notizbuch in seiner Handschrift beschrieben ist.

## Lesehilfe

Der Text ist zum Lesen und Diskutieren. Die Blöcke sind die verbindliche Fassung und werden von einem Werkzeug durchgespielt. Steht im Text etwas anderes als im Block, gilt der Block.

| Block | Bedeutung |
|---|---|
| `place` | ein Ort. Ein Punkt im Namen (`pond.island`) ist ein Teil derselben Welt, den man nicht immer erreicht. |
| `way` | ein Weg von einem Ort zum anderen. `back` sagt, wann er zurück offen ist. |
| `step` | etwas, das der Spieler tut. |
| `memory` | ein Ort der Erinnerung. Wirkt, wenn der Spieler dort stehen bleibt, solange das Stück noch einen offenen Fehler hat oder im Ausschnitt etwas anders ist als früher. |
| `talk` | ein Gesprächsstand einer Figur. `says` ist der Kern der Aussage, nicht der Wortlaut. |
| `rule` | eine Folge, die von selbst eintritt und wieder vergeht, wenn `when` nicht mehr gilt. |
| `path` | ein Abschnitt des gedachten Wegs, in dieser Reihenfolge spielbar. |

| Schlüssel | Bedeutung |
|---|---|
| `needs` | Bedingung. Komma heißt „und“, `any(a, b)` heißt „oder“, `not` verneint. |
| `while` | wie `needs`, aber was der Block gibt, vergeht wieder, sobald die Bedingung nicht mehr gilt. |
| `gives`, `takes` | was dazukommt und was wegfällt. |
| `cycles` | ein Wert, der bei jedem Mal zum nächsten der genannten Werte springt (der erste ist der Anfang). |
| `rolls` | ein Wert, der vom ersten Wert (dem Anfang) zum zweiten springt und danach zwischen dem zweiten und dritten wechselt. |
| `fixes` | Fehler, die damit behoben sind. |
| `undo` | der Schritt lässt sich zurücknehmen; der Name ist der Gegenschritt. |
| `hint` | woher der Spieler es wissen kann: `figur.wissen`, `memory.ort` oder `sight` (man sieht es). |
| `knows` | Wissen der Figur, das in diesem Gespräch steckt. Muss in ihrer Tabelle stehen. |

| Name | Bedeutung |
|---|---|
| `fact.x`, `fact.x=wert` | etwas, das im Spielstand gilt |
| `item.x` | ein Gegenstand, den der Spieler trägt |
| `note.x` | ein Eintrag im Notizbuch |
| `fixed.ort.fehler` | dieser Fehler ist behoben |
| `whole.ort` | alle Fehler dieses Orts sind behoben |

## Geschichte

Das Tal besteht aus fünf Stücken, die einmal im Kreis lagen: Dorf, Mühlenhügel, Quelle, Weiher, Warte und von dort wieder ins Dorf. Abends brannten die Laternen, oben auf der Warte brannte das große Licht, und das Wehr an der Quelle wurde über Nacht geschlossen.

Der Riss kam an einem Abend. Seitdem ist es im Tal Abend geblieben. Das Wehr ist zu, weil der Morgen nie kam. Der Wind weht falsch und bläst jede Flamme aus. Der Bogen am Dorfrand ist verschwunden. An Weiher und Warte erinnert sich niemand mehr, und die Bögen überspringen sie.

Jeder im Tal hat dabei etwas verloren:

- Der **Alte** stieg jeden Abend zur Warte hinauf und zündete das große Licht an. Er weiß es nicht mehr. Er weiß nur, dass seine Spieluhr nicht mehr richtig spielt und dass im Schrank etwas liegt, das ihm nicht gehört.
- Die **Frau am Bach** ging jeden Abend am Wasser entlang. Jetzt ist das Bachbett leer.
- Der **Müller** hat seine Kurbel verliehen und weiß nicht mehr an wen. Die Mühle steht, das Feld ist verdorrt.
- Das **Kind** steht jeden Tag am Abhang, weil dort manchmal etwas zurückkommt.
- Die **Fischerin** kam an dem Abend nicht mehr heim. Ihr Boot liegt im Schlamm, und das Licht auf der Insel, nach dem sie steuerte, ist aus.

Der Spieler bringt das Tal wieder in Gang und zündet am Ende das große Licht an, weil der Alte nicht mehr hinaufkommt. Von oben sieht man das Tal heil und dahinter weitere dunkle Stücke. Den Spieler kennen alle, er kennt niemanden. Warum, erfährt er hier nicht.

## Regeln der Welt

1. **Licht hält zusammen.** Ein Bogen führt vorwärts nur, wenn die Laterne seines Stücks brennt. Zurück führt jeder Bogen immer.
2. **Bögen kennen nur, was im Notizbuch steht.** Ein Stück, an das sich niemand erinnert, wird übersprungen. Steht es im Buch, führt der Bogen dorthin.
3. **Der falsche Wind bläst Flammen aus.** Er weht, solange die Mühle nicht richtig läuft. Eine Laterne hält dann nur im Windschatten eines Heuwagens. Den Wind sieht man als feine Streifen in der Luft; hinter Wagen und Häusern reißen sie ab. Am Mühlenhügel selbst ist es still.
4. **Erinnern geht dort, wo jemand jeden Tag steht.** Wer sich neben die Figur stellt und still wartet, sieht, was dort war. Auf der Warte ist es der Platz neben dem großen Licht, weil der Alte nicht mehr hinaufkommt. Der Spieler lernt das vom Kind und kann es erst danach.
5. **Das Wasser folgt dem Wehr.** Ist es zu, sind Bachbett und Weiher fast leer. Ist es offen, fließt der Bach, das Feld wächst, das Boot schwimmt.
6. **Die Heuwagen haben feste Plätze.** Ein angetippter Wagen rollt zuerst dorthin, wo er einmal stand, und danach zwischen diesem Platz und einem zweiten hin und her. Deshalb kann nie einer endgültig im Weg stehen.

## Orte

### Dorf vor dem Riss

Der Prolog. Das Spiel beginnt im Haus des Alten. Der Spieler lernt hier Laufen, Antippen und wie das Dorf richtig aussieht. Der Riss kommt, wenn er nach getaner Arbeit zur Tür hinausgeht: Das Bild wackelt, die Musik läuft herunter, es wird dunkel. Wenn das Licht zurückkehrt, liegt er im kaputten Dorf am Weg.

```place
id: before
music: village_theme
```

```step
id: p_light_lanterns
at: before
does: Aus dem Haus gehen und die drei Laternen des Dorfs anzünden. Frau und Kind grüßen.
needs: fact.evening_asked
gives: fact.p_lanterns
hint: old_man.evening_task
```

```step
id: p_wind_music_box
at: before
does: Zurück im Haus die Spieluhr aufziehen, die Kurbel steckt schon. Sie spielt das Leitmotiv. Auf dem Tisch liegt ein Buch, das sich nicht nehmen lässt.
needs: fact.p_lanterns
gives: fact.p_music
hint: old_man.evening_task
```

```step
id: p_rift
at: before
does: Der Alte nimmt seinen Mantel und schickt den Spieler vor. In der Tür wird die Melodie langsamer und tiefer. Riss. Der Spieler wacht am Weg auf.
needs: fact.p_music
gives: fact.rift
moves: village
hint: old_man.leaving
```

### Dorf

```place
id: village
music: village_theme
faults: lanterns, arch, wind, brook, carts, music_box
gives: note.village
```

`village` ist das Westufer mit dem Haus des Alten, dem Nachbarhaus und der Laterne an der Brücke. `village.east` ist das Ostufer mit der Frau, dem Kind am Abhang und dem Bogen.

```place
id: village.east
```

```place
id: house_inside
music: room_theme
```

| Fehler | Was man sieht |
|---|---|
| `lanterns` | Die drei Laternen sind dunkel. |
| `arch` | Am Ostrand steht eine einzelne Laterne vor dem Nichts. |
| `wind` | Bäume und Gras biegen sich in die falsche Richtung. |
| `brook` | Das Bachbett ist trocken. |
| `carts` | Der Heuwagen an der Brücke steht nicht dort, wo er stand: Er versperrt den Weg. Der Wagen im Osten zählt nicht dazu; er darf bleiben, wo der Spieler ihn hinschiebt, weil nichts im Spiel zeigt, wo er einmal stand. |
| `music_box` | Die Spieluhr im Haus spielt nicht oder schief. |

```way
from: village
to: village.east
by: Brücke
needs: not fact.cart_bridge=bridge
back: same
```

```way
from: village.east
to: mill_hill
by: Steinbogen am Ostrand
needs: fact.arch_back, fact.arch_lantern
back: always
```

```way
from: village
to: house_inside
by: Tür des Alten. Brennt die Laterne davor nicht, kommt man beim Nachbarhaus wieder heraus.
needs: fact.house_lantern
back: always
```

```step
id: roll_cart_bridge
at: village, village.east
does: Den Heuwagen an der Brücke antippen. `lee` ist der Platz auf der Windseite der Laterne vor dem Haus.
rolls: fact.cart_bridge = bridge, home, lee
hint: sight
```

```step
id: roll_cart_east
at: village.east
does: Den Heuwagen im Osten antippen. `lee` ist der Platz auf der Windseite der Laterne am Bogen.
rolls: fact.cart_east = astray, home, lee
hint: sight
```

```step
id: light_house_lantern
at: village
does: Die Laterne vor dem Haus des Alten anzünden. Ohne Windschatten flackert sie kurz und geht aus.
while: any(fact.cart_bridge=lee, fact.wind_right)
gives: fact.house_lantern
hint: stranger.lee_of_cart, stranger.light_means_home
```

```step
id: light_arch_lantern
at: village.east
does: Die Laterne am Bogen anzünden.
while: any(fact.cart_east=lee, fact.wind_right)
gives: fact.arch_lantern
hint: stranger.lee_of_cart
```

```step
id: light_bridge_lantern
at: village
does: Die Laterne an der Brücke anzünden. Kein Wagen kann sie schützen.
while: fact.wind_right
gives: fact.bridge_lantern
hint: sight
```

```step
id: take_notebook
at: house_inside
does: Das Buch vom Tisch nehmen. Was der Spieler bis dahin erfahren hat, steht schon darin.
needs: fact.met_old_man
gives: item.notebook
hint: old_man.book_on_table
```

```step
id: take_crank
at: house_inside
does: Den Schrank antippen und die Kurbel zwischen den Decken finden. Das geht erst, wenn der Alte gesagt hat, dass er sie weggepackt hat und nicht mehr findet; das sagt er, sobald der Spieler vom Müller weiß. Eine Randnotiz im Dialogfeld zeigt, dass die Kurbel eingesteckt ist.
needs: note.millers_crank, fact.crank_sought
gives: item.crank
hint: old_man.lent_thing, miller.millers_crank
```

```step
id: wind_music_box
at: house_inside
does: Die Spieluhr aufziehen. Solange im Dorf noch etwas falsch ist, spielt sie schief.
needs: item.crank, fixed.village.lanterns, fixed.village.arch, fixed.village.wind, fixed.village.brook, fixed.village.carts
fixes: village.music_box
hint: old_man.music_box
```

```memory
id: cliff
at: village.east
why: Das Kind steht hier jeden Tag.
shows: den Steinbogen am Ostrand, der jetzt fehlt, und die brennende Laterne daneben. Der Heuwagen im Osten erscheint hier nie (`without`), auch wenn sein alter Platz im Ausschnitt liegt: Er bleibt, wo der Spieler ihn hingeschoben hat, damit sein alter Platz nicht mit dem Windschatten verwechselt wird.
needs: note.still_place
gives: fact.arch_back, note.arch_village
fixes: village.arch
```

```memory
id: brook_walk
at: village.east
why: Die Frau ging hier jeden Abend am Bach entlang.
shows: die Brücke mit dem Heuwagen an seinem Platz, der brennenden Laterne und der Frau am Bach
needs: note.still_place, note.evening_walk
gives: note.cart_places
```

```rule
id: lanterns_burn
when: fact.house_lantern, fact.arch_lantern, fact.bridge_lantern
fixes: village.lanterns
```

```rule
id: carts_home
when: fact.cart_bridge=home
fixes: village.carts
```

### Mühlenhügel

```place
id: mill_hill
music: mill_theme
faults: lantern, vane, sails, field
gives: note.mill_hill
```

| Fehler | Was man sieht |
|---|---|
| `lantern` | Die Laterne am Bogen zur Quelle ist dunkel. |
| `vane` | Die Wetterfahne zeigt in eine andere Richtung als die Wolken ziehen: Richtig zeigt sie zur Mühle. Nach dem Riss steht sie eine Vierteldrehung daneben, damit der Unterschied zur Erinnerung zu sehen ist (die beiden Enden des Pfeils sehen sich ähnlich). |
| `sails` | Die Flügel stehen. Mit falscher Wetterfahne drehen sie rückwärts. |
| `field` | Das Feld hinter der Mühle ist verdorrt. |

Jedes Stück außer dem Dorf hat zwei Bögen: einen zurück und einen weiter. Die Laterne des Stücks gehört zum Bogen, der weiterführt; er leuchtet, solange sie brennt.

```way
from: mill_hill
to: spring
by: Steinbogen zur Quelle
needs: fact.mill_lantern
back: always
```

```step
id: light_mill_lantern
at: mill_hill
does: Die Laterne anzünden. Hier ist es windstill, sie hält.
gives: fact.mill_lantern
fixes: mill_hill.lantern
hint: sight
```

```step
id: set_vane
at: mill_hill
does: Die Wetterfahne zur Mühle hin drehen. Sie lässt sich erst drehen, wenn die Mühle rückwärts läuft und der Spieler aus der Erinnerung weiß, wohin sie zeigte. Läuft die Mühle richtig, macht der Müller sie fest.
needs: fact.mill_runs, note.vane_direction, not fact.wind_right
gives: fact.vane = east
hint: memory.millers_seat, miller.vane_decides
```

```step
id: start_mill
at: mill_hill
does: Die Kurbel einsetzen und die Mühle anwerfen. Die Kurbel bleibt stecken. Die Wetterfahne steht falsch, also läuft die Mühle rückwärts, bis sie richtig steht.
needs: item.crank
takes: item.crank
gives: fact.mill_runs
hint: miller.millers_crank
```

```memory
id: millers_seat
at: mill_hill
why: Der Müller steht hier jeden Abend und sieht dem Wetter zu.
shows: die Mühle mit drehenden Flügeln und die Wetterfahne zur Mühle hin (`east`)
needs: note.still_place, fact.mill_runs, not fact.wind_right
gives: note.vane_direction
```

```rule
id: vane_right
when: fact.vane=east
fixes: mill_hill.vane
```

```rule
id: wind_turns
when: fact.mill_runs, fact.vane=east
gives: fact.wind_right
fixes: mill_hill.sails, village.wind, spring.raft
```

```rule
id: grain_grows
when: fact.water
fixes: mill_hill.field
```

### Quelle

```place
id: spring
music: spring_theme
faults: lantern, raft, sluice
gives: note.spring
```

```place
id: spring.far
```

| Fehler | Was man sieht |
|---|---|
| `lantern` | Die Laterne am vorderen Bogen wird ausgeblasen. |
| `raft` | Das Floß liegt am anderen Ufer. |
| `sluice` | Das Wehr ist zu, das Bachbett darunter trocken. |

```way
from: spring
to: spring.far
by: Floß
needs: fact.wind_right
back: same
```

```way
from: spring
to: village.east
by: vorderer Steinbogen, solange der Weiher vergessen ist
needs: fact.spring_lantern, not note.pond
back: never
```

```way
from: spring
to: pond
by: vorderer Steinbogen, sobald der Weiher im Buch steht
needs: fact.spring_lantern, note.pond
back: always
```

```way
from: spring.far
to: pond
by: Stufen am Ende des Bachbetts, wo der Bach über den Rand fällt (vom Ostufer aus), dann zu Fuß durch das trockene Bett
needs: not fact.water
back: same
```

```step
id: light_spring_lantern
at: spring
does: Die Laterne am vorderen Bogen anzünden.
while: fact.wind_right
gives: fact.spring_lantern
fixes: spring.lantern
hint: sight
```

```step
id: open_sluice
at: spring.far
does: Das Wehr öffnen. Es lässt sich erst öffnen, wenn die Fischerin von ihrem Licht erzählt hat und die Laterne auf der Insel brennt: Vorher würde das Wasser nur den Weg dorthin versperren. Was die Figur am Wehr bis dahin sagt, gibt nur wieder, was sie von der Fischerin weiß.
needs: fact.island_lantern, note.island_light
gives: fact.water
fixes: spring.sluice
undo: close_sluice
hint: fisher.morning_water, miller.field_thirsty
```

### Weiher

```place
id: pond
music: pond_theme
faults: lantern, level, boat
gives: note.pond
```

```place
id: pond.island
```

```place
id: pond.far
```

| Fehler | Was man sieht |
|---|---|
| `lantern` | Die Laterne auf der Insel ist dunkel. |
| `level` | Der Weiher ist fast leer, Trittsteine liegen frei. |
| `boat` | Das Boot liegt am falschen Ufer im Schlamm, die Fischerin steht daneben. |

```way
from: pond
to: pond.island
by: Trittsteine, nur bei niedrigem Wasser
needs: not fact.water
back: same
```

```way
from: pond
to: pond.far
by: Boot der Fischerin
needs: fact.water, fact.boat_home
back: same
```

```way
from: pond
to: village.east
by: Steinbogen am Ufer, solange die Warte vergessen ist
needs: fact.island_lantern, not note.watch
back: never
```

```way
from: pond
to: watch
by: Steinbogen am Ufer, sobald die Warte im Buch steht
needs: fact.island_lantern, note.watch
back: always
```

```step
id: light_island_lantern
at: pond.island
does: Die Laterne auf der Insel anzünden.
gives: fact.island_lantern
fixes: pond.lantern
hint: fisher.island_light
```

```step
id: row_home
at: pond
does: Die Fischerin oder ihr Boot antippen. Sie fährt nur, wenn das Boot schwimmt und das Licht auf der Insel brennt. Die Überfahrt ist zu sehen: Beide gleiten im Boot hinüber. Danach ist sie daheim, und der Spieler rudert selbst.
needs: fact.water, fact.island_lantern
gives: fact.boat_home
moves: pond.far
fixes: pond.boat
hint: fisher.island_light, fisher.morning_water
```

```memory
id: jetty
at: pond.far
why: Die Fischerin saß hier jeden Abend auf dem Steg.
shows: über dem Wasser, hoch oben, ein großes Licht
needs: note.still_place, note.fishers_evening
gives: note.big_light
```

```rule
id: pond_fills
when: fact.water
fixes: pond.level, village.brook
```

### Warte

```place
id: watch
music: watch_theme
faults: light
```

| Fehler | Was man sieht |
|---|---|
| `light` | Das große Licht ist dunkel. Am Rand steht für jedes Stück des Tals ein kleines Licht; wo unten noch etwas falsch ist, ist es dunkel. |

```memory
id: lookout
at: watch
why: Der Alte stand hier jeden Abend.
shows: den Alten, wie er das große Licht anzündet, und unten nacheinander die Lichter des Tals
needs: note.still_place
gives: note.lookout
```

```step
id: light_big_light
at: watch
does: Den Docht einsetzen und das große Licht anzünden. Es fängt erst Feuer, wenn unten alles brennt.
needs: item.wick, whole.village, whole.mill_hill, whole.spring, whole.pond
takes: item.wick
fixes: watch.light
ends: chapter
hint: old_man.watch, memory.lookout
```

## Figuren

**Wenn ein Stück heil wird,** sagt dort jemand, dass es wie früher ist: im Dorf das Kind („Alle drei brennen!“), am Mühlenhügel der Müller, am Weiher die Fischerin vor ihrem Haus, an der Quelle die eigene Figur. Der Satz fällt beim ersten Mal, das der Spieler im heilen Stück steht.

**Abendplatz und Platz der Erinnerung.** Am Abend vor dem Riss leben die Figuren im Dorf ihren Abend: Die Frau steht am Ostufer des Bachs bei der Brücke, das Kind an der Wegkreuzung zwischen den Häusern und zählt die Lichter. Nach dem Riss stehen beide dort, wo für sie etwas zurückkommt: die Frau weiter östlich abseits des Bachs, das Kind am Abhang. Wird das Dorf heil, kehren sie an ihre Abendplätze zurück. Die Erinnerung an der Brücke zeigt die Frau am Bach.

Alle reden in Bruchstücken, mit Pausen und Abschweifungen, und nie als Anweisung. Im Dialog steht zuerst die Beschreibung („Frau am Bach“); ein Name erscheint erst, wenn die Figur sich an ihn erinnert.

| Figur | Ort | Weiß | Weiß nicht |
|---|---|---|---|
| `old_man` | `house_inside` | `evening_task`, `book_on_table`, `lent_thing`, `music_box`, `watch` (erst am Ende) | von wem die Kurbel ist, wohin er abends ging |
| `stranger` (Frau am Bach) | `village.east` | `lee_of_cart`, `light_means_home`, `evening_walk` | alles über Mühle und Kurbel |
| `miller` | `mill_hill` | `millers_crank`, `vane_decides`, `field_thirsty` | an wen er die Kurbel verlieh, wo sie ist, wohin die Fahne zeigte |
| `child` | `village.east` | `still_place` | fast alles andere |
| `fisher` | `pond`, später `pond.far` | `island_light`, `morning_water`, `fishers_evening` | den Weg zur Warte |

### Alter Mann

```talk
id: old_man.before
who: old_man
at: before
knows: evening_task
says: Es wird Abend. Die Laternen, wie immer. Und zieh mir die Spieluhr auf, meine Finger wollen nicht mehr.
```

```talk
id: old_man.leaving
who: old_man
at: before
when: fact.p_music
says: So ging sie. Er muss los. Der Spieler soll vorgehen, er kommt gleich nach.
```

```talk
id: old_man.first
who: old_man
when: not item.notebook
knows: book_on_table
says: Er erkennt den Spieler halb. Auf dem Tisch liegt ein Buch, seit er denken kann. Die Schrift sei nicht seine.
gives: fact.met_old_man
```

```talk
id: old_man.borrowed
who: old_man
when: item.notebook, not fact.mill_runs
knows: lent_thing, music_box
says: Die Spieluhr schweigt. Er hat sie immer mit etwas aufgezogen, das ihm nicht gehört. Er hat es weggepackt, irgendwohin, und findet es seit Jahren nicht. Von wem es ist, weiß er nicht mehr.
gives: note.lent_thing
```

```talk
id: old_man.humming
who: old_man
when: whole.village, not note.big_light
says: Er summt die Melodie mit. Abends sei er immer irgendwo hinaufgegangen. Wohin, fällt ihm nicht ein.
```

```talk
id: old_man.above
who: old_man
when: whole.village, note.big_light
knows: watch
says: Die Warte. Er hat das große Licht jeden Abend angezündet. An dem Abend wollte er gerade los. Er kommt nicht mehr hinauf und gibt dem Spieler den Docht. Er habe noch die Spieluhr gehört, und sie habe rückwärts gespielt.
gives: note.watch, item.wick, note.rift_old_man
```

### Frau am Bach

```talk
id: stranger.wind
who: stranger
when: not fact.wind_right
knows: lee_of_cart, light_means_home
says: Seit dem Riss fängt kein Docht mehr Feuer, der Wind ist anders. Als Kind saß sie hinter dem Heuwagen, da zog es nie. Und beim Alten sei wohl niemand daheim, vor seinem Haus ist es dunkel.
gives: note.lee_of_cart, note.light_means_home
```

```talk
id: stranger.evening
who: stranger
when: fact.wind_right
knows: evening_walk
says: Der Wind ist wieder der alte. Sie ging jeden Abend am Bach entlang bis zur Brücke, immer dieselben Schritte. An dem Abend seien alle Laternen auf einmal ausgegangen, noch bevor ein Wind ging.
gives: note.evening_walk, note.rift_stranger
```

### Müller

```talk
id: miller.crank
who: miller
when: not fact.mill_runs
knows: millers_crank
says: Ohne Kurbel wirft er die Mühle nicht an. Er hat sie verliehen, an einen, der etwas aufziehen wollte. Etwas Kleines. An wen, fällt ihm nicht ein. Von der Wetterfahne und seinem Platz spricht er hier noch nicht: eine Aufgabe je Gespräch.
gives: note.millers_crank
```

```talk
id: miller.backwards
who: miller
when: fact.mill_runs, not fact.wind_right
knows: vane_decides
says: Falsch herum. Die Mühle richtet sich nach der Fahne. Wohin die zeigte, wüsste er, wenn er an seinem Platz säße; aber er sieht dort nichts mehr.
```

```talk
id: miller.dry
who: miller
when: fact.wind_right, not fact.water
knows: field_thirsty
says: Sie läuft, aber leer. Das Feld bekam sein Wasser immer am Morgen, von oben. Es ist lange kein Morgen gewesen.
gives: note.field_thirsty
```

```talk
id: miller.grain
who: miller
when: fact.wind_right, fact.water
says: Mit Korn im Gang bleibt sie nicht mehr stehen. Er gibt die Kurbel zurück. An dem Abend hätten die Flügel einen Augenblick stillgestanden, bei vollem Wind.
gives: item.crank, note.rift_miller
```

### Kind

```talk
id: child.still
who: child
when: item.notebook
knows: still_place
says: Das Buch hattest du immer dabei. Es steht jeden Tag hier. Wenn man ganz still ist, kommt es zurück. Hier war etwas, durch das man gehen konnte.
gives: note.still_place
```

```talk
id: child.bright
who: child
when: fact.arch_back
says: An dem Abend sei es hell gewesen wie mittags.
gives: note.rift_child
```

### Fischerin

```talk
id: fisher.mud
who: fisher
at: pond
when: not fact.boat_home
knows: island_light, morning_water
says: Sie wollte nur noch heim. Ohne das Licht auf der Insel fährt sie nicht hinaus, und im Schlamm fährt niemand. Das Wasser kam immer am Morgen und ging am Abend.
gives: note.island_light, note.morning_water
```

```talk
id: fisher.home
who: fisher
at: pond.far
when: fact.boat_home
knows: fishers_evening
says: Sie saß jeden Abend auf dem Steg. Vom Wasser aus sah man oben das große Licht. Hinauf ging nur der Alte. An dem Abend habe es sich noch im Weiher gespiegelt, als es oben schon aus war.
gives: note.fishers_evening, note.rift_fisher
```

## Notizbuch

Was der Spieler erfährt, bevor er das Buch hat, steht darin, sobald er es nimmt. Niemand erklärt das.

| Eintrag | Art | Woher | Hängt zusammen mit |
|---|---|---|---|
| `village`, `mill_hill`, `spring`, `pond` | Weltstück | beim ersten Betreten | den Nachbarn im Kreis |
| `watch` | Weltstück | `old_man.above` | `pond`, `big_light` |
| `lee_of_cart` | Hinweis | `stranger.wind` | `village` |
| `light_means_home` | Hinweis | `stranger.wind` | `village` |
| `lent_thing` | Hinweis | `old_man.borrowed` | `millers_crank` |
| `millers_crank` | Hinweis | `miller.crank` | `lent_thing`, `mill_hill` |
| `still_place` | Hinweis | `child.still` | alle Erinnerungen |
| `field_thirsty` | Hinweis | `miller.dry` | `morning_water`, `spring` |
| `morning_water` | Hinweis | `fisher.mud` | `field_thirsty`, `spring` |
| `island_light` | Hinweis | `fisher.mud` | `pond` |
| `evening_walk` | Hinweis | `stranger.evening` | `cart_places` |
| `fishers_evening` | Hinweis | `fisher.home` | `big_light` |
| `arch_village` | Erinnerung | `cliff` | `village`, `mill_hill` |
| `vane_direction` | Erinnerung | `millers_seat` | `mill_hill` |
| `cart_places` | Erinnerung | `brook_walk` | `village`, `evening_walk` |
| `big_light` | Erinnerung | `jetty` | `watch`, `fishers_evening` |
| `lookout` | Erinnerung | `lookout` | `watch` |
| `rift_old_man`, `rift_stranger`, `rift_miller`, `rift_child`, `rift_fisher` | Riss (nur Geschichte) | je eine Figur | einander. Bleibt über das Kapitel hinaus offen. |

## Gedachter Weg

Die Minuten sind geschätzt und enthalten Laufwege und Lesen.

```path
part: Prolog
minutes: 4
order: old_man.before, p_light_lanterns, p_wind_music_box, old_man.leaving, p_rift
```

```path
part: Dorf
minutes: 11
order: roll_cart_bridge, stranger.wind, roll_cart_bridge, light_house_lantern, old_man.first, take_notebook, old_man.borrowed, child.still, cliff, roll_cart_east, light_arch_lantern
```

Der Heuwagen gibt die Brücke frei. Die erste Laterne geht im Wind aus, bis sie im Windschatten des Wagens steht. Das Licht vor dem Haus öffnet die Tür, das Buch bringt das Kind zum Reden, die Erinnerung bringt den Bogen zurück.

```path
part: Mühlenhügel und Quelle, erster Besuch
minutes: 5
order: light_mill_lantern, miller.crank
```

An der Quelle ist beim ersten Besuch nichts zu tun: Das Floß ist fort, die Laterne geht aus. Zurück führen die Bögen ins Dorf.

```path
part: Kurbel und Mühle
minutes: 6
order: take_crank, start_mill, miller.backwards, millers_seat, set_vane
```

Die Kurbel findet sich erst, wenn der Spieler beide Hälften kennt: Dann sagt der Alte, dass er sie weggepackt hat und nicht mehr findet, und der Spieler sucht im Schrank. Mit der Kurbel läuft die Mühle zuerst rückwärts; die richtige Richtung der Fahne zeigt die Erinnerung am Platz des Müllers. Mit dem richtigen Wind halten alle Laternen ohne Stein, und das Floß treibt zurück.

```path
part: Quelle und Weiher
minutes: 12
order: miller.dry, light_spring_lantern, fisher.mud, light_island_lantern, open_sluice, row_home, fisher.home, jetty
```

Hinunter zum Weiher geht es zuerst nur durch das trockene Bett, also bei geschlossenem Wehr. Die Insel erreicht man nur bei niedrigem Wasser, das andere Ufer nur bei hohem. Dazwischen liegt der Weg zurück zum Wehr; danach führt der Bogen der Quelle zum Weiher.

```path
part: Das Dorf wird heil
minutes: 8
order: stranger.evening, brook_walk, roll_cart_bridge, roll_cart_east, light_bridge_lantern, miller.grain, wind_music_box, old_man.above
```

```path
part: Warte
minutes: 5
order: lookout, light_big_light
```

Zur Warte geht der Spieler einmal durch das ganze heile Tal: Dorf, Mühlenhügel, Quelle, Weiher. Zusammen 51 Minuten.

## Bilder und Musik

Generiert am 2026-10-12 (`tools/valley_images.py`, `tools/world_images.py`), Rohdaten in `styletest/valley`, `styletest/pond` und `styletest/watch`:

- **Bodenbilder (2):** Weiher, Warte.
- **Heuwagen (1 Bild):** nachträglich generiert. Er hat die Steine ersetzt, die zu klein waren, um eine Laterne glaubhaft vor dem Wind zu schützen.
- **Objektbilder (14):** Kind, Fischerin, Pfahl und Pfeil der Wetterfahne, Spieluhr zu und offen, Feld gewachsen und verdorrt, Stufen, Boot, Trittsteine, großes Licht dunkel und brennend, kleines Licht der Warte.
- **Musik (2):** Weiher, Warte.

Es fehlt noch:

- **Die Spieluhr als Klang.** Sie hat ein Bild, aber das Leitmotiv ist nicht zu hören; das Spiel kann bisher nur ein Musikstück je Welt abspielen.
- **Das ferne Licht am Weiher** ist ein gezeichneter Schein.
- **Ein eigenes Bild der liegenden Figur** für den Riss; bisher ist es das umgekippte Standbild.

## Offen

1. **Wehr wieder schließen:** Feld und Weiher folgen dem Wehr (Regel 5). Mühlenhügel, Quelle und Weiher können deshalb kurz heil sein und es wieder verlieren.
2. **Wetterfahne:** Sie bewegt sich erst mit dem Eintrag `vane_direction` und dann mit einem Tipp in die richtige Stellung. Das ist kein Rätsel mehr, nur noch ein Schritt; schwerer wäre, dass der Spieler die Richtung selbst wählt.
3. **Heuwagen:** Der Windschatten ist nach zwei Tipps gefunden. Das schützt vor Sackgassen, ist aber kaum ein Rätsel. Schwerer wäre, dass der Spieler die Richtung selbst wählt.
4. **Prolog:** Das Buch liegt schon auf dem Tisch und lässt sich nicht nehmen. Ob der Spieler es im Prolog selbst hinlegt, entscheidet die große Geschichte.
5. **Wenige Fehler:** Quelle und Weiher haben je drei, die Warte einen. Das Konzept will vier bis sechs.
6. **Der Weg zur Warte:** vier Weltwechsel ohne Aufgabe. Gedacht als Gang durch das heile Tal; kann sich auch lang anfühlen.
7. **Ton des Alten:** Er vergisst und wiederholt sich. Das ist nah an Demenz und sollte zart bleiben.
8. **Hinweise der Frau sind entbehrlich:** Wer die Laternen selbst in den Windschatten eines Wagens bringt, braucht sie nie anzusprechen. Ihre Erinnerung an den Riss bekommt er dann erst spät.

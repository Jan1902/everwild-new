# Kapitel: Das Tal

Stand: gebaut und bebildert (2026-10-12), dazu ein neuer Prolog, das Notizbuch als RÃ¤tsel mit drei Einsichten und eine Szene zum Anspielen (2026-10-14). Die BlÃ¶cke beschreiben, was die Weltdateien tun; ein Werkzeug, das die BlÃ¶cke selbst liest und durchspielt, gibt es noch nicht. Ziel: 40 Minuten beim ersten Durchspielen.

**Was das Kapitel von der groÃŸen Geschichte preisgibt:** fÃ¼nf BruchstÃ¼cke davon, wie der Moment des Risses aussah. Sie passen nicht zusammen.

**Was offen bleibt:** was der Riss ist, wer der Spieler ist, wann er den Zettel geschrieben hat, an den er sich nicht erinnert (â€žEr geht hinauf. Ich soll nachkommen. Wenn oben das Licht â€“â€œ), und ob der Alte oben angekommen ist.

## Lesehilfe

Der Text ist zum Lesen und Diskutieren. Die BlÃ¶cke sind die verbindliche Fassung und werden von einem Werkzeug durchgespielt. Steht im Text etwas anderes als im Block, gilt der Block.

| Block | Bedeutung |
|---|---|
| `place` | ein Ort. Ein Punkt im Namen (`pond.island`) ist ein Teil derselben Welt, den man nicht immer erreicht. |
| `way` | ein Weg von einem Ort zum anderen. `back` sagt, wann er zurÃ¼ck offen ist. |
| `step` | etwas, das der Spieler tut. |
| `memory` | ein Ort der Erinnerung. Wirkt, wenn der Spieler dort stehen bleibt, solange das StÃ¼ck noch einen offenen Fehler hat oder im Ausschnitt etwas anders ist als frÃ¼her. |
| `talk` | ein GesprÃ¤chsstand einer Figur. `says` ist der Kern der Aussage, nicht der Wortlaut. |
| `rule` | eine Folge, die von selbst eintritt und wieder vergeht, wenn `when` nicht mehr gilt. |
| `path` | ein Abschnitt des gedachten Wegs, in dieser Reihenfolge spielbar. |
| `insight` | eine Einsicht: Der Spieler zieht im Notizbuch zwei Notizen (`from`) aufeinander, und sie wird aufgeschrieben. |

| SchlÃ¼ssel | Bedeutung |
|---|---|
| `needs` | Bedingung. Komma heiÃŸt â€žundâ€œ, `any(a, b)` heiÃŸt â€žoderâ€œ, `not` verneint. |
| `while` | wie `needs`, aber was der Block gibt, vergeht wieder, sobald die Bedingung nicht mehr gilt. |
| `gives`, `takes` | was dazukommt und was wegfÃ¤llt. |
| `cycles` | ein Wert, der bei jedem Mal zum nÃ¤chsten der genannten Werte springt (der erste ist der Anfang). |
| `rolls` | ein Wert, der vom ersten Wert (dem Anfang) zum zweiten springt und danach zwischen dem zweiten und dritten wechselt. |
| `fixes` | Fehler, die damit behoben sind. |
| `undo` | der Schritt lÃ¤sst sich zurÃ¼cknehmen; der Name ist der Gegenschritt. |
| `hint` | woher der Spieler es wissen kann: `figur.wissen`, `memory.ort` oder `sight` (man sieht es). |
| `knows` | Wissen der Figur, das in diesem GesprÃ¤ch steckt. Muss in ihrer Tabelle stehen. |

| Name | Bedeutung |
|---|---|
| `fact.x`, `fact.x=wert` | etwas, das im Spielstand gilt |
| `item.x` | ein Gegenstand, den der Spieler trÃ¤gt |
| `note.x` | ein Eintrag im Notizbuch |
| `fixed.ort.fehler` | dieser Fehler ist behoben |
| `whole.ort` | alle Fehler dieses Orts sind behoben |

## Geschichte

Das Tal besteht aus fÃ¼nf StÃ¼cken, die einmal im Kreis lagen: Dorf, MÃ¼hlenhÃ¼gel, Quelle, Weiher, Warte und von dort wieder ins Dorf. Abends brannten die Laternen, oben auf der Warte brannte das groÃŸe Licht, und das Wehr an der Quelle wurde Ã¼ber Nacht geschlossen.

Der Riss kam an einem Abend. Seitdem ist es im Tal Abend geblieben. Das Wehr ist zu, weil der Morgen nie kam. Der Wind weht falsch und blÃ¤st jede Flamme aus. Der Bogen am Dorfrand ist verschwunden. An Weiher und Warte erinnert sich niemand mehr, und die BÃ¶gen Ã¼berspringen sie.

Jeder im Tal hat dabei etwas verloren:

- Der **Alte** stieg jeden Abend zur Warte hinauf und zÃ¼ndete das groÃŸe Licht an. Er weiÃŸ es nicht mehr. Er weiÃŸ nur, dass seine Spieluhr nicht mehr richtig spielt und dass im Schrank etwas liegt, das ihm nicht gehÃ¶rt.
- Die **Frau am Bach** ging jeden Abend am Wasser entlang. Jetzt ist das Bachbett leer.
- Der **MÃ¼ller** hat seine Kurbel verliehen und weiÃŸ nicht mehr an wen. Die MÃ¼hle steht, das Feld ist verdorrt.
- Das **Kind** steht jeden Tag am Abhang, weil dort manchmal etwas zurÃ¼ckkommt.
- Die **Fischerin** kam an dem Abend nicht mehr heim. Ihr Boot liegt im Schlamm, und das Licht auf der Insel, nach dem sie steuerte, ist aus.

Der Spieler bringt das Tal wieder in Gang und zÃ¼ndet am Ende das groÃŸe Licht an, weil der Alte nicht mehr hinaufkommt. Von oben sieht man das Tal heil und dahinter weitere dunkle StÃ¼cke. Den Spieler kennen alle, er kennt niemanden. Warum, erfÃ¤hrt er hier nicht.

## Regeln der Welt

1. **Licht hÃ¤lt zusammen.** Ein Bogen fÃ¼hrt vorwÃ¤rts nur, wenn die Laterne seines StÃ¼cks brennt. ZurÃ¼ck fÃ¼hrt jeder Bogen immer.
2. **BÃ¶gen kennen nur, was im Notizbuch steht.** Ein StÃ¼ck, an das sich niemand erinnert, wird Ã¼bersprungen. Steht es im Buch, fÃ¼hrt der Bogen dorthin.
3. **Der falsche Wind blÃ¤st Flammen aus.** Er weht, solange die MÃ¼hle nicht richtig lÃ¤uft. Eine Laterne hÃ¤lt dann nur im Windschatten eines Heuwagens. Den Wind sieht man als feine Streifen in der Luft; hinter Wagen und HÃ¤usern reiÃŸen sie ab. Am MÃ¼hlenhÃ¼gel selbst ist es still.
4. **Erinnern geht dort, wo jemand jeden Tag steht.** Wer sich neben die Figur stellt und still wartet, sieht, was dort war. Auf der Warte ist es der Platz neben dem groÃŸen Licht, weil der Alte nicht mehr hinaufkommt. Der Spieler lernt das vom Kind und kann es erst danach.
5. **Das Wasser folgt dem Wehr.** Ist es zu, sind Bachbett und Weiher fast leer. Ist es offen, flieÃŸt der Bach, das Feld wÃ¤chst, das Boot schwimmt.
6. **Die Heuwagen haben feste PlÃ¤tze.** Ein angetippter Wagen rollt zuerst dorthin, wo er einmal stand, und danach zwischen diesem Platz und einem zweiten hin und her. Deshalb kann nie einer endgÃ¼ltig im Weg stehen.

## Orte

### Dorf vor dem Riss

Der Prolog. Das Spiel beginnt im Haus des Alten. Der Spieler lernt hier Laufen, Antippen und wie das Dorf richtig aussieht; ein Finger im Bild zeigt jeweils, was als NÃ¤chstes dran ist, wenn eine Weile nichts geschieht. Am Abend gehen die Frau am Bach und das Kind ihre kleinen Wege. Wenn die Spieluhr spielt, bricht der Alte auf: Man sieht ihn aus dem Haus gehen, Ã¼ber die BrÃ¼cke und durch den Bogen, und oben am Himmel geht ein fernes Licht an. Der Riss kommt, wenn der Spieler ihm folgen will und zur TÃ¼r hinausgeht: Es wird hell wie mittags, das Bild wackelt, die Musik lÃ¤uft herunter, es wird dunkel. Wenn das Licht zurÃ¼ckkehrt, liegt er im kaputten Dorf am Weg, und neben ihm liegt sein Buch im Gras. Darin steht der Abend schon in seiner Handschrift, und ein Zettel, den er nicht geschrieben zu haben glaubt.

```place
id: before
music: village_theme
```

```step
id: p_ask
at: before
does: Den Alten ansprechen. Er nennt die Abendrunde. Sie steht spÃ¤ter im Buch, das der Spieler noch nicht hat.
gives: note.village, note.evening_round, fact.evening_asked
hint: sight
```

```step
id: p_light_lanterns
at: before
does: Aus dem Haus gehen und die drei Laternen des Dorfs anzÃ¼nden. Frau und Kind gehen ihre Abendwege.
needs: fact.evening_asked
gives: fact.p_lanterns
hint: old_man.evening_task
```

```step
id: p_wind_music_box
at: before
does: ZurÃ¼ck im Haus die Spieluhr aufziehen, die Kurbel steckt schon. Sie spielt die Melodie und wird zur Musik des Raums. Der Alte summt mit, steht auf und bricht auf (Szene `old_man_leaves`): aus dem Haus, Ã¼ber die BrÃ¼cke, durch den Bogen; oben geht ein fernes Licht an.
needs: fact.p_lanterns
gives: fact.p_music, note.old_man_went
hint: old_man.evening_task
```

```step
id: find_notebook
at: village
does: Nach dem Aufwachen das Buch im Gras neben dem Weg aufheben. Es ist die eigene Handschrift, und der Abend steht schon darin, auch ein Zettel, an den der Spieler sich nicht erinnert.
needs: fact.rift
gives: item.notebook
hint: sight (ein Finger zeigt darauf)
```

```step
id: p_rift
at: before
does: Dem Alten folgen wollen und zur TÃ¼r hinausgehen. Es wird hell wie mittags, dann wird die Melodie langsamer und tiefer. Riss. Der Spieler wacht am Weg auf; im Buch steht ein Zettel in seiner Schrift, an den er sich nicht erinnert, und die Abendrunde ist durchgestrichen.
needs: fact.p_music
gives: fact.rift, note.rift_own
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

`village` ist das Westufer mit dem Haus des Alten, dem Nachbarhaus und der Laterne an der BrÃ¼cke. `village.east` ist das Ostufer mit der Frau, dem Kind am Abhang und dem Bogen.

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
| `wind` | BÃ¤ume und Gras biegen sich in die falsche Richtung. |
| `brook` | Das Bachbett ist trocken. |
| `carts` | Der Heuwagen an der BrÃ¼cke steht nicht dort, wo er stand: Er versperrt den Weg. Der Wagen im Osten zÃ¤hlt nicht dazu; er darf bleiben, wo der Spieler ihn hinschiebt, weil nichts im Spiel zeigt, wo er einmal stand. |
| `music_box` | Die Spieluhr im Haus spielt nicht oder schief. |

```way
from: village
to: village.east
by: BrÃ¼cke
needs: not fact.cart_bridge=bridge
back: same
```

```way
from: village.east
to: mill_hill
by: Steinbogen am Ostrand
needs: fact.arch_back, fact.arch_lantern, note.mill_way
back: always
```

```way
from: village
to: house_inside
by: TÃ¼r des Alten. Brennt die Laterne davor nicht, kommt man beim Nachbarhaus wieder heraus.
needs: fact.house_lantern
back: always
```

```step
id: roll_cart_bridge
at: village, village.east
does: Den Heuwagen an der BrÃ¼cke antippen. `lee` ist der Platz auf der Windseite der Laterne vor dem Haus. Dorthin rollt er erst, wenn der Spieler auf den Windschatten gekommen ist; vorher sagt er sich, dass der Wagen steht, wo er stand.
rolls: fact.cart_bridge = bridge, home, lee
needs: note.shelter (nur fÃ¼r lee)
hint: sight, insight.shelter
```

```step
id: roll_cart_east
at: village.east
does: Den Heuwagen im Osten antippen. `lee` ist der Platz auf der Windseite der Laterne am Bogen, wie beim anderen Wagen erst mit dem Windschatten.
rolls: fact.cart_east = astray, home, lee
needs: note.shelter (nur fÃ¼r lee)
hint: sight, insight.shelter
```

```insight
id: shelter
from: note.lantern_blown, note.lee_of_cart
says: Hinter dem Heuwagen ist es still. Steht er auf der Windseite einer Laterne, hÃ¤lt die Flamme.
hint: sight (der Wind ist als Streifen zu sehen, hinter dem Wagen reiÃŸen sie ab)
```

Die erste Einsicht des Spiels. Bis der Spieler zum ersten Mal einen Zettel zieht, zeigt ein durchscheinender Finger im Buch, wie es geht. Weil `lee_of_cart` nur von der Frau kommt, muss man sie jetzt ansprechen.

```step
id: light_house_lantern
at: village
does: Die Laterne vor dem Haus des Alten anzÃ¼nden. Ohne Windschatten flackert sie kurz und geht aus.
while: any(fact.cart_bridge=lee, fact.wind_right)
gives: fact.house_lantern
hint: stranger.lee_of_cart, stranger.light_means_home
```

```step
id: light_arch_lantern
at: village.east
does: Die Laterne am Bogen anzÃ¼nden.
while: any(fact.cart_east=lee, fact.wind_right)
gives: fact.arch_lantern
hint: stranger.lee_of_cart
```

```step
id: light_bridge_lantern
at: village
does: Die Laterne an der BrÃ¼cke anzÃ¼nden. Kein Wagen kann sie schÃ¼tzen.
while: fact.wind_right
gives: fact.bridge_lantern
hint: sight
```

```step
id: take_crank
at: house_inside
does: Den Schrank antippen und die Kurbel zwischen den Decken finden. Das geht erst, wenn der Spieler darauf gekommen ist, dass das Geliehene des Alten die Kurbel des MÃ¼llers ist. Danach sagt auch der Alte, dass er sie zwischen die Decken gepackt hat. Eine Randnotiz im Dialogfeld zeigt, dass die Kurbel eingesteckt ist.
needs: note.crank_whose
gives: item.crank
hint: insight.crank_whose, old_man.lent_thing
```

```insight
id: crank_whose
from: note.lent_thing, note.millers_crank
says: Das Geliehene des Alten ist die Kurbel des MÃ¼llers. Er hat sie weggepackt. Irgendwo in seinem Haus?
hint: Die beiden HÃ¤lften des Wissens (Alter und MÃ¼ller)
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
shows: die BrÃ¼cke mit dem Heuwagen an seinem Platz, der brennenden Laterne und der Frau am Bach
needs: note.still_place, note.evening_walk
gives: note.cart_places
```

```way
from: village.east
to: mill_hill
by: Steinbogen am Ostrand, solange der Spieler nicht weiÃŸ, wohin er fÃ¼hrt
needs: fact.arch_back, fact.arch_lantern, not note.mill_way
back: never
```

Ohne die Einsicht trÃ¤gt der Bogen, aber nirgendwohin: â€žEin Bogen fÃ¼hrt nur dorthin, wo man hinwill. Wo wollte ich hin?â€œ Der Spieler bleibt im Dorf, und auf der Karte zeigt ein Pfeil vom Dorf ins Ungewisse mit â€ž?â€œ.

```insight
id: mill_way
from: note.arch_village, note.old_man_went
says: Wo das Kind steht, war der Bogen. Durch ihn ging der Alte, zum MÃ¼hlenhÃ¼gel. Dahin fÃ¼hrt er.
hint: memory.cliff, die Szene beim Aufbruch des Alten
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

### MÃ¼hlenhÃ¼gel

```place
id: mill_hill
music: mill_theme
faults: lantern, vane, sails, field
gives: note.mill_hill
```

| Fehler | Was man sieht |
|---|---|
| `lantern` | Die Laterne am Bogen zur Quelle ist dunkel. |
| `vane` | Die Wetterfahne zeigt in eine andere Richtung als die Wolken ziehen: Richtig zeigt sie zur MÃ¼hle. Nach dem Riss steht sie eine Vierteldrehung daneben, damit der Unterschied zur Erinnerung zu sehen ist (die beiden Enden des Pfeils sehen sich Ã¤hnlich). |
| `sails` | Die FlÃ¼gel stehen. Mit falscher Wetterfahne drehen sie rÃ¼ckwÃ¤rts. |
| `field` | Das Feld hinter der MÃ¼hle ist verdorrt. |

Jedes StÃ¼ck auÃŸer dem Dorf hat zwei BÃ¶gen: einen zurÃ¼ck und einen weiter. Die Laterne des StÃ¼cks gehÃ¶rt zum Bogen, der weiterfÃ¼hrt; er leuchtet, solange sie brennt.

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
does: Die Laterne anzÃ¼nden. Hier ist es windstill, sie hÃ¤lt.
gives: fact.mill_lantern
fixes: mill_hill.lantern
hint: sight
```

```step
id: set_vane
at: mill_hill
does: Die Wetterfahne zur MÃ¼hle hin drehen. Sie lÃ¤sst sich erst drehen, wenn die MÃ¼hle rÃ¼ckwÃ¤rts lÃ¤uft und der Spieler aus der Erinnerung weiÃŸ, wohin sie zeigte. LÃ¤uft die MÃ¼hle richtig, macht der MÃ¼ller sie fest.
needs: fact.mill_runs, note.vane_direction, not fact.wind_right
gives: fact.vane = east
hint: memory.millers_seat, miller.vane_decides
```

```step
id: start_mill
at: mill_hill
does: Die Kurbel einsetzen und die MÃ¼hle anwerfen. Die Kurbel bleibt stecken. Die Wetterfahne steht falsch, also lÃ¤uft die MÃ¼hle rÃ¼ckwÃ¤rts, bis sie richtig steht.
needs: item.crank
takes: item.crank
gives: fact.mill_runs
hint: miller.millers_crank
```

```memory
id: millers_seat
at: mill_hill
why: Der MÃ¼ller steht hier jeden Abend und sieht dem Wetter zu.
shows: die MÃ¼hle mit drehenden FlÃ¼geln und die Wetterfahne zur MÃ¼hle hin (`east`)
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
faults: lantern, raft, gates, sluice
gives: note.spring
```

```place
id: spring.far
```

| Fehler | Was man sieht |
|---|---|
| `lantern` | Die Laterne am vorderen Bogen wird ausgeblasen. |
| `raft` | Das FloÃŸ liegt am anderen Ufer. |
| `gates` | Die drei Schieber Ã¼ber dem Wehr sind alle heruntergelassen. Am Morgen standen die beiden Ã¤uÃŸeren oben, der mittlere unten. |
| `sluice` | Das Wehr ist zu, das Bachbett darunter trocken. |

```way
from: spring
to: spring.far
by: FloÃŸ
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
by: Stufen am Ende des Bachbetts, wo der Bach Ã¼ber den Rand fÃ¤llt (vom Ostufer aus), dann zu FuÃŸ durch das trockene Bett
needs: not fact.water
back: same
```

```step
id: light_spring_lantern
at: spring
does: Die Laterne am vorderen Bogen anzÃ¼nden.
while: fact.wind_right
gives: fact.spring_lantern
fixes: spring.lantern
hint: sight
```

```memory
id: basin
at: spring.far
why: Der WehrwÃ¤rter steht hier jeden Tag und sieht die Schieber an.
shows: die drei Schieber, wie sie am Morgen standen (auÃŸen oben, in der Mitte unten)
needs: note.still_place
gives: note.gate_positions
```

```step
id: set_gates
at: spring.far
does: Die drei Schieber so stellen, wie sie am Morgen standen. Jeder Tipp zieht einen Schieber hoch oder lÃ¤sst ihn herunter; der Spieler liest die Stellung aus der Erinnerung ab und wÃ¤hlt selbst. Stehen alle drei richtig, rasten sie ein und bewegen sich nicht mehr. Wer die Quelle mit halb gestellten Schiebern verlÃ¤sst, findet sie wieder heruntergelassen.
needs: note.gate_positions
gives: fact.gates_set
fixes: spring.gates
hint: keeper.sluice_hours, memory.basin
```

Die Schieber sind das erste RÃ¤tsel, bei dem die Erinnerung einen Zustand zum Ablesen zeigt und nicht einen Platz (Jan, 2026-10-13). Sie sind gezeichnete Platzhalter. **Gestrichen (Jan, 2026-10-14):** Das RÃ¤tsel wirkt fehl am Platz und ist langweilig; es wird durch ein anderes ersetzt.

```step
id: open_sluice
at: spring.far
does: Das Wehr Ã¶ffnen. Es lÃ¤sst sich erst Ã¶ffnen, wenn die Fischerin von ihrem Licht erzÃ¤hlt hat, die Laterne auf der Insel brennt und die Schieber stehen wie am Morgen: Vorher wÃ¼rde das Wasser nur den Weg zur Insel versperren, und mit den Schiebern vom Abend gibt das Rad nicht nach. Was die Figur am Wehr bis dahin sagt, gibt nur wieder, was sie von der Fischerin weiÃŸ.
needs: fact.island_lantern, note.island_light, fact.gates_set
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
from: pond.far
to: village.east
by: Steinbogen am unteren Ende des Ufers der Fischerin, solange die Warte vergessen ist
needs: fact.island_lantern, not note.watch
back: never
```

```way
from: pond.far
to: watch
by: Steinbogen am unteren Ende des Ufers der Fischerin, sobald die Warte im Buch steht
needs: fact.island_lantern, note.watch
back: always
```

Der Bogen steht am Ufer der Fischerin, weil man von dort das groÃŸe Licht gesehen hat; hin kommt man nur mit dem Boot, und der WehrwÃ¤rter sagt das auch. Wer durch den Bogen geht, findet das Boot bei der RÃ¼ckkehr an dem Ufer, an dem er ankommt (vom Dorf her am Ankunftsufer, von der Warte her bei der Fischerin), damit es nie am falschen Ufer liegt.

```step
id: light_island_lantern
at: pond.island
does: Die Laterne auf der Insel anzÃ¼nden.
gives: fact.island_lantern
fixes: pond.lantern
hint: fisher.island_light
```

```step
id: row_home
at: pond
does: Die Fischerin oder ihr Boot antippen. Sie fÃ¤hrt nur, wenn das Boot schwimmt und das Licht auf der Insel brennt. Die Ãœberfahrt ist zu sehen: Beide gleiten im Boot hinÃ¼ber. Danach ist sie daheim, und der Spieler rudert selbst.
needs: fact.water, fact.island_lantern
gives: fact.boat_home
moves: pond.far
fixes: pond.boat
hint: fisher.island_light, fisher.morning_water
```

```memory
id: jetty
at: pond.far
why: Die Fischerin saÃŸ hier jeden Abend auf dem Steg.
shows: Ã¼ber dem Wasser, hoch oben, ein groÃŸes Licht
needs: note.still_place
gives: note.big_light
hint: fisher.whole_pond (ihr Ausruf am heilen Weiher nennt den Steg). Danach sagt die eigene Figur, dass der Mann oben am Wehr vielleicht weiÃŸ, wer dort hinaufging.
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
| `light` | Das groÃŸe Licht ist dunkel. Am Rand steht fÃ¼r jedes StÃ¼ck des Tals ein kleines Licht; wo unten noch etwas falsch ist, ist es dunkel. |

```memory
id: lookout
at: watch
why: Der Alte stand hier jeden Abend.
shows: den Alten, wie er das groÃŸe Licht anzÃ¼ndet, und unten nacheinander die Lichter des Tals
needs: note.still_place
gives: note.lookout
```

```step
id: light_big_light
at: watch
does: Den Docht einsetzen und das groÃŸe Licht anzÃ¼nden. Es fÃ¤ngt erst Feuer, wenn unten alles brennt.
needs: item.wick, whole.village, whole.mill_hill, whole.spring, whole.pond
takes: item.wick
fixes: watch.light
ends: chapter
hint: keeper.watch, memory.lookout
```

## Figuren

**Wenn ein StÃ¼ck heil wird,** sagt dort jemand, dass es wie frÃ¼her ist: im Dorf das Kind (â€žAlle drei brennen!â€œ), am MÃ¼hlenhÃ¼gel der MÃ¼ller, am Weiher die Fischerin vor ihrem Haus, an der Quelle der WehrwÃ¤rter. Der Satz fÃ¤llt beim ersten Mal, das der Spieler im heilen StÃ¼ck steht.

**Abendplatz und Platz der Erinnerung.** Am Abend vor dem Riss leben die Figuren im Dorf ihren Abend: Die Frau steht am Ostufer des Bachs bei der BrÃ¼cke, das Kind an der Wegkreuzung zwischen den HÃ¤usern und zÃ¤hlt die Lichter. Nach dem Riss stehen beide dort, wo fÃ¼r sie etwas zurÃ¼ckkommt: die Frau weiter Ã¶stlich abseits des Bachs, das Kind am Abhang. Wird das Dorf heil, kehren sie an ihre AbendplÃ¤tze zurÃ¼ck. Die Erinnerung an der BrÃ¼cke zeigt die Frau am Bach.

Alle reden in BruchstÃ¼cken, mit Pausen und Abschweifungen, und nie als Anweisung. Im Dialog steht zuerst die Beschreibung (â€žFrau am Bachâ€œ); ein Name erscheint erst, wenn die Figur sich an ihn erinnert.

| Figur | Ort | WeiÃŸ | WeiÃŸ nicht |
|---|---|---|---|
| `old_man` | `house_inside` | `evening_task`, `lent_thing`, `music_box`, `fetched_at_sluice` (erst am Ende) | von wem die Kurbel ist, wohin er abends ging |
| `stranger` (Frau am Bach) | `village.east` | `lee_of_cart`, `light_means_home`, `evening_walk` | alles Ã¼ber MÃ¼hle und Kurbel |
| `miller` | `mill_hill` | `millers_crank`, `vane_decides`, `field_thirsty` | an wen er die Kurbel verlieh, wo sie ist, wohin die Fahne zeigte |
| `child` | `village.east` | `still_place` | fast alles andere |
| `fisher` | `pond`, spÃ¤ter `pond.far` | `island_light`, `morning_water`, `fishers_evening` | den Weg zur Warte |
| `keeper` (WehrwÃ¤rter) | `spring` | `sluice_hours`, `watch`, `over_the_water` | fÃ¼r wen er den Docht aufhebt, bis der Spieler vom groÃŸen Licht erzÃ¤hlt |

### Alter Mann

```talk
id: old_man.before
who: old_man
at: before
knows: evening_task
says: Es wird Abend. Die Laternen, wie immer. Und zieh mir die Spieluhr auf, meine Finger wollen nicht mehr. Dazu das Buch des Spielers, das wieder auf seinem Tisch lag: â€žSchreib's dir auf.â€œ
gives: item.notebook, note.evening_round
```

```talk
id: old_man.leaving
who: old_man
at: before
when: fact.p_music
says: So ging sie. Er muss los, hinauf. Der Spieler soll bleiben und ihr zuhÃ¶ren, dann nachkommen: â€žDu weiÃŸt ja, wohin.â€œ Danach die Szene seines Aufbruchs.
```

```talk
id: old_man.first
who: old_man
when: not fact.met_old_man
says: Er erkennt den Spieler halb, am Gang. Der Spieler schreibe immer alles in sein Buch; er solle aufschreiben, dass der Alte hier sitzt. Worauf er wartet, weiÃŸ er nicht mehr.
gives: fact.met_old_man
```

```talk
id: old_man.borrowed
who: old_man
when: not fact.crank_taken, not note.crank_whose
knows: lent_thing, music_box
says: Die Spieluhr schweigt. Er hat sie immer mit etwas aufgezogen, das ihm nicht gehÃ¶rt. Er hat es weggepackt, irgendwohin, und findet es seit Jahren nicht. Von wem es ist, weiÃŸ er nicht mehr.
gives: note.lent_thing
```

```talk
id: old_man.yours
who: old_man
when: not fact.crank_taken, note.crank_whose
says: Die Kurbel des MÃ¼llers, natÃ¼rlich. Er hat sie zwischen die Decken gepackt, glaubt er. Der Spieler soll sie ihm bringen und ihn grÃ¼ÃŸen.
```

```talk
id: old_man.humming
who: old_man
when: whole.village, not fact.watch_told
knows: fetched_at_sluice
says: Er summt die Melodie mit. An dem Abend habe die Spieluhr rÃ¼ckwÃ¤rts gespielt, er stand schon im Mantel. Abends sei er immer irgendwo hinaufgegangen; wohin, fÃ¤llt ihm nicht ein. Vorher habe er oben am Wehr etwas abgeholt, der dort wisse es vielleicht noch.
gives: note.rift_old_man
```

```talk
id: old_man.go
who: old_man
when: whole.village, fact.watch_told
says: Die Warte, ja. Er hat es jeden Abend angezÃ¼ndet. Der Spieler soll gehen; brennt es oben, sieht er es vom Fenster.
```

Die Warte fÃ¤llt nicht mehr dem Alten ein, sondern dem WehrwÃ¤rter an der Quelle (Jan, 2026-10-13): Er steht eine Welt neben dem Weiher, und die Quelle hatte zu wenig Inhalt. Der Alte behÃ¤lt sein BruchstÃ¼ck vom Riss und schickt, wenn man zuerst zu ihm kommt, zum Wehr.

### WehrwÃ¤rter

Steht an der Quelle neben dem Wehr. Abends schloss er es, morgens Ã¶ffnete er es; seit dem Riss wartet er auf den Morgen. Er drehte die Dochte fÃ¼r das groÃŸe Licht aus dem Schilf der Quelle, und der Alte holte jeden Abend einen bei ihm ab, bevor die Fischerin ihn Ã¼ber den Weiher fuhr. Er hat kein BruchstÃ¼ck vom Riss und noch kein Bild (gezeichneter Platzhalter).

```talk
id: keeper.evening
who: keeper
at: spring
when: not fact.water
knows: sluice_hours
says: Abends zu, morgens auf. Es ist schon sehr lange Abend. Der Spieler mag selbst am Rad drehen, soll aber erst nachsehen, was unten liegt. Auch die Schieber hat er heruntergelassen; wie sie morgens standen, fÃ¤llt ihm nicht ein, obwohl er jeden Tag hier steht.
```

```talk
id: keeper.open
who: keeper
at: spring
when: fact.water, not note.big_light
says: Es lÃ¤uft, so klingt der Morgen. Abends holte hier immer einer etwas ab. Er hat es noch und weiÃŸ nicht mehr, fÃ¼r wen.
```

```talk
id: keeper.above
who: keeper
at: spring
when: note.big_light
knows: watch, over_the_water
says: Die Warte. Der Alte aus dem Dorf zÃ¼ndete dort jeden Abend das groÃŸe Licht an, holte vorher hier seinen Docht, und die Fischerin fuhr ihn hinÃ¼ber: Ã¼bers Wasser, anders kommt man nicht zum Bogen. Er gibt dem Spieler den Docht von jenem Abend.
gives: note.watch, item.wick, fact.watch_told
```

```talk
id: keeper.go
who: keeper
at: spring
when: fact.watch_told
says: Ãœber den Weiher, mit dem Boot; der Bogen steht am Ufer der Fischerin. Das groÃŸe Licht fÃ¤ngt erst, wenn unten alles brennt.
```

### Frau am Bach

```talk
id: stranger.wind
who: stranger
when: not fact.wind_right
knows: lee_of_cart, light_means_home
says: Seit dem Riss fÃ¤ngt kein Docht mehr Feuer, der Wind ist anders. Als Kind saÃŸ sie hinter dem Heuwagen, da zog es nie. Und beim Alten sei wohl niemand daheim, vor seinem Haus ist es dunkel.
gives: note.lee_of_cart, note.light_means_home
```

```talk
id: stranger.evening
who: stranger
when: fact.wind_right
knows: evening_walk
says: Der Wind ist wieder der alte. Sie ging jeden Abend am Bach entlang bis zur BrÃ¼cke, immer dieselben Schritte. An dem Abend seien alle Laternen auf einmal ausgegangen, noch bevor ein Wind ging.
gives: note.evening_walk, note.rift_stranger
```

### MÃ¼ller

```talk
id: miller.crank
who: miller
when: not fact.mill_runs
knows: millers_crank
says: Ohne Kurbel wirft er die MÃ¼hle nicht an. Er hat sie verliehen, an einen, der etwas aufziehen wollte. Etwas Kleines. An wen, fÃ¤llt ihm nicht ein. Von der Wetterfahne und seinem Platz spricht er hier noch nicht: eine Aufgabe je GesprÃ¤ch.
gives: note.millers_crank
```

```talk
id: miller.backwards
who: miller
when: fact.mill_runs, not fact.wind_right
knows: vane_decides
says: Falsch herum. Die MÃ¼hle richtet sich nach der Fahne. Wohin die zeigte, wÃ¼sste er, wenn er an seinem Platz sÃ¤ÃŸe; aber er sieht dort nichts mehr.
```

```talk
id: miller.dry
who: miller
when: fact.wind_right, not fact.water
knows: field_thirsty
says: Sie lÃ¤uft, aber leer. Das Feld bekam sein Wasser immer am Morgen, von oben. Es ist lange kein Morgen gewesen.
gives: note.field_thirsty
```

```talk
id: miller.grain
who: miller
when: fact.wind_right, fact.water
says: Mit Korn im Gang bleibt sie nicht mehr stehen. Er gibt die Kurbel zurÃ¼ck. An dem Abend hÃ¤tten die FlÃ¼gel einen Augenblick stillgestanden, bei vollem Wind.
gives: item.crank, note.rift_miller
```

### Kind

```talk
id: child.still
who: child
when: item.notebook
knows: still_place
says: Das Buch hattest du immer dabei. Es steht jeden Tag hier. Wenn man ganz still ist, kommt es zurÃ¼ck. Hier war etwas, durch das man gehen konnte.
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
says: Sie wollte nur noch heim. Ohne das Licht auf der Insel fÃ¤hrt sie nicht hinaus, und im Schlamm fÃ¤hrt niemand. Das Wasser kam immer am Morgen und ging am Abend.
gives: note.island_light, note.morning_water
```

```talk
id: fisher.home
who: fisher
at: pond.far
when: fact.boat_home
knows: fishers_evening
says: Sie saÃŸ jeden Abend auf dem Steg. Vom Wasser aus sah man oben das groÃŸe Licht. Hinauf ging nur der Alte. An dem Abend habe es sich noch im Weiher gespiegelt, als es oben schon aus war.
gives: note.fishers_evening, note.rift_fisher
```

## Notizbuch

Der Spieler hat das Buch vom Alten im Prolog. Links ist die Karte (`data/map.json`), rechts liegen die Notizen als Zettel. WeltstÃ¼cke stehen nur auf der Karte; Notizen, aus denen eine Einsicht wurde, liegen unter ihr.

| Eintrag | Art | Woher | HÃ¤ngt zusammen mit |
|---|---|---|---|
| `evening_round` | Hinweis, nach dem Riss durchgestrichen | `old_man.before` | |
| `old_man_went` | Hinweis | Szene beim Aufbruch | Einsicht `mill_way` |
| `lantern_blown` | Hinweis | eine Laterne geht im Wind aus | Einsicht `shelter` |
| `rift_own` | Riss | beim Aufwachen | |
| `shelter`, `mill_way`, `crank_whose` | Einsicht | Denken (`from`) | |
| `village`, `mill_hill`, `spring`, `pond` | WeltstÃ¼ck | beim ersten Betreten | den Nachbarn im Kreis |
| `watch` | WeltstÃ¼ck | `keeper.above` | `pond`, `big_light` |
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
| `gate_positions` | Erinnerung | `basin` | `spring` |
| `cart_places` | Erinnerung | `brook_walk` | `village`, `evening_walk` |
| `big_light` | Erinnerung | `jetty` | `watch`, `fishers_evening` |
| `lookout` | Erinnerung | `lookout` | `watch` |
| `rift_old_man`, `rift_stranger`, `rift_miller`, `rift_child`, `rift_fisher` | Riss (nur Geschichte) | je eine Figur | einander. Bleibt Ã¼ber das Kapitel hinaus offen. |

## Gedachter Weg

Die Minuten sind geschÃ¤tzt und enthalten Laufwege und Lesen.

```path
part: Prolog
minutes: 6
order: p_ask, p_light_lanterns, p_wind_music_box, old_man.leaving, p_rift
```

```path
part: Dorf
minutes: 12
order: find_notebook, roll_cart_bridge, light_house_lantern, stranger.wind, shelter, roll_cart_bridge, light_house_lantern, old_man.first, old_man.borrowed, child.still, cliff, roll_cart_east, light_arch_lantern, mill_way
```

Der Heuwagen gibt die BrÃ¼cke frei. Die erste Laterne geht im Wind aus; die Frau erzÃ¤hlt vom Heuwagen; erst der Gedanke â€žWindschattenâ€œ bringt den Wagen vor die Laterne. Das Licht vor dem Haus Ã¶ffnet die TÃ¼r. Das Kind (zu dem man auch zuerst gehen kann) bringt den Bogen zurÃ¼ck, aber wohin er fÃ¼hrt, weiÃŸ der Spieler erst, wenn er ihn mit dem Weg des Alten zusammendenkt. Haus und Bogen sind zwei FÃ¤den, die sich in beliebiger Reihenfolge spielen lassen.

```path
part: MÃ¼hlenhÃ¼gel und Quelle, erster Besuch
minutes: 5
order: light_mill_lantern, miller.crank
```

An der Quelle ist beim ersten Besuch nichts zu tun: Das FloÃŸ ist fort, die Laterne geht aus. ZurÃ¼ck fÃ¼hren die BÃ¶gen ins Dorf.

```path
part: Kurbel und MÃ¼hle
minutes: 6
order: crank_whose, old_man.yours, take_crank, start_mill, miller.backwards, millers_seat, set_vane
```

Die Kurbel findet sich erst, wenn der Spieler beide HÃ¤lften zusammendenkt: das Geliehene des Alten und die Kurbel des MÃ¼llers. Dann sucht er im Schrank. Mit der Kurbel lÃ¤uft die MÃ¼hle zuerst rÃ¼ckwÃ¤rts; die richtige Richtung der Fahne zeigt die Erinnerung am Platz des MÃ¼llers. Mit dem richtigen Wind halten alle Laternen ohne Stein, und das FloÃŸ treibt zurÃ¼ck.

```path
part: Quelle und Weiher
minutes: 12
order: miller.dry, light_spring_lantern, fisher.mud, light_island_lantern, keeper.evening, basin, set_gates, open_sluice, row_home, fisher.home, jetty
```

Hinunter zum Weiher geht es zuerst nur durch das trockene Bett, also bei geschlossenem Wehr. Die Insel erreicht man nur bei niedrigem Wasser, das andere Ufer nur bei hohem. Dazwischen liegt der Weg zurÃ¼ck zum Wehr; danach fÃ¼hrt der Bogen der Quelle zum Weiher.

```path
part: Das Dorf wird heil
minutes: 8
order: stranger.evening, brook_walk, roll_cart_bridge, roll_cart_east, light_bridge_lantern, miller.grain, wind_music_box, old_man.humming
```

```path
part: Warte
minutes: 5
order: keeper.above, lookout, light_big_light
```

Zur Warte geht der Spieler einmal durch das ganze heile Tal: Dorf, MÃ¼hlenhÃ¼gel, Quelle, Weiher. Zusammen 51 Minuten.

## Bilder und Musik

Generiert am 2026-10-12 (`tools/valley_images.py`, `tools/world_images.py`), Rohdaten in `styletest/valley`, `styletest/pond` und `styletest/watch`:

- **Bodenbilder (2):** Weiher, Warte.
- **Heuwagen (1 Bild):** nachtrÃ¤glich generiert. Er hat die Steine ersetzt, die zu klein waren, um eine Laterne glaubhaft vor dem Wind zu schÃ¼tzen.
- **Objektbilder (14):** Kind, Fischerin, Pfahl und Pfeil der Wetterfahne, Spieluhr zu und offen, Feld gewachsen und verdorrt, Stufen, Boot, Trittsteine, groÃŸes Licht dunkel und brennend, kleines Licht der Warte.
- **Musik (2):** Weiher, Warte.

Es fehlt noch:

- **Die Spieluhr als Klang.** Sie hat ein Bild, aber das Leitmotiv ist nicht zu hÃ¶ren; das Spiel kann bisher nur ein MusikstÃ¼ck je Welt abspielen.
- **Das ferne Licht am Weiher** ist ein gezeichneter Schein.
- **Ein eigenes Bild der liegenden Figur** fÃ¼r den Riss; bisher ist es das umgekippte Standbild.

## Offen

1. **Wehr wieder schlieÃŸen:** Feld und Weiher folgen dem Wehr (Regel 5). MÃ¼hlenhÃ¼gel, Quelle und Weiher kÃ¶nnen deshalb kurz heil sein und es wieder verlieren.
2. **Wetterfahne:** Sie bewegt sich erst mit dem Eintrag `vane_direction` und dann mit einem Tipp in die richtige Stellung. Das ist kein RÃ¤tsel mehr, nur noch ein Schritt; schwerer wÃ¤re, dass der Spieler die Richtung selbst wÃ¤hlt.
3. **Heuwagen:** Der Windschatten ist nach zwei Tipps gefunden. Das schÃ¼tzt vor Sackgassen, ist aber kaum ein RÃ¤tsel. Schwerer wÃ¤re, dass der Spieler die Richtung selbst wÃ¤hlt.
4. **Prolog:** Zum Anspielen gibt der Alte dem Spieler das Buch als dessen eigenes (Claude, 2026-10-14). Ob das so bleibt, entscheidet Jan; die alte Fassung lieÃŸ es seit jeher in fremder Schrift auf dem Tisch liegen.
5. **Wenige Fehler:** Quelle und Weiher haben je drei, die Warte einen. Das Konzept will vier bis sechs.
6. **Der Weg zur Warte:** vier Weltwechsel ohne Aufgabe. Gedacht als Gang durch das heile Tal; kann sich auch lang anfÃ¼hlen.
7. **Ton des Alten:** Er vergisst und wiederholt sich. Das ist nah an Demenz und sollte zart bleiben.
8. **Die Einsichten sind leicht:** Die drei Paare liegen nah beieinander, und wer alle Zettel aufeinanderzieht, findet sie auch durch Probieren. FÃ¼rs Anspielen ist das gewollt; schwerer wÃ¼rden sie mit mehr Zetteln, die auf den ersten Blick zu passen scheinen.
9. **Was die Einsicht im Dorf an RÃ¤tsel lÃ¤sst:** Der Bogen fÃ¼hrt erst nach dem Gedanken zum MÃ¼hlenhÃ¼gel. Ob â€žein Bogen fÃ¼hrt nur dorthin, wo man hinwillâ€œ als Regel trÃ¤gt, zeigt das Spielen.

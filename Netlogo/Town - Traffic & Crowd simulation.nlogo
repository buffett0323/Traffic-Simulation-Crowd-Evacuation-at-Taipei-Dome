breed[cars car]
breed[houses house]
breed[trees tree]
breed[crossings crossing]
breed[lightsR lightR]
breed[lightsL lightL]
breed[lightsU lightU]
breed[lightsD lightD]
breed[persons person]
patches-own[
  meaning        ;;the role of the patch
  will-cross?    ;;is anybody going to cross this crossing?
  used           ;;tells how many pedestrians are using this crossing
  traffic        ;;tells how many car will cross this crossing, if traffic > 0, it's dangerous for pedestrians
]
globals[
  redV           ;;this variable is used to switch traffic lights..it means how many times there was red in the vertical direction
  greenV         ;;how many times there was green in the vertical direction
  redH           ;;how many times there was red in the horizontal direction
  greenH         ;;how many times there was green in the horizontal direction
  speedLimit     ;;the global maximum speed in the city

]
persons-own[
  speed          ;;current speed of person
  walk-time      ;;how long they will walk before crossing the road
  crossing-part  ;;it divides the crossing to parts
  waiting?       ;;is pedestrian waiting for crossing the road?

]

cars-own[
  speed          ;;car's current speed
  maxSpeed       ;;each car has its own maximum speed depending on the global maximum speeed (little bit lower or higher)
  will-turn?     ;;whether car is going to turn or not
  turnX          ;;coordinates of patch where car will change its direction when turning left
  turnY          ;;coordinates of patch where car will change its direction when turning left
  politeness     ;;how politeness cars are, that means how often they will stop and let people cross the road
  will-stop?     ;;whether the car will stop and let pedestrian(s) to cross the road
]


to setup
  ca
  set speedLimit speed-limit
  draw-sidewalk
  draw-roads
  draw-houses&trees
  draw-crossings
  place-cars
  place-lights
  place-people

  reset-ticks
  tick

end

to go
  move-cars
  control-traffic-lights
  move-people
  plot-waiting

  tick
end


to control-traffic-lights
  if ticks mod (50 * lights-interval * greenH + 65 * lights-interval * redH ) = 0 [change-color lightsR "H" change-color lightsL "H"]
  if ticks mod (50 * lights-interval * greenV + 65 * lights-interval * redV ) = 0 [change-color lightsU "V" change-color lightsD "V"]
end

to change-color [lights D]

  ask one-of lights [
    ifelse color = red [
      ifelse D = "H" [
        set greenH greenH + 1
        ][
        set greenV greenV + 1]
        ]
    [
      ifelse D = "H" [
        set redH redH + 1][
        set redV redV + 1]
        ]

  ]

  ask lights [
    ifelse color = red [set color green][set color red]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Setup procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to draw-roads
  ;create crossroads
  ask patches with [(pxcor mod 40 = 39 or pxcor mod 40 = 0 or pxcor mod 40 = 36 or pxcor mod 40 = 37 or pxcor mod 40 = 38 )
    and (pycor mod 22 = 21 or pycor mod 22 = 0 or pycor mod 22 = 19 or pycor mod 22 = 18 or pycor mod 22 = 20)] [
  set pcolor grey
  set meaning "crossroad"
    ]

  ;roads-up
  ask patches with [pxcor mod 40 = 39 and meaning != "crossroad"] [
    set pcolor grey
    sprout 1 [
      set shape "road2"
      set color grey
      set heading 270
      stamp die
    ]
    set meaning "road-up"]

  ask patches with [pxcor mod 40 = 0 and meaning != "crossroad"] [
    set pcolor grey
    sprout 1 [
      set shape "road2"
      set color grey
      set heading 90
      stamp die
    ]
    set meaning "road-up"]

  ;roads-down
  ask patches with [pxcor mod 40 = 36 and meaning != "crossroad"] [
    set pcolor grey
    sprout 1 [
      set shape "road2"
      set color grey
      set heading 270
      stamp die
    ]
    set meaning "road-down"]

  ask patches with [pxcor mod 40 = 37 and meaning != "crossroad"] [
    set pcolor grey
    sprout 1 [
      set shape "road2"
      set color grey
      set heading 90
      stamp die
    ]
    set meaning "road-down"]

  ;roads-right
  ask patches with [pycor mod 22 = 21 and meaning != "crossroad"] [
    set pcolor grey
    sprout 1 [
      set shape "road2"
      set color grey
      set heading 180
      stamp die
    ]
    set meaning "road-left"]

  ask patches with [pycor mod 22 = 0 and meaning != "crossroad"] [
    set pcolor grey
    sprout 1 [
      set shape "road2"
      set color grey
      set heading 0
      stamp die
    ]
    set meaning "road-left"]

  ;roads-left
  ask patches with [pycor mod 22 = 19 and meaning != "crossroad"] [
    set pcolor grey
    sprout 1 [
      set shape "road2"
      set color grey
      set heading 0
      stamp die
    ]
    set meaning "road-right"]

  ask patches with [pycor mod 22 = 18 and meaning != "crossroad"] [
    set pcolor grey
    sprout 1 [
      set shape "road2"
      set color grey
      set heading 180
      stamp die
    ]
    set meaning "road-right"]

  ask patches with [pxcor mod 40 = 38 and meaning != "crossroad"] [
    set pcolor white
    sprout 1 [
      set shape "road-middle"
      set color grey - 1
      set heading 90
      stamp
      die
    ]
    set meaning "road-middle-v"
  ]

  ;the middle lanes
  ask patches with [pycor mod 22 = 20 and meaning != "crossroad"] [
    set pcolor white
    sprout 1 [
      set shape "road-middle"
      set color grey - 1
      set heading 0
      stamp
      die
    ]
    set meaning "road-middle-h"
  ]
end

to draw-sidewalk

  ;sidewalks
  ask patches with [pxcor mod 40 = 1 or pxcor mod 40 = 2 or pxcor mod 40 = 3
    or pxcor mod 40 = 35 or pxcor mod 40 = 34 or pxcor mod 40 = 33 or pycor mod 22 = 1
    or pycor mod 22 = 2 or pycor mod 22 = 3 or pycor mod 22 = 15 or pycor mod 22 = 16 or pycor mod 22 = 17] [
  set pcolor brown + 2
  sprout 1 [
    set shape "tile stones"
    set color 36
    stamp
    die
  ]
  set meaning "sidewalk"]

end

to draw-houses&trees

  ;create couple of houses
  ask patches with [pcolor = black] [
    if count neighbors with [pcolor = black] = 8 and not any? turtles in-radius 4 [
      sprout-houses 1 [
        set shape one-of ["house" "house bungalow" "house ranch" "house colonial" "house efficiency" "house two story"]
        set size 4
        stamp
      ]
    ]
  ]

  ;create couple of trees
  ask patches with [pcolor = black] [
    if count neighbors with [pcolor = black] = 8 and not any? turtles in-radius 2[
      if random 100 > 90 [
        sprout-trees 1 [
          set shape one-of ["tree" "tree pine"]
          set size 4
          set color green
          stamp
        ]
      ]
    ]
  ]

  ;let them die at the end because of the proper functionality of the function "not any? turtles in radius 2"
  ask houses [die]
  ask trees [die]
end

to draw-trees

end

to draw-crossings

  ;create pairs of crossings on roads-up
  ask patches with [(meaning = "road-up" or meaning = "road-down" or meaning = "road-middle-v") and (pycor mod 22 = 8 or pycor mod 22 = 9)][
    sprout-crossings 1 [
      set shape "crossing"
      set color white
      set heading 0
      set size 1
    ]
  ]

  ;make a random position of crossings on roads-up
  ask crossings with [pxcor mod 40 = 38] [
    let newY one-of [1 -1]
    ask crossings in-radius 3 with [shape = "crossing"] [
      set ycor ycor + newY
    ]
  ]

  ;create waitpoints for pedestrians
  ask crossings with [pxcor mod 40 = 38] [
    set shape "waitpoint"
    set meaning "waitpoint2"
    set color black + 1
    stamp die
  ]


  ;create pairs of crossings on roads-down
  ask patches with [(meaning = "road-left" or meaning = "road-right" or meaning = "road-middle-h") and (pxcor mod 40 = 18 or pxcor mod 40 = 19)][
    sprout-crossings 1 [
      set shape "crossing"
      set heading 90
      set color white
      set size 1
    ]
  ]

  ;make a random position of crossings on roads-down
  ask crossings with [pycor mod 22 = 20] [
    let newX one-of [1 2 3 4 5 -1 -2 -3 -4 -5]
    ask crossings in-radius 3 with [shape = "crossing"] [
      set xcor xcor + newX
    ]
  ]


  ask crossings with [pycor mod 22 = 20] [
    set heading 90
    set shape "waitpoint"
    set meaning "waitpoint2"
    set color black + 1
    stamp die
  ]

  ;necessary row for crossings on the edges (function in-radius doesn't work)
  ask crossings [
    set will-cross? false
    set meaning "crossing"
    stamp
    die
  ]

  ask patches with [meaning = "crossing"] [
    ask neighbors4 [
      if meaning = "sidewalk" [
        set meaning "waitpoint"
        ]
      ]
    ]
end

to place-cars

  ;make a random placement of cars
  ask n-of (num-of-cars / 3) patches with [meaning = "road-up"] [
    if not any? cars-on patch pxcor (pycor + 1) and not any? cars-here and not any? cars-on patch pxcor (pycor - 1) and not any? patches with [meaning = "crossing"] in-radius 2 [
      sprout-cars 1 [
        set size 2
        set will-turn? "maybe"
        set will-stop? "maybe"
        set shape "car top"
        set politeness basic-politeness + random (101 - basic-politeness)
        if random 100 > basic-politeness [set politeness random 21]
        set heading 0
        let s random 10
        if s < 7 [set maxSpeed speed-limit - 15 + random 16]
        if s = 7 [set maxSpeed speed-limit - 20 + random 6]
        if s > 7 [set maxSpeed speed-limit + random 16]
        set speed maxSpeed - random 20
      ]
    ]
  ]

  ask n-of (num-of-cars / 3) patches with [meaning = "road-down" and count turtles-on neighbors = 0] [
    if not any? cars-on patch pxcor (pycor + 1) and not any? cars-here and not any? cars-on patch pxcor (pycor - 1) and not any? patches with [meaning = "crossing"] in-radius 2 [
      sprout-cars 1 [
        set size 2
        set shape "car top"
        set politeness basic-politeness + random (101 - basic-politeness)
        if random 100 > basic-politeness [set politeness random 21]
        set heading 180
        set will-turn? "maybe"
        set will-stop? "maybe"
        let s random 10
        if s < 7 [set maxSpeed speed-limit - 15 + random 16]
        if s = 7 [set maxSpeed speed-limit - 20 + random 6]
        if s > 7 [set maxSpeed speed-limit + random 16]
        set speed maxSpeed - random 20
      ]
    ]
  ]

  ask n-of (num-of-cars / 3) patches with [meaning = "road-left" and count turtles-on neighbors = 0] [
    if not any? cars-on patch (pxcor + 1) pycor and not any? cars-here and not any? cars-on patch (pxcor - 1) pycor and not any? patches with [meaning = "crossing"] in-radius 2 [
      sprout-cars 1 [
        set will-turn? "maybe"
        set will-stop? "maybe"
        set size 2
        set shape "car top"
        set politeness basic-politeness + random (101 - basic-politeness)
        if random 100 > basic-politeness [set politeness random 21]
        set heading 270
        let s random 10
        if s < 7 [set maxSpeed speed-limit - 15 + random 16]
        if s = 7 [set maxSpeed speed-limit - 20 + random 6]
        if s > 7 [set maxSpeed speed-limit + random 16]
        set speed maxSpeed - random 20
      ]
    ]
  ]

  while [count cars < num-of-cars] [
    ask one-of patches with [meaning = "road-right"] [
      if not any? cars-on patch (pxcor + 1) pycor and not any? cars-here and not any? cars-on patch (pxcor - 1) pycor and not any? patches with [meaning = "crossing"] in-radius 2 [
        sprout-cars 1 [
          set will-turn? "maybe"
          set will-stop? "maybe"
          set size 2
          set shape "car top"
          set politeness basic-politeness + random (101 - basic-politeness)
          if random 100 > basic-politeness [set politeness random 21]
          set heading 90
          let s random 10
          if s < 7 [set maxSpeed speed-limit - 15 + random 16]
          if s = 7 [set maxSpeed speed-limit - 20 + random 6]
          if s > 7 [set maxSpeed speed-limit + random 16]
          set speed maxSpeed - random 20
        ]
      ]
    ]
  ]

end

to place-people
  while [count persons < num-of-people] [
    ask one-of patches with [meaning = "sidewalk"] [
      sprout-persons 1 [
        set speed random 7 + 5
        set size 1
        set waiting? false
        set walk-time random time-to-crossing
        set shape one-of ["person business" "person construction" "person doctor"
          "person farmer" "person graduate" "person lumberjack" "person police" "person service"
          "person student" "person soldier"
        ]
      ]
    ]
  ]
end

to place-lights
  ask patches with [(pycor mod 22 = 0 or pycor mod 22 = 21) and pxcor mod 40 = 1] [
    sprout-lightsL 1 [
      set color red
      set shape "lights"
    ]
  ]

  ask patches with [(pycor mod 22 = 19 or pycor mod 22 = 18) and pxcor mod 40 = 35] [
    sprout-lightsR 1 [
      set color red
      set shape "lights"
    ]
  ]

  ask patches with [(pxcor mod 40 = 36 or pxcor mod 40 = 37) and pycor mod 22 = 1] [
    sprout-lightsD 1 [
      set color green
      set shape "lights"
    ]
  ]

  ask patches with [(pxcor mod 40 = 39 or pxcor mod 40 = 0) and pycor mod 22 = 17] [
    sprout-lightsU 1 [
      set color green
      set shape "lights"
    ]
  ]

  set greenH 0
  set redH 1
  set redV 0
  set greenV 1

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Car procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to control-speed
  let car-ahead one-of cars-on patch-ahead 1.5
  ifelse car-ahead = nobody  [
    ifelse speed < maxSpeed [set speed speed + acceleration] [set speed speed - deceleration]
  ]
  [
    ifelse [speed] of car-ahead = 0 [set speed 0] [
      ifelse [speed] of car-ahead >= maxSpeed [
        set speed maxSpeed
        set speed speed - deceleration
      ] [
      ;try to overtake
      ifelse [meaning] of patch-left-and-ahead 90 1 = meaning and not any? turtles-on patch-left-and-ahead 90 1 and [meaning] of patch-left-and-ahead 90 1 != "crossroad"
      and meaning != "crossing" and [meaning] of patch-left-and-ahead 180 1.3 != "crossing" and not any? turtles-on patch-left-and-ahead 169 3
      and not any? turtles-on patch-left-and-ahead 45 1 and not any? turtles-on patch-left-and-ahead 135 1 and not any? turtles-on patch-left-and-ahead 23 2
      and not any? turtles-on patch-left-and-ahead 157 2 and not any? turtles-on patch-left-and-ahead 12 3 and [meaning] of patch-ahead 1 != "crossing" [move-to patch-left-and-ahead 90 1] [


        ifelse [meaning] of patch-right-and-ahead 90 1 = meaning and not any? turtles-on patch-right-and-ahead 90 14 and [meaning] of patch-right-and-ahead 90 1 != "crossroad"
        and meaning != "crossing" and [meaning] of patch-right-and-ahead 180 1.3 != "crossing" and not any? turtles-on patch-right-and-ahead 12 3
        and not any? turtles-on patch-right-and-ahead 45 1 and not any? turtles-on patch-right-and-ahead 135 1 and not any? turtles-on patch-right-and-ahead 23 2
        and not any? turtles-on patch-right-and-ahead 157 2 and not any? turtles-on patch-right-and-ahead 169 3 and [meaning] of patch-ahead 1 != "crossing"[move-to patch-right-and-ahead 90 1] [
          set speed [speed] of car-ahead
          set speed speed - deceleration]
      ]



      ]
    ]
  ]
end

to-report can-turn-right?
  if pxcor mod 40 = 0 and pycor mod 22 = 18 and heading = 0 [report true]
  if pxcor mod 40 = 36 and pycor mod 22 = 0 and heading = 180 [report true]
  if pxcor mod 40 = 36 and pycor mod 22 = 18 and heading = 90 [report true]
  if pxcor mod 40 = 0 and pycor mod 22 = 0 and heading = 270 [report true]
  report false
end

to-report can-turn-left?
  if pxcor mod 40 = 39 and pycor mod 22 = 18 and heading = 0 [report true]
  if pxcor mod 40 = 37 and pycor mod 22 = 0 and heading = 180 [report true]
  if pxcor mod 40 = 36 and pycor mod 22 = 19 and heading = 90 [report true]
  if pxcor mod 40 = 0 and pycor mod 22 = 21 and heading = 270 [report true]
  report false
end

to move-cars
  ask cars [
    control-speed
    if will-turn? = "maybe" [
      if can-turn-right? [
        ifelse random 100 < prob-of-turning [
          set will-turn? "yesR"
          move-to patch-ahead 0 rt 35
        ]
        [set will-turn? "no"]
      ]
      if turning-left? [
        if can-turn-left? [
          ifelse random 100 < prob-of-turning [
            move-to patch-ahead 0 lt 35
            set will-turn? "yesL"
            set turnX [pxcor] of patch-left-and-ahead 1 4
            set turnY [pycor] of patch-left-and-ahead 1 4
          ]
          [set will-turn? "no"]
        ]
      ]
    ]

    if will-turn? = "yesR" [
      ifelse not any? cars-on patch-right-and-ahead 55 1 [
        if speed < 15 [
          set speed 15
        ]
        rt 55
        set will-turn? "no"
      ]
      [
        set speed 0
      ]
    ]

    if will-turn? = "yesL" [
      ifelse safe-to-turn? [
        if speed < 15 [
          set speed 15
        ]
        if pxcor = turnX and pycor = turnY [
          move-to patch-ahead 0
          lt 55
          set will-turn? "no"
        ]
      ]
      [
        set speed 0
      ]

    ]

    if meaning = "crossing" [
      set will-turn? "maybe"
    ]

    check-crossing

    ;whether traffic lights show red or green
    ifelse not any? (lightsR-on patch-ahead 1.5) with [color = red] and not any? (lightsL-on patch-ahead 1.5) with [color = red]
    and not any? (lightsD-on patch-ahead 1.5) with [color = red] and not any? (lightsU-on patch-ahead 1.5) with [color = red] [fd speed / 200 ] [set speed 0]

  ]
end

to check-crossing

  if [meaning] of patch-ahead 1 = "crossing" and will-stop? = "maybe"[
    if [used] of patch-ahead 1 = 0 and will-stop? = "maybe"[
      set will-stop? "no"
      ask patch-ahead 1 [
        set traffic traffic + 1
        ask other neighbors with [meaning = "crossing"] [set traffic traffic + 1]
      ]
    ]
    if [used] of patch-ahead 1 > 0 and will-stop? = "maybe"[
      ifelse random 100 < politeness [
        set will-stop? "yes"
        set speed 0
      ]
      [
        set will-stop? "no"
        ask patch-ahead 1 [
          set traffic traffic + 1
          ask other neighbors with [meaning = "crossing"] [set traffic traffic + 1]
        ]
        if any? persons-on patch-ahead 1 or any? persons-on patch-ahead 2 [set speed 0]
      ]
    ]
  ]

  if [meaning] of patch-ahead 1 = "crossing" and [meaning] of patch-ahead 2 = "crossing" and will-stop? = "yes" and [used] of patch-ahead 1 > 0 [set speed 0]

  if [meaning] of patch-left-and-ahead 180 1 = "crossing" and [meaning] of patch-left-and-ahead 180 2 = "crossing" and will-stop? = "no" and meaning != "crossing" [
    set will-stop? "maybe"
    ask patch-left-and-ahead 180 1 [
      set traffic traffic - 1
      ask other neighbors with [meaning = "crossing"] [set traffic traffic - 1]
    ]
  ]

  if meaning = "crossroad" and will-stop? != "maybe" [
    set will-stop? "maybe"
  ]

end

;it is safe to turn left, that means no cars that I could hit while turning left
to-report safe-to-turn?
  if not any? cars-on patch-right-and-ahead 1 5 and not any? cars-on patch-right-and-ahead 1 6 and
  not any? cars-on patch-right-and-ahead 10 7 and not any? cars-on patch-right-and-ahead 10 8 and
  not any? cars-on patch-right-and-ahead 15 9 and not any? cars-on patch-right-and-ahead 15 10 and not any? cars-on patch-right-and-ahead 17 11 [
    if any? (cars-on patch-right-and-ahead 10 4) with [will-turn? = "yesL"] [report true]
    if not any? cars-on patch-right-and-ahead 10 4 [report true]
  ]
  if count turtles with [shape = "lights" and color = red] in-cone 7 70 > 1 [report true]
  report false
end

to check-pedestrians

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; People's procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to move-people
  ask persons [
    ifelse walk-time >= time-to-crossing [
      if crossing-part >= 1[
        cross-the-street
        stop
      ]
      if meaning = "waitpoint" [
        set crossing-part 1
      ]
      face min-one-of patches with [meaning = "waitpoint"] [distance myself]
      walk
    ]
    [walk]
  ]

end

to walk
  ifelse [meaning] of patch-ahead 1 = "sidewalk" or [meaning] of patch-ahead 1 = "waitpoint" [
    ifelse any? other persons-on patch-ahead 1 [
      rt random 45
      lt  random 45
      set walk-time walk-time + 1
    ]
    [fd speed / 200 set walk-time walk-time + 1]
  ]
  [
    rt random 120
    lt random 120
    if [meaning] of patch-ahead 1 = "sidewalk" or [meaning] of patch-ahead 1 = "waitpoint" [
      fd speed / 200
    ]
    set walk-time walk-time + 1
  ]
end

to cross-the-street
  if crossing-part = 1[
    face min-one-of patches with [meaning = "waitpoint2"] in-radius 4 [abs([xcor] of myself - pxcor)]
    ask patches in-cone 3 180 with [meaning = "crossing"] [set used used + 1]
    set crossing-part 2
  ]
  if crossing-part = 2 [
    if heading > 315 and heading < 45 [set heading 0]
    if heading > 45 and heading < 135 [set heading 90]
    if heading > 135 and heading < 225 [set heading 180]
    if heading > 225 and heading < 315 [set heading 270]
  ]
  if meaning = "waitpoint2" and crossing-part = 2 [
    rt 180
    ask patches in-cone 3 180 with [meaning = "crossing"] [set used used - 1]
    lt 180
    ask patches in-cone 3 180 with [meaning = "crossing"] [set used used + 1]
    set crossing-part 3
  ]
  if crossing-part = 3 and meaning = "waitpoint" [
    rt 180
    ask patches in-cone 3 180 with [meaning = "crossing"] [set used used - 1]
    lt 180
    set crossing-part 0
    set walk-time 0
  ]
  ifelse meaning = "waitpoint" and crossing-part = 2  and ([traffic] of patch-ahead 1 > 0 or [traffic] of patch-ahead 2 > 0) [
    fd 0
    set waiting? true
  ]
  [
    ifelse meaning = "waitpoint2" and crossing-part = 3 and ([traffic] of patch-ahead 1 > 0 or [traffic] of patch-ahead 2 > 0)[
      fd 0
      set waiting? true
    ]
    [
      if not any? cars-on patch-ahead 1 [
        fd speed / 200 set waiting? false
      ]
    ]
  ]




end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Plot ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to plot-waiting
  set-current-plot "Number of waiting pedestrians"
  set-current-plot-pen "Waiting pedestrians"
  plot (count persons with [waiting? = true])
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
1018
459
-1
-1
10.0
1
10
1
1
1
0
1
1
1
0
79
0
43
0
0
1
ticks
30.0

BUTTON
18
28
82
61
Setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
104
28
167
61
Go
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

SLIDER
11
110
183
143
num-of-cars
num-of-cars
0
200
100.0
1
1
NIL
HORIZONTAL

SLIDER
11
143
183
176
lights-interval
lights-interval
1
50
10.0
1
1
NIL
HORIZONTAL

SLIDER
11
176
183
209
acceleration
acceleration
0
1
0.185
0.001
1
NIL
HORIZONTAL

SLIDER
11
209
183
242
deceleration
deceleration
0
1
0.057
0.001
1
NIL
HORIZONTAL

SLIDER
11
242
183
275
speed-limit
speed-limit
30
150
70.0
1
1
NIL
HORIZONTAL

SLIDER
11
78
183
111
num-of-people
num-of-people
0
1000
100.0
1
1
NIL
HORIZONTAL

SLIDER
11
275
183
308
prob-of-turning
prob-of-turning
0
100
40.0
1
1
NIL
HORIZONTAL

SWITCH
35
389
159
422
turning-left?
turning-left?
0
1
-1000

SLIDER
11
307
183
340
time-to-crossing
time-to-crossing
400
5000
1000.0
1
1
NIL
HORIZONTAL

SLIDER
11
340
183
373
basic-politeness
basic-politeness
0
100
50.0
1
1
NIL
HORIZONTAL

MONITOR
43
436
152
481
Waiting pedestrians
count persons with [waiting? = true]
17
1
11

PLOT
1040
35
1348
208
Number of waiting pedestrians
Time
Waiting persons
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Waiting pedestrians" 1.0 0 -14070903 true "" ""

@#$#@#$#@
## WHAT IS IT?

This model generates a small part of a town and simulates an interaction between 3 kinds od agents: traffic lights, vehicles and pedestrians. Cars can make their own decisions, they can accelerate, decelerate, change lanes, they can even turn at crossroads. Pedestrians can walk, avoid other pedestrians, cross the road by using crossings. They can communicate with vehicles when crossing the road.Although there are some bugs, this model can be usefull for researching some traffic situations, intervals of traffic lights, traffic flow etc. 
Note: Sometimes it may look that cars touch each other or people go through the cars. It is cause by the size of cars, which is 2. That means the agent is on 1 patch, but the shape i bigger then the patch. You can set up the default size of the car, but it doesn't look well.

## HOW IT WORKS

There are created 2-lane-roads in every direction. Each step, cars try to make a move forward at their current speed. They can accelerate until their maximum speed, based on town speed limit. If there is a slower car in front of them, they match the speed of the slower car and then decelerate, or they can try to change lane and overtake this car.If they want to change the lane, they have to check if there are no other vehicles they could endanger or hit. If there is crossing in front of them, they have to decide whether they will stop and let pedestrians cross the road or they will keep going - every vehicle is unique, in this case they use their variable POLITENESS to make decision. If there is a red traffic light in front of them, they will stop. If there is a green traffic light, they will make decision whether they will turn or keep going. If they are in righ lane, they can turn only right, in left lane they can turn only left. If they are going to turn left, they always check other vehicles in opposite direction to avoid crashes. 
Pedestrians can walk and also avoid other pedestrians. If there are any other pedestrians in front of them, they turn around slightly and wait for next step. If the variable of an individual WALK-TIME reaches the desired value, they start looking for the nearest crossing. There is waitpoint where they wait and say to vehicles around they want to cross the road. If the crossing is empty or the car stopped, they start crossing the road. 

## HOW TO USE IT

The town is generated bz using function MODULO, so you can resize your world as you want. But be aware, But the world hast to make up, it means that the roads and lanes must run consecutively to avoid problems when turning.

### Buttons

 Setup - it generates the town with pedestrians and cars based on NUM-OF-PEOPLE and NUM-OF-CARS (hotkey S)

Go - runs the model (hotkey G)

### Sliders

num-of-people - sets the number of pedestrians in town (you need to press SETUP button again to change it)

num-of-cars - sets the number of cars in town (you need to press SETUP button again to change it)

lights-interval - sets the interval of traffic lights

acceleration - says how fast cars will accelerate

decelerate - says how fast cars will slow down

speed-limit - sets the speed limit in the town

prob-of-turning - sets the probability of turning, i.e. says how likely cars will turn right/left at crossroad

time-to-crossing - says how long pedestrians have to walk before they start looking for crossing and decide to cross the road

basic-politeness - sets the input value for computing of politeness of cars

### Switcher

turtning-left? - says whether cars will be able to turn left or not (turning left is quite complicated computation that sometimes can slow down the model)

### Monitor

Waiting pedestrians - show the number of pedestrians waiting on waitpoints for crossing the road

### Plot

Number of waiting pedestrians - displays the number of pedestrians waiting on waitpoints for crossing the road

## THINGS TO TRY

There is lots of opportunities to try. For example try changing BASIC-POLITENESS or LIGHTS-INTERVAL. Does it effect the number of waiting pedestrians? Or what about the number of cars or pedestrians, does it affect the efficiency of the traffic flow? 

## EXTENDING THE MODEL

I know there is lots of bugs and the model is quite complicated. There is lots of rules for agents, lots of decisions they make etc. So you can try to optimize the model. 
You can add lights on crossings. You can improve overtaking, turning on crossroad. You can add some new activities for pedestrians, new rules. 
The last thing you can do is to add any fuzzy logic and make this model more interesting.

## NETLOGO FEATURES

See how the town is generated. There is used function MODULO. This is on of many ways how to generate the town. With the modulo, you can resize the world as you want, you can have 5000 x 5000 patches and it will still work.
You can also notice the usage of the function STAMP that prints the agent look and then you can kill the agent.

## RELATED MODELS

Before I started I have looked for some related model to get some inspiration how to simulate the traffic or the crowd:
* TrafficBasic by Uri Wilensky
* Traffic Grid by Uri Wilensky
* Traffic Intersection by Uri Wilensky
* Traffic 2 Lanes by Uri Wilensky
* Traffic_dynamics by Francesca De Min and Aurora Patetta
* Traffic with lane changing by Carl Edwards
	

## CREDITS AND REFERENCES

Author: Jiri Lukas 
Email: jirilukas3@seznam.cz 
Adress: Street: Havlickova 628 
Town: Mlada Boleslav 
Zip code: 29301 
State: Czech Republic 
Continent: Europe 
Facebook link: https://www.facebook.com/jiri.lukas.7?fref=ts

This is my third major project in NetLogo, the first was Checkers Ai vs. Ai (http://ccl.northwestern.edu/netlogo/models/community/Checkers). The second one was Graph_search-DFS_and_BFS (http://ccl.northwestern.edu/netlogo/models/community/Graph_search-DFS_and_BFS).
If you have any questions or comments please feel free to write me an email or contact me on facebook.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

building store
false
0
Rectangle -7500403 true true 30 45 45 240
Rectangle -16777216 false false 30 45 45 165
Rectangle -7500403 true true 15 165 285 255
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 30 180 105 240
Rectangle -16777216 true false 195 180 270 240
Line -16777216 false 0 165 300 165
Polygon -7500403 true true 0 165 45 135 60 90 240 90 255 135 300 165
Rectangle -7500403 true true 0 0 75 45
Rectangle -16777216 false false 0 0 75 45

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

car top
true
0
Polygon -7500403 true true 151 8 119 10 98 25 86 48 82 225 90 270 105 289 150 294 195 291 210 270 219 225 214 47 201 24 181 11
Polygon -16777216 true false 210 195 195 210 195 135 210 105
Polygon -16777216 true false 105 255 120 270 180 270 195 255 195 225 105 225
Polygon -16777216 true false 90 195 105 210 105 135 90 105
Polygon -1 true false 205 29 180 30 181 11
Line -7500403 true 210 165 195 165
Line -7500403 true 90 165 105 165
Polygon -16777216 true false 121 135 180 134 204 97 182 89 153 85 120 89 98 97
Line -16777216 false 210 90 195 30
Line -16777216 false 90 90 105 30
Polygon -1 true false 95 29 120 30 119 11

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

crossing
true
15
Line -16777216 false 150 90 150 210
Line -16777216 false 120 90 120 210
Line -16777216 false 90 90 90 210
Line -16777216 false 240 90 240 210
Line -16777216 false 270 90 270 210
Line -16777216 false 30 90 30 210
Line -16777216 false 60 90 60 210
Line -16777216 false 210 90 210 210
Line -16777216 false 180 90 180 210
Rectangle -1 true true 0 0 30 300
Rectangle -7500403 true false 120 0 150 300
Rectangle -1 true true 180 0 210 300
Rectangle -7500403 true false 240 0 270 300
Rectangle -1 true true 30 0 60 300
Rectangle -7500403 true false 90 0 120 300
Rectangle -1 true true 150 0 180 300
Rectangle -7500403 true false 270 0 300 300
Rectangle -1 true true 60 0 90 300
Rectangle -1 true true 210 0 240 300

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

house bungalow
false
0
Rectangle -7500403 true true 210 75 225 255
Rectangle -7500403 true true 90 135 210 255
Rectangle -16777216 true false 165 195 195 255
Line -16777216 false 210 135 210 255
Rectangle -16777216 true false 105 202 135 240
Polygon -7500403 true true 225 150 75 150 150 75
Line -16777216 false 75 150 225 150
Line -16777216 false 195 120 225 150
Polygon -16777216 false false 165 195 150 195 180 165 210 195
Rectangle -16777216 true false 135 105 165 135

house colonial
false
0
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 45 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 60 195 105 240
Rectangle -16777216 true false 60 150 105 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Polygon -7500403 true true 30 135 285 135 240 90 75 90
Line -16777216 false 30 135 285 135
Line -16777216 false 255 105 285 135
Line -7500403 true 154 195 154 255
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 135 150 180 180

house efficiency
false
0
Rectangle -7500403 true true 180 90 195 195
Rectangle -7500403 true true 90 165 210 255
Rectangle -16777216 true false 165 195 195 255
Rectangle -16777216 true false 105 202 135 240
Polygon -7500403 true true 225 165 75 165 150 90
Line -16777216 false 75 165 225 165

house ranch
false
0
Rectangle -7500403 true true 270 120 285 255
Rectangle -7500403 true true 15 180 270 255
Polygon -7500403 true true 0 180 300 180 240 135 60 135 0 180
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 45 195 105 240
Rectangle -16777216 true false 195 195 255 240
Line -7500403 true 75 195 75 240
Line -7500403 true 225 195 225 240
Line -16777216 false 270 180 270 255
Line -16777216 false 0 180 300 180

house two story
false
0
Polygon -7500403 true true 2 180 227 180 152 150 32 150
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 75 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 90 150 135 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Rectangle -7500403 true true 15 180 75 255
Polygon -7500403 true true 60 135 285 135 240 90 105 90
Line -16777216 false 75 135 75 180
Rectangle -16777216 true false 30 195 93 240
Line -16777216 false 60 135 285 135
Line -16777216 false 255 105 285 135
Line -16777216 false 0 180 75 180
Line -7500403 true 60 195 60 240
Line -7500403 true 154 195 154 255

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

lights
false
0
Rectangle -16777216 true false 15 15 285 285
Rectangle -7500403 true true 30 30 270 270

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

person construction
false
0
Rectangle -7500403 true true 123 76 176 95
Polygon -1 true false 105 90 60 195 90 210 115 162 184 163 210 210 240 195 195 90
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Circle -7500403 true true 110 5 80
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -955883 true false 180 90 195 90 195 165 195 195 150 195 150 120 180 90
Polygon -955883 true false 120 90 105 90 105 165 105 195 150 195 150 120 120 90
Rectangle -16777216 true false 135 114 150 120
Rectangle -16777216 true false 135 144 150 150
Rectangle -16777216 true false 135 174 150 180
Polygon -955883 true false 105 42 111 16 128 2 149 0 178 6 190 18 192 28 220 29 216 34 201 39 167 35
Polygon -6459832 true false 54 253 54 238 219 73 227 78
Polygon -16777216 true false 15 285 15 255 30 225 45 225 75 255 75 270 45 285

person doctor
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -13345367 true false 135 90 150 105 135 135 150 150 165 135 150 105 165 90
Polygon -7500403 true true 105 90 60 195 90 210 135 105
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -1 true false 105 90 60 195 90 210 114 156 120 195 90 270 210 270 180 195 186 155 210 210 240 195 195 90 165 90 150 150 135 90
Line -16777216 false 150 148 150 270
Line -16777216 false 196 90 151 149
Line -16777216 false 104 90 149 149
Circle -1 true false 180 0 30
Line -16777216 false 180 15 120 15
Line -16777216 false 150 195 165 195
Line -16777216 false 150 240 165 240
Line -16777216 false 150 150 165 150

person farmer
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 60 195 90 210 114 154 120 195 180 195 187 157 210 210 240 195 195 90 165 90 150 105 150 150 135 90 105 90
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -13345367 true false 120 90 120 180 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90 172 89 165 135 135 135 127 90
Polygon -6459832 true false 116 4 113 21 71 33 71 40 109 48 117 34 144 27 180 26 188 36 224 23 222 14 178 16 167 0
Line -16777216 false 225 90 270 90
Line -16777216 false 225 15 225 90
Line -16777216 false 270 15 270 90
Line -16777216 false 247 15 247 90
Rectangle -6459832 true false 240 90 255 300

person graduate
false
0
Circle -16777216 false false 39 183 20
Polygon -1 true false 50 203 85 213 118 227 119 207 89 204 52 185
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -8630108 true false 90 19 150 37 210 19 195 4 105 4
Polygon -8630108 true false 120 90 105 90 60 195 90 210 120 165 90 285 105 300 195 300 210 285 180 165 210 210 240 195 195 90
Polygon -1184463 true false 135 90 120 90 150 135 180 90 165 90 150 105
Line -2674135 false 195 90 150 135
Line -2674135 false 105 90 150 135
Polygon -1 true false 135 90 150 105 165 90
Circle -1 true false 104 205 20
Circle -1 true false 41 184 20
Circle -16777216 false false 106 206 18
Line -2674135 false 208 22 208 57

person lumberjack
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -2674135 true false 60 196 90 211 114 155 120 196 180 196 187 158 210 211 240 196 195 91 165 91 150 106 150 135 135 91 105 91
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -6459832 true false 174 90 181 90 180 195 165 195
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -6459832 true false 126 90 119 90 120 195 135 195
Rectangle -6459832 true false 45 180 255 195
Polygon -16777216 true false 255 165 255 195 240 225 255 240 285 240 300 225 285 195 285 165
Line -16777216 false 135 165 165 165
Line -16777216 false 135 135 165 135
Line -16777216 false 90 135 120 135
Line -16777216 false 105 120 120 120
Line -16777216 false 180 120 195 120
Line -16777216 false 180 135 210 135
Line -16777216 false 90 150 105 165
Line -16777216 false 225 165 210 180
Line -16777216 false 75 165 90 180
Line -16777216 false 210 150 195 165
Line -16777216 false 180 105 210 180
Line -16777216 false 120 105 90 180
Line -16777216 false 150 135 150 165
Polygon -2674135 true false 100 30 104 44 189 24 185 10 173 10 166 1 138 -1 111 3 109 28

person police
false
0
Polygon -1 true false 124 91 150 165 178 91
Polygon -13345367 true false 134 91 149 106 134 181 149 196 164 181 149 106 164 91
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -13345367 true false 120 90 105 90 60 195 90 210 116 158 120 195 180 195 184 158 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Polygon -13345367 true false 150 26 110 41 97 29 137 -1 158 6 185 0 201 6 196 23 204 34 180 33
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Rectangle -16777216 true false 109 183 124 227
Rectangle -16777216 true false 176 183 195 205
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Polygon -1184463 true false 172 112 191 112 185 133 179 133
Polygon -1184463 true false 175 6 194 6 189 21 180 21
Line -1184463 false 149 24 197 24
Rectangle -16777216 true false 101 177 122 187
Rectangle -16777216 true false 179 164 183 186

person service
false
0
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -1 true false 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -1 true false 123 90 149 141 177 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -2674135 true false 180 90 195 90 183 160 180 195 150 195 150 135 180 90
Polygon -2674135 true false 120 90 105 90 114 161 120 195 150 195 150 135 120 90
Polygon -2674135 true false 155 91 128 77 128 101
Rectangle -16777216 true false 118 129 141 140
Polygon -2674135 true false 145 91 172 77 172 101

person soldier
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -10899396 true false 105 90 60 195 90 210 135 105
Polygon -10899396 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -10899396 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -6459832 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -6459832 true false 120 193 180 201
Polygon -6459832 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -6459832 true false 114 187 128 208
Rectangle -6459832 true false 177 187 191 208

person student
false
0
Polygon -13791810 true false 135 90 150 105 135 165 150 180 165 165 150 105 165 90
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 100 210 130 225 145 165 85 135 63 189
Polygon -13791810 true false 90 210 120 225 135 165 67 130 53 189
Polygon -1 true false 120 224 131 225 124 210
Line -16777216 false 139 168 126 225
Line -16777216 false 140 167 76 136
Polygon -7500403 true true 105 90 60 195 90 210 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

road
true
0
Rectangle -7500403 true true 0 0 300 300
Rectangle -1 true false 0 75 300 225

road-middle
true
0
Rectangle -7500403 true true 0 0 300 300
Rectangle -10899396 true false 0 45 300 255

road2
true
0
Rectangle -7500403 true true 0 0 300 300
Rectangle -1 true false 60 255 225 390

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tile brick
false
0
Rectangle -1 true false 0 0 300 300
Rectangle -7500403 true true 15 225 150 285
Rectangle -7500403 true true 165 225 300 285
Rectangle -7500403 true true 75 150 210 210
Rectangle -7500403 true true 0 150 60 210
Rectangle -7500403 true true 225 150 300 210
Rectangle -7500403 true true 165 75 300 135
Rectangle -7500403 true true 15 75 150 135
Rectangle -7500403 true true 0 0 60 60
Rectangle -7500403 true true 225 0 300 60
Rectangle -7500403 true true 75 0 210 60

tile stones
false
0
Polygon -7500403 true true 0 240 45 195 75 180 90 165 90 135 45 120 0 135
Polygon -7500403 true true 300 240 285 210 270 180 270 150 300 135 300 225
Polygon -7500403 true true 225 300 240 270 270 255 285 255 300 285 300 300
Polygon -7500403 true true 0 285 30 300 0 300
Polygon -7500403 true true 225 0 210 15 210 30 255 60 285 45 300 30 300 0
Polygon -7500403 true true 0 30 30 0 0 0
Polygon -7500403 true true 15 30 75 0 180 0 195 30 225 60 210 90 135 60 45 60
Polygon -7500403 true true 0 105 30 105 75 120 105 105 90 75 45 75 0 60
Polygon -7500403 true true 300 60 240 75 255 105 285 120 300 105
Polygon -7500403 true true 120 75 120 105 105 135 105 165 165 150 240 150 255 135 240 105 210 105 180 90 150 75
Polygon -7500403 true true 75 300 135 285 195 300
Polygon -7500403 true true 30 285 75 285 120 270 150 270 150 210 90 195 60 210 15 255
Polygon -7500403 true true 180 285 240 255 255 225 255 195 240 165 195 165 150 165 135 195 165 210 165 255

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

tree pine
false
0
Rectangle -6459832 true false 120 225 180 300
Polygon -7500403 true true 150 240 240 270 150 135 60 270
Polygon -7500403 true true 150 75 75 210 150 195 225 210
Polygon -7500403 true true 150 7 90 157 150 142 210 157 150 7

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

waitpoint
false
14
Rectangle -16777216 true true 15 15 285 285
Rectangle -7500403 true false 30 30 270 270

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="hit" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>hit</metric>
    <enumeratedValueSet variable="lights-interval">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-to-crossing">
      <value value="510"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="acceleration">
      <value value="0.248"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="speed-limit">
      <value value="74"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="deceleration">
      <value value="0.057"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-people">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-cars">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="basic-politeness">
      <value value="0"/>
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="turning-left?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob-of-turning">
      <value value="46"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="standing - trafficLightsInterval" repetitions="15" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>standing</metric>
    <enumeratedValueSet variable="turning-left?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="acceleration">
      <value value="0.185"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="basic-politeness">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-to-crossing">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob-of-turning">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="deceleration">
      <value value="0.057"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="speed-limit">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-cars">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-people">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lights-interval">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="standing-politeness" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>standing</metric>
    <enumeratedValueSet variable="basic-politeness">
      <value value="0"/>
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-cars">
      <value value="183"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="deceleration">
      <value value="0.057"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="acceleration">
      <value value="0.185"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="turning-left?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="time-to-crossing">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob-of-turning">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-people">
      <value value="76"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="speed-limit">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lights-interval">
      <value value="4"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@

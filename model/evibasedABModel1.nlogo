breed [ richhousehold a-richhousehold ]
breed [ poorhousehold a-poorhousehold ]
breed [PHubs a-planned-hub] 
breed [UPHubs a-unplanned-hub]
;breed [ hubs hub ] 

richhousehold-own [utilityr]
poorhousehold-own [utilityp]
PHubs-own [utilityPH] 
UPHubs-own [utilityUPH]
;hubs-own [utility]
patches-own [value price accessibility]
globals [counter view-mode min-poorhousehold-util max-poorhousehold-util min-richhousehold-util max-richhousehold-util ]

;;
;************ Initialization ************;
;;

to setup
  clear-all
  set view-mode "value"
  ;setup-PHubs 
  ;setup-UPHubs
  setup-cells
  setup-richhousehold
  setup-poorhousehold
  ask patches [ update-cell-color ]
  set-default-shape richhousehold "pentagon"
  set-default-shape poorhousehold "pentagon"
  reset-ticks
end


;to setup-PHubs
; create-PHubs 1
;  ask PHubs
;  [
;    set color 15    
;    set shape "circle"    
;   set size 2   
;    let radius 10  
;    setxy ( ( radius / 2 ) - random-float ( radius * 1.0 ) ) ( ( radius / 2 ) - random-float ( radius * 1.0 ) )
;  ] 
;end

;to setup-UPHubs
;create-UPHubs 1
;ask UPHubs  
;[
;  set color 105    
;  set shape "circle"    
;  set size 2  
;  let radius 10  
;  setxy ( ( radius / 2 ) - random-float ( radius * 1.0 ) ) ( ( radius / 2 ) - random-float ( radius * 1.0 ) )] end


;Initially each parcel consists of land value information,
;price or cost of living information and the accessibility information.
;Accessibility is assigned to random values below 50 at this stage.

to setup-cells
  ask patches [
    set value 50
    set price 50
  ]
   ask patches
  [
    set accessibility random(50) ;min [distance myself] of UPHubs
  ]
  
end

to setup-richhousehold
  create-richhousehold 5
  ask richhousehold
  [
    set color 15
    set size 1
    ;set shape "house"
    let radius 10
    setxy ( ( radius / 2 ) - random-float ( radius * 1.0 ) ) ( ( radius / 2 ) - random-float ( radius * 1.0 ) )
    raise-price
    raise-landvalue
  ]
end

to setup-poorhousehold
  create-poorhousehold 5
  ask poorhousehold
  [
    set color 105
    set size 1
    ;set shape "house"
    let radius 10
    setxy ( ( radius / 2 ) - random-float ( radius * 1.0 ) ) ( ( radius / 2 ) - random-float ( radius * 1.0 ) )
    decrease-price
    decrease-landvalue
  ]

end

to decrease-landvalue
  ask patch-here [ set value ( value * 0.95 ) ]
  ask patches in-radius 1 [ set value ( value * 0.96 ) ]
  ask patches in-radius 2 [ set value ( value * 0.97 ) ]
  ask patches in-radius 3 [ set value ( value * 0.98 ) ]
  ask patches in-radius 4 [ set value ( value * 0.99 )
    if (value < 1) [ set value 1]
  ]

end

to raise-price
  ask patch-here [ set price ( price * 1.05 ) ]
  ask patches in-radius 1 [ set price ( price * 1.04 ) ]
  ask patches in-radius 2 [ set price ( price * 1.03 ) ]
  ask patches in-radius 3 [ set price ( price * 1.02 ) ]
  ask patches in-radius 4 [ set price ( price * 1.01 )
   if price > 100 [ set price 100 ] ]
end

to raise-landvalue
  ask patch-here [ set value ( value * 1.05 ) ]
  ask patches in-radius 1 [ set value ( value * 1.04 ) ]
  ask patches in-radius 2 [ set value ( value * 1.03 ) ]
  ask patches in-radius 3 [ set value ( value * 1.02 ) ]
  ask patches in-radius 4 [ set value ( value * 1.01 )
    if value > 100 [ set value 100 ]
  ]
end

to decrease-price
  ask patch-here [ set price ( price * 0.95 ) ]
  ask patches in-radius 1 [ set price ( price * 0.96 ) ]
  ask patches in-radius 2 [ set price ( price * 0.97 ) ]
  ask patches in-radius 3 [ set price ( price * 0.98 ) ]
  ask patches in-radius 4 [ set price ( price * 0.99 )
    if (price < 1) [ set price 1]
  ]
end

;;
;************ Run model  **************;
;;

to go
  locate-poorhousehold
  locate-richhousehold
  if counter > population-per-hub
  [
    locate-hubs
    set counter 0
  ]
  if count (richhousehold) >= 20 [kill-richhousehold]
  if count (poorhousehold) >= 20 [kill-poorhousehold]
  if count (PHubs) >= max-PHubs [kill-planhub]
  if count(UPHubs) >= max-UPHubs[kill-unplanhub]
  update-view
  do-plots
  tick
end

to locate-poorhousehold
  set counter ( counter + poorhousehold-per-step )
  create-poorhousehold poorhousehold-per-step
  [
    set color 105
    set size 1
    ;set shape "house"
    evaluate-poorhousehold
    decrease-landvalue
    decrease-price
  ]
end

to locate-richhousehold
  set counter ( counter + richhousehold-per-step )
  create-richhousehold richhousehold-per-step
  [
    set color 15
    set size 1
    ;set shape "house"
    evaluate-richhousehold
    raise-price
    raise-landvalue
  ]
end

;evaluation of house holds are based on a utility function

to evaluate-poorhousehold
  let candidate-cells n-of test-period patches
  set candidate-cells candidate-cells with [ not any? turtles-here ]
  if (not any? candidate-cells)
    [ stop ]

 
  let best-candidate max-one-of candidate-cells
    [ patch-utility-for-poorhousehold ]
  move-to best-candidate
  set utilityp [ patch-utility-for-poorhousehold ] of best-candidate
end

to-report patch-utility-for-poorhousehold
    report ( 1 / (accessibility / 100 + 0.1) )  * ( 1 / price   );(( 1 / price) * (accessibility))             ;;
end

to evaluate-richhousehold
  let candidate-cells n-of test-period patches
  set candidate-cells candidate-cells with [ not any? turtles-here ]
  if (not any? candidate-cells)
    [ stop ]

  
  let best-candidate max-one-of candidate-cells
        [ patch-utility-for-richhousehold ]
  move-to best-candidate
  set utilityr [ patch-utility-for-richhousehold ] of best-candidate
end

to-report patch-utility-for-richhousehold
  report ( 1 / (accessibility + 0.1) )   * ( value );((value) * (accessibility))            ; ;
end

to kill-poorhousehold
  repeat ( exit-rate )
  [
    ; kill the hh that's been in the city the longest
    ask min-one-of poorhousehold [who]
      [ die ]
  ]
end

to kill-richhousehold
  repeat ( exit-rate)
  [
    ; kill the hh that's been in the city the longest
    ask min-one-of richhousehold [who]
      [ die ]
  ]
end



to locate-hubs
  let empty-cells patches with [ not any? turtles-here ]

  if any? empty-cells
  [
    ask one-of empty-cells
    [
      sprout-PHubs 1
      [
        set color 15
        set shape "circle"
        set size 2
        evaluate-PHubs
      ]
       sprout-UPHubs 1
      [
        set color 105
        set shape "circle"
        set size 2
        evaluate-UPHubs
      ]
    ]
    ask patches
      [ set accessibility min [distance myself] of UPHubs ]
  ]
end

to evaluate-PHubs
  let candidate-patches n-of test-period patches
  set candidate-patches candidate-patches with [any? planned-cluster ]
  if (not any? candidate-patches)
    [ stop ]


  let best-candidate max-one-of candidate-patches [ value]              
  move-to best-candidate
  set utilityPH [ value ] of best-candidate
end

to-report planned-cluster
    
  report (patch-set ([neighbors] of richhousehold with [ any? richhousehold ]))
    
end

to evaluate-UPHubs
  let candidate-cells n-of test-period patches
  set candidate-cells candidate-cells  with [any? unplanned-cluster]               
  

  if (not any? candidate-cells)
    [ stop ]
  let best-candidate max-one-of candidate-cells [ 1 / price]                       
  move-to best-candidate
  set utilityUPH [ 1 / price ] of best-candidate
end

to-report unplanned-cluster
    
  report (patch-set ([ neighbors] of poorhousehold with [ any? poorhousehold ]))
    
end

to kill-planhub
   ;kill the oldest hub
  ask min-one-of PHubs [who]
  [ die ]
  
  ask patches
    [ set accessibility min [distance myself + .01] of UPHubs ]
end

to kill-unplanhub
  ; always kill the oldest hub
  ask min-one-of UPHubs [who]
  [ die ]
  
  ask patches
    [ set accessibility min [distance myself + .01] of UPHubs ]
end


      
;;
;************ Visualization ************;
;;

to update-view
  
  
  if (view-mode = "poorhousehold-utility" or view-mode = "richhousehold-utility")
  [
    let poorhousehold-util-list [ patch-utility-for-poorhousehold ] of patches
    set min-poorhousehold-util min poorhousehold-util-list
    set max-poorhousehold-util max poorhousehold-util-list
    
    let richhousehold-util-list [ patch-utility-for-richhousehold ] of patches
    set min-richhousehold-util min richhousehold-util-list
    set max-richhousehold-util max richhousehold-util-list
    
  ]
  ask patches [ update-cell-color ]
end

to update-cell-color
 
  ifelse view-mode = "value"
  [                                                                                                                                                                               
    set pcolor scale-color 6 value 1 100
  ][
  ifelse view-mode = "price"
  [
    set pcolor scale-color 117 price 1 100
  ][
  ifelse view-mode = "poorhousehold-utility"
  [
    ; use a logarithm for coloring for better gradation
    set pcolor scale-color 65 ln patch-utility-for-poorhousehold ln min-poorhousehold-util ln max-poorhousehold-util
  ][
  if view-mode = "richhousehold-utility"
  [
    ; use a logarithm for coloring for better gradation
    set pcolor scale-color 16 ln patch-utility-for-richhousehold ln min-richhousehold-util ln max-richhousehold-util
  ]]]]
end

;;
;************ Plotting ************;
;;

to do-plots
  
  set-current-plot "Accessibility"
  
  set-current-plot-pen "poorhousehold"
  plot median [ accessibility ] of poorhousehold
  
  set-current-plot-pen "richhousehold"
  plot median [ accessibility ] of richhousehold

  
end
@#$#@#$#@
GRAPHICS-WINDOW
364
10
819
486
44
44
5.0
1
10
1
1
1
0
0
0
1
-44
44
-44
44
1
1
1
ticks
30.0

BUTTON
58
82
136
115
Initialize
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
141
82
230
115
Run Model
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
31
204
181
237
test-period
test-period
0
30
15
1
1
NIL
HORIZONTAL

PLOT
824
10
1104
195
Accessibility
time
accessibility
0.0
100.0
0.0
20.0
true
true
"" ""
PENS
"richhousehold" 1.0 0 -2674135 true "" ""
"poorhousehold" 1.0 0 -13345367 true "" ""

BUTTON
235
82
318
116
Run once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
824
252
1001
285
View mode : Cost of Living
set view-mode \"price\"\nupdate-view
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
824
215
962
249
View mode: Quality
set view-mode \"quality\"\nupdate-view
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
30
170
180
203
population-per-hub
population-per-hub
0
500
300
10
1
NIL
HORIZONTAL

SLIDER
180
172
357
205
poorhousehold-per-step
poorhousehold-per-step
0
15
10
1
1
NIL
HORIZONTAL

SLIDER
180
204
330
237
richhousehold-per-step
richhousehold-per-step
0
15
10
1
1
NIL
HORIZONTAL

SLIDER
104
236
254
269
exit-rate
exit-rate
0
15
5
1
1
NIL
HORIZONTAL

MONITOR
27
318
105
363
No. of hubs
count UPHubs + count PHubs
17
1
11

MONITOR
110
318
185
363
Population
count poorhousehold + count richhousehold
17
1
11

BUTTON
824
325
1044
358
View mode: Rich-household Utility
set view-mode \"richhousehold-utility\"\nupdate-view
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
824
288
1043
321
View mode: Poor-household Utility
set view-mode \"poorhousehold-utility\"\nupdate-view
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
193
318
268
363
Poor pop
count poorhousehold
17
1
11

MONITOR
274
319
349
364
Rich pop
count richhousehold
17
1
11

SLIDER
181
139
353
172
max-UPHubs
max-UPHubs
5
20
5
1
1
NIL
HORIZONTAL

SLIDER
10
139
182
172
max-PHubs
max-PHubs
5
20
5
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?
**Modelling of Urban Informal Settlement (IS) : An evidence based approach to understanding urban spatial segregation. (A Case study of Mumbai)**

Urban spatial segeration model is an evidence based interactive model that visualizes the settlement behavior of people in a city based on their income. 

Based on the principle that, spatial configuration provides a great deal of insight into the socio-economic conditions of cities, we aim to model the spatial preferences of the city's population with respect to their economic status.   

The analysis of spatial configuration of the study area within Mumbai was done with Space Syntax methodology. With the help of this methodology, the relation between spatial layout and social, economic and environmenal aspects can be explored. This is done by analyzing the pedestrian movement network. Angular segment analysis performed on the study area revealed patterns showcasing evidence of spatial segregation. This evidence echos with the property, unplanned settlements or IS often have edges of settlements that are spatially well-integrated but the cavity inside is separated from the outside urban fabric .

This model can be used to visualize and understand the housing preferences of people in cities. It helps to interpret the relationship between spatial layout of the city and economic status of people.


## HOW IT WORKS
The main elements of this model are, the city, the people and information about planned-ness of the city.

With each tick or time stamp, certain households enter into the city based upon the "poorhousehold-per-step" and "richhousehold-per-step" sliders. They look for a place to settle based on their respective requirements. Poor households and rich households are displayed in blue and yellow pentagons respectively.


**THE CITY**

The city is formed by land parcels or cells. Each parcel has information about price, land vaue and accessibility. The price in this case is concerned with cost of living (_COL_). Land value reffers to the quality of land in terms of the neighborhood. Accessibility measure is incorporated based on the evidence from network analysis performed through space syntax techniques. In this model the accessibility increases with increase in planned-ness of the area, also with increase in land value.


**THE PEOPLE**

The population or people in the city are incorporated in terms of households. They are classified into two categories (for the purpose of modeling), rich households and poor households. 

HOUSEHOLD BEHAVIOR
Rich Households: They look for a land parcel that has a high land value or high quality and high accessibility. They are not worried about the cost of living at that location. Once they find such a land parcel, they settle.

Poor Households: They look for a land parcel that has a low cost of living and are as accessible as it can get, given the cost of living at that location. They do not bother very much about the quality. Once they find such a land parcel, they settle.

Based on the above household behavior, a utility function is used. This fuction makes each household chose a location which maximises the utility of that location for them. 


**PLANNED-NESS**

Based on the analysis of road netowrk data, it is observed that there is a difference in accessibility from one location to the other within the city. The urban areas with lower accessibility and land value are generally unplanned or spontaneously fabricated and the areas with higher land value and accessibility are generally planned or carefully fabricated. The areas with low land value are categorised as "unplanned hubs" and the vice versa is categorised as "planned hubs". 

"HUBS" BEHAVIOR
Planned Hubs: A planned hub, displayed as a yellow circle, appears in those areas where the quality of the land is very high and has relaitively high accessibility. The area close to these hubs are mostly occupied by rich households.

Unplanned Hubs: An unplanned hub, displayed as a blue circle, appears in those areas where the _COL_ is low (consequently also low land value) and has relatively low accessibility. The area close to these hubs are mosltly occupied by poor households.

The "hubs" mentioned in this model is a term used for the purpose of easy understanding of the model. The areas close to the unplanned hubs, where there is existance of poorhouseholds, can be considered as an informal settlement. As they potray the following properties, low accessibility, low cost of living and low quality of land. 


## HOW TO USE IT

The big square display at the middle is a representative of the city, also known as the "world" as per netlogo terminology.

**Initialize**  
On Initialization, the city in its elementary state is displayed. A few rich and poor households exist at the center of the world. The presence of these households effects the land value and _COL_ of their surrounding area. The model is now ready to run.

**Run Model**  
On runing the model, new households enter into the city. Their population is controlled by the _"poorhousehold-per-step"_ and _"richhousehold-per-step"_ sliders and also the _"exit-rate"_ slider. The _"exit-rate"_ slider determines the number of houselds exiting from the city at every tick. Exit can be in the form of out-migration, deaths or any other reason. 

The _"Max-PHub"_ slider controls the maximum number of planned hubs that can exist in the city. Similarly the _"Max-UPHub"_ controlls the maximum number of unplanned hubs that can exist in the city.

The increase in population for which a new hub appears, is controlled by the _"population-per-hub"_ slider. By default, it set to 300 meaning that, for every additional 300 households entering the city, a new hub appears at the appropriate location.

Every household, on entry, tests the land for a suitable parcel to settle. The _"test-period"_ slider determines the time for which a household will seek a suitable location or quit on not finding one. Note that households settle in the locations that best suit them but that may or may not be the maximum utility parcels of the entire city as they can test only a limited number of parcels.

The model can be paused at any point by re-clicking the "Run Model" button. After a considerable number of ticks it is observed that the city displays a seggregated formation of household settlements.

For the purpose of visualization, four view modes are presented. They are, 

* Quality mode 
* Cost of living mode 
* Rich household utility mode 
* Poor household utility mode

_Quality mode_ is set by default when the Initialize button is clicked. It shows the land-value at each cell. Black cells represent low land value, white cells represent high land value and all other shades of grey are intermediate values. 

_Cost of living(COL)_ mode shows the land price or cost of living at each cell. Black cells represent low _COL_, white cells represent high _COL_ and all other shades of violet are intermediate values.

_Rich household utility_ mode shows the usability or attractiveness assigned to cells by rich households. White regions represent high utility for rich population. Black cells represent low utility and all other shades of green are intermediate values.

_Poor household utility_ mode shows the usability or attractiveness assigned to cells by poor households. White regions represent high utility for poor population. Black cells represent low utility and all other shades of red are intermediate values.

On the left side of the world, there is a graph. This plots time on x-axis and accessibility on y-axis. The yellow line shows the accessibility variation of rich household settlements with time. The Blue line showa the accessibility variation of poor household settlement with time.

The population of poor and rich, total population,  and the number of hubs are monitored through the runtime of the model and displayed on-screen.


## THINGS TO NOTICE

Inspect patch and check the attributes of the land parcels. Take notice of the price, value and accessibility near the planned areas and the same near the unplanned areas. Note that the values are low near the unplannedareas and also coupled with high poor population and vice versa in case of the planned areas. 

There are few rich households settled in lower quality areas and poor households settled in higher _COL_ areas. This echos with the real world scenario, not all	housing	where	poor people live is an IS and not all people living in ISs are poor.

Also change the view of the map and observe the changes in the land in terms of cost of living, utility for the rich households and utility of the poor households.

Observe the plot of Accessibility and notice the difference in the accessibility values of the rich when compared to the poor.


## THINGS TO TRY
Try increasing the population expansion rate of the city and observe the model behavior. It is possible to play with the sliders and observe theirs effects on the model.

## CREDITS AND REFERENCES

Karimi, Kayvan, Abdulgader Amir, and K. Shaiei. "Evidence-based spatial intervention for regeneration of informal settlements: the case of jeddah central unplanned areas." (2007).

Turner, Alasdair. "From axial to road-centre lines: a new representation for space syntax and a new model of route choice for transport network analysis." Environment and Planning B: Planning and Design 34.3 (2007): 539-555.

Charalambous, Nadia, and Magda Mavridou. "Space Syntax: Spatial Integration Accessibility and Angular Segment Analysis by Metric Distance (ASAMeD)."

This model is loosely based on the urban suit model of economic disparity built at Illinois Institute of Technology.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

ant
true
0
Polygon -7500403 true true 136 61 129 46 144 30 119 45 124 60 114 82 97 37 132 10 93 36 111 84 127 105 172 105 189 84 208 35 171 11 202 35 204 37 186 82 177 60 180 44 159 32 170 44 165 60
Polygon -7500403 true true 150 95 135 103 139 117 125 149 137 180 135 196 150 204 166 195 161 180 174 150 158 116 164 102
Polygon -7500403 true true 149 186 128 197 114 232 134 270 149 282 166 270 185 232 171 195 149 186
Polygon -7500403 true true 225 66 230 107 159 122 161 127 234 111 236 106
Polygon -7500403 true true 78 58 99 116 139 123 137 128 95 119
Polygon -7500403 true true 48 103 90 147 129 147 130 151 86 151
Polygon -7500403 true true 65 224 92 171 134 160 135 164 95 175
Polygon -7500403 true true 235 222 210 170 163 162 161 166 208 174
Polygon -7500403 true true 249 107 211 147 168 147 168 150 213 150

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bee
true
0
Polygon -1184463 true false 151 152 137 77 105 67 89 67 66 74 48 85 36 100 24 116 14 134 0 151 15 167 22 182 40 206 58 220 82 226 105 226 134 222
Polygon -16777216 true false 151 150 149 128 149 114 155 98 178 80 197 80 217 81 233 95 242 117 246 141 247 151 245 177 234 195 218 207 206 211 184 211 161 204 151 189 148 171
Polygon -7500403 true true 246 151 241 119 240 96 250 81 261 78 275 87 282 103 277 115 287 121 299 150 286 180 277 189 283 197 281 210 270 222 256 222 243 212 242 192
Polygon -16777216 true false 115 70 129 74 128 223 114 224
Polygon -16777216 true false 89 67 74 71 74 224 89 225 89 67
Polygon -16777216 true false 43 91 31 106 31 195 45 211
Line -1 false 200 144 213 70
Line -1 false 213 70 213 45
Line -1 false 214 45 203 26
Line -1 false 204 26 185 22
Line -1 false 185 22 170 25
Line -1 false 169 26 159 37
Line -1 false 159 37 156 55
Line -1 false 157 55 199 143
Line -1 false 200 141 162 227
Line -1 false 162 227 163 241
Line -1 false 163 241 171 249
Line -1 false 171 249 190 254
Line -1 false 192 253 203 248
Line -1 false 205 249 218 235
Line -1 false 218 235 200 144

bird1
false
0
Polygon -7500403 true true 2 6 2 39 270 298 297 298 299 271 187 160 279 75 276 22 100 67 31 0

bird2
false
0
Polygon -7500403 true true 2 4 33 4 298 270 298 298 272 298 155 184 117 289 61 295 61 105 0 43

boat1
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 33 230 157 182 150 169 151 157 156
Polygon -7500403 true true 149 55 88 143 103 139 111 136 117 139 126 145 130 147 139 147 146 146 149 55

boat2
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 157 54 175 79 174 96 185 102 178 112 194 124 196 131 190 139 192 146 211 151 216 154 157 154
Polygon -7500403 true true 150 74 146 91 139 99 143 114 141 123 137 126 131 129 132 139 142 136 126 142 119 147 148 147

boat3
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 37 172 45 188 59 202 79 217 109 220 130 218 147 204 156 158 156 161 142 170 123 170 102 169 88 165 62
Polygon -7500403 true true 149 66 142 78 139 96 141 111 146 139 148 147 110 147 113 131 118 106 126 71

box
true
0
Polygon -7500403 true true 45 255 255 255 255 45 45 45

butterfly1
true
0
Polygon -16777216 true false 151 76 138 91 138 284 150 296 162 286 162 91
Polygon -7500403 true true 164 106 184 79 205 61 236 48 259 53 279 86 287 119 289 158 278 177 256 182 164 181
Polygon -7500403 true true 136 110 119 82 110 71 85 61 59 48 36 56 17 88 6 115 2 147 15 178 134 178
Polygon -7500403 true true 46 181 28 227 50 255 77 273 112 283 135 274 135 180
Polygon -7500403 true true 165 185 254 184 272 224 255 251 236 267 191 283 164 276
Line -7500403 true 167 47 159 82
Line -7500403 true 136 47 145 81
Circle -7500403 true true 165 45 8
Circle -7500403 true true 134 45 6
Circle -7500403 true true 133 44 7
Circle -7500403 true true 133 43 8

circle
false
0
Circle -7500403 true true 35 35 230

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 155 20 63
Rectangle -7500403 true true 158 79 217 164
Polygon -7500403 true true 158 81 110 129 131 143 158 109 165 110
Polygon -7500403 true true 216 83 267 123 248 143 215 107
Polygon -7500403 true true 167 163 145 234 183 234 183 163
Polygon -7500403 true true 195 163 195 233 227 233 206 159

sheep
false
15
Rectangle -1 true true 90 75 270 225
Circle -1 true true 15 75 150
Rectangle -16777216 true false 81 225 134 286
Rectangle -16777216 true false 180 225 238 285
Circle -16777216 true false 1 88 92

spacecraft
true
0
Polygon -7500403 true true 150 0 180 135 255 255 225 240 150 180 75 240 45 255 120 135

thin-arrow
true
0
Polygon -7500403 true true 150 0 0 150 120 150 120 293 180 293 180 150 300 150

truck-down
false
0
Polygon -7500403 true true 225 30 225 270 120 270 105 210 60 180 45 30 105 60 105 30
Polygon -8630108 true false 195 75 195 120 240 120 240 75
Polygon -8630108 true false 195 225 195 180 240 180 240 225

truck-left
false
0
Polygon -7500403 true true 120 135 225 135 225 210 75 210 75 165 105 165
Polygon -8630108 true false 90 210 105 225 120 210
Polygon -8630108 true false 180 210 195 225 210 210

truck-right
false
0
Polygon -7500403 true true 180 135 75 135 75 210 225 210 225 165 195 165
Polygon -8630108 true false 210 210 195 225 180 210
Polygon -8630108 true false 120 210 105 225 90 210

turtle
true
0
Polygon -7500403 true true 138 75 162 75 165 105 225 105 225 142 195 135 195 187 225 195 225 225 195 217 195 202 105 202 105 217 75 225 75 195 105 187 105 135 75 142 75 105 135 105

wolf
false
0
Rectangle -7500403 true true 15 105 105 165
Rectangle -7500403 true true 45 90 105 105
Polygon -7500403 true true 60 90 83 44 104 90
Polygon -16777216 true false 67 90 82 59 97 89
Rectangle -1 true false 48 93 59 105
Rectangle -16777216 true false 51 96 55 101
Rectangle -16777216 true false 0 121 15 135
Rectangle -16777216 true false 15 136 60 151
Polygon -1 true false 15 136 23 149 31 136
Polygon -1 true false 30 151 37 136 43 151
Rectangle -7500403 true true 105 120 263 195
Rectangle -7500403 true true 108 195 259 201
Rectangle -7500403 true true 114 201 252 210
Rectangle -7500403 true true 120 210 243 214
Rectangle -7500403 true true 115 114 255 120
Rectangle -7500403 true true 128 108 248 114
Rectangle -7500403 true true 150 105 225 108
Rectangle -7500403 true true 132 214 155 270
Rectangle -7500403 true true 110 260 132 270
Rectangle -7500403 true true 210 214 232 270
Rectangle -7500403 true true 189 260 210 270
Line -7500403 true 263 127 281 155
Line -7500403 true 281 155 281 192

wolf-left
false
3
Polygon -6459832 true true 117 97 91 74 66 74 60 85 36 85 38 92 44 97 62 97 81 117 84 134 92 147 109 152 136 144 174 144 174 103 143 103 134 97
Polygon -6459832 true true 87 80 79 55 76 79
Polygon -6459832 true true 81 75 70 58 73 82
Polygon -6459832 true true 99 131 76 152 76 163 96 182 104 182 109 173 102 167 99 173 87 159 104 140
Polygon -6459832 true true 107 138 107 186 98 190 99 196 112 196 115 190
Polygon -6459832 true true 116 140 114 189 105 137
Rectangle -6459832 true true 109 150 114 192
Rectangle -6459832 true true 111 143 116 191
Polygon -6459832 true true 168 106 184 98 205 98 218 115 218 137 186 164 196 176 195 194 178 195 178 183 188 183 169 164 173 144
Polygon -6459832 true true 207 140 200 163 206 175 207 192 193 189 192 177 198 176 185 150
Polygon -6459832 true true 214 134 203 168 192 148
Polygon -6459832 true true 204 151 203 176 193 148
Polygon -6459832 true true 207 103 221 98 236 101 243 115 243 128 256 142 239 143 233 133 225 115 214 114

wolf-right
false
3
Polygon -6459832 true true 170 127 200 93 231 93 237 103 262 103 261 113 253 119 231 119 215 143 213 160 208 173 189 187 169 190 154 190 126 180 106 171 72 171 73 126 122 126 144 123 159 123
Polygon -6459832 true true 201 99 214 69 215 99
Polygon -6459832 true true 207 98 223 71 220 101
Polygon -6459832 true true 184 172 189 234 203 238 203 246 187 247 180 239 171 180
Polygon -6459832 true true 197 174 204 220 218 224 219 234 201 232 195 225 179 179
Polygon -6459832 true true 78 167 95 187 95 208 79 220 92 234 98 235 100 249 81 246 76 241 61 212 65 195 52 170 45 150 44 128 55 121 69 121 81 135
Polygon -6459832 true true 48 143 58 141
Polygon -6459832 true true 46 136 68 137
Polygon -6459832 true true 45 129 35 142 37 159 53 192 47 210 62 238 80 237
Line -16777216 false 74 237 59 213
Line -16777216 false 59 213 59 212
Line -16777216 false 58 211 67 192
Polygon -6459832 true true 38 138 66 149
Polygon -6459832 true true 46 128 33 120 21 118 11 123 3 138 5 160 13 178 9 192 0 199 20 196 25 179 24 161 25 148 45 140
Polygon -6459832 true true 67 122 96 126 63 144

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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

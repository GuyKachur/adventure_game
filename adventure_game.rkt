#lang racket

#|
   The Adventure Game 
   ------------------

   In the Adventure Game you will control the avatar Guy.  He is a muscular warrior with special powers and can
   pickup and use new weapons he finds on his quests.

   Items like gold will be scattered around he map for you to collect but beware of nasty creatures trying to 
   lure you into a trap!

   You will move with arrow keys and fights will 

   How to Play
   -----------
 
   Run ;; and maybe evaluate 
     (start-quest)
|#
;                                                                                                                                
;                                                                                                                                
;                                                                                                                                
;   ;;;;;  ;                     ;;;       ;                                                           ;;;                       
;     ;    ;                    ;   ;      ;                        ;                                 ;   ;                      
;     ;    ;                    ;   ;      ;                        ;                                 ;                          
;     ;    ;;;;    ;;;          ;   ;   ;;;;  ;   ;   ;;;   ;;;;   ;;;    ;   ;  ; ;;    ;;;          ;       ;;;;  ;;;;;   ;;;  
;     ;    ;   ;  ;   ;         ;;;;;  ;   ;  ;   ;  ;   ;  ;   ;   ;     ;   ;  ;;  ;  ;   ;         ;  ;;  ;   ;  ; ; ;  ;   ; 
;     ;    ;   ;  ;;;;;         ;   ;  ;   ;   ; ;   ;;;;;  ;   ;   ;     ;   ;  ;   ;  ;;;;;         ;   ;  ;   ;  ; ; ;  ;;;;; 
;     ;    ;   ;  ;             ;   ;  ;   ;   ; ;   ;      ;   ;   ;     ;   ;  ;      ;             ;   ;  ;   ;  ; ; ;  ;     
;     ;    ;   ;  ;   ;         ;   ;  ;   ;    ;    ;   ;  ;   ;   ;     ;  ;;  ;      ;   ;         ;   ;  ;  ;;  ; ; ;  ;   ; 
;     ;    ;   ;   ;;;          ;   ;   ;;;;    ;     ;;;   ;   ;    ;;    ;; ;  ;       ;;;           ;;;    ;; ;  ; ; ;   ;;;  
;                                                                                                                                
;                                                                                                                                
; 

(require 2htdp/image 2htdp/universe)

;; -----------------------------------------------------------------------------
;; Data Definitions
;; -----------------------------------------------------------------------------

;; Game World is a (game-world current_map (Listof adventurers) (Listof Monsters)(Listof Items)(Numberof Gold))
(struct game-world (current_map adventurer items) #:transparent #:mutable)

;; Adventurer is a (make-adventurer Health (cons Items [Listof Items]) Gold Direction Location)
;; - Health is just an integer value between 0-100
;; - Gold is also just an integer but does not max out at 100
;; - Direction is the direction the adventurer is facing in the game_world, viz., "up" "down" "left" "right".
;; - Location is the (posn Number_x Number_y) of the adventurer in the game_world
;;(struct adventurer (health items direction location) #:transparent)
(struct adventurer (name health items direction location image) #:transparent #:mutable)
(struct location (x y) #:transparent #:mutable)
(struct item (name location size image health solid)#:transparent #:mutable) ;; im thinking health we can control for decay.


;; -----------------------------------------------------------------------------
;; Constants
;; -----------------------------------------------------------------------------

;; Tick Rate 
(define TICK-RATE 1/10) ;; not sure what this should be so using snake game tick rate

;; Board Size Constants
(define SIZE 30) ;; this was okay but not sure it is final game size

;; Item Constants
(define basic_sword (item "Basic Sword" (location 5 5) 15 (circle 15 "solid" "black") 5 #f))
(define testitem1 (item "hey" (location 100 100) 15 (circle 15 "solid" "black") 5 #f))
(define testitem2 (item "hey" (location 100 100) 15 (circle 15 "solid" "black") 5 #f))
(define testitem3 (item "hey" (location 100 100) 15 (circle 15 "solid" "black") 5 #f))
(define TESTITEMS (list testitem1 testitem2 testitem3))



  

;; Adventurer Constants
(define AVATAR-SIZE 15)
(define MAX-HEALTH 100)
(define HEALTH_BAR_HEIGHT 5)
(define DEFAULT-ITEMS (list basic_sword))
(define HEALTH_CONSTANT 20) ;;what incriment the health potions will heal.
(define MAX_HEALTH 100) ;;max health of adventurers
(define MOVE 15) ;;how much you move when you hit an arrow key



;; Monster Constants
(define LRG-MONSTER-SIZE 25)
(define MONSTER-SIZE 15)
(define MAX-MONSTERS 5) ;; max monsters necessary? NO

;; GRAPHICAL BOARD
(define WIDTH-PX  (* AVATAR-SIZE 30))
(define HEIGHT-PX (* AVATAR-SIZE 30))

;; DEFAULT MAP
;; This is currently the same as the empty scene setup as temp until we make a default one that is different.
(define DEFAULT_MAP (empty-scene WIDTH-PX HEIGHT-PX))

;; Visual constants
(define EMPTY-SCENE (empty-scene WIDTH-PX HEIGHT-PX))
(define ENDGAME-TEXT-SIZE 15)

;;(define AVATAR-LEFT-IMG (circle 15 "solid" "green"))


(define AVATAR-LEFT-IMG (bitmap "graphics/avatar-left.gif")) ;;i think we need to force this to the same size
(define AVATAR-RIGHT-IMG (flip-horizontal AVATAR-LEFT-IMG)) ;; this might need to not be flipped but be a separate image all together


(define DEFAULT_ADVENTURERS (adventurer "guy" MAX-HEALTH (list empty) "down" (location 200 200) AVATAR-LEFT-IMG))


;;;;;;

(define (random-dot)
  (item "dot" (location (- (random 15 WIDTH-PX) 15) (- (random 15 HEIGHT-PX) 15)) (random 0 15) (circle (random 0 15) "solid" (random-color)) 5 #f));;size and circle size are not the same!

(define (random-color)
  (make-color (random 0 255) (random 0 255) (random 0 255) (random 0 255)))

(define TESTDOTS (list (random-dot) (random-dot) (random-dot) (random-dot)  (random-dot) (random-dot) (random-dot) (random-dot) (random-dot) (random-dot)))


(define STARTING_WORLD (game-world 
                 DEFAULT_MAP 
                 DEFAULT_ADVENTURERS
                 ;;TESTITEMS
                 TESTDOTS
                 )
  )

(println "Please Enter a Color you want your avatar to be MUST BE IN RGB FORMAT (color 0-255 0-255 0-255 0-255) you may also do (random-color)")
(define new-color (random-color)) ;;will be read or something, maybe a gui? but for now 

;                                          
;                                          
;                                          
;                          ;               
;                          ;               
;  ;;;   ;;;                               
;   ;;   ;;                                
;   ; ; ; ;     ;;;;     ;;;      ;; ;;;   
;   ; ; ; ;    ;    ;      ;       ;;   ;  
;   ; ; ; ;         ;      ;       ;    ;  
;   ;  ;  ;    ;;;;;;      ;       ;    ;  
;   ;     ;   ;     ;      ;       ;    ;  
;   ;     ;   ;    ;;      ;       ;    ;  
;  ;;;   ;;;   ;;;; ;;  ;;;;;;;   ;;;  ;;; 
;                                          
;                                          
;                                          
;                                          
;; -----------------------------------------------------------------------------

;; Contract: start-quest: none -> none

;; Purpose: starts the game in bigbang and is the main game loop

;; Example: (start-quest)

;; Definition: 
;; Start the Game
(define (start-quest)
  (big-bang STARTING_WORLD
            (on-tick next-game-world TICK-RATE)
            (on-key direct-avatar)
            (to-draw render-game-world)
            (stop-when end? render-end)))

;; Contract: next-game-world: world --> world

;; Purpose: starts the game in bigbang and is the main game loop

;; Example: (start-quest)

;; Definition: 
;; Game-world -> Game-world (M A I)
;;takes a game world and checks the health of items and adventurer.
(define (next-game-world world)
  (define current_map (game-world-current_map world));; the current map being drawn
  (define adventurer (game-world-adventurer world)) ;; a list of players in the world
  (define items (game-world-items world)) ;; a list of the current game world items
  (game-world current_map (health-check-A adventurer) items) ;;(health-check (list adventurer))
  )


;; Game-world KeyEvent -> Game-world
;; Handle a key event


;; Game-world -> Scene
;; Render the world as a scene
(define (render-game-world world)
  (define adventurer (game-world-adventurer world)) ;; a list of players in the world
  (define items (game-world-items world) ) ;; a list of the current game world items
  (objects-on-world (flatten (list adventurer items))))

;;takes a list of objects and palces them onto the world
(define (objects-on-world list)
   (cond
    ((empty? list) DEFAULT_MAP)
    ((item? (first list)) 
                                 (place-image (above
                                               (render-health-bar (first list))
                                               (item-image (first list)))
                                       (location-x (item-location (first list)))
                                       (location-y (item-location (first list)))
                                       (objects-on-world (rest list))))
    ((adventurer? (first list)) 
                                             (place-image (above
                                             (render-health-bar (first list))
                                             (adventurer-image (first list)))
                                                          (location-x (adventurer-location (first list)))
                                                          (location-y (adventurer-location (first list)))
                                                          (objects-on-world (rest list))))
      (else (text "ERROR IN OBJECTS ON WORLD" 24 "red")))
  )


;;health bar, take adventurer and give back image of health bar
(define (render-health-bar object)
  (cond
    [(item? object) (if (item-solid object) empty-image
                        (overlay
                             (overlay/align "left" "center"
                                            (rectangle (* (/ (item-health object) 100) (item-size object)) HEALTH_BAR_HEIGHT "solid" "red")
                                            (rectangle (item-size object) HEALTH_BAR_HEIGHT "solid" "white"))
                             (rectangle (+ (item-size object) 3) (+ HEALTH_BAR_HEIGHT 3) "solid" "black"))
                             )]
     [(adventurer? object) (overlay
                                (overlay/align "left" "center"
                                               (rectangle (* (/ (adventurer-health object) 100) AVATAR-SIZE) HEALTH_BAR_HEIGHT "solid" "red")
                                               (rectangle AVATAR-SIZE HEALTH_BAR_HEIGHT "solid" "white"))
                                  (rectangle (+ AVATAR-SIZE 3) (+ HEALTH_BAR_HEIGHT 3) "solid" "black"))
                                ]
     [else (text "ERROR IN RENDER-HEALTH-BAR" 24 "red")]))



;; Game-world -> Boolean
;; Is the adventurer dead?

(define (end? world)
  (if (empty? (game-world-adventurer world)) #t
      #f))

;; Game-world -> Scene
;; overlays the gameover scene
(define (render-end w)
  (overlay (text "Game over" ENDGAME-TEXT-SIZE "black")
           (render-game-world w)))


;                                                                                                      
;                                                                                                      
;                                                                                                      
;                                                                                                      
;                                                                                                      
;   ;;; ;;;;
;    ;   ;
;    ;  ;       ;;;    ;;;   ;;;   ;;;; ;
;    ; ;       ;   ;    ;     ;   ;    ;;
;    ;;;;     ;     ;    ;   ;    ;
;    ;   ;    ;;;;;;;    ;   ;     ;;;;;
;    ;   ;    ;           ; ;           ;
;    ;    ;    ;    ;     ; ;     ;     ;
;   ;;;   ;;    ;;;;       ;      ;;;;;;
;                          ;
;                         ;
;                      ;;;;;
;                                                                                                      
;; -----------------------------------------------------------------------------


;; String -> Boolean
;; Is the given value a direction?
;; > (dir? "up")
;; #t

(define (dir? x)
  (or (string=? x "up") 
      (string=? x "down") 
      (string=? x "left") 
      (string=? x "right")))


(define (heal? x) (string=? x "h"))


;; Game-world Move -> Game-world
;; Move in a direction
;; > (world-player-move world0 "up")
;; (game-world adventurer1 (list items)) 
;; Key input
;;takes a world and key, and returns a new world, with the adventurer changed and the items changed
(define (direct-avatar world input_key)
  (define player (game-world-adventurer world))
  (cond
    [(dir? input_key) (if (legal-move? world input_key) (move-adventurer world input_key) world)]
    [(heal? input_key) (update-adventurer-health world HEALTH_CONSTANT)]
    [else world]))




;                                                                          
;                                                                          
;                                                                          
;                                                                          
;   ;;; ;;;                                 ;;                      ;;     
;    ;; ;;                                   ;                       ;     
;    ;; ;;   ;;;;  ;;;  ;;;  ;;;;    ;;; ;   ; ;;    ;;;;    ;;; ;   ; ;;;;
;    ; ; ;  ;    ;  ;    ;  ;    ;  ;   ;;   ;;  ;  ;    ;  ;   ;;   ;  ;  
;    ; ; ;  ;    ;   ;  ;   ;;;;;;  ;        ;   ;  ;;;;;;  ;        ;;;   
;    ;   ;  ;    ;   ;  ;   ;       ;        ;   ;  ;       ;        ; ;   
;    ;   ;  ;    ;    ;;    ;       ;    ;   ;   ;  ;       ;    ;   ;  ;  
;   ;;; ;;;  ;;;;     ;;     ;;;;;   ;;;;   ;;; ;;;  ;;;;;   ;;;;   ;;  ;;;
;                                                                          
;                                                                          
;                                                                          
;                                                                          
 
;;asses if there is a legal move.

(define (legal-move? world input_key)
  (if (and (in-board? world input_key) (dont-overlap-stagnant-items? world input_key)) #t
      #f))
;; asseses if the move is within the bounds of the board.

(define (in-board? world input_key)
  (define player (game-world-adventurer world))
  
 ( cond
    
                       ((string=? input_key "up") (if (< (- (location-y (adventurer-location player)) (/ AVATAR-SIZE 2) MOVE) 0) #f
                                                      #t))
                       ((string=? input_key "down") (if (> (+ (location-y (adventurer-location player)) (/ AVATAR-SIZE 2) MOVE) HEIGHT-PX) #f
                                                        #t))
                       ((string=? input_key "left") (if (< (- (location-x (adventurer-location player)) (/ AVATAR-SIZE 2) MOVE) 0) #f
                                                      #t))
                       ((string=? input_key "right") (if (> (+ (location-x (adventurer-location player)) (/ AVATAR-SIZE 2) MOVE) WIDTH-PX) #f
                                                        #t))
                       )
  )

;;takes world and input key, and determines if you are overlapping any items that have the tag, unwalkable
(define (dont-overlap-stagnant-items? world input_key)
   (define player (game-world-adventurer world))
   (dont-overlap? player (non-walkable-items (game-world-items world))))

   ;;return true if nothing overlaps, and false if anything overlaps.
   

;;take a adventurer and a list of items, determines if any of the non walkable ones overlap
;;returns t if they dont overlap, and returns false if an item and player overlap
(define (dont-overlap? explorer list-of-items)
  (cond
    [(empty? list-of-items) #t]
    [(inside-of-player? explorer (first list-of-items)) #f]
    [else (dont-overlap? explorer (rest list-of-items))]
    ))
    





(define (inside-of-player? adventurer item)
  (if (empty? item) item
      
  (inside-of-player-helper adventurer (four-corners item))))
 

(define (inside-of-player-helper adventurer list-of-corners)
  (cond
    ((empty? list-of-corners) #f)
    (
     (and
         (<
            (- (location-x (adventurer-location adventurer)) (/ AVATAR-SIZE 2))
            (location-x (first list-of-corners))
            (+ (location-x (adventurer-location adventurer)) (/ AVATAR-SIZE 2))
         )

         (<
            (- (location-y (adventurer-location adventurer)) (/ AVATAR-SIZE 2))
            (location-y (first list-of-corners))
            (+ (location-y (adventurer-location adventurer)) (/ AVATAR-SIZE 2))
         )
     )
      #t)
    (else (inside-of-player-helper adventurer (rest list-of-corners)))))
   


(define (four-corners image)
  (define Limage (item-location image))
  (define topleft (location (- (location-x Limage) (/ (item-size image) 2)) (+ (location-y Limage) (/ (item-size image) 2))))
  (define topright (location (+ (location-x Limage) (/(item-size image) 2)) (+ (location-y Limage) (/ (item-size image) 2))))
  (define bottomleft (location (- (location-x Limage) (/ (item-size image) 2)) (- (location-y Limage) (/ (item-size image) 2))))
  (define bottomright (location (+ (location-x Limage) (/ (item-size image) 2)) (- (location-y Limage) (/ (item-size image) 2))))
  (list topleft topright bottomleft bottomright )
  )

   

;;takes a list of items and returns a list of the (item-solid #t)
(define (non-walkable-items itemL)
(cond
    [(item? itemL) (if (item-solid itemL) itemL '() )]
    [(empty? itemL) '()]
    [(item-solid (first itemL)) (cons (first itemL) (non-walkable-items (rest itemL)))]
    [else (non-walkable-items (rest itemL))])
  )


;;moves adventurer and returns world... should update item list as well right?

(define (move-adventurer world input_key)
  (define current_map (game-world-current_map world));; the current map being drawn
  (define player (game-world-adventurer world)) ;;
  (define items (game-world-items world))  ;; a list of the current game world items
  (game-world
        current_map
        (adventurer
             ;;name
                      (adventurer-name player)
             ;;health
                      (adventurer-health player)
              ;;Items
                      (flatten (item-helper-a player items)) ;;HERE FIX MEEEE
             ;; Direction
                      (cond
                           ((string=? input_key "up") "up")
                           ((string=? input_key "down") "down")
                           ((string=? input_key "left") "left")
                           ((string=? input_key "right") "right")
                           (else (adventurer-direction player))
                         )
            ;; Location
                     ( cond
                       [(and (string=? input_key "up") (legal-move? world input_key))    (location (location-x (adventurer-location player)) (- (location-y (adventurer-location player)) MOVE))]
                       [(and (string=? input_key "down") (legal-move? world input_key))  (location (location-x (adventurer-location player)) (+ (location-y (adventurer-location player)) MOVE))]
                       [(and (string=? input_key "left") (legal-move? world input_key)) (location (- (location-x (adventurer-location player)) MOVE) (location-y (adventurer-location player)))]
                       [(and (string=? input_key "right") (legal-move? world input_key)) (location (+ (location-x (adventurer-location player)) MOVE) (location-y (adventurer-location player)))]
                     )
             ;;image
                     (cond
                       [(string=? input_key "left")AVATAR-LEFT-IMG]
                       [(string=? input_key "right")AVATAR-RIGHT-IMG]
                       [else (adventurer-image player)])
                   )
         (flatten (item-helper-i player items)) ;;ME TOOO FIX ME
  ))





;                                                                                            
;                                                                                            
;                                                                                            
;                                                                                            
;                                                                                            
;     ;;;     ;;;  ;;; ;;;   ;;;  ;;;;;;;   ;;;;;     ;;;;;;;     ;;;     ;;;;;;   ;;;   ;;; 
;      ;;      ;    ;   ;     ;      ;        ;          ;         ;;      ;    ;   ;     ;  
;     ;  ;     ;    ;    ;   ;       ;        ;          ;        ;  ;     ;    ;    ;   ;   
;     ;  ;     ;    ;     ; ;        ;        ;          ;        ;  ;     ;    ;     ; ;    
;     ;  ;     ;    ;      ;         ;        ;          ;        ;  ;     ;;;;;       ;     
;    ;;;;;;    ;    ;     ; ;        ;        ;    ;     ;       ;;;;;;    ;  ;        ;     
;    ;    ;    ;    ;    ;   ;       ;        ;    ;     ;       ;    ;    ;   ;       ;     
;   ;      ;   ;    ;   ;     ;      ;        ;    ;     ;      ;      ;   ;    ;      ;     
;  ;;;    ;;;   ;;;;   ;;;   ;;;  ;;;;;;;   ;;;;;;;;  ;;;;;;;  ;;;    ;;; ;;;   ;;   ;;;;;   
;                                                                                            
;                                                                                            
;                                                                                            
;
;; -----------------------------------------------------------------------------




;;return a list of items that is not inside of a player.

 (define (item-helper-i player list-of-items)
   (cond
    [(empty? list-of-items) list-of-items]
    [(inside-of-player? player (first list-of-items)) (item-helper-i player (rest list-of-items))]
    [else (cons (first list-of-items) (item-helper-i player (rest list-of-items)))]
    )
   )
;;update items should take a world and return a list of items

 (define (item-helper-a player list-of-items)
   (cond
    [(empty? list-of-items) (adventurer-items player)]
    [(inside-of-player? player (first list-of-items)) (cons (first list-of-items) (item-helper-a player (rest list-of-items)))]
    [else (item-helper-a player (rest list-of-items))]
)
)


;;takes a world and returns the adventurers health added.
(define (update-adventurer-health world health-incrimenter) 
  (define current_map (game-world-current_map world));; the current map being drawn
  (define player (game-world-adventurer world)) ;;
  (define items (game-world-items world))  ;; a list of the current game world items
  (game-world current_map (adventurer
             ;;name
                      (adventurer-name player)
             ;;health
                      (if (< (adventurer-health player) (- MAX-HEALTH health-incrimenter))
                                   ;;then
                                   (+ (adventurer-health player) health-incrimenter)
                                   ;;else
                                   MAX_HEALTH)
              ;;Items
                      (adventurer-items player)
             ;; Direction
                       (adventurer-direction player)
            ;; Location
                    (adventurer-location player)
             ;;image
                     (adventurer-image player)
                   )
              items
  ))


;;Health check player
(define (health-check-A player)
  (if (<= (adventurer-health player) 0) empty
      ;;else
      player))

;;Health Check Items
(define (health-check-items lst)
  (cond
    ((empty? lst) lst )
    ((and (item? (first lst)) (<= (item-health (first lst)) 0)) (health-check-items (rest lst)))
    ((item? (first lst)) (cons (first lst)  (health-check-items (rest lst))))
    )
  
)

;;Color Change for avatar not implemented but i thought i would copy it over so you can play with it if you want
;;take image and return new image with different color

(define (color-change image)
  (define xlist (image->color-list image))
  (define new-color-list (map colorchange-helper xlist))
  (color-list->bitmap new-color-list (image-width image) (image-height image)))

(define (colorchange-helper listitem)
  (colorchange listitem (color 255 0 0 255) 150));; this is a range number seems to be good for getting rid of all the red


(define (colorchange item chosen_color range)
  (if (and
       (< (- (color-red chosen_color) range) (color-red item) (+ (color-red chosen_color) range))
       (< (- (color-green chosen_color) range) (color-green item) (+ (color-green chosen_color) range))
       (< (- (color-blue chosen_color) range) (color-blue item) (+ (color-blue chosen_color) range))
       (< (- (color-alpha chosen_color) range) (color-alpha item) (+ (color-alpha chosen_color) range)))
      new-color
      ;;else
      item)
  )

;;you can try it with this (color-change (circle 50 "solid" "red"))
;;or your avatar image, Basically it find all RED (color 255 0 0 255) and replaces it with whatever new-color is. which currnently is a random color. i was having trouble with (read) and how it assigns things,
;;didnt want to have to do four seperate calls for an umber, but we might have to.

(start-quest)
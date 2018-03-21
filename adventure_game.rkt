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

;; Game World is a (game-world current_map adventurer (Listof Monsters)(Listof Items)(Numberof Gold))
;;(struct game-world (current_map adventurer monsters items world_gold) #:transparent)
(struct game-world (adventurer world_gold) #:transparent #:mutable)


;; Adventurer is a (make-adventurer Health (cons Items [Listof Items]) Gold Direction Location)
;; - Health is just an integer value between 0-100
;; - Gold is also just an integer but does not max out at 100
;; - Direction is the direction the adventurer is facing in the game_world, viz., "up" "down" "left" "right".
;; - Location is the (posn Number_x Number_y) of the adventurer in the game_world
;;(struct adventurer (health items gold direction location) #:transparent)
(struct adventurer (health direction gold location) #:transparent #:mutable)
(struct monster (health items gold direction location) #:transparent)
(struct posn (x y) #:transparent)


;; -----------------------------------------------------------------------------
;; Constants
;; -----------------------------------------------------------------------------

;; Tick Rate 
(define TICK-RATE 1/10) ;; not sure what this should be so using snake game tick rate

;; Board Size Constants
(define SIZE 30) ;; this was okay but not sure it is final game size

;; Adventurer Constants
(define AVATAR-SIZE 15)
(define MAX-HEALTH 100)
(define DEFAULT-GOLD 100)
(define DEFAULT-ITEMS (list 'basic sword'))

;; Monster Constants
(define LRG-MONSTER-SIZE 25)
(define MED-MONSTER-SIZE 15)
(define SML-MONSTER-SIZE 5) ;; this may be too small but could be fun to trick an adventurer into a fight!
(define MAX-MONSTERS 5) ;; max monsters necessary?

;; GRAPHICAL BOARD
(define WIDTH-PX  (* AVATAR-SIZE 30))
(define HEIGHT-PX (* AVATAR-SIZE 30))

;; Visual constants
(define EMPTY-SCENE (empty-scene WIDTH-PX HEIGHT-PX))
(define MONSTER-IMG (bitmap "graphics/monster.gif"))
(define GOLD-IMG  (bitmap "graphics/gold.gif"))
(define AVATAR-IMG (bitmap "graphics/avatar.gif"))
(define AVATAR-LEFT-IMG (bitmap "graphics/avatar-left.gif"))
(define AVATAR-DOWN-IMG (bitmap "graphics/avatar-down.gif"))
(define AVATAR-RIGHT-IMG (flip-horizontal AVATAR-LEFT-IMG)) ;; this might need to not be flipped but be a separate image all together
(define AVATAR-UP-IMG (bitmap "graphics/avatar-up.gif"))

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

;;game-world current_map adventurer (Listof Monsters)(Listof Items)(Numberof Gold)

;; Start the Game
(define (start-quest)
  (big-bang (game-world 
                 (current-map (default_map)) 
                 (adventurer MAX-HEALTH DEFAULT-ITEMS DEFAULT-GOLD "down" (list (posn 1 1)))
                 (list (spawn-monster)
                       (spawn-monster)
                       (spawn-monster)
                       (spawn-monster)
                       (spawn-monster)
                       (spawn-monster))
            (on-tick next-game-world TICK-RATE)
            (on-key direct-avatar)
            (to-draw render-game-world)
            (stop-when dead? render-end))))

;; Game-world -> Game-world
(define (next-game-world world)
  (define adventurer (game-world-adventurer world))
  ;;(define monsters  (game-world-monsters world)) ;; when adding monsters, re-add this
  (define item-to-pickup (can-pickup adventurer world_items_list))
  (if item-to-pickup
      (game-world adventurer (pickup world_items_list item-to-pickup))
      (game-world adventurer worlds_item_list)))

;; Game-world KeyEvent -> Game-world
;; Handle a key event
(define (direct-avatar world input_key)
  (cond [(dir? input_key) (world-change-dir world input_key)]
        [(heal? input_key) (world-heal-adventurer world)]
        [else world]))

;; Game-world -> Scene
;; Render the world as a scene
(define (render-game-world world)
  (adventurer+scene (game-world-adventurer world)
               (item-list+scene (game-world-world_items_list world) EMPTY-SCENE)))

;; Game-world -> Boolean
;; Is the adventurer dead?
(define (dead? world)
  (define adventurer (game-world-adventurer world))
  (or (zero-health? adventurer) (wall-colliding? adventurer)))

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


;; Game-world Direction or Move -> Game-world
;; Change the direction or move in that direction
;; > (world-dir-or-mv world0 "up")
;; (game-world adventurer1 (list items)) 

(define (world-dir-or-mv world direction)
  (define the-adventurer (game-world-adventurer world))
     (game-world (adventurer-change-dir the-adventurer direction) world_gold))

(define (world-heal-adventurer world)
   (define the-adventurer (game-world-adventurer world))
     (game-world (heal-adventurer the-adventurer) world_gold))
)


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
;; Posn Posn -> Boolean
;; Are the two posns are equal?
;; > (posn=? (posn 1 1) (posn 1 1))
;; true
(define (posn=? p1 p2)
  (and (= (posn-x p1) (posn-x p2))
       (= (posn-y p1) (posn-y p2))))

(define (legal-move=? avatar direction)
    (if (= move-adv-loc obs)
      
    )
)

;; Adventurer Direction -> Adventurer 
(define (adventurer-change-dir avatar direction)
  (if (= (adventurer-direction avatar) direction (legal-move? avatar))
         (adventurer (adventurer-direction avatar) (adventurer-gold avatar) (move-adventurer avatar))
         (adventurer direction (adventurer-gold avatar) (adventurer-location avatar))))

;; Adventurer Heal -> Adventurer
(define (heal-adventurer adventurer)
        (if (< (adventurer-health avatar) 49)
            (adventurer (+ (adventurer-health avatar) 50) (adventurer-direction avatar) (adventurer-gold avatar) (adventurer-location avatar))
            (adventurer MAX-HEALTH (adventurer-direction avatar) (adventurer-gold avatar) (adventurer-location avatar))))


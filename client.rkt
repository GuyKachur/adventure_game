#lang racket

;                                                                                                                                                  
;                                                                                                                                                  
;                                                                                                                                                  
;                                                                                                                                                  
;   ;;;;;;; ;;                        ;;        ;;                                                                    ;;;;                         
;   ;  ;  ;  ;                         ;         ;                           ;                                       ;   ;                         
;      ;     ; ;;    ;;;;             ; ;    ;;; ; ;;;  ;;;  ;;;;   ;; ;;   ;;;;;   ;;  ;;  ;; ;;;   ;;;;           ;        ;;;;  ;; ;  ;   ;;;;  
;      ;     ;;  ;  ;    ;            ; ;   ;   ;;  ;    ;  ;    ;   ;;  ;   ;       ;   ;   ;;     ;    ;          ;       ;    ;  ;; ;; ; ;    ; 
;      ;     ;   ;  ;;;;;;            ; ;   ;    ;   ;  ;   ;;;;;;   ;   ;   ;       ;   ;   ;      ;;;;;;          ;   ;;;  ;;;;;  ;  ;  ; ;;;;;; 
;      ;     ;   ;  ;                 ;;;   ;    ;   ;  ;   ;        ;   ;   ;       ;   ;   ;      ;               ;    ;  ;    ;  ;  ;  ; ;      
;      ;     ;   ;  ;                ;   ;  ;   ;;    ;;    ;        ;   ;   ;   ;   ;  ;;   ;      ;                ;   ;  ;   ;;  ;  ;  ; ;      
;     ;;;   ;;; ;;;  ;;;;;          ;;; ;;;  ;;; ;;   ;;     ;;;;;  ;;; ;;;   ;;;     ;; ;; ;;;;;    ;;;;;            ;;;    ;;; ;;;;; ;; ;  ;;;;; 
;                                                                                                                                                  
;                                                                                                                                                  
;                                                                                                                                                  
;    To start game just type (start-game adventurername IP) (IP the only thing that needs to change)

;;Requires
(require racket/trace)
(require 2htdp/universe 2htdp/image)
(require (prefix-in draw: racket/draw)) ;;rebinds draw functions to draw:(then function name) needed for color database


;                                                                                            
;                                                                                            
;                                                                                            
;                                                                                            
;                                                                                            
;     ;;;; ;                                 ;                             ;                 
;    ;    ;;                                 ;                             ;                 
;   ;      ;    ;;;     ;; ;;;     ;;;; ;  ;;;;;;;      ;;;;    ;; ;;;   ;;;;;;;     ;;;; ;  
;   ;          ;   ;     ;;   ;   ;    ;;    ;         ;    ;    ;;   ;    ;        ;    ;;  
;   ;         ;     ;    ;    ;   ;          ;              ;    ;    ;    ;        ;        
;   ;         ;     ;    ;    ;    ;;;;;     ;         ;;;;;;    ;    ;    ;         ;;;;;   
;   ;         ;     ;    ;    ;         ;    ;        ;     ;    ;    ;    ;              ;  
;    ;     ;   ;   ;     ;    ;   ;     ;    ;    ;   ;    ;;    ;    ;    ;    ;   ;     ;  
;     ;;;;;     ;;;     ;;;  ;;;  ;;;;;;      ;;;;     ;;;; ;;  ;;;  ;;;    ;;;;    ;;;;;;   
;                                                                                            
;                                                                                            
;                                                                                            
;                                                                                            


;;Game Structs


;;(struct renderworld (listofitemstorender) #:prefab)
(struct player (name ip))
(struct item (name location size image health solid direction decay)#:transparent #:mutable)
(struct location (x y) #:transparent #:mutable)
(struct serverworld (map players items spectators) #:transparent)
(struct waitingworld (listofplayers) #:transparent)
(struct adventurer (name health items direction location image) #:transparent #:mutable)


;;Visual Constants
(define HEALTH_BAR_HEIGHT 5)
(define AVATAR-RIGHT-IMG (bitmap "graphics/right-tank.png"))


(define OTHER_PLAYER AVATAR-RIGHT-IMG) ;;should we change the color on the fly? seems like a lot of work, instead just give them all a random color

(define AVATAR-SIZE (/ (image-width AVATAR-RIGHT-IMG) 2))
(define AVATAR-TEXT-SIZE 10)

(define BULLETIMAGE (bitmap "graphics/bullet.png"))

;; GRAPHICAL BOARD
(define WIDTH-PX  500)
(define HEIGHT-PX 500)

;; DEFAULT MAP
(define DEFAULT_MAP (bitmap "graphics/background.png"))

;; Visual constants



(define client-world (player "guy" LOCALHOST))

(define (start-game NAME IP)
  (big-bang client-world
     (on-draw render-world)
     (name NAME)
     (register IP)
     (on-receive update-world-state)
     (on-key send-server-message)
    )
  )


;;Renders the world, takes a world state and passes it either to objects on world (the real renderer) or displays please wait
(define (render-world s)
   (cond 
         [(list? s)  (objects-on-world s) ]
         [(player? s) (overlay
                         (text "Please Wait" 15 "black")
                         DEFAULT_MAP)]
         [else (underlay DEFAULT_MAP)]
         )
)


;;take player world and msg-returns new serverstate(in this case a list)
(define (update-world-state s msg)
  (flatten (list_to_structs msg)))


  
;;(name health items direction location image)
;; (struct item (name location size image health solid direction decay)#:transparent #:mutable)
;;'("hey" 5 "south" 100 100 "hey" 5 "south" 100 100 "hey" 5 "south" 100 100 "adventurer" "neil" 100 "left" 138 44 "adventurer" "guy" 100 "left" 363 435)

;;This is taking the data that has been serialized and returning it to the struct forms so it can be rendered. Data comes in as a specific string of information where order matters!

(define (list_to_structs lst) ;;(name health items direction location image)
  (cond
    [(empty? lst) '()]
    [(and (string=? (first lst) "adventurer") (string=? (second lst) adventurername)) (list (adventurer
                                                                                             (second lst)
                                                                                             (third lst)
                                                                                             '()
                                                                                             (fourth lst)
                                                                                             (location (fifth lst) (sixth lst))
                                                                                              (cond
                                                                                                [(string=? "down" (fourth lst)) (rotate -90 PLAYER-IMAGE)]
                                                                                                [(string=? "up" (fourth lst)) (rotate 90 PLAYER-IMAGE)]
                                                                                                [(string=? "left" (fourth lst)) (rotate 180 PLAYER-IMAGE)]
                                                                                                {else PLAYER-IMAGE}))
                                                                                            (list_to_structs (rest (rest (rest (rest (rest (rest lst))))))))]
    
    [(string=? (first lst) "adventurer") (list (adventurer
                                                (second lst)
                                                (third lst)
                                                '()
                                                (fourth lst)
                                                (location (fifth lst) (sixth lst))
                                                (cond
                                                  [(string=? "down" (fourth lst)) (rotate -90 OTHER_PLAYER)]
                                                  [(string=? "up" (fourth lst)) (rotate 90 OTHER_PLAYER)]
                                                  [(string=? "left" (fourth lst)) (rotate 180 OTHER_PLAYER)]
                                                  {else OTHER_PLAYER}))
                                               (list_to_structs (rest (rest (rest (rest (rest (rest lst))))))))]
    
    [(and (string=? (second lst) "bullet") (string=? (first lst) "item")) (list (item
                                                                                 (second lst)
                                                                                 (location (third lst) (fourth lst))
                                                                                 (fifth lst)
                                                                                 (cond
                                                                                   [(string=? "down" (seventh lst)) (rotate 180 BULLETIMAGE)]
                                                                                   [(string=? "left" (seventh lst)) (rotate 90 BULLETIMAGE)]
                                                                                   [(string=? "right" (seventh lst)) (rotate 270 BULLETIMAGE)]
                                                                                   {else BULLETIMAGE})
                                                                                 (sixth lst)
                                                                                 #f
                                                                                 (seventh lst)
                                                                                 1)
                                                                                (list_to_structs (rest (rest (rest (rest (rest (rest (rest lst)))))))))]
    
    [(string=? (first lst) "item") (list (item '
                                               (second lst)
                                               (location (third lst) (fourth lst))
                                               (fifth lst)
                                               (correct-item-image (second lst))
                                               (sixth lst)
                                               #f
                                               (seventh lst)
                                               1)
                                         (list_to_structs (rest (rest (rest (rest (rest (rest (rest lst)))))))))]
    
    )
  )


;here is where we change the item images match the name to the item
(define (correct-item-image itemname) ;;
  (cond
    [(string=? itemname "bullet") BULLETIMAGE]
    [else (circle 15 "solid" "green")]
    )
  )
;;need to define all the items





;; Sends the server a package with the key that was pressed and the world. (server recives an iworld struct as well as the key that was pressed, and the worldstate

(define (send-server-message w key)
    (cond [(key=? key "up")   (make-package w "up")]
          [(key=? key "down") (make-package w "down")]
          [(key=? key "right")    (make-package w "right")]
          [(key=? key "left")    (make-package w "left")]
          [(key=? key " ")    (make-package w " ")]
          [else w]
          ))



;;Takes a list of items and adventurers and displays them on the defualt map
(define (objects-on-world world)
  (cond
    [(empty? world) DEFAULT_MAP]
    [(empty? (first world)) DEFAULT_MAP]
    [(item? (first world))
                                 (place-image (above
                                                  (render-health-bar (first world))
                                                  (item-image  (first world)))
                                              (location-x (item-location (first world)))
                                              (location-y (item-location (first  world)))
                                              (objects-on-world (rest world)))]
     [(adventurer? (first world)) 
                                             (place-image (above
                                                           (text (adventurer-name (first world)) AVATAR-TEXT-SIZE chosencolor)
                                                           (render-health-bar (first world))
                                                           (adventurer-image (first world)))
                                                          (location-x (adventurer-location (first world)))
                                                          (location-y (adventurer-location (first world)))
                                                          (objects-on-world (rest world)))]
     [else (text "ERROR IN OBJECTS ON WORLD" 24 "red")]
  )
  )



;;take an object, (either an adventurer or an item) and renders the health bar, if we want the health bar rendered (no health or item is solid means no helath bar)
(define (render-health-bar object)
  (cond
    [(item? object) (if
                     (or (< (item-health object) 0)
                         (item-solid object))
                               empty-image ;;puts an empty image if the item is solid (should we add (or (< (item-health object) 0) ?
                        (overlay
                             (overlay/align "left" "center"
                                            (rectangle (* (/ (item-health object) 100) (item-size object)) HEALTH_BAR_HEIGHT "solid" "red")
                                            (rectangle (item-size object) HEALTH_BAR_HEIGHT "solid" "white"))
                             (rectangle (+ (item-size object) 3) (+ HEALTH_BAR_HEIGHT 3) "solid" "black"))
                             )]
     [(adventurer? object) (if (< (adventurer-health object) 0) empty-image
                               ;;else
                               (overlay
                                   (overlay/align "left" "center"
                                               (rectangle (* (/ (adventurer-health object) 100) AVATAR-SIZE) HEALTH_BAR_HEIGHT "solid" "red")
                                               (rectangle AVATAR-SIZE HEALTH_BAR_HEIGHT "solid" "white"))
                                   (rectangle (+ AVATAR-SIZE 3) (+ HEALTH_BAR_HEIGHT 3) "solid" "black")))
                                ]
                                
                                   
     [else (text "ERROR IN RENDER-HEALTH-BAR" 24 "red")]))








;;takes a color object, gets its red green and blue, and makes it into a stuct color. (no transparency for you)

(define (color-object-to-struct COLOR)
  (color (send COLOR red) (send COLOR green) (send COLOR blue) 255))

;;Sets the color that a person wants to use as their avatar.

(displayln "Please choose a color for your avatar")
(define chosencolor (color-object-to-struct (send draw:the-color-database find-color (symbol->string (read)))))

;;takes image and returns an image with the chosen color swapped, (
;;function swaps all red pixels in an image with chosencolor.

(define (color-change image)
  (define xlist (image->color-list image))
  (define new-color-list (map colorchange-helper xlist))
  (color-list->bitmap new-color-list (image-width image) (image-height image)))

(define (colorchange-helper listitem)
  (colorchange listitem (color 255 0 0 255) 150 chosencolor));; this is a range number seems to be good for getting rid of all the red


(define (colorchange item chosen_color range new-color)
  (if (and
       (< (- (color-red chosen_color) range) (color-red item) (+ (color-red chosen_color) range))
       (< (- (color-green chosen_color) range) (color-green item) (+ (color-green chosen_color) range))
       (< (- (color-blue chosen_color) range) (color-blue item) (+ (color-blue chosen_color) range))
       (< (- (color-alpha chosen_color) range) (color-alpha item) (+ (color-alpha chosen_color) range)))
      new-color
      ;;else
      item)
  )

(define PLAYER-IMAGE (color-change AVATAR-RIGHT-IMG))

(displayln "Please enter your name")
(define adventurername (symbol->string (read)))


;;(start-game adventurername LOCALHOST)
;;(start-game "guy" LOCALHOST)
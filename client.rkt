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
(define AVATAR-IMAGE (circle 15 "solid" "red"))
(define OTHER_ADVENTURER (circle 15 "solid" "blue")) ;;should we change the color on the fly? seems like a lot of work, instead just give them all a random color
(define AVATAR-SIZE 15)
(define AVATAR-TEXT-SIZE 10)

;; GRAPHICAL BOARD
(define WIDTH-PX  (* AVATAR-SIZE 30))
(define HEIGHT-PX (* AVATAR-SIZE 30))

;; DEFAULT MAP
(define DEFAULT_MAP (empty-scene WIDTH-PX HEIGHT-PX))

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



(define (render-world s)
   (cond 
         [(list? s)  (objects-on-world s) ]
         [(player? s) (underlay
                  (text "Please Wait" 15 "black")
                     DEFAULT_MAP)]
         [else DEFAULT_MAP]
         )
)


;;take player world and msg-returns new serverstate(in this case a list)
(define (update-world-state s msg)
  (flatten (list_to_structs msg)))


  
;;(name health items direction location image)
;; (struct item (name location size image health solid direction decay)#:transparent #:mutable)
;;'("hey" 5 "south" 100 100 "hey" 5 "south" 100 100 "hey" 5 "south" 100 100 "adventurer" "neil" 100 "left" 138 44 "adventurer" "guy" 100 "left" 363 435)



(define (list_to_structs lst) ;;(name health items direction location image)
  (cond
    [(empty? lst) '()]
    [(and (string=? (first lst) "adventurer") (string=? (second lst) adventurername)) (list (adventurer (second lst) (third lst) '() (fourth lst) (location (fifth lst) (sixth lst)) PLAYER-IMAGE) (list_to_structs (rest (rest (rest (rest (rest (rest lst))))))))]
    [(string=? (first lst) "adventurer") (list (adventurer (second lst) (third lst) '() (fourth lst) (location (fifth lst) (sixth lst)) OTHER_ADVENTURER) (list_to_structs (rest (rest (rest (rest (rest (rest lst))))))))]
    [(string=? (first lst) "item") (list (item (second lst) (location (third lst) (fourth lst)) (fifth lst) (correct-item-image (second lst)) (sixth lst) #f (seventh lst) 1) (list_to_structs (rest (rest (rest (rest (rest (rest (rest lst)))))))))]
    )
  )

(define (correct-item-image itemname) ;;
  (cond
    [(string=? itemname "bullet") (circle 10 "solid" "purple")]
    [else (circle 10 "solid" "purple")]
    )
  )
;;need to define all the items





;; Sends the server a package with the key that was pressed

(define (send-server-message w key)
    (cond [(key=? key "up")   (make-package w "up")]
        [(key=? key "down") (make-package w "down")]
        [(key=? key "right")    (make-package w "right")]
        [(key=? key "left")    (make-package w "left")]
        [(key=? key " ")    (make-package w " ")]
        [else w]))




(define (objects-on-world world)
   (cond
     ((empty? world) DEFAULT_MAP)
     ((empty? (first world)) DEFAULT_MAP)
     
    ((item? (first world))
                                 (place-image (above
                                               (render-health-bar (first world))
                                               (item-image  (first world)))
                                       (location-x (item-location (first world)))
                                       (location-y (item-location (first  world)))
                                       (objects-on-world (rest world))))
     ((adventurer? (first world)) 
                                             (place-image (above
                                                           (text (adventurer-name (first world)) AVATAR-TEXT-SIZE chosencolor)
                                             (render-health-bar (first world))
                                             (adventurer-image (first world)))
                                                          (location-x (adventurer-location (first world)))
                                                          (location-y (adventurer-location (first world)))
                                                          (objects-on-world (rest world))))
     (else (text "ERROR IN OBJECTS ON WORLD" 24 "red")))
  )



(define (render-health-bar object)
  (cond
    [(item? object) (if (or (< (item-health object) 0) (item-solid object)) empty-image ;;puts an empty image if the item is solid (should we add (or (< (item-health object) 0) ?
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










(define (color-object-to-struct COLOR)
  (color (send COLOR red) (send COLOR green) (send COLOR blue) 255))


(displayln "Please choose a color for your avatar")
(define chosencolor (color-object-to-struct (send draw:the-color-database find-color (symbol->string (read)))))

;;Color Change for avatar not implemented but i thought i would copy it over so you can play with it if you want
;;take image and return new image with different color

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

(define PLAYER-IMAGE (color-change AVATAR-IMAGE))

(displayln "Please enter your name")
(define adventurername (symbol->string (read)))


;;(start-game adventurername LOCALHOST)
;;(start-game "guy" LOCALHOST)
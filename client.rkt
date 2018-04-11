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
;                                                                                                                                                  

;;constants
(require racket/trace)


(struct renderworld (listofitemstorender) #:prefab)

(struct player (name ip))
(define client-world (player "guy" LOCALHOST))
(struct item (name location size image health solid direction decay)#:transparent #:mutable)
(struct location (x y) #:transparent #:mutable)
(define HEALTH_BAR_HEIGHT 5)

(struct serverworld (map players items spectators) #:transparent)
(struct waitingworld (listofplayers) #:transparent)
(struct adventurer (name health items direction location image) #:transparent #:mutable)



(define AVATAR-SIZE 15)

;; GRAPHICAL BOARD
(define WIDTH-PX  (* AVATAR-SIZE 30))
(define HEIGHT-PX (* AVATAR-SIZE 30))

;; DEFAULT MAP
;; This is currently the same as the empty scene setup as temp until we make a default one that is different.
(define DEFAULT_MAP (empty-scene WIDTH-PX HEIGHT-PX))

;; Visual constants
(define EMPTY-SCENE (empty-scene WIDTH-PX HEIGHT-PX))
(define ENDGAME-TEXT-SIZE 15)

(define CURRENT_PLAYER_IMAGE (circle 15 "solid" "blue"))

;;just type (start-game NAME IP)

(require 2htdp/universe 2htdp/image) ; "shared.rkt")
;;we need to provide defualtMAP

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
#;(define (pass-to-render s msg)
  (define struct_list (list_to_structs msg))
  (objects-on-world (flatten struct_list)))

(define OTHER_ADVENTURER (circle 15 "solid" "red"))
(define (list_to_structs lst) ;;(name health items direction location image)
  (cond
    [(empty? lst) '()]
    [(string=? (first lst) "adventurer") (list (adventurer (second lst) (third lst) '() (fourth lst) (location (fifth lst) (sixth lst)) OTHER_ADVENTURER) (list_to_structs (rest (rest (rest (rest (rest (rest lst))))))))]
    [(string=? (first lst) "item") (list (item (second lst) (location (third lst) (fourth lst)) (fifth lst) (correct-item-image (second lst)) (sixth lst) #f (seventh lst) 1) (list_to_structs (rest (rest (rest (rest (rest (rest (rest lst)))))))))]
    )
  )

(define (correct-item-image itemname)
  (cond
    [(string=? itemname "bullet") (circle 10 "solid" "purple")]
    [else (circle 10 "solid" "purple")]
    )
  )
;;need to define all the items




  
;(trace pass-to-render)

;;sends a player name and a key press to the server



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
                                               (render-health-bar (first (first world)))
                                               (item-image (first (first world))))
                                       (location-x (item-location (first (first world))))
                                       (location-y (item-location (first (first world))))
                                       (objects-on-world (rest (first world)))))
     ((adventurer? (first world)) 
                                             (place-image (above
                                             (render-health-bar (first world))
                                             (adventurer-image (first world)))
                                                          (location-x (adventurer-location (first world)))
                                                          (location-y (adventurer-location (first world)))
                                                          (objects-on-world (rest world))))
     (else (text "ERROR IN OBJECTS ON WORLD" 24 "red")))
  )


(trace objects-on-world)

(define (render-health-bar object)
  (cond
    [(item? object) (if (item-solid object) empty-image ;;puts an empty image if the item is solid (should we add (or (< (item-health object) 0) ?
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


(require racket/trace)
;;(trace objects-on-world)
;;(trace render-world)
;;(trace pass-to-render)

(start-game "guy" LOCALHOST)
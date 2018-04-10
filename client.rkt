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

(struct player (name ip))
(define client-world (player "guy" LOCALHOST))
(struct item (name location size image health solid direction)#:transparent #:mutable)
(define DEFAULT_MAP (empty-scene 500 500))
(struct location (x y) #:transparent #:mutable)
(define HEALTH_BAR_HEIGHT 5)


;;just type (start-game NAME IP)

(require 2htdp/universe 2htdp/image) ; "shared.rkt")
;;we need to provide defualtMAP

(define (start-game NAME IP)
  (big-bang client-world
    (on-draw render-waiting-screen)
    (name NAME)
    (register IP)
    (on-receive objects-on-world)
    (on-key send-server-message)
    )
  )


(define (render-waiting-screen world)
  (overlay
   (text "Please Wait" 15 "black")
   (empty-scene 500 500))
  )



;;sends a player name and a key press to the server



(define (send-server-message w key)
    (cond [(key=? key "up")   (make-package w "up")]
        [(key=? key "down") (make-package w "down")]
        [(key=? key "right")    (make-package w "right")]
        [(key=? key "left")    (make-package w "left")]
          [(key=? key "space")    (make-package w "space")]
        [else w]))




(define (objects-on-world world)
   (cond
    ((empty? world) DEFAULT_MAP)
    ((item? (first world)) 
                                 (place-image (above
                                               (render-health-bar (first world))
                                               (item-image (first world)))
                                       (location-x (item-location (first world)))
                                       (location-y (item-location (first world)))
                                       (objects-on-world (rest world))))
     (else (text "ERROR IN OBJECTS ON WORLD" 24 "red")))
  )




(define (render-health-bar object)
  (cond
    [(item? object) (if (item-solid object) empty-image ;;puts an empty image if the item is solid (should we add (or (< (item-health object) 0) ?
                        (overlay
                             (overlay/align "left" "center"
                                            (rectangle (* (/ (item-health object) 100) (item-size object)) HEALTH_BAR_HEIGHT "solid" "red")
                                            (rectangle (item-size object) HEALTH_BAR_HEIGHT "solid" "white"))
                             (rectangle (+ (item-size object) 3) (+ HEALTH_BAR_HEIGHT 3) "solid" "black"))
                             )]
                                   
     [else (text "ERROR IN RENDER-HEALTH-BAR" 24 "red")]))

#lang racket
(require 2htdp/universe)

;                                                  
;                                                  
;                                                  
;                                                  
;    ;;; ;                                         
;   ;   ;;                                         
;   ;        ;;;;   ;; ;;; ;;;  ;;;  ;;;;   ;; ;;; 
;    ;;;;   ;    ;   ;;     ;    ;  ;    ;   ;;    
;        ;  ;;;;;;   ;       ;  ;   ;;;;;;   ;     
;        ;  ;        ;       ;  ;   ;        ;     
;   ;;   ;  ;        ;        ;;    ;        ;     
;   ; ;;;    ;;;;;  ;;;;;     ;;     ;;;;;  ;;;;;  
;                                                  
;                                                  
;                                                  
;                                                  
;;To start (start-server)

(struct adventurer (name health items direction location image) #:transparent #:mutable)
(struct location (x y) #:transparent #:mutable)
(struct item (name location size image health solid)#:transparent #:mutable)




(struct player (number adventurer ip) #:transparent #:mutable)
(struct server-state (status players game-state) #:transparent #:mutable)


;;;THESE WERE STRAIGHT COPIED

;; Functional updaters for the server state
(define (server-state-set-status s status)
  (server-state status (server-state-players s) (server-state-game-state s)))
(define (server-state-set-players s players)
  (server-state (server-state-status s) players (server-state-game-state s)))
(define (server-state-set-game-state s game-state)
  (server-state (server-state-status s) (server-state-players s) game-state))




(define (server-start)
  (universe initial-world
            (on-new handle-server-connect)
            (on-msg handle-server-msg)
            (on-disconnect handle-server-disconnect)))

;;takes a world and passes it to the next players

;;all i want to do is pass the world from a player, to the server, extract the adventurer and turn it into an item. and then pass it forward
;;
(define (handle-server-msg player-world)
  (game-world
   (game-world-map player-world)
   (

;;so we need a program that takes a wolrd, extracts teh adventurer and sends it to the other people


;; world-> world (previous adventurer is now an item

   #; (so server is basically modifying an item list and passing it back and forth
       so it needs to get a player from everyone,
             create list
          convert players to items add to item list
          then return item list to each player

          player then needs to take item list, remove itself and repopulate world)
;       
;   players make action->
;   player item lists updated->
;   player sends to server->
;   server updates item lists->
;   server passes back items->
;   player removes itself->
;   player updates item list ->
;   world renders



;;takes world, returns all entities list,
   ;;this is trying to update item lists
   ;;

;;function needs to create an item list.

   (define (items-left-on-world-with-adventurer world)
     (list (game-world-items world) (



     
(define (handle-message-from-player world)
  
  (cons (game-world-adventurer 
  
   

;;server takes a world, extracts the adventurer passes it to another client which then adds its adventurer to the adventurer list



;;client side function that takes a server world extracts the adventuerer and adds it to the item list of the client world

(define (merge-worlds server-world client-world)
  (define items (flatten (list (game-world-items server-world) (adventurer-to-item (game-world-adventuer server-world)))))
  (game-world
   (game-world-current_map server-world)
   (game-world-adventurer client-world)
   items
   )
  )

;;;add adventurer list to item list of incoming world



  ;;world comes in, needs to have adventurer extracted, and added to item list which is then added to the world
  ;;world is returned, with adventurer in item list

  ;;another function, which removes item from list if it matches current adventurer
(define (remove-current-adventurer-from-item-list world)
  (remove ((adventurer-to-item adventurer

  

(define (adventurer-to-item adventurer)
  (item "adventurer"
        (adventurer-location adventurer)
        (image-width (adventuerer-image adventuerer))
        (adventuere-image adventuerer)
        (adventuerer-health adventurer)
        #t
        )
  )




#lang racket


;;RUN the sever

(require 2htdp/universe)
(require "adventurerserver.rkt")
(require "adventuregame.rkt")

(define (start-game)
  (launch-many-worlds
   (start-server)
   (start-quest "Guy" LOCALHOST)
   (start-quest "Neil" LOCALHOST)
   )
  )
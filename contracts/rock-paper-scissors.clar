;; Rock Paper Scissors Contract
;; Simple rock-paper-scissors game on-chain
;; Users choose rock, paper, or scissors; contract chooses randomly
;; If user wins, gains points; tracks win rate and streaks
;; Each game generates transaction fees

;; Error codes
(define-constant ERR-INVALID-CHOICE (err u1001))
(define-constant ERR-INSUFFICIENT-FEE (err u1002))

;; Game fee (in micro-STX)
(define-constant GAME-FEE u10000)  ;; 0.01 STX per game

;; Points awarded on win
(define-constant POINTS-ON-WIN u10)

;; Game choices: 1 = Rock, 2 = Paper, 3 = Scissors
(define-constant ROCK u1)
(define-constant PAPER u2)
(define-constant SCISSORS u3)


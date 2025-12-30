;; Rock Paper Scissors Contract
;; Simple rock-paper-scissors game on-chain
;; Users choose rock, paper, or scissors; contract chooses randomly
;; If user wins, gains points; tracks win rate and streaks
;; Each game generates transaction fees

;; Error codes
(define-constant ERR-INVALID-CHOICE (err u1001))
(define-constant ERR-INSUFFICIENT-FEE (err u1002))


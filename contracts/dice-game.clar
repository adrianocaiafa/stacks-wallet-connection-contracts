;; Dice Game Contract
;; Simple dice rolling game on-chain
;; Users choose a number (1-6), contract rolls dice, if match wins points
;; Each roll generates transaction fees

;; Error codes
(define-constant ERR-INVALID-NUMBER (err u1001))
(define-constant ERR-INSUFFICIENT-FEE (err u1002))


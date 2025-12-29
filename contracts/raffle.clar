;; Raffle Contract
;; On-chain raffle/sorteio system
;; Users buy tickets; admin closes and picks winner
;; Each ticket purchase generates transaction fees

(define-constant ERR-RAFFLE-CLOSED (err u1001))
(define-constant ERR-INVALID-AMOUNT (err u1002))
(define-constant ERR-NO-PARTICIPANTS (err u1003))
(define-constant ERR-NOT-ADMIN (err u1004))
(define-constant ERR-ALREADY-CLOSED (err u1005))
(define-constant ERR-INVALID-TICKET-COUNT (err u1006))

;; Ticket price (in micro-STX)
(define-constant TICKET-PRICE u10000)  ;; 0.01 STX per ticket

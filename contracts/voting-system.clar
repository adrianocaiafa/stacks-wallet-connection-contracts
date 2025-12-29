;; Voting System Contract
;; On-chain voting/poll system for community decisions
;; Users vote on polls by paying fees; tracks results in real-time
;; Each vote generates transaction fees

;; Error codes
(define-constant ERR-POLL-NOT-FOUND (err u1001))
(define-constant ERR-POLL-CLOSED (err u1002))
(define-constant ERR-INVALID-OPTION (err u1003))
(define-constant ERR-INSUFFICIENT-FEE (err u1004))
(define-constant ERR-ALREADY-VOTED (err u1005))
(define-constant ERR-NOT-ADMIN (err u1006))


;; Daily Check-in Contract
;; On-chain daily check-in system with streak tracking
;; Users check in daily by paying fees; tracks streaks and rewards
;; Each check-in generates transaction fees

;; Error codes
(define-constant ERR-ALREADY-CHECKED-IN (err u1001))
(define-constant ERR-INSUFFICIENT-FEE (err u1002))
(define-constant ERR-NO-REWARD-AVAILABLE (err u1003))


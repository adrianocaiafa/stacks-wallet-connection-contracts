;; Daily Check-in Contract
;; On-chain daily check-in system with streak tracking
;; Users check in daily by paying fees; tracks streaks and rewards
;; Each check-in generates transaction fees

;; Error codes
(define-constant ERR-ALREADY-CHECKED-IN (err u1001))
(define-constant ERR-INSUFFICIENT-FEE (err u1002))
(define-constant ERR-NO-REWARD-AVAILABLE (err u1003))

;; Check-in fee (in micro-STX)
(define-constant CHECK-IN-FEE u10000)  ;; 0.01 STX per check-in

;; Streak milestones for rewards (in days)
(define-constant MILESTONE-7-DAYS u7)
(define-constant MILESTONE-30-DAYS u30)
(define-constant MILESTONE-100-DAYS u100)

;; Points per check-in
(define-constant POINTS-PER-CHECK-IN u1)

;; Total check-ins counter
(define-data-var total-check-ins uint u0)

;; Unique users counter
(define-data-var user-count uint u0)

;; List of unique users
(define-map user-list uint principal)

;; Map to track if user is in list
(define-map user-index principal (optional uint))


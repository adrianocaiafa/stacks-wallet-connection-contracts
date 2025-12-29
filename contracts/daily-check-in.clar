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

;; User check-in data: user -> {total-check-ins, current-streak, longest-streak, last-check-in-day, total-points}
(define-map user-check-ins principal {
    total-check-ins: uint,
    current-streak: uint,
    longest-streak: uint,
    last-check-in-day: uint,
    total-points: uint
})

;; Check-in history: (user, check-in-id) -> {day, streak, points}
(define-map check-in-history (tuple (user principal) (check-in-id uint)) {
    day: uint,
    streak: uint,
    points: uint
})

;; User check-in counter
(define-map user-check-in-counter principal uint)

;; Milestone rewards claimed: (user, milestone) -> claimed
(define-map milestone-claims (tuple (user principal) (milestone uint)) bool)

;; Helper to add user to list if new
(define-private (add-user-if-new (user principal))
    (let ((existing-index (map-get? user-index user)))
        (if (is-none existing-index)
            ;; New user, add to list
            (let ((new-index (var-get user-count)))
                (var-set user-count (+ new-index u1))
                (map-set user-list new-index user)
                (map-set user-index user (some new-index))
                true
            )
            ;; Already in list
            false
        )
    )
)

;; Helper to calculate current day (using total-check-ins as day counter)
(define-private (get-current-day)
    (var-get total-check-ins)
)


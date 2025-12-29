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

;; Helper to update user check-in stats
(define-private (update-user-stats (user principal) (fee uint) (current-day uint))
    (let ((current-stats (map-get? user-check-ins user)))
        (if (is-none current-stats)
            ;; First check-in for user
            (map-set user-check-ins user {
                total-check-ins: u1,
                current-streak: u1,
                longest-streak: u1,
                last-check-in-day: current-day,
                total-points: POINTS-PER-CHECK-IN
            })
            ;; Update existing stats
            (let ((stats (unwrap-panic current-stats)))
                (let ((last-day (get last-check-in-day stats))
                      (current-streak (get current-streak stats))
                      (longest-streak (get longest-streak stats)))
                    ;; Check if streak continues (same day or consecutive)
                    (let ((new-streak 
                        (if (is-eq current-day last-day)
                            ;; Same day - streak continues
                            current-streak
                            (if (is-eq current-day (+ last-day u1))
                                ;; Consecutive day - increment streak
                                (+ current-streak u1)
                                ;; Streak broken - reset to 1
                                u1
                            )
                        ))
                        (new-longest (if (> new-streak longest-streak) new-streak longest-streak)))
                        (map-set user-check-ins user {
                            total-check-ins: (+ (get total-check-ins stats) u1),
                            current-streak: new-streak,
                            longest-streak: new-longest,
                            last-check-in-day: current-day,
                            total-points: (+ (get total-points stats) POINTS-PER-CHECK-IN)
                        })
                    )
                )
            )
        )
    )
)


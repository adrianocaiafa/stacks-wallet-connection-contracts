;; Dice Game Contract
;; Simple dice rolling game on-chain
;; Users choose a number (1-6), contract rolls dice, if match wins points
;; Each roll generates transaction fees

;; Error codes
(define-constant ERR-INVALID-NUMBER (err u1001))
(define-constant ERR-INSUFFICIENT-FEE (err u1002))

;; Dice roll fee (in micro-STX)
(define-constant DICE-FEE u10000)  ;; 0.01 STX per roll

;; Points awarded on win
(define-constant POINTS-ON-WIN u10)

;; Dice number range
(define-constant DICE-MIN u1)
(define-constant DICE-MAX u6)

;; Total rolls counter
(define-data-var total-rolls uint u0)

;; Unique users counter
(define-data-var user-count uint u0)

;; List of unique users
(define-map user-list uint principal)

;; Map to track if user is in list
(define-map user-index principal (optional uint))

;; User statistics: user -> {total-rolls, wins, total-points, win-streak, longest-streak}
(define-map user-stats principal {
    total-rolls: uint,
    wins: uint,
    total-points: uint,
    win-streak: uint,
    longest-streak: uint
})

;; Roll history: (user, roll-id) -> {user-choice, dice-result, won, points, timestamp}
(define-map roll-history (tuple (user principal) (roll-id uint)) {
    user-choice: uint,
    dice-result: uint,
    won: bool,
    points: uint,
    timestamp: uint
})

;; User roll counter
(define-map user-roll-counter principal uint)

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

;; Helper to update user stats after roll
(define-private (update-user-stats (user principal) (won bool) (points uint) (roll-time uint))
    (let ((current-stats (map-get? user-stats user)))
        (if (is-none current-stats)
            ;; First roll for user
            (map-set user-stats user {
                total-rolls: u1,
                wins: (if won u1 u0),
                total-points: points,
                win-streak: (if won u1 u0),
                longest-streak: (if won u1 u0)
            })
            ;; Update existing stats
            (let ((stats (unwrap-panic current-stats)))
                (let ((current-streak (get win-streak stats))
                      (longest-streak (get longest-streak stats)))
                    (let ((new-streak 
                        (if won
                            (+ current-streak u1)
                            u0
                        ))
                        (new-longest (if (> new-streak longest-streak) new-streak longest-streak)))
                        (map-set user-stats user {
                            total-rolls: (+ (get total-rolls stats) u1),
                            wins: (+ (get wins stats) (if won u1 u0)),
                            total-points: (+ (get total-points stats) points),
                            win-streak: new-streak,
                            longest-streak: new-longest
                        })
                    )
                )
            )
        )
    )
)


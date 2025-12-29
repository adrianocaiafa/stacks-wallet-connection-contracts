;; Quest System Contract
;; On-chain quest/mission system for high engagement
;; Users complete quests by paying fees; tracks progress and rewards
;; Each quest completion generates transaction fees

;; Error codes
(define-constant ERR-INVALID-QUEST (err u1001))
(define-constant ERR-QUEST-ON-COOLDOWN (err u1002))
(define-constant ERR-INSUFFICIENT-FEE (err u1003))
(define-constant ERR-QUEST-ALREADY-COMPLETED (err u1004))
(define-constant ERR-NO-REWARD-AVAILABLE (err u1005))

;; Quest fees (in micro-STX)
(define-constant FEE-DAILY-QUEST u10000)      ;; 0.01 STX
(define-constant FEE-WEEKLY-QUEST u50000)     ;; 0.05 STX
(define-constant FEE-SPECIAL-QUEST u20000)    ;; 0.02 STX
(define-constant FEE-CLAIM-REWARD u10000)     ;; 0.01 STX

;; Cooldown periods (in blocks, approximate)
;; Daily: ~144 blocks (24 hours)
;; Weekly: ~1008 blocks (7 days)
(define-constant DAILY-COOLDOWN u144)
(define-constant WEEKLY-COOLDOWN u1008)

;; Points per quest type
(define-constant POINTS-DAILY u10)
(define-constant POINTS-WEEKLY u50)
(define-constant POINTS-SPECIAL u20)

;; Total quests counter
(define-data-var total-quests uint u0)

;; Unique users counter
(define-data-var user-count uint u0)

;; List of unique users
(define-map user-list uint principal)

;; Map to track if user is in list
(define-map user-index principal (optional uint))

;; User statistics: user -> {total-quests, total-points, total-spent, quest-master-level}
(define-map user-stats principal {
    total-quests: uint,
    total-points: uint,
    total-spent: uint,
    quest-master-level: uint
})

;; Quest completion history: (user, quest-id) -> {quest-type, points, timestamp, block-height}
(define-map quest-history (tuple (user principal) (quest-id uint)) {
    quest-type: (string-ascii 20),
    points: uint,
    timestamp: uint,
    block-height: uint
})

;; User quest counter
(define-map user-quest-counter principal uint)

;; Last completion time for daily quest: user -> block-height
(define-map last-daily-quest principal uint)

;; Last completion time for weekly quest: user -> block-height
(define-map last-weekly-quest principal uint)

;; Quest type statistics: quest-type -> {count, total-fees, total-points}
(define-map quest-type-stats (string-ascii 20) {
    count: uint,
    total-fees: uint,
    total-points: uint
})

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

;; Helper to update user stats
(define-private (update-user-stats (user principal) (fee uint) (points uint) (quest-time uint))
    (let ((current-stats (map-get? user-stats user)))
        (if (is-none current-stats)
            ;; First quest for user
            (map-set user-stats user {
                total-quests: u1,
                total-points: points,
                total-spent: fee,
                quest-master-level: u1
            })
            ;; Update existing stats
            (let ((stats (unwrap-panic current-stats)))
                (let ((new-points (+ (get total-points stats) points))
                      (new-level (+ u1 (/ new-points u100))))  ;; Level up every 100 points
                    (map-set user-stats user {
                        total-quests: (+ (get total-quests stats) u1),
                        total-points: new-points,
                        total-spent: (+ (get total-spent stats) fee),
                        quest-master-level: new-level
                    })
                )
            )
        )
    )
)


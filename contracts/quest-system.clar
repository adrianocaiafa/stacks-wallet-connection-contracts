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


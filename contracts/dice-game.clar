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


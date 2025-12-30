;; Rock Paper Scissors Contract
;; Simple rock-paper-scissors game on-chain
;; Users choose rock, paper, or scissors; contract chooses randomly
;; If user wins, gains points; tracks win rate and streaks
;; Each game generates transaction fees

;; Error codes
(define-constant ERR-INVALID-CHOICE (err u1001))
(define-constant ERR-INSUFFICIENT-FEE (err u1002))

;; Game fee (in micro-STX)
(define-constant GAME-FEE u10000)  ;; 0.01 STX per game

;; Points awarded on win
(define-constant POINTS-ON-WIN u10)

;; Game choices: 1 = Rock, 2 = Paper, 3 = Scissors
(define-constant ROCK u1)
(define-constant PAPER u2)
(define-constant SCISSORS u3)

;; Total games counter
(define-data-var total-games uint u0)

;; Unique users counter
(define-data-var user-count uint u0)

;; List of unique users
(define-map user-list uint principal)

;; Map to track if user is in list
(define-map user-index principal (optional uint))

;; User statistics: user -> {total-games, wins, losses, draws, total-points, win-streak, longest-streak}
(define-map user-stats principal {
    total-games: uint,
    wins: uint,
    losses: uint,
    draws: uint,
    total-points: uint,
    win-streak: uint,
    longest-streak: uint
})

;; Game history: (user, game-id) -> {user-choice, contract-choice, result, points, timestamp}
(define-map game-history (tuple (user principal) (game-id uint)) {
    user-choice: uint,
    contract-choice: uint,
    result: (string-ascii 10),
    points: uint,
    timestamp: uint
})

;; User game counter
(define-map user-game-counter principal uint)

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


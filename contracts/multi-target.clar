;; Multi-Target Contract
;; Guess multiple hidden numbers that sum to a known total
;; Example: Find 3 numbers (0-100) that sum to 150
;; High difficulty - massive search space
;; No fees, just gas - pure deduction gameplay

;; Error codes
(define-constant ERR-NO-ACTIVE-GAME (err u1001))
(define-constant ERR-GAME-ALREADY-ACTIVE (err u1002))
(define-constant ERR-INVALID-GUESS (err u1003))
(define-constant ERR-WRONG-COUNT (err u1004))
(define-constant ERR-NO-ATTEMPTS-LEFT (err u1005))

;; Constants
(define-constant TARGET-COUNT u3)  ;; 3 numbers to guess
(define-constant MIN-NUMBER u0)
(define-constant MAX-NUMBER u100)
(define-constant MAX-ATTEMPTS u15)  ;; More attempts due to difficulty

;; Total games counter
(define-data-var total-games uint u0)

;; Unique players counter
(define-data-var player-count uint u0)

;; List of unique players
(define-map player-list uint principal)

;; Map to track if player is in list
(define-map player-index principal (optional uint))

;; Game state per player
(define-map active-games principal {
    targets: (list 3 uint),      ;; The 3 secret numbers
    target-sum: uint,             ;; Known sum (the clue!)
    attempts-left: uint,
    attempts-used: uint,
    game-id: uint
})

;; Attempt history: (player, attempt-num) -> {guess, exact-matches}
(define-map attempt-history (tuple (player principal) (attempt-num uint)) {
    guess: (list 3 uint),
    exact-matches: uint  ;; How many numbers are exactly right (value + position)
})

;; Player statistics
(define-map player-stats principal {
    total-games: uint,
    wins: uint,
    best-attempts: uint
})

;; Game history: (player, game-id) -> {targets, attempts-used, won}
(define-map game-history (tuple (player principal) (game-id uint)) {
    targets: (list 3 uint),
    target-sum: uint,
    attempts-used: uint,
    won: bool
})

;; Player game counter
(define-map player-game-counter principal uint)

;; Helper to add player to list if new
(define-private (add-player-if-new (player principal))
    (let ((existing-index (map-get? player-index player)))
        (if (is-none existing-index)
            (let ((new-index (var-get player-count)))
                (var-set player-count (+ new-index u1))
                (map-set player-list new-index player)
                (map-set player-index player (some new-index))
                true
            )
            false
        )
    )
)

;; Helper to generate 3 random numbers
(define-private (generate-targets (seed uint))
    (let ((base-seed (+ (+ (* seed u997) stacks-block-height) (var-get player-count))))
        (list
            (+ MIN-NUMBER (mod base-seed (+ u1 (- MAX-NUMBER MIN-NUMBER))))
            (+ MIN-NUMBER (mod (+ base-seed u37) (+ u1 (- MAX-NUMBER MIN-NUMBER))))
            (+ MIN-NUMBER (mod (+ base-seed u73) (+ u1 (- MAX-NUMBER MIN-NUMBER))))
        )
    )
)

;; Helper to calculate sum of list
(define-private (sum-list (numbers (list 3 uint)))
    (+ (unwrap-panic (element-at? numbers u0))
       (unwrap-panic (element-at? numbers u1))
       (unwrap-panic (element-at? numbers u2)))
)

;; Helper to validate guess
(define-private (validate-guess (guess (list 3 uint)))
    (and
        (is-eq (len guess) TARGET-COUNT)
        (<= (unwrap-panic (element-at? guess u0)) MAX-NUMBER)
        (<= (unwrap-panic (element-at? guess u1)) MAX-NUMBER)
        (<= (unwrap-panic (element-at? guess u2)) MAX-NUMBER)
    )
)

;; Public function: Start new game
(define-public (start-game)
    (let ((player tx-sender))
        (asserts! (is-none (map-get? active-games player)) ERR-GAME-ALREADY-ACTIVE)
        (add-player-if-new player)
        
        (let ((game-counter (var-get total-games)))
            (let ((targets (generate-targets game-counter))
                  (target-sum (sum-list targets)))
                (map-set active-games player {
                    targets: targets,
                    target-sum: target-sum,
                    attempts-left: MAX-ATTEMPTS,
                    attempts-used: u0,
                    game-id: game-counter
                })
                (var-set total-games (+ game-counter u1))
                (ok {
                    game-id: game-counter,
                    message: "Find 3 numbers that sum to:",
                    target-sum: target-sum,
                    range: "0-100",
                    attempts-left: MAX-ATTEMPTS
                })
            )
        )
    )
)

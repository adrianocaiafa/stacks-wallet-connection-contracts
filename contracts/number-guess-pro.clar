;; Number Guess Pro Contract
;; Challenge mode - Exactly 10 attempts
;; Guess a number between 0-1000 within 10 tries
;; No fees, just gas - competitive gameplay
;; Optional hint available for 0.003 STX (consumes 1 attempt)

;; Error codes
(define-constant ERR-NO-ACTIVE-GAME (err u1001))
(define-constant ERR-GAME-ALREADY-ACTIVE (err u1002))
(define-constant ERR-INVALID-NUMBER (err u1003))
(define-constant ERR-INSUFFICIENT-FEE (err u1004))
(define-constant ERR-HINT-ALREADY-USED (err u1005))
(define-constant ERR-NO-ATTEMPTS-LEFT (err u1006))

;; Constants
(define-constant MIN-NUMBER u0)
(define-constant MAX-NUMBER u1000)
(define-constant MAX-ATTEMPTS u10)
(define-constant HINT-FEE u3000)  ;; 0.003 STX

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
    secret-number: uint,
    attempts-left: uint,
    attempts-used: uint,
    hint-used: bool,
    game-id: uint
})

;; Player statistics
(define-map player-stats principal {
    total-games: uint,
    wins: uint,
    total-score: uint,
    best-score: uint,
    perfect-games: uint  ;; Games won in 1 attempt
})

;; Game history: (player, game-id) -> {secret-number, attempts-used, won, score, hint-used}
(define-map game-history (tuple (player principal) (game-id uint)) {
    secret-number: uint,
    attempts-used: uint,
    won: bool,
    score: uint,
    hint-used: bool
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

;; Helper to generate random number between MIN-NUMBER and MAX-NUMBER
(define-private (generate-secret-number (seed uint))
    (let ((random-seed (+ (+ (* seed u997) stacks-block-height) (var-get player-count))))
        (+ MIN-NUMBER (mod random-seed (+ u1 (- MAX-NUMBER MIN-NUMBER))))
    )
)

;; Helper to calculate score based on attempts
;; 1 attempt = 1000 points, 2 = 900, 3 = 800, ... 10 = 100
(define-private (calculate-score (attempts-used uint))
    (if (<= attempts-used MAX-ATTEMPTS)
        (- u1100 (* attempts-used u100))
        u0
    )
)

;; Public function: Start new game
(define-public (start-game)
    (let ((player tx-sender))
        ;; Check if player already has active game
        (asserts! (is-none (map-get? active-games player)) ERR-GAME-ALREADY-ACTIVE)
        
        ;; Add player to list if new
        (add-player-if-new player)
        
        ;; Get game counter
        (let ((game-counter (var-get total-games)))
            ;; Generate secret number
            (let ((secret (generate-secret-number game-counter)))
                ;; Create new game
                (map-set active-games player {
                    secret-number: secret,
                    attempts-left: MAX-ATTEMPTS,
                    attempts-used: u0,
                    hint-used: false,
                    game-id: game-counter
                })
                
                ;; Increment total games
                (var-set total-games (+ game-counter u1))
                
                (ok {
                    game-id: game-counter,
                    message: "Game started! 10 attempts",
                    min: MIN-NUMBER,
                    max: MAX-NUMBER,
                    attempts-left: MAX-ATTEMPTS
                })
            )
        )
    )
)

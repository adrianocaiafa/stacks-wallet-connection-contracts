;; Number Guess Zen Contract
;; Infinite attempts mode - Casual gameplay
;; Guess a number between 0-1000
;; No fees, just gas - pure on-chain activity
;; Optional hint available for 0.003 STX

;; Error codes
(define-constant ERR-NO-ACTIVE-GAME (err u1001))
(define-constant ERR-GAME-ALREADY-ACTIVE (err u1002))
(define-constant ERR-INVALID-NUMBER (err u1003))
(define-constant ERR-INSUFFICIENT-FEE (err u1004))
(define-constant ERR-HINT-ALREADY-USED (err u1005))

;; Constants
(define-constant MIN-NUMBER u0)
(define-constant MAX-NUMBER u1000)
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
    attempts: uint,
    hint-used: bool,
    game-id: uint
})

;; Player statistics
(define-map player-stats principal {
    total-games: uint,
    total-attempts: uint,
    best-attempts: uint,  ;; Lowest number of attempts to win
    current-streak: uint,
    longest-streak: uint
})

;; Game history: (player, game-id) -> {secret-number, attempts, won, hint-used}
(define-map game-history (tuple (player principal) (game-id uint)) {
    secret-number: uint,
    attempts: uint,
    won: bool,
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
    (let ((random-seed (+ (+ seed stacks-block-height) 
                          (unwrap-panic (element-at? (unwrap-panic (as-max-len? (list tx-sender) u1)) u0)))))
        (+ MIN-NUMBER (mod random-seed (+ u1 (- MAX-NUMBER MIN-NUMBER))))
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
                    attempts: u0,
                    hint-used: false,
                    game-id: game-counter
                })
                
                ;; Increment total games
                (var-set total-games (+ game-counter u1))
                
                (ok {
                    game-id: game-counter,
                    message: "Game started! Guess a number between 0-1000",
                    min: MIN-NUMBER,
                    max: MAX-NUMBER
                })
            )
        )
    )
)

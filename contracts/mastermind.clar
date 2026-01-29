;; Mastermind Contract
;; Classic code-breaking game on-chain
;; Guess the secret 5-digit code (0-9)
;; 10 attempts to crack the code
;; Feedback: exact matches and number matches with wrong position
;; No fees, just gas - pure deduction gameplay

;; Error codes
(define-constant ERR-NO-ACTIVE-GAME (err u1001))
(define-constant ERR-GAME-ALREADY-ACTIVE (err u1002))
(define-constant ERR-INVALID-CODE (err u1003))
(define-constant ERR-INVALID-CODE-LENGTH (err u1004))
(define-constant ERR-NO-ATTEMPTS-LEFT (err u1005))

;; Constants
(define-constant CODE-LENGTH u5)
(define-constant MAX-DIGIT u9)
(define-constant MAX-ATTEMPTS u10)

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
    secret-code: (list 5 uint),
    attempts-left: uint,
    attempts-used: uint,
    game-id: uint
})

;; Attempt history per game: (player, attempt-number) -> {code, exact, partial}
(define-map attempt-history (tuple (player principal) (attempt-num uint)) {
    code: (list 5 uint),
    exact-matches: uint,
    partial-matches: uint
})

;; Player statistics
(define-map player-stats principal {
    total-games: uint,
    wins: uint,
    total-attempts: uint,
    best-attempts: uint,  ;; Fewest attempts to win
    perfect-games: uint   ;; Games won in 1 attempt (lucky!)
})

;; Game history: (player, game-id) -> {secret-code, attempts-used, won, score}
(define-map game-history (tuple (player principal) (game-id uint)) {
    secret-code: (list 5 uint),
    attempts-used: uint,
    won: bool,
    score: uint
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

;; Helper to generate random code
(define-private (generate-secret-code (seed uint))
    (let ((base-seed (+ (+ (* seed u997) stacks-block-height) (var-get player-count))))
        (list
            (mod base-seed u10)
            (mod (+ base-seed u13) u10)
            (mod (+ base-seed u37) u10)
            (mod (+ base-seed u71) u10)
            (mod (+ base-seed u113) u10)
        )
    )
)

;; Helper to validate code format
(define-private (validate-code (code (list 5 uint)))
    (let ((len (len code)))
        (and
            (is-eq len CODE-LENGTH)
            (<= (unwrap-panic (element-at? code u0)) MAX-DIGIT)
            (<= (unwrap-panic (element-at? code u1)) MAX-DIGIT)
            (<= (unwrap-panic (element-at? code u2)) MAX-DIGIT)
            (<= (unwrap-panic (element-at? code u3)) MAX-DIGIT)
            (<= (unwrap-panic (element-at? code u4)) MAX-DIGIT)
        )
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
            ;; Generate secret code
            (let ((secret (generate-secret-code game-counter)))
                ;; Create new game
                (map-set active-games player {
                    secret-code: secret,
                    attempts-left: MAX-ATTEMPTS,
                    attempts-used: u0,
                    game-id: game-counter
                })
                
                ;; Increment total games
                (var-set total-games (+ game-counter u1))
                
                (ok {
                    game-id: game-counter,
                    message: "Crack the 5-digit code!",
                    digits-range: "0-9",
                    attempts-left: MAX-ATTEMPTS
                })
            )
        )
    )
)

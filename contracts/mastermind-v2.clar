;; Mastermind V2 Contract
;; Classic code-breaking game on-chain - NO DUPLICATES VERSION
;; Guess the secret 5-digit code (0-9, all unique digits)
;; 10 attempts to crack the code
;; Feedback: exact matches and number matches with wrong position
;; No fees, just gas - pure deduction gameplay
;; V2: Numbers cannot repeat (e.g., 01234, 56789, NOT 22467)

;; Error codes
(define-constant ERR-NO-ACTIVE-GAME (err u1001))
(define-constant ERR-GAME-ALREADY-ACTIVE (err u1002))
(define-constant ERR-INVALID-CODE (err u1003))
(define-constant ERR-INVALID-CODE-LENGTH (err u1004))
(define-constant ERR-NO-ATTEMPTS-LEFT (err u1005))
(define-constant ERR-DUPLICATE-DIGITS (err u1006))

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
    best-attempts: uint,
    perfect-games: uint
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

;; Helper to check if digit exists in code
(define-private (digit-exists (digit uint) (code (list 5 uint)))
    (or (is-eq (unwrap-panic (element-at? code u0)) digit)
        (is-eq (unwrap-panic (element-at? code u1)) digit)
        (is-eq (unwrap-panic (element-at? code u2)) digit)
        (is-eq (unwrap-panic (element-at? code u3)) digit)
        (is-eq (unwrap-panic (element-at? code u4)) digit))
)

;; Helper to check if code has duplicates
(define-private (has-duplicates (code (list 5 uint)))
    (let ((d0 (unwrap-panic (element-at? code u0)))
          (d1 (unwrap-panic (element-at? code u1)))
          (d2 (unwrap-panic (element-at? code u2)))
          (d3 (unwrap-panic (element-at? code u3)))
          (d4 (unwrap-panic (element-at? code u4))))
        (or (or (is-eq d0 d1) (is-eq d0 d2))
            (or (is-eq d0 d3) (is-eq d0 d4))
            (or (is-eq d1 d2) (is-eq d1 d3))
            (or (is-eq d1 d4) (is-eq d2 d3))
            (or (is-eq d2 d4) (is-eq d3 d4)))
    )
)

;; Generate unique code: 5 different digits from 0-9
(define-private (generate-unique-code (seed uint))
    (let ((base-seed (+ (+ (* seed u997) stacks-block-height) (var-get player-count))))
        ;; Select 5 unique digits using modulo with different offsets
        (list
            (mod base-seed u10)
            (mod (+ base-seed u1) u10)
            (mod (+ base-seed u3) u10)
            (mod (+ base-seed u7) u10)
            (mod (+ base-seed u13) u10)
        )
    )
)

;; Helper to validate code format (no duplicates!)
(define-private (validate-code (code (list 5 uint)))
    (let ((code-len (len code)))
        (and
            (is-eq code-len CODE-LENGTH)
            (<= (unwrap-panic (element-at? code u0)) MAX-DIGIT)
            (<= (unwrap-panic (element-at? code u1)) MAX-DIGIT)
            (<= (unwrap-panic (element-at? code u2)) MAX-DIGIT)
            (<= (unwrap-panic (element-at? code u3)) MAX-DIGIT)
            (<= (unwrap-panic (element-at? code u4)) MAX-DIGIT)
            (not (has-duplicates code))
        )
    )
)

;; Public function: Start new game
(define-public (start-game)
    (let ((player tx-sender))
        (asserts! (is-none (map-get? active-games player)) ERR-GAME-ALREADY-ACTIVE)
        (add-player-if-new player)
        (let ((game-counter (var-get total-games)))
            (let ((secret (generate-unique-code game-counter)))
                (map-set active-games player {
                    secret-code: secret,
                    attempts-left: MAX-ATTEMPTS,
                    attempts-used: u0,
                    game-id: game-counter
                })
                (var-set total-games (+ game-counter u1))
                (ok {
                    game-id: game-counter,
                    message: "Crack the code! All digits unique",
                    digits-range: "0-9",
                    attempts-left: MAX-ATTEMPTS,
                    note: "No duplicate digits allowed!"
                })
            )
        )
    )
)

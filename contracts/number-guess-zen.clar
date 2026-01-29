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

;; Public function: Make a guess
(define-public (guess (number uint))
    (let ((player tx-sender))
        ;; Validate number range
        (asserts! (>= number MIN-NUMBER) ERR-INVALID-NUMBER)
        (asserts! (<= number MAX-NUMBER) ERR-INVALID-NUMBER)
        
        ;; Get active game
        (let ((game-opt (map-get? active-games player)))
            (asserts! (is-some game-opt) ERR-NO-ACTIVE-GAME)
            (let ((game (unwrap-panic game-opt)))
                (let ((secret (get secret-number game))
                      (attempts (get attempts game))
                      (game-id (get game-id game))
                      (hint-used (get hint-used game)))
                    
                    ;; Increment attempts
                    (let ((new-attempts (+ attempts u1)))
                        (if (is-eq number secret)
                            ;; Correct guess! End game
                            (begin
                                ;; Remove active game
                                (map-delete active-games player)
                                
                                ;; Update stats
                                (let ((stats-opt (map-get? player-stats player)))
                                    (if (is-none stats-opt)
                                        ;; First game
                                        (map-set player-stats player {
                                            total-games: u1,
                                            total-attempts: new-attempts,
                                            best-attempts: new-attempts,
                                            current-streak: u1,
                                            longest-streak: u1
                                        })
                                        ;; Update existing stats
                                        (let ((stats (unwrap-panic stats-opt)))
                                            (let ((current-streak (get current-streak stats))
                                                  (longest-streak (get longest-streak stats))
                                                  (best-attempts (get best-attempts stats)))
                                                (let ((new-streak (+ current-streak u1))
                                                      (new-longest (if (> (+ current-streak u1) longest-streak) 
                                                                      (+ current-streak u1) 
                                                                      longest-streak))
                                                      (new-best (if (< new-attempts best-attempts) 
                                                                   new-attempts 
                                                                   best-attempts)))
                                                    (map-set player-stats player {
                                                        total-games: (+ (get total-games stats) u1),
                                                        total-attempts: (+ (get total-attempts stats) new-attempts),
                                                        best-attempts: new-best,
                                                        current-streak: new-streak,
                                                        longest-streak: new-longest
                                                    })
                                                )
                                            )
                                        )
                                    )
                                )
                                
                                ;; Save to history
                                (let ((player-game-id (default-to u0 (map-get? player-game-counter player))))
                                    (map-set player-game-counter player (+ player-game-id u1))
                                    (map-set game-history (tuple (player player) (game-id player-game-id)) {
                                        secret-number: secret,
                                        attempts: new-attempts,
                                        won: true,
                                        hint-used: hint-used
                                    })
                                )
                                
                                (ok {
                                    result: "correct",
                                    number: secret,
                                    attempts: new-attempts,
                                    message: "Congratulations! You guessed it!",
                                    hint-used: hint-used
                                })
                            )
                            ;; Wrong guess - update attempts and give hint
                            (begin
                                ;; Update game state
                                (map-set active-games player {
                                    secret-number: secret,
                                    attempts: new-attempts,
                                    hint-used: hint-used,
                                    game-id: game-id
                                })
                                
                                (ok {
                                    result: (if (> number secret) "lower" "higher"),
                                    attempts: new-attempts,
                                    message: (if (> number secret) 
                                               "Try a lower number!" 
                                               "Try a higher number!"),
                                    hint-used: hint-used
                                })
                            )
                        )
                    )
                )
            )
        )
    )
)

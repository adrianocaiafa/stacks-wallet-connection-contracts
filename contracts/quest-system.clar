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


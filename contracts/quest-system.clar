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


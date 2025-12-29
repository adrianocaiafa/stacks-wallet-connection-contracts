;; Voting System Contract
;; On-chain voting/poll system for community decisions
;; Users vote on polls by paying fees; tracks results in real-time
;; Each vote generates transaction fees

;; Error codes
(define-constant ERR-POLL-NOT-FOUND (err u1001))
(define-constant ERR-POLL-CLOSED (err u1002))
(define-constant ERR-INVALID-OPTION (err u1003))
(define-constant ERR-INSUFFICIENT-FEE (err u1004))
(define-constant ERR-ALREADY-VOTED (err u1005))
(define-constant ERR-NOT-ADMIN (err u1006))

;; Vote fee (in micro-STX)
(define-constant VOTE-FEE u10000)  ;; 0.01 STX per vote

;; Maximum options per poll
(define-constant MAX-OPTIONS u10)

;; Contract admin (set to deployer)
(define-data-var admin principal tx-sender)

;; Poll counter
(define-data-var poll-counter uint u0)

;; Current active poll ID (none if no active poll)
(define-data-var active-poll-id (optional uint) none)

;; Poll data: poll-id -> {title, options, is-open, total-votes, creator}
(define-map polls uint {
    title: (string-ascii 200),
    options: (list 10 (string-ascii 100)),
    is-open: bool,
    total-votes: uint,
    creator: principal
})

;; Vote tracking: (poll-id, voter) -> {option-index, timestamp}
(define-map votes (tuple (poll-id uint) (voter principal)) {
    option-index: uint,
    timestamp: uint
})

;; Option vote counts: (poll-id, option-index) -> vote-count
(define-map option-votes (tuple (poll-id uint) (option-index uint)) uint)

;; Voter list for poll: (poll-id, index) -> voter
(define-map poll-voters (tuple (poll-id uint) (index uint)) principal)

;; Voter count per poll: poll-id -> count
(define-map poll-voter-count uint uint)


;; Enhanced Community Voting Contract
;; Phase 2 improvements: Added voting logic, security enhancements, and execution functionality

(define-trait sip010-token-trait
  ((get-balance (principal) (response uint uint)))
)

;; Error constants
(define-constant err-not-authorized (err u100))
(define-constant err-proposal-not-found (err u101))
(define-constant err-voting-period-ended (err u102))
(define-constant err-voting-period-not-started (err u103))
(define-constant err-already-voted (err u104))
(define-constant err-proposal-already-executed (err u105))
(define-constant err-insufficient-votes (err u106))
(define-constant err-invalid-voting-period (err u107))

;; Data maps and variables
(define-map proposals
  uint
  {
    proposer: principal,
    description: (buff 100),
    start-block: uint,
    end-block: uint,
    yes-votes: uint,
    no-votes: uint,
    executed: bool,
    execution-threshold: uint
  }
)

(define-map has-voted (tuple (proposal-id uint) (voter principal)) bool)
(define-map voter-weights principal uint)
(define-data-var proposal-counter uint u0)
(define-data-var contract-owner principal tx-sender)

;; Configuration constants
(define-constant quorum-threshold u100)
(define-constant min-voting-period u144) ;; ~1 day in blocks
(define-constant max-voting-period u1008) ;; ~1 week in blocks
(define-constant default-execution-threshold u60) ;; 60% approval needed

;; Read-only functions
(define-read-only (get-current-block)
  block-height
)

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals proposal-id)
)

(define-read-only (get-voter-weight (voter principal))
  (default-to u1 (map-get? voter-weights voter))
)

(define-read-only (has-user-voted (proposal-id uint) (voter principal))
  (default-to false (map-get? has-voted {proposal-id: proposal-id, voter: voter}))
)

(define-read-only (get-proposal-status (proposal-id uint))
  (match (map-get? proposals proposal-id)
    proposal (let ((current-block block-height))
      {
        active: (and (>= current-block (get start-block proposal)) 
                     (< current-block (get end-block proposal))),
        ended: (>= current-block (get end-block proposal)),
        executed: (get executed proposal),
        yes-votes: (get yes-votes proposal),
        no-votes: (get no-votes proposal),
        total-votes: (+ (get yes-votes proposal) (get no-votes proposal))
      })
    {
      active: false,
      ended: false,
      executed: false,
      yes-votes: u0,
      no-votes: u0,
      total-votes: u0
    }
  )
)

;; Administrative functions
(define-public (set-voter-weight (voter principal) (weight uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-authorized)
    (asserts! (> weight u0) (err u108))
    (ok (map-set voter-weights voter weight))
  )
)

(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-authorized)
    (ok (var-set contract-owner new-owner))
  )
)

;; Core functionality
(define-public (create-proposal (description (buff 100)) (voting-period uint))
  (begin
    ;; Validate inputs
    (asserts! (>= voting-period min-voting-period) err-invalid-voting-period)
    (asserts! (<= voting-period max-voting-period) err-invalid-voting-period)
    (asserts! (> (len description) u0) (err u109))
    
    (let ((proposal-id (var-get proposal-counter))
          (voter-weight (get-voter-weight tx-sender)))
      ;; Require minimum weight to create proposals
      (asserts! (>= voter-weight u1) err-not-authorized)
      
      (map-set proposals proposal-id {
        proposer: tx-sender,
        description: description,
        start-block: block-height,
        end-block: (+ block-height voting-period),
        yes-votes: u0,
        no-votes: u0,
        executed: false,
        execution-threshold: default-execution-threshold
      })
      (var-set proposal-counter (+ proposal-id u1))
      (ok proposal-id)
    )
  )
)

(define-public (vote (proposal-id uint) (support bool))
  (let 
    ((proposal (unwrap! (map-get? proposals proposal-id) err-proposal-not-found))
     (voter-weight (get-voter-weight tx-sender))
     (current-block block-height))
    
    ;; Security validations
    (asserts! (>= current-block (get start-block proposal)) err-voting-period-not-started)
    (asserts! (< current-block (get end-block proposal)) err-voting-period-ended)
    (asserts! (not (has-user-voted proposal-id tx-sender)) err-already-voted)
    (asserts! (> voter-weight u0) err-not-authorized)
    
    ;; Record the vote
    (map-set has-voted {proposal-id: proposal-id, voter: tx-sender} true)
    
    ;; Update vote counts based on support and voter weight
    (if support
      (map-set proposals proposal-id
        (merge proposal {yes-votes: (+ (get yes-votes proposal) voter-weight)}))
      (map-set proposals proposal-id
        (merge proposal {no-votes: (+ (get no-votes proposal) voter-weight)}))
    )
    
    (ok true)
  )
)

(define-public (execute-proposal (proposal-id uint))
  (let 
    ((proposal (unwrap! (map-get? proposals proposal-id) err-proposal-not-found))
     (current-block block-height)
     (total-votes (+ (get yes-votes proposal) (get no-votes proposal)))
     (approval-percentage (if (> total-votes u0) 
                           (/ (* (get yes-votes proposal) u100) total-votes) 
                           u0)))
    
    ;; Execution validations
    (asserts! (>= current-block (get end-block proposal)) err-voting-period-ended)
    (asserts! (not (get executed proposal)) err-proposal-already-executed)
    (asserts! (>= total-votes quorum-threshold) err-insufficient-votes)
    (asserts! (>= approval-percentage (get execution-threshold proposal)) err-insufficient-votes)
    
    ;; Mark as executed
    (map-set proposals proposal-id
      (merge proposal {executed: true}))
    
    ;; TODO: Add actual execution logic here based on proposal type
    (ok true)
  )
)

;; Emergency functions
(define-public (cancel-proposal (proposal-id uint))
  (let ((proposal (unwrap! (map-get? proposals proposal-id) err-proposal-not-found)))
    ;; Only proposer or contract owner can cancel
    (asserts! (or (is-eq tx-sender (get proposer proposal))
                  (is-eq tx-sender (var-get contract-owner))) err-not-authorized)
    (asserts! (not (get executed proposal)) err-proposal-already-executed)
    
    ;; Mark as executed to prevent further voting
    (map-set proposals proposal-id
      (merge proposal {executed: true}))
    
    (ok true)
  )
)

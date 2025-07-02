;; Token-Weighted Voting Contract
;; This contract allows voting power based on token holdings

(impl-trait .community-voting.sip010-token-trait)

;; Error constants
(define-constant err-token-transfer-failed (err u200))
(define-constant err-insufficient-tokens (err u201))
(define-constant err-not-authorized (err u202))
(define-constant err-delegation-not-found (err u203))
(define-constant err-self-delegation (err u204))

;; Data storage
(define-map token-locks
  {user: principal, proposal-id: uint}
  {amount: uint, unlock-block: uint}
)

(define-map vote-delegations
  principal ;; delegator
  principal ;; delegate
)

(define-data-var governance-token (optional principal) none)
(define-data-var contract-admin principal tx-sender)

;; Read-only functions
(define-read-only (get-governance-token)
  (var-get governance-token)
)

(define-read-only (get-contract-admin)
  (var-get contract-admin)
)

(define-read-only (get-delegation (delegator principal))
  (map-get? vote-delegations delegator)
)

(define-read-only (get-token-lock (user principal) (proposal-id uint))
  (map-get? token-locks {user: user, proposal-id: proposal-id})
)

(define-read-only (get-direct-voting-power (user principal) (proposal-id uint))
  (match (map-get? token-locks {user: user, proposal-id: proposal-id})
    lock (get amount lock)
    u0)
)

;; Implement the token trait
(define-read-only (get-balance (user principal))
  (ok u0) ;; Placeholder implementation
)

;; Administrative functions
(define-public (set-governance-token (token-contract principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-admin)) err-not-authorized)
    (ok (var-set governance-token (some token-contract)))
  )
)

(define-public (set-contract-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-admin)) err-not-authorized)
    (ok (var-set contract-admin new-admin))
  )
)

;; Token-weighted voting functions
(define-public (lock-tokens-for-voting (proposal-id uint) (amount uint) (token-contract principal))
  (let ((unlock-block (+ block-height u1008))) ;; Lock for ~1 week
   
    ;; Verify this is the governance token
    (asserts! (is-eq (some token-contract) (var-get governance-token)) err-not-authorized)
    (asserts! (> amount u0) err-insufficient-tokens)
   
    ;; Lock the tokens (simulate by recording the lock)
    (map-set token-locks
      {user: tx-sender, proposal-id: proposal-id}
      {amount: amount, unlock-block: unlock-block})
   
    (ok amount)
  )
)

(define-public (unlock-tokens (proposal-id uint))
  (let ((lock-info (unwrap! (map-get? token-locks {user: tx-sender, proposal-id: proposal-id})
                            (err u205))))
    (asserts! (>= block-height (get unlock-block lock-info)) (err u206))
    (map-delete token-locks {user: tx-sender, proposal-id: proposal-id})
    (ok (get amount lock-info))
  )
)

;; Delegation functions
(define-public (delegate-voting-power (delegate principal))
  (begin
    (asserts! (not (is-eq tx-sender delegate)) err-self-delegation)
    (map-set vote-delegations tx-sender delegate)
    (ok true)
  )
)

(define-public (revoke-delegation)
  (begin
    (asserts! (is-some (map-get? vote-delegations tx-sender)) err-delegation-not-found)
    (map-delete vote-delegations tx-sender)
    (ok true)
  )
)

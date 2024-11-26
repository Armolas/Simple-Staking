;; title: simple-staking
;; description: This is a simple staking smart contract where users can stake their NFT for FT rewards

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars and Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-constant profit-per-block u1)

(define-map NFT-status uint {last-staked-height: uint, staker: principal})

(define-map user-stakes principal (list 100 uint))

;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Read-only Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-unclaimed-balance)
    (let
        (
            (stakes (default-to (list ) (map-get? user-stakes tx-sender)))
        )
        (fold + (map get-height-difference stakes) u0)
    )
)

(define-read-only (check-NFT-status (id uint))
    (map-get? NFT-status id)
)

(define-read-only (get-user-stakes)
    (map-get? user-stakes tx-sender)
)

(define-read-only (check-reward-rate)
    (let
        (
            (stakes (default-to (list ) (map-get? user-stakes tx-sender)))
        )
        (* profit-per-block (len stakes))
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Public Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (stake-NFT (id uint))
    (let
        (   
            (owner (unwrap! (contract-call? .simple-NFT get-owner id) (err "err-item-not-minted")))
            (stakes (default-to (list ) (map-get? user-stakes tx-sender)))
            (stake (map-get? NFT-status id))
        )
        (asserts! (is-eq (some tx-sender) owner) (err "err-tx-sender-not-item-owner"))
        (asserts! (is-none stake) (err "err-item-already-staked"))
        (unwrap! (contract-call? .simple-NFT transfer id tx-sender (as-contract tx-sender)) (err "err-transferring-NFT"))
        (map-set NFT-status id {last-staked-height: block-height, staker: tx-sender})
        (ok (map-set user-stakes tx-sender (unwrap! (as-max-len? (append stakes id) u100) (err "err-stake-overflow"))))
    )
)

(define-public (unstake-NFT (id uint))
    (let
        (
            (current-tx-sender tx-sender)
            (owner (unwrap! (contract-call? .simple-NFT get-owner id) (err "err-item-not-minted")))
            (stakes (default-to (list ) (map-get? user-stakes tx-sender)))
            (stake (unwrap! (map-get? NFT-status id) (err "err-item-not-staked")))
            (staker (get staker stake))
            (reward (get-height-difference id))
        )
        (asserts! (is-eq staker tx-sender) (err "err-tx-sender-not-item-staker"))
        (unwrap! (contract-call? .simple-NFT transfer id (as-contract tx-sender) tx-sender) (err "err-transferring-NFT"))
        (unwrap! (contract-call? .simple-FT mint-stake-reward reward) (err "err-minting-reward"))
        (map-delete NFT-status id)
        (var-set temp-int id)
        (ok (map-set user-stakes tx-sender (filter remove-uint stakes)))
    )
)

(define-public (claim-one (id uint))
    (let
        (
            (stake (unwrap! (map-get? NFT-status id) (err "err-item-not-staked")))
            (staker (get staker stake))
            (reward (get-height-difference id))
        )
        (asserts! (is-eq staker tx-sender) (err "err-tx-sender-not-item-staker"))
        (unwrap! (contract-call? .simple-FT mint-stake-reward reward) (err "err-minting-reward"))
        (ok (map-set NFT-status id 
            (merge
                stake
                {last-staked-height: block-height}
            )
        ))
    )
)

(define-public (claim-rewards)
    (let
        (
            (stakes (default-to (list ) (map-get? user-stakes tx-sender)))
            (rewards (get-unclaimed-balance ))
        )
        (unwrap! (contract-call? .simple-FT mint-stake-reward rewards) (err "err-minting-reward"))
        (ok (map reset-stake stakes))
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Private Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-data-var temp-int uint u0)

(define-private (get-height-difference (stake-id uint))
    (let
        (
            (stake-status (default-to {last-staked-height: block-height, staker: tx-sender} (map-get? NFT-status stake-id)))
            (last-stake-height (get last-staked-height stake-status))
        )
        (- block-height last-stake-height)
    )
)

(define-private (remove-uint (item uint))
    (not (is-eq (var-get temp-int) item))
)

(define-private (reset-stake (stake-id uint))
    (let
        (
            (stake (unwrap! (map-get? NFT-status stake-id) (err "err-item-not-staked")))
        )
        (ok (map-set NFT-status stake-id 
            (merge
                stake
                {last-staked-height: block-height}
            )
        ))
    )
)
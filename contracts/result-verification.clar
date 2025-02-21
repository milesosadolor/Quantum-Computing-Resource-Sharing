;; Result Verification Contract

(define-constant CONTRACT_OWNER tx-sender)

(define-map verified-results
  { job-id: uint }
  {
    result: (string-utf8 1000),
    verified: bool
  }
)

(define-public (submit-result (job-id uint) (result (string-utf8 1000)))
  (let
    ((job (unwrap! (contract-call? .job-submission get-job job-id) (err u404)))
     (allocation (unwrap! (contract-call? .resource-allocation get-allocated-computer job-id) (err u404))))
    (asserts! (is-eq tx-sender (get submitter job)) (err u403))
    (ok (map-set verified-results
      { job-id: job-id }
      {
        result: result,
        verified: false
      }
    ))
  )
)

(define-public (verify-result (job-id uint))
  (let
    ((result (unwrap! (map-get? verified-results { job-id: job-id }) (err u404))))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err u403))
    (ok (map-set verified-results
      { job-id: job-id }
      (merge result { verified: true })
    ))
  )
)

(define-read-only (get-verified-result (job-id uint))
  (map-get? verified-results { job-id: job-id })
)


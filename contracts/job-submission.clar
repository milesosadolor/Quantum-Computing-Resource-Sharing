;; Job Submission Contract

(define-data-var next-job-id uint u0)

(define-map quantum-jobs
  { id: uint }
  {
    submitter: principal,
    computer-id: uint,
    status: (string-ascii 20),
    result: (optional (string-utf8 1000))
  }
)

(define-public (submit-job (computer-id uint))
  (let
    ((job-id (+ (var-get next-job-id) u1)))
    (var-set next-job-id job-id)
    (ok (map-set quantum-jobs
      { id: job-id }
      {
        submitter: tx-sender,
        computer-id: computer-id,
        status: "pending",
        result: none
      }
    ))
  )
)

(define-public (update-job-status (job-id uint) (new-status (string-ascii 20)))
  (let
    ((job (unwrap! (map-get? quantum-jobs { id: job-id }) (err u404))))
    (asserts! (is-eq tx-sender (get submitter job)) (err u403))
    (ok (map-set quantum-jobs
      { id: job-id }
      (merge job { status: new-status })
    ))
  )
)

(define-public (set-job-result (job-id uint) (result (string-utf8 1000)))
  (let
    ((job (unwrap! (map-get? quantum-jobs { id: job-id }) (err u404))))
    (asserts! (is-eq tx-sender (get submitter job)) (err u403))
    (ok (map-set quantum-jobs
      { id: job-id }
      (merge job { status: "completed", result: (some result) })
    ))
  )
)

(define-read-only (get-job (job-id uint))
  (map-get? quantum-jobs { id: job-id })
)


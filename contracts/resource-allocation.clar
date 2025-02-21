;; Resource Allocation Contract

(define-map allocated-resources
  { job-id: uint }
  { computer-id: uint }
)

(define-public (allocate-resource (job-id uint) (computer-id uint))
  (ok (map-set allocated-resources
    { job-id: job-id }
    { computer-id: computer-id }
  ))
)

(define-public (deallocate-resource (job-id uint))
  (ok (map-delete allocated-resources { job-id: job-id }))
)

(define-read-only (get-allocated-computer (job-id uint))
  (map-get? allocated-resources { job-id: job-id })
)


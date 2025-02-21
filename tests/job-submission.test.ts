import { describe, it, beforeEach, expect } from "vitest"

describe("Job Submission Contract", () => {
  let mockStorage: Map<string, any>
  let nextJobId: number
  
  beforeEach(() => {
    mockStorage = new Map()
    nextJobId = 0
  })
  
  const mockContractCall = (method: string, args: any[], sender: string) => {
    switch (method) {
      case "submit-job":
        const [computerId] = args
        nextJobId++
        mockStorage.set(`job-${nextJobId}`, {
          submitter: sender,
          computer_id: computerId,
          status: "pending",
          result: null,
        })
        return { success: true, value: nextJobId }
      
      case "update-job-status":
        const [jobId, newStatus] = args
        const job = mockStorage.get(`job-${jobId}`)
        if (!job) return { success: false, error: 404 }
        if (job.submitter !== sender) return { success: false, error: 403 }
        job.status = newStatus
        mockStorage.set(`job-${jobId}`, job)
        return { success: true }
      
      case "set-job-result":
        const [resultJobId, result] = args
        const resultJob = mockStorage.get(`job-${resultJobId}`)
        if (!resultJob) return { success: false, error: 404 }
        if (resultJob.submitter !== sender) return { success: false, error: 403 }
        resultJob.status = "completed"
        resultJob.result = result
        mockStorage.set(`job-${resultJobId}`, resultJob)
        return { success: true }
      
      case "get-job":
        return { success: true, value: mockStorage.get(`job-${args[0]}`) }
      
      default:
        return { success: false, error: "Unknown method" }
    }
  }
  
  it("should submit a job", () => {
    const result = mockContractCall("submit-job", [1], "user1")
    expect(result.success).toBe(true)
    expect(result.value).toBe(1)
  })
  
  it("should update job status", () => {
    mockContractCall("submit-job", [1], "user1")
    const result = mockContractCall("update-job-status", [1, "processing"], "user1")
    expect(result.success).toBe(true)
  })
  
  it("should not update job status if not the submitter", () => {
    mockContractCall("submit-job", [1], "user1")
    const result = mockContractCall("update-job-status", [1, "processing"], "user2")
    expect(result.success).toBe(false)
    expect(result.error).toBe(403)
  })
  
  it("should set job result", () => {
    mockContractCall("submit-job", [1], "user1")
    const result = mockContractCall("set-job-result", [1, "Job result"], "user1")
    expect(result.success).toBe(true)
  })
  
  it("should get a job", () => {
    mockContractCall("submit-job", [1], "user1")
    const result = mockContractCall("get-job", [1], "anyone")
    expect(result.success).toBe(true)
    expect(result.value).toMatchObject({
      submitter: "user1",
      computer_id: 1,
      status: "pending",
    })
  })
})


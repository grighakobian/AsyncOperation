import XCTest
@testable import AsyncOperation

final class AsyncOperationTests: XCTestCase {
    
    private var operationQueue: OperationQueue!
    
    override func setUp() {
        self.operationQueue = OperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 5
    }
    
    override func tearDown() {
        self.operationQueue.cancelAllOperations()
        self.operationQueue = nil
    }
    
    // MARK: - AsynDispatchOperation
    
    final class AsynOperationSpy: AsyncOperation {
        
        static let completionTime = 1
        
        override func run(onCompleted: @escaping () -> Void) {
            let deadline: DispatchTime = .now() + .seconds(AsynOperationSpy.completionTime)
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                onCompleted()
            }
        }
    }
    
    // MARK: - Tests
    
    func testAsyncOperation() {
        let description = "Operation should be completed after 2 seconds."
        let expectation = XCTestExpectation(description: description)

        let asyncOperation = AsynOperationSpy()
        operationQueue.addOperation(asyncOperation)
        asyncOperation.completionBlock = {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: TimeInterval(AsynOperationSpy.completionTime) + 0.1)
    }
    
    func testAsyncOperationDependeicies() {
        var expectations = [XCTestExpectation]()
        var asyncOperations = [AsynOperationSpy]()
        
        for index in 0..<operationQueue.maxConcurrentOperationCount {
            let description = "Operation: \(index + 1) should be completed after 2 seconds."
            let expectation = XCTestExpectation(description: description)

            let asyncOperation = AsynOperationSpy()
            asyncOperation.completionBlock = {
                expectation.fulfill()
            }
            
            if let lastOperation = asyncOperations.last {
                asyncOperation.addDependency(lastOperation)
            }
            
            expectations.append(expectation)
            asyncOperations.append(asyncOperation)
        }
        
        operationQueue.addOperations(asyncOperations, waitUntilFinished: false)
        
        for (index, expectation) in expectations.enumerated() {
            let timeout = TimeInterval((index+1) * AsynOperationSpy.completionTime) + 0.1
            wait(for: [expectation], timeout: timeout)
        }
    }
}

//    MIT License
//
//    Copyright (c) 2022 Grigor Hakobyan
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.


import Foundation

open class AsyncOperation: Operation {
    internal var _isExecuting: Bool
    internal var _isFinished: Bool
    internal let _lock: NSRecursiveLock
        
    override init() {
        self._isExecuting = false
        self._isFinished = false
        self._lock = NSRecursiveLock()
        super.init()
    }
    
    open override var isAsynchronous: Bool {
        return true
    }
    
    open override var isConcurrent: Bool {
        return true
    }
    
    open override var isExecuting: Bool {
        get {
            _lock.lock()
            let isExecuting = _isExecuting
            _lock.unlock()
            return isExecuting
        }
        set(isExecuting) {
            _lock.lock()
            willChangeValue(forKey: "isExecuting")
            self._isExecuting = isExecuting
            didChangeValue(forKey: "isExecuting")
            _lock.unlock()
        }
    }
    
    open override var isFinished: Bool {
        get {
            _lock.lock()
            let isFinished = _isFinished
            _lock.unlock()
            return isFinished
        }
        set(isFinished) {
            _lock.lock()
            willChangeValue(forKey: "isFinished")
            self._isFinished = isFinished
            didChangeValue(forKey: "isFinished")
            _lock.unlock()
        }
    }
    
    open override func start() {
        if isCancelled {
            completeOperation()
            return
        }
        startOperation()
        main()
    }

    open override func main() {
        fatalError("Subclasses must implement `main` without overriding super.")
    }
    
    internal func completeOperation() {
        isExecuting = false
        isFinished = true
    }
    
    internal func startOperation() {
        isFinished = false
        isExecuting = true
    }
}

import Foundation

extension DispatchQueue: Executor {
    func execute(task: @escaping Runnable) {
        async(execute: task)
    }
    
    func execute(after deadline: DispatchTime, task: @escaping Runnable) {
        asyncAfter(deadline: deadline, execute: task)
    }
}

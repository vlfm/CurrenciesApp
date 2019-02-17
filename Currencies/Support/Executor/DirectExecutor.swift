import Foundation

final class DirectExecutor: Executor {
    func execute(task: @escaping Runnable) {
        task()
    }
    
    func execute(after: DispatchTime, task: @escaping Runnable) {
        task()
    }
}

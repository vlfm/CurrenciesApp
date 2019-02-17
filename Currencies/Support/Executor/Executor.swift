import Foundation

protocol Executor {
    func execute(task: @escaping Runnable)
    func execute(after: DispatchTime, task: @escaping Runnable)
}

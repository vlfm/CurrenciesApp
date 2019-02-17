import Foundation

enum Result<T> {
    case failure(Error)
    case success(T)
}

extension Result {
    func getValue() throws -> T {
        switch self {
        case .failure(let error):
            throw error
        case .success(let value):
            return value
        }
    }
}

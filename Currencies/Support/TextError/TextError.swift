import Foundation

struct TextError: Error, Equatable {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
}

extension TextError: CustomStringConvertible {
    var description: String {
        return message
    }
}

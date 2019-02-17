import Foundation

typealias DataNetworkResponse = NetworkResponse<Data>

struct NetworkResponse<Value> {
    let value: Value?
    let response: URLResponse?
    let error: Error?
}

extension NetworkResponse {
    func extractValue() throws -> (Value, Int) {
        if let error = error {
            throw error
        }
        
        guard let response = response as? HTTPURLResponse else {
            throw TextError("Missing http response")
        }
        
        guard let value = value else {
            throw TextError("Missing value")
        }
        
        return (value, response.statusCode)
    }
}

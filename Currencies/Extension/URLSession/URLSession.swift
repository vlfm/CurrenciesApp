import Foundation

extension URLSession: Network {
    func send(_ request: URLRequest, _ completionHandler: @escaping Consumer<DataNetworkResponse>) {
        let task = dataTask(with: request) { data, response, error in
            let networkResponse = DataNetworkResponse(value: data, response: response, error: error)
            completionHandler(networkResponse)
        }
        task.resume()
    }
}

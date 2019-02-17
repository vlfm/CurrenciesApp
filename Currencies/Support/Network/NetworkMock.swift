import Foundation

final class NetworkMock {
    typealias SendHandler = (URLRequest, Consumer<DataNetworkResponse>) -> Void
    var sendHandler: SendHandler?
}

extension NetworkMock: Network {
    func send(_ request: URLRequest, _ completionHandler: @escaping Consumer<DataNetworkResponse>) {
        sendHandler?(request, completionHandler)
    }
}

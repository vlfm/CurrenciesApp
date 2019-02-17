import Foundation

final class ApiClientMock {
    typealias SendHandler = (_ request: Any, _ completionHandler: Any) -> Void
    var sendHandler: SendHandler?
}

extension ApiClientMock: ApiClient {
    func send<Request: ApiRequest>(_ request: Request,
                                   _ completionHandler: @escaping (Result<Request.Response>) -> Void) {
        sendHandler?(request, completionHandler)
    }
}

import Foundation

protocol ApiClient {
    func send<Request: ApiRequest>(_ request: Request,
                                   _ completionHandler: @escaping Consumer<Result<Request.Response>>)
}

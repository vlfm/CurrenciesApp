import Foundation

final class DefaultApiClient {
    private let network: Network
    private let baseUrl: URL
    private let decoder = JSONDecoder()
    
    init(_ network: Network, baseUrl: URL) {
        self.network = network
        self.baseUrl = baseUrl
    }
}

extension DefaultApiClient: ApiClient {
    func send<Request: ApiRequest>(_ request: Request,
                                   _ completionHandler: @escaping Consumer<Result<Request.Response>>) {
        let urlRequest = makeUrlRequest(from: request)
        network.send(urlRequest) { networkResponse in
            do {
                let response = try self.decodeResponse(from: networkResponse,
                                                       ofType: Request.Response.self)
                completionHandler(.success(response))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }
}

extension DefaultApiClient {
    private func makeUrlRequest<Request: ApiRequest>(from request: Request) -> URLRequest {
        let url = makeUrl(from: request)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method
        return urlRequest
    }
    
    private func makeUrl<Request: ApiRequest>(from request: Request) -> URL {
        var path = request.path
        if let query = request.query {
            path += "?\(query)"
        }
        return baseUrl.appendingPathComponent(path)
    }
}

extension DefaultApiClient {
    private func decodeResponse<Response: Codable>(from networkResponse: DataNetworkResponse,
                                                   ofType type: Response.Type) throws -> Response {
        let (data, _) = try networkResponse.extractValue()
        return try decoder.decode(type, from: data)
    }
}

import Foundation

protocol Network {
    func send(_ request: URLRequest, _ completionHandler: @escaping Consumer<DataNetworkResponse>)
}

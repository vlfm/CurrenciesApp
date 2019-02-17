import Foundation

protocol ApiRequest {
    associatedtype Response: Codable
    
    var query: String? {get}
    var method: String {get}
    var path: String {get}
}

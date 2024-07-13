//
//  Client.swift
//  PokeExampleUiKIT
//
//  Created by Carlos Paredes on 12/7/24.
//

import Foundation

///Handle error with enum case
enum NetworkError: Error {
    case invalidURL, invalidServerResponse, decodingError, invalidData
}

///Handle http method and pass parameters
enum HttpMethod {
    case get([URLQueryItem])
    case post(Data?)
    
    var name: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        }
    }
}

/// blueprint for making HTTP requests and decoding
struct Resource<T: Codable> {
    let url: URL
    var headers: [String: String] = [:]
    var method: HttpMethod = .get([])
}

class PEHttpClient {
    /// executing HTTP requests, decoding their responses, and returning the decoded data
    /// - Parameter resource:  contains the details of the request
    /// - Returns: decoded T object,, representing the data retrieved from the server.
    func load<T: Codable>(_ resource: Resource<T>, completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        var request = URLRequest(url: resource.url)
        
        switch resource.method {
        case .get(let queryItems):
            var components = URLComponents(url: resource.url, resolvingAgainstBaseURL: true)
            components?.queryItems = queryItems
            guard let url = components?.url else {
                completion(.failure(.invalidURL))
                return
            }
            
            request = URLRequest(url: url)
        case .post(let data):
            request.httpBody = data
        }
        
        request.allHTTPHeaderFields = resource.headers
        request.httpMethod = resource.method.name
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "accept":"application/json"
        ]
        
        let session = URLSession(configuration: configuration)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.invalidData))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidServerResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(.decodingError))
            }
        }
        task.resume()
    }
}

//
//  NetworkClient.swift
//  ShoppingApp
//
//  Created by Syed Asim Najam on 13/10/2026.
//

import Foundation

enum NetworkClientError: Error, CustomStringConvertible, LocalizedError {
    case taskCancellation
    case networkError(Error)
    case invalidResponse
    case invalidURL
    case statusCode(Int)
    case decodingError(DecodingError)

    var description: String {
        switch self {
        case .taskCancellation:
            "The network request was cancelled."
        case .networkError(let error):
            "A network error occurred: \(error.localizedDescription)"
        case .invalidResponse:
            "The server returned an invalid response."
        case .statusCode(let code):
            "Server error: \(code)"
        case .decodingError(let error):
            "Failed to decode the server response: \(error.readableDescription)"
        case .invalidURL:
            "The URL provided was invalid."
        }
    }

    var errorDescription: String? { description }
}

extension DecodingError {
    var readableDescription: String {
        switch self {
        case .typeMismatch(let type, let context):
            let path = context.codingPath.map(\.stringValue).joined(separator: " -> ")
            return "Type Mismatch: Expected type '\(type)' at path [\(path)]. \(context.debugDescription)"
            
        case .valueNotFound(let type, let context):
            let path = context.codingPath.map(\.stringValue).joined(separator: " -> ")
            return "Value Not Found: Expected non-null '\(type)' at path [\(path)]. \(context.debugDescription)"
            
        case .keyNotFound(let key, let context):
            let path = context.codingPath.map(\.stringValue).joined(separator: " -> ")
            let fullPath = path.isEmpty ? key.stringValue : "\(path) -> \(key.stringValue)"
            return "Key Not Found: Missing key '\(key.stringValue)' at path [\(fullPath)]."
            
        case .dataCorrupted(let context):
            let path = context.codingPath.map(\.stringValue).joined(separator: " -> ")
            return "Data Corrupted at path [\(path)]: \(context.debugDescription)"
            
        @unknown default:
            return "Unknown decoding error: \(self.localizedDescription)"
        }
    }
}

protocol DataDecodable: Sendable {
    func decode<R>(_ data: Data, type: R.Type) throws -> R where R: Decodable
}

struct DefaultDataDecoder: DataDecodable {
    func decode<R>(_ data: Data, type: R.Type = R.self) throws -> R where R : Decodable {
        let decoder = JSONDecoder()
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        return try decoder.decode(type, from: data)
    }
}

protocol NetworkClient: Sendable {
    @concurrent
    func fetch<E>(endPoint: E) async throws -> E.Response where E: EndPoint
}

struct DefaultNetworkClient: NetworkClient {
    private let session: URLSession
    private let baseURLString: String
    private let decoder: DataDecodable
    
    init(session: URLSession = .shared,
         baseURLString: String,
         decoder: DataDecodable = DefaultDataDecoder()) {
        self.session = session
        self.baseURLString = baseURLString
        self.decoder = decoder
    }
    
    @concurrent
    func fetch<E>(endPoint: E) async throws -> E.Response where E: EndPoint {
        do {
            let request = try endPoint.makeRequest(baseURLString)
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkClientError.invalidResponse
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkClientError.statusCode(httpResponse.statusCode)
            }
            
            return try  decoder.decode(data, type: E.Response.self)
        } catch let error as NetworkClientError {
            throw error
        } catch let error as URLError where error.code == .cancelled {
            throw NetworkClientError.taskCancellation
        } catch is CancellationError {
            throw NetworkClientError.taskCancellation
        } catch let error as DecodingError {
            throw NetworkClientError.decodingError(error)
        } catch {
            throw NetworkClientError.networkError(error)
        }
    }
}

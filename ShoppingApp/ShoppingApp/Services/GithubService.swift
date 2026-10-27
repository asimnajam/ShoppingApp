//
//  GithubService.swift
//  RepoRadar
//
//  Created by Syed Asim Najam on 13/10/2026.
//

import Foundation



protocol GithubService {
    var baseURLString: String { get }
    func search() async throws
    func repoDetail()
    func readMePreview()
    func rateLimit()
}

//struct DefaultGithubService: GithubService {
//    let baseURLString = "https://api.github.com"
//
//    func search() async throws {
//        let request = try SearchEndpoint().makeRequest(baseURLString)
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse,
//              (200..<299).contains(httpResponse.statusCode) else {
//            throw URLError(.badServerResponse)
//        }
//        
//        let searchData = try JSONDecoder().decode(String.self, from: data)
//        
//    }
//    
//    func repoDetail() {
//        
//    }
//    
//    func readMePreview() {
//        
//    }
//    
//    func rateLimit() {
//        
//    }
//}

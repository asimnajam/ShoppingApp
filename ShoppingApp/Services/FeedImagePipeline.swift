//
//  FeedImagePipeline.swift
//  RepoRadar
//
//  Created by Syed Asim Najam on 16/10/2026.
//

import Foundation

actor FeedImagePipeline {
    enum PipelineError: Error {
        case invalidResponse
    }
    
    private let session: URLSession
    private let memoryCache = NSCache<NSURL, NSData>()
    private var inFlightTasks: [URL: Task<Data, Error>] = [:]

    init(session: URLSession = FeedImagePipeline.makeSession()) {
        self.session = session
        memoryCache.totalCostLimit = 24 * 1024 * 1024
        memoryCache.countLimit = 80
    }

    func imageData(for url: URL) async throws -> Data {
        if let cachedData = memoryCache.object(forKey: url as NSURL) {
            return cachedData as Data
        }

        if let inFlightTask = inFlightTasks[url] {
            return try await inFlightTask.value
        }

        let session = self.session
        let task = Task<Data, Error> {
            let request = URLRequest(
                url: url,
                cachePolicy: .returnCacheDataElseLoad,
                timeoutInterval: 30
            )

            let (data, response) = try await session.data(for: request)
            try Task.checkCancellation()

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                throw PipelineError.invalidResponse
            }

            return data
        }

        inFlightTasks[url] = task

        do {
            let data = try await task.value
            memoryCache.setObject(data as NSData, forKey: url as NSURL, cost: data.count)
            inFlightTasks[url] = nil
            return data
        } catch {
            inFlightTasks[url] = nil
            throw error
        }
    }

    private static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.httpMaximumConnectionsPerHost = 6
        configuration.urlCache = URLCache(
            memoryCapacity: 24 * 1024 * 1024,
            diskCapacity: 160 * 1024 * 1024,
            diskPath: "InterviewNewsFeedImages"
        )

        return URLSession(configuration: configuration)
    }
}

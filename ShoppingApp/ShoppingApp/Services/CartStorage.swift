//
//  CartStorage.swift
//  RepoRadar
//
//  Created by Syed Asim Najam on 27/10/2026.
//

import Foundation

protocol CartStorage: Sendable {
    func load() async throws -> [CartItem]
    func save(_ items: [CartItem]) async throws
}

actor FileCartStorage: CartStorage {
    private let fileURL: URL

    init(
        fileURL: URL = URL.applicationSupportDirectory
            .appendingPathComponent("ShoppingApp", isDirectory: true)
            .appendingPathComponent("cart.json")
    ) {
        self.fileURL = fileURL
    }

    func load() async throws -> [CartItem] {
        guard FileManager.default.fileExists(
            atPath: fileURL.path
        ) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)

        do {
            return try JSONDecoder().decode([CartItem].self, from: data)
        } catch is DecodingError {
            // Saved with an older or incompatible model. Start with an empty cart.
            try? FileManager.default.removeItem(at: fileURL)
            return []
        }
    }

    func save(_ items: [CartItem]) async throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let data = try JSONEncoder().encode(items)
        try data.write(to: fileURL, options: .atomic)
    }
}

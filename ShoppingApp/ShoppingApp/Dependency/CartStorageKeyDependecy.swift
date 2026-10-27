//
//  CartStorageKeyDependecy.swift
//  RepoRadar
//
//  Created by Syed Asim Najam on 27/10/2026.
//


import ComposableArchitecture

private enum CartStorageKey: DependencyKey {
    static let liveValue: any CartStorage = FileCartStorage()
}

extension DependencyValues {
    var cartStorage: any CartStorage {
        get { self[CartStorageKey.self] }
        set { self[CartStorageKey.self] = newValue }
    }
}

//
//  SnippetsManager.swift
//  xcman
//
//  Created by Josef Dolezal on 26/08/2018.
//

import Foundation

public final class SnippetsManager {
    // MARK: Properties

    private let dataManager: UserDataManager

    // MARK: Initializers

    public init(cacheUrl: URL) {
        let snippetsCacheUrl = cacheUrl.appendingPathComponent("snippets", isDirectory: true)

        self.dataManager = UserDataManager(cacheUrl: snippetsCacheUrl, dataType: .snippets)
    }

    // MARK: Public API

    public func add(repository: GitRepository) throws {
        try dataManager.add(repository: repository)
    }
}

//
//  TemplatesManager.swift
//  xcman
//
//  Created by Josef Dolezal on 26/08/2018.
//

import Foundation

@available(OSX 10.12, *)
public final class TemplatesManager {
    // MARK: Properties

    private let dataManager: UserDataManager

    // MARK: Initializers

    public init(cacheUrl: URL) {
        let templatesCacheUrl = cacheUrl.appendingPathComponent("templates", isDirectory: true)

        self.dataManager = UserDataManager(cacheUrl: templatesCacheUrl, dataType: .templates)
    }

    // MARK: Public API

    public func add(repository: GitRepository) throws {
        try dataManager.add(repository: repository)
    }
}

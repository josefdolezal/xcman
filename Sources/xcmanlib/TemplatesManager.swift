//
//  TemplatesManager.swift
//  xcman
//
//  Created by Josef Dolezal on 26/08/2018.
//

import Foundation

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

    public func list() throws -> [String] {
        // URL of Xcode templates directory
        let url = FileManager.default.homeDirectoryUrl.appendingPathComponent(UserDataType.templates.xcodePath(for: ""), isDirectory: true)

        // Get content of Xcode directory, skip hidden files/folders and do not
        // perform recursive search in subdirectories
        guard
            let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [], options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
        else {
            throw UserDataError.couldNotReadRepositoryContent(url)
        }

        return enumerator
            // Filter out non-URL objects
            .compactMap { $0 as? URL }
            // Filter out non-directory objects
            .filter { url in
                var isDirectory = ObjCBool(false)

                FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)

                return isDirectory.boolValue
            }
            // Map to folders name
            .map { $0.lastPathComponent }
    }
}

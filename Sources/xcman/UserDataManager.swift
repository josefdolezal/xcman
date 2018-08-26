//
//  UserDataManager.swift
//  xcman
//
//  Created by Josef Dolezal on 26/08/2018.
//

import Foundation

enum UserDataType: String {
    case templates
    case snippets

    var identifier: String { return rawValue }

    var dataExtension: String {
        switch self {
        case .templates: return "xctemplate"
        case .snippets: return "codesnippet"
        }
    }

    func xcodePath(for dataSet: String) -> String {
        switch self {
        case .templates:
            // Namespace templates using dataset name
            return "Library/Developer/Xcode/Templates/File Templates/\(dataSet)"
        case .snippets:
            // Snippets does not support structured namespacing, keep hierarchy flat
            return "Library/Developer/Xcode/UserData/CodeSnippets"
        }
    }
}

enum UserDataError: Error {
    case couldNotCreateUserDataDirectory(URL, Error)
    case couldNotReadRepositoryContent(URL)
    case couldNotRemoveExistingUserData(URL, Error)
    case couldNotInstallUserData(URL, Error)
}

final class UserDataManager {
    // MARK: Properties

    private let fileManager: FileManager
    private let dataType: UserDataType

    private let cacheUrl: URL

    // MARK: Initializers

    init(cacheUrl: URL, dataType: UserDataType) {
        self.fileManager = FileManager.default
        self.dataType = dataType

        self.cacheUrl = cacheUrl
    }

    // MARK: Public API

    func add(repository: GitRepository) throws {
        // Dataset cache directory name
        let dataset = repository.name
        // The url of dataset in local cache
        let cachedDataset = cacheUrl.appendingPathComponent(dataset, isDirectory: true)
        // The url of Xcode dataset
        let xcodeDataset = xcodeUserDataUrl(for: repository)

        do {
            try fileManager.createDirectory(at: cacheUrl, withIntermediateDirectories: true)
        } catch {
            throw UserDataError.couldNotCreateUserDataDirectory(cacheUrl, error)
        }

        // If the was not clonned yet, clone it into cache and use set name as directory
        if !fileManager.fileExists(atPath: cachedDataset.path) {
            let clone = Process(["git", "clone", repository.url.absoluteString, dataset], workingDirectory: cacheUrl)

            clone.launch()
            clone.waitUntilExit()
        }
            // If we already have the repository clonned, pull latest commits
        else {
            let pull = Process(["git", "pull"], workingDirectory: cachedDataset)

            pull.launch()
            pull.waitUntilExit()
        }

        // Local repository is ready, install dataset
        try installDataset(cachedDataset, into: xcodeDataset)
    }

    // MARK: Private API

    private func installDataset(_ cachedSet: URL, into xcodeSet: URL) throws {
        // Try to read cached dataset directory content, ignore hidden files
        // so directories like .git are not searched unnecessarily
        guard
            let contentEnumerator = fileManager.enumerator(at: cachedSet, includingPropertiesForKeys: [], options: [.skipsHiddenFiles])
            else {
                throw UserDataError.couldNotReadRepositoryContent(cachedSet)
        }

        do {
            try fileManager.createDirectory(at: xcodeSet, withIntermediateDirectories: true)
        } catch {
            throw UserDataError.couldNotCreateUserDataDirectory(xcodeSet, error)
        }

        // Create list of dataset items being install
        let datasetItems = contentEnumerator
            // Ignore objects which are not convertible into URL
            .compactMap { $0 as? URL }
            // Filter out non-item files and directories
            .filter { $0.pathExtension == dataType.dataExtension }

        // Install each item one by one
        try datasetItems.forEach { try installItem($0, into: xcodeSet) }
    }

    private func installItem(_ cacheUrl: URL, into xcodeSet: URL) throws {
        // Item installation url
        let xcodeItemUrl = xcodeSet.appendingPathComponent(cacheUrl.lastPathComponent)

        // Check if the item already exists in Xcode
        if fileManager.fileExists(atPath: xcodeItemUrl.path) {
            // If it exists, remove it so it can be linked again
            do {
                try fileManager.removeItem(at: xcodeItemUrl)
            } catch {
                throw UserDataError.couldNotRemoveExistingUserData(xcodeItemUrl, error)
            }
        }

        // Create symolic link from Xcode internal folder into cache
        do {
            try fileManager.createSymbolicLink(at: xcodeItemUrl, withDestinationURL: cacheUrl)
        } catch {
            throw UserDataError.couldNotInstallUserData(xcodeItemUrl, error)
        }
    }

    private func xcodeUserDataUrl(for repository: GitRepository) -> URL {
        // Resolve relative path using repository name as dataset name
        let path = dataType.xcodePath(for: repository.name)

        return fileManager.homeDirectoryForCurrentUser.appendingPathComponent(path, isDirectory: true)
    }
}

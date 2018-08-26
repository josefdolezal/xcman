//
//  TemplatesManager.swift
//  xcman
//
//  Created by Josef Dolezal on 26/08/2018.
//

import Foundation

enum TemplatesError: Error {
    case couldNotCreateTemplatesDirectory(URL, Error)
    case couldNotReadRepositoryContent(URL)
    case couldNotRemoveExistingTemplate(URL, Error)
    case couldNotInstallTemplate(URL, Error)
}

final class TemplatesManager {
    private let fileManager: FileManager
    private let templatesExtension = "xctemplate"

    private let cacheUrl: URL
    private let xcodeTemplatesDirectory: URL

    init(cacheUrl: URL) {
        self.fileManager = FileManager.default
        self.cacheUrl = cacheUrl
        self.xcodeTemplatesDirectory = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Library/Developer/Xcode/Templates/File Templates", isDirectory: true)
    }

    // MARK: Public API

    func add(repository: GitRepository) throws {
        // Templates set cache directory name
        let templatesSet = repository.name
        // The url of templates set in local cache
        let cacheTemplatesSet = cacheUrl.appendingPathComponent(templatesSet, isDirectory: true)
        // The url of Xcode templates set
        let xcodeTemplatesSet = xcodeTemplatesDirectory.appendingPathComponent(templatesSet, isDirectory: true)

        do {
            try fileManager.createDirectory(at: cacheUrl, withIntermediateDirectories: true)
        } catch {
            throw TemplatesError.couldNotCreateTemplatesDirectory(cacheUrl, error)
        }

        // If the was not clonned yet, clone it into cache and use set name as directory
        if !fileManager.fileExists(atPath: cacheTemplatesSet.path) {
            let clone = Process(["git", "clone", repository.url.absoluteString, templatesSet], workingDirectory: cacheUrl)

            clone.launch()
            clone.waitUntilExit()
        }
        // If we already have the repository clonned, pull latest commits
        else {
            let pull = Process(["git", "pull"], workingDirectory: cacheTemplatesSet)

            pull.launch()
            pull.waitUntilExit()
        }

        // Local repository is ready, install templates
        try installTemplates(cacheTemplatesSet, into: xcodeTemplatesSet)
    }

    // MARK: Private API

    private func installTemplates(_ cachedSet: URL, into xcodeSet: URL) throws {
        // Try to read cached templates directory content, ignore hidden files
        // so directories like .git are not searched unnecessarily
        guard
            let contentEnumerator = fileManager.enumerator(at: cachedSet, includingPropertiesForKeys: [], options: [.skipsHiddenFiles])
        else {
            throw TemplatesError.couldNotReadRepositoryContent(cachedSet)
        }

        do {
            try fileManager.createDirectory(at: xcodeSet, withIntermediateDirectories: true)
        } catch {
            throw TemplatesError.couldNotCreateTemplatesDirectory(xcodeSet, error)
        }

        // Create list of templates being install
        let templates = contentEnumerator
            // Ignore objects which are not convertible into URL
            .compactMap { $0 as? URL }
            // Filter out non-templates files and directories
            .filter { $0.pathExtension == templatesExtension }

        // Install each template one by one
        try templates.forEach { try installTemplate($0, into: xcodeSet) }
    }

    private func installTemplate(_ cacheUrl: URL, into xcodeSet: URL) throws {
        // Template installation url
        let xcodeTemplateUrl = xcodeSet.appendingPathComponent(cacheUrl.lastPathComponent)

        // Check if the template already exists in Xcode
        if fileManager.fileExists(atPath: xcodeTemplateUrl.path) {
            // If it exists, remove it so it can be linked again
            do {
                try fileManager.removeItem(at: xcodeTemplateUrl)
            } catch {
                throw TemplatesError.couldNotRemoveExistingTemplate(xcodeTemplateUrl, error)
            }
        }

        // Create symolic link from Xcode into cache
        do {
            try fileManager.createSymbolicLink(at: xcodeTemplateUrl, withDestinationURL: cacheUrl)
        } catch {
            throw TemplatesError.couldNotInstallTemplate(xcodeTemplateUrl, error)
        }
    }
}

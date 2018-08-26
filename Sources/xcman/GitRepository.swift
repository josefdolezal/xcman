//
//  GitRepository.swift
//  xcman
//
//  Created by Josef Dolezal on 26/08/2018.
//

import Foundation

struct GitRepository: Codable {
    var url: URL
    var name: String

    private static let githubBaseUrl = URL(string: "https://github.com/")!

    init(url: URL, name: String? = nil) {
        // If no explicit name is given, create name from repository name
        let repositoryName = name ?? GitRepository.deriveRepositoryName(from: url)

        self.url = url
        self.name = repositoryName
    }

    init(githubHandle: String, name: String? = nil) {
        // Expand github url handle into standard URL
        let url = GitRepository.githubBaseUrl
            .appendingPathComponent(githubHandle)
            .appendingPathExtension("git")

        self.init(url: url, name: name)
    }

    // MARK: Private API

    private static func deriveRepositoryName(from url: URL) -> String {
        // Take only last url component, also remove all extensions (e.g. .git)
        return url.deletingPathExtension()
            .lastPathComponent
            // Remove all non-alphanumeric trailing charactes
            .trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    }
}

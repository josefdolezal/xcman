//
//  main.swift
//  xcman
//
//  Created by Josef Dolezal on 26/08/2018.
//

import Foundation

typealias URL = Foundation.URL

extension Process {
    convenience init(_ arguments: [String], workingDirectory: Foundation.URL) {
        self.init()

        self.arguments = arguments
        self.launchPath = "/usr/bin/env"
        self.currentDirectoryPath = workingDirectory.path
    }
}

let fileManager = FileManager.default
let url = fileManager.homeDirectoryForCurrentUser.appendingPathComponent(".xcman")
let repo = URL(string: "git@github.com:AckeeCZ/ios-templates.git")!
let templatesDirectory = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Library/Developer/Xcode/Templates/File Templates", isDirectory: true)

try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
let directory = repo.deletingPathExtension().lastPathComponent
let localRepoUrl = url.appendingPathComponent(directory)
let repoTemplatesDirectory = templatesDirectory.appendingPathComponent(directory, isDirectory: true)

if fileManager.fileExists(atPath: localRepoUrl.path) {
    print("Fetching \(directory)...")
    let pull = Process(["git", "pull"], workingDirectory: localRepoUrl)

    pull.launch()
} else {
    print("Clonning \(repo.path)...")
    let clone = Process(["git", "clone", repo.path, directory], workingDirectory: url)

    clone.launch()
    clone.waitUntilExit()
}

guard let enumerator = fileManager.enumerator(at: localRepoUrl, includingPropertiesForKeys: [], options: [.skipsHiddenFiles]) else {
    print("could not read content for '\(directory)' template set.")
    exit(1)
}

try fileManager.createDirectory(at: repoTemplatesDirectory, withIntermediateDirectories: true)
print("Locating templates...")

// Search for templates inside local repository
let templates = enumerator
    .compactMap { $0 as? URL }
    .filter { $0.pathExtension == "xctemplate" }

// Link templates from Xcode directory into local repository
try templates.forEach { localTemplateUrl in
    let templateLinkName = repoTemplatesDirectory.appendingPathComponent(localTemplateUrl.lastPathComponent)
    print("Linking \(templateLinkName.path) -> \(localTemplateUrl.path)")

    // Check if the link already exists
    if fileManager.fileExists(atPath: templateLinkName.path) {
        // If link exists, remove it so it can be linked again
        try fileManager.removeItem(at: templateLinkName)
    }

    try fileManager.createSymbolicLink(at: templateLinkName, withDestinationURL: localTemplateUrl)
}

print("Installed \(templates.count) templates")

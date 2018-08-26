//
//  main.swift
//  xcman
//
//  Created by Josef Dolezal on 26/08/2018.
//

import Foundation

guard CommandLine.arguments.count > 1 else {
    print("Usage: xcman <github handle>")
    exit(1)
}

let cacheUrl = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".xcman", isDirectory: true)
let templatesManager = TemplatesManager(cacheUrl: cacheUrl)
let repository = GitRepository(githubHandle: CommandLine.arguments[1])

try templatesManager.add(repository: repository)

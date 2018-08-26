//
//  main.swift
//  xcman
//
//  Created by Josef Dolezal on 26/08/2018.
//

import Foundation
import XCManLib

func main() {
    guard CommandLine.arguments.count > 1 else {
        print("Usage: xcman <github handle>")
        exit(1)
    }

    guard #available(OSX 10.12, *) else {
        print("Minimum required version is macOS 12.12")
        return
    }
    let cacheUrl = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".xcman", isDirectory: true)
    let templatesManager = SnippetsManager(cacheUrl: cacheUrl)
    let repository = GitRepository(githubHandle: CommandLine.arguments[1])

    do {
        try templatesManager.add(repository: repository)
    } catch {
        print(error)
    }
}

main()

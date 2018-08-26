//
//  XCManSnippetsTool.swift
//  Commander
//
//  Created by Josef Dolezal on 26/08/2018.
//

import Foundation
import Commander
import XCManLib

let snippetsCommand = Group {
    $0.command("install",
               Flag("use-url", default: false, flag: "u", description: "Interprets repository as generic URL instead of GitHub handle"),
               Argument<String>("repo", description: "GitHub handle or repository URL"),
               description: "Installs code snippets from given repository"
    ) { useUrl, repo in
        // Create repository base on given options
        let repository = useUrl
            ? GitRepository(url: URL(string: repo)!)
            : GitRepository(githubHandle: repo)

        let snippetsManager = SnippetsManager(cacheUrl: XCManConfiguration.defaultCacheUrl)
        try snippetsManager.add(repository: repository)
    }
}

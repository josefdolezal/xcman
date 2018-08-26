//
//  XCManTemplatesTool.swift
//  XCManLib
//
//  Created by Josef Dolezal on 26/08/2018.
//

import Foundation
import XCManLib
import Commander

let templatesCommand = Group {
    $0.command("install",
        Flag("use-url", default: false, flag: "u", description: "Interprets repository as generic URL instead of GitHub handle"),
        Option("name", default: "", flag: "n", description: "Custom name for Xcode templates group"),
        Argument<String>("repo", description: "GitHub handle or repository URL"),
        description: "Installs templates from given repository"
    ) { useUrl, name, repo in
        // Check if the custom name is set
        let repositoryName = name.isEmpty ? nil : name
        // Create repository base on given options
        let repository = useUrl
            ? GitRepository(url: URL(string: repo)!, name: repositoryName)
            : GitRepository(githubHandle: repo, name: repositoryName)

        let templatesManager = TemplatesManager(cacheUrl: XCManConfiguration.defaultCacheUrl)
        try templatesManager.add(repository: repository)
    }
}

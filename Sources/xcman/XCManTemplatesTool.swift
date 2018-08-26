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
    // Create shared templates mananger
    let templatesManager = TemplatesManager(cacheUrl: XCManConfiguration.defaultCacheUrl)

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

        try templatesManager.add(repository: repository)
    }

    $0.command("list", description: "Lists installed templates sets") {
        // Get list of templates set
        let templates = try templatesManager.list()

        // Print each templates set one by one
        templates.forEach { print($0) }
    }

    $0.command("remove",
        VariadicArgument<String>("name", description: "Name of the templates set to be deleted"),
        description: "Removes installed templates from Xcode"
    ) { names in
        // Remove all sets listed by user
        try names.forEach { try templatesManager.delete(templatesSet: $0) }
    }
}

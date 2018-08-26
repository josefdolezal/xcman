//
//  XCManConfiguration.swift
//  Commander
//
//  Created by Josef Dolezal on 26/08/2018.
//

import Foundation

extension FileManager {
    var homeDirectoryUrl: URL {
        if #available(OSX 10.12, *) {
            return FileManager.default.homeDirectoryForCurrentUser
        } else {
            return URL(fileURLWithPath: NSHomeDirectory())
        }
    }
}

public struct XCManConfiguration {
    public static let defaultCacheUrl: URL = FileManager.default.homeDirectoryUrl.appendingPathComponent(".xcman", isDirectory: true)

    public static let defaultTemplatesCacheUrl: URL = defaultCacheUrl.appendingPathComponent("templates", isDirectory: true)

    public static let defaultSnippetsCacheUrl: URL = defaultCacheUrl.appendingPathComponent("snippets", isDirectory: true)
}

//
//  Process+Commands.swift
//  xcman
//
//  Created by Josef Dolezal on 26/08/2018.
//

import Foundation

extension Process {
    convenience init(_ arguments: [String], workingDirectory: Foundation.URL) {
        self.init()

        self.arguments = arguments
        self.launchPath = "/usr/bin/env"
        self.currentDirectoryPath = workingDirectory.path
    }
}

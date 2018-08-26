//
//  main.swift
//  xcman
//
//  Created by Josef Dolezal on 26/08/2018.
//

import Foundation
import XCManLib
import Commander

let main = Group {
    $0.addCommand("templates", templatesCommand)
    $0.addCommand("snippets", snippetsCommand)
}

main.run()

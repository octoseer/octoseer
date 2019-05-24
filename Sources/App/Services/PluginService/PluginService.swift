//
//  PluginService.swift
//  App
//
//  Created by Denis Chagin on 03/05/2019.
//

import Foundation

class PluginService {

    func listPlugins() -> [String] {
        print(FileManager.default.currentDirectoryPath)

        let e = try! FileManager.default
            .contentsOfDirectory(at: URL.init(fileURLWithPath: FileManager.default.currentDirectoryPath), includingPropertiesForKeys: nil, options: [])
            .filter { FileManager.default.isExecutableFile(atPath: $0.path) }
            .map { $0.path }


        print(e)

        return e
    }
}

let pluginService = PluginService()

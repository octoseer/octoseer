//
//  PluginService.swift
//  App
//
//  Created by Denis Chagin on 03/05/2019.
//

import Foundation

struct Plugin: Decodable {

    let execPath: String
    let info: PluginInfo
}

struct PluginInfo: Decodable {
    let trials: [String]
}

class PluginService {

    private let pluginsDirPath = "/tmp"
    private let pluginExtensionName = "trial"

    func listPlugins() -> [String] {
        let pluginsPaths = try! FileManager.default
            .contentsOfDirectory(at: URL.init(fileURLWithPath: pluginsDirPath),
                                 includingPropertiesForKeys: nil,
                                 options: [])
            .filter { FileManager.default.isExecutableFile(atPath: $0.path) }
            .filter { $0.pathExtension == pluginExtensionName }
            .map { $0.path }

        return pluginsPaths
    }

    func loadPlugins() -> [Plugin] {

        return listPlugins().map { pluginPath -> Plugin? in
            let output = Result { try Process.execute(pluginPath, ["--info"]) }

            switch output {
            case .success(let data):
                print("PLUGIN OUT: ", data)

                guard let pluginInfo = try? JSONDecoder().decode(PluginInfo.self, from: data) else { return nil }

                print("PLUGIN INFO:", pluginInfo)

                return Plugin(execPath: pluginPath, info: pluginInfo)

            case .failure(let error):
                print("PLUGIN ERROR: ", error)
                return nil
            }
        }
        .compactMap { $0 }
    }
}

let pluginService = PluginService()

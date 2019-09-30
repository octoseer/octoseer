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

struct Trial {
    let name: String
    let execPath: String
}

class PluginService {

    private let pluginsDirPath = "/tmp"
    private let pluginExtensionName = "trial"

    private lazy var configuration: ConfigurationData = {
        let configurationProvider = AppAssembly.shared.resolve(ConfigurationProvider.self)

        return configurationProvider.configuration
    }()

    private func listPlugins() -> Result<[String], Error> {
        let pluginsPaths = Result {
            try FileManager.default
                .contentsOfDirectory(at: URL.init(fileURLWithPath: pluginsDirPath),
                                     includingPropertiesForKeys: nil,
                                     options: [])
                .filter { FileManager.default.isExecutableFile(atPath: $0.path) }
                .filter { $0.pathExtension == configuration.pluginExtensionName }
                .map { $0.path }
        }

        return pluginsPaths
    }

    private func loadPlugins() -> Result<[Plugin], Error> {

        let availablePluginsPaths = listPlugins()

        let availablePlugins = availablePluginsPaths.map { pluginsPaths in
            return pluginsPaths.compactMap(loadPlugin(pluginPath:))
        }

        return availablePlugins
    }

    private func loadPlugin(pluginPath: String) -> Plugin? {
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

    func loadTrials() -> Result<[Trial], Error> {
        let availablePlugins = loadPlugins()

        let availableTrials = availablePlugins.map { plugins in
            return plugins.flatMap { plugin in
                return plugin.info.trials.map { Trial(name: $0, execPath: plugin.execPath) }
            }
        }

        return availableTrials
    }
}

//let pluginService = PluginService()
//let kTrials = try! pluginService.loadTrials().get()

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

    private lazy var configuration: ConfigurationData = {
        let configurationProvider = AppAssembly.shared.resolve(ConfigurationProvider.self)

        return configurationProvider.configuration
    }()

    private func listPlugins() -> Result<[String], Error> {
        let pluginsPaths = Result {
            try FileManager.default
                .contentsOfDirectory(at: URL.init(fileURLWithPath: configuration.pluginsDirectory),
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
            guard let pluginInfo = try? JSONDecoder().decode(PluginInfo.self, from: data) else { return nil }

            return Plugin(execPath: pluginPath, info: pluginInfo)

        case .failure:
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

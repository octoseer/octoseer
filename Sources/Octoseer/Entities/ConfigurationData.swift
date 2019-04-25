import Foundation

struct ConfigurationData {
    let appID: String
    let pluginsDirectory: String
    let pluginExtensionName = "trial"
}

extension ConfigurationData: Decodable {}

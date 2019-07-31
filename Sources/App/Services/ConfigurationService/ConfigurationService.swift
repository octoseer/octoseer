//
//  ConfigurationService.swift
//  App
//
//  Created by Denis Chagin on 31.07.2019.
//

import Foundation
import Yams

class ConfigurationService {

    private var configurationData: ConfigurationData!
}

extension ConfigurationService: ConfigurationProvider {

    var configuration: ConfigurationData {
        return configurationData
    }

    func loadConfiguration(from filePath: String) {
        if let configData = FileManager.default.contents(atPath: filePath),
            let data = String(bytes: configData, encoding: .utf8) {
            print(data)
            let config = try? YAMLDecoder().decode(ConfigurationData.self,
                                                   from: data)

            self.configurationData = config
        } else {
            fatalError("Configuration file error")
        }
    }
}

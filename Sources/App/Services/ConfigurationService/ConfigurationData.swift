//
//  ConfigurationData.swift
//  App
//
//  Created by Denis Chagin on 31.07.2019.
//

import Foundation

struct ConfigurationData {
    let appID: String
    let pluginsDirectory: String
    let pluginExtensionName = "trial"
}

extension ConfigurationData: Decodable {}

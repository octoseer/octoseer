//
//  ConfigurationProvider.swift
//  App
//
//  Created by Denis Chagin on 31.07.2019.
//

import Foundation

protocol ConfigurationProvider {

    var configuration: ConfigurationData { get }

    func loadConfiguration(from filePath: String)
}

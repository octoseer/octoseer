//
//  ConfigurationLoader.swift
//  App
//
//  Created by Denis Chagin on 30.09.2019.
//

import Foundation

protocol ConfigurationLoader {

    func loadConfiguration(fromPath filePath: String) -> Result<Void, Error>
}

import Foundation
import Yams

class ConfigurationService {

    private var configurationData: ConfigurationData!
}

extension ConfigurationService: ConfigurationProvider {

    var configuration: ConfigurationData {
        return configurationData
    }
}

extension ConfigurationService: ConfigurationLoader {

    enum ConfigurationError: Error {
        case fileError
    }

    func loadConfiguration(fromPath filePath: String) -> Result<Void, Error> {
        if let configFileRawData = FileManager.default.contents(atPath: filePath),
            let configFileData = String(bytes: configFileRawData, encoding: .utf8) {
            let configDecodingResult = Result {
                try YAMLDecoder().decode(ConfigurationData.self,
                                         from: configFileData)
            }

            switch configDecodingResult {
            case .success(let configuration):
                configurationData = configuration
            case .failure(let error):
                return .failure(error)
            }
        } else {
            return .failure(ConfigurationError.fileError)
        }

        return .success(())
    }
}

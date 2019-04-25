import Foundation

protocol ConfigurationLoader {

    func loadConfiguration(fromPath filePath: String) -> Result<Void, Error>
}

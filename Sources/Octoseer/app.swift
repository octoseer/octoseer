import Vapor

public func app(_ env: Environment) throws -> Application {
    AppAssembly.shared.addAssembly(ServiceAssembly())

    var config = Config.default()
    var env = env
    var services = Services.default()
    try configure(&config, &env, &services)
    let app = try Application(config: config, environment: env, services: services)
    try boot(app)

    let configurationService = AppAssembly.shared.resolve(ConfigurationLoader.self)

    let result = configurationService.loadConfiguration(fromPath: "/tmp/octoseer.yaml")

    if case let .failure(error) = result {
        print("Configuration error: ", error)
        exit(1)
    }

    return app
}

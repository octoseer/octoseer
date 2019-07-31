import RxSwift
import Swinject
import Vapor

class AppAssembly {

    static var shared: AppAssembly {
        return privateSelf
    }

    private static let privateSelf = AppAssembly()
    private let assembler = Assembler()

    private init() {

    }

    func addAssembly(_ assembly: Assembly) {
        self.assembler.apply(assembly: assembly)
    }

    func resolve<T>(_ type: T.Type) -> T {
        if let resolvedDependency = self.assembler.resolver.resolve(T.self) {
            return resolvedDependency
        }

        fatalError("\(T.self) entity is not registered.")
    }
}

public func app(_ env: Environment) throws -> Application {
    print(kTrials)
    var config = Config.default()
    var env = env
    var services = Services.default()
    try configure(&config, &env, &services)
    let app = try Application(config: config, environment: env, services: services)
    try boot(app)

    AppAssembly.shared.addAssembly(ServiceAssembly())

    let configurationService = AppAssembly.shared.resolve(ConfigurationProvider.self)

    configurationService.loadConfiguration(from: "/tmp/octoseer.yaml")

    print(configurationService.configuration)

    return app
}

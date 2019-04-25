import Swinject

class ServiceAssembly: Assembly {

    func assemble(container: Container) {
        container.register(ConfigurationProvider.self) { _ in
            return ConfigurationService()
        }
        .implements(ConfigurationLoader.self)
        .inObjectScope(.container)

        container.register(TrialLoader.self) { _ in
            return TrialService()
        }
        .implements(TrialStorage.self)
        .inObjectScope(.container)
    }
}

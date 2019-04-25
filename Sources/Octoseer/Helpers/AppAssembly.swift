import Swinject

class AppAssembly {

    static var shared: AppAssembly {
        return privateSelf
    }

    private static let privateSelf = AppAssembly()
    private let assembler = Assembler()

    private init() {}

    func addAssembly(_ assembly: Assembly) {
        assembler.apply(assembly: assembly)
    }

    func resolve<T>(_ type: T.Type) -> T {
        if let resolvedDependency = assembler.resolver.resolve(T.self) {
            return resolvedDependency
        }

        fatalError("\(T.self) entity is not registered.")
    }
}

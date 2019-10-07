@propertyWrapper
struct Injected<Value> {

    private(set) var wrappedValue: Value

    init() {
        wrappedValue = AppAssembly.shared.resolve(Value.self)
    }
}

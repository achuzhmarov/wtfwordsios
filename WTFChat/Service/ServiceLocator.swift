import Foundation

class ServiceLocator {
    lazy var s = [String: Any]()

    func add(services: Service...) {
        for service in services {
            let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
            dispatch_async(backgroundQueue, {
                service.initService()
            })

            service.initServiceOnMain()

            s[typeName(service)] = service
        }
    }

    func get<T>(_: T.Type) -> T {
        if s[typeName(T)] != nil {
            return s[typeName(T)] as! T
        } else {
            ServiceInitializer.initServices()
            return s[typeName(T)] as! T
        }
    }

    private func typeName(some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(some.dynamicType)"
    }
}

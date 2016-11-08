import Foundation

class ServiceLocator {
    lazy var s = [String: Any]()

    func add(_ services: Service...) {
        for service in services {
            let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
            backgroundQueue.async(execute: {
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

    fileprivate func typeName(_ some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(type(of: (some) as AnyObject))"
    }
}

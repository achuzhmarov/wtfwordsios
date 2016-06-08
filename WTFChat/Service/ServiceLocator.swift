//
// Created by Artem Chuzhmarov on 30/05/16.
// Copyright (c) 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class ServiceLocator {
    lazy var s = [String: Any]()

    func add(services: Service...) {
        for service in services {
            service.initService()
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

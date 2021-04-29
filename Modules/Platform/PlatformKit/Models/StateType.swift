// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public protocol StateType {
    func update<Value>(keyPath: WritableKeyPath<Self, Value>, value: Value) -> Self
}

public extension StateType {
    func update<Value>(keyPath: WritableKeyPath<Self, Value>, value: Value) -> Self {
        var newState = self
        newState[keyPath: keyPath] = value
        return newState
    }
}

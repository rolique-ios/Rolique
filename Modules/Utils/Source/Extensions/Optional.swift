//
//  Optional.swift
//  GetGrub
//
//  Created by Bohdan Savych on 12/16/17.
//  Copyright © 2017 ROLIQUE. All rights reserved.
//

import UIKit

public extension Optional {
    func apply<Result>(_ transform: ((Wrapped) -> Result)?) -> Result? {
        return self.flatMap { value in
            transform.map { $0(value) }
        }
    }
    
    func apply<Value, Result>(_ value: Value?) -> Result?
        where Wrapped == (Value) -> Result
    {
        return value.apply(self)
    }
    
    func flatten<Result>() -> Result?
        where Wrapped == Result?
    {
        return self.flatMap { $0 }
    }
    
    func `do`(_ action: (Wrapped) -> ()) {
        self.map(action)
    }
}

public extension Optional where Wrapped == String {
    var orEmpty: String {
        return self ?? ""
    }
}

public extension Optional where Wrapped == Bool {
  var orFalse: Bool {
    return self ?? false
  }
  
  var orTrue: Bool {
    return self ?? true
  }
}

public extension Optional where Wrapped == Int {
    var orZero: Int {
        return self ?? 0
    }
}

public extension Optional where Wrapped == Double {
    var orZero: Double {
        return self ?? 0
    }
    
    var orMax: Double {
        return self ?? Double.greatestFiniteMagnitude
    }
}

public extension Optional where Wrapped == CGFloat {
    var orZero: CGFloat {
        return self ?? 0
    }
    
    var orMax: CGFloat {
        return self ?? CGFloat.greatestFiniteMagnitude
    }
}

public extension Optional where Wrapped == Date {
    var orCurrent: Date {
        return self ?? Date()
    }
}

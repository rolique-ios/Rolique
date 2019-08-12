//
//  Net.swift
//  Networking
//
//  Created by Andrii on 7/31/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Foundation

public struct Net {
  public typealias JsonResult = (Json) -> Void
  public typealias ErrorResult = (Error) -> Void
  public typealias RouteInvocation = (Route) -> Void
  
  public struct Worker {}
}

public protocol NetworkerCompatible {
  var route: Route { get }
  var onSuccess: Net.JsonResult? { get }
  var onError: Net.ErrorResult? { get }
  
  func now()
}

public extension NetworkerCompatible {
  func now() {
    Net.Worker.request(route, onSuccess: onSuccess, onError: onError)
  }
}

public extension Net.Worker {
  static func request(_ route: Route, onSuccess: Net.JsonResult?, onError: Net.ErrorResult?) {
    Transport.request(route, onSuccess: onSuccess, onError: onError)
  }
}

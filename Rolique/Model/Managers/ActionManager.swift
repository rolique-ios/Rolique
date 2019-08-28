//
//  ActionManager.swift
//  Model
//
//  Created by Andrii on 8/1/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Foundation
import Networking

public enum ActionType: String, CaseIterable {
  case late
  case remote
  case doprac
  case pochav
}

public enum DopracType {
  case now
  case hour(Date?)
  
  var description: String {
    switch self {
    case .now:
      return "now"
    case .hour:
      return "hour"
    }
  }
}

public protocol ActionManger {
  func sendAction(_ action: Action, result: ((Result<ActionResult, Error>) -> Void)?)
}

public final class ActionMangerImpl: ActionManger {
  
  public init() {}
  
  public func sendAction(_ action: Action, result: ((Result<ActionResult, Error>) -> Void)?) {
    Net.Worker.request(action.makeCommand(), onSuccess: { json in
      DispatchQueue.main.async {
        result?(.success(ActionResult(error: json.string("error"))))
      }
    }, onError: { error in
      DispatchQueue.main.async {
        print(error)
        result?(.success(ActionResult(error: error.localizedDescription)))
      }
    })
  }
}

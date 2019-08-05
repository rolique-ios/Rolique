//
//  ActionManager.swift
//  Model
//
//  Created by Andrii on 8/1/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Foundation
import Networking

public enum ActionType {
  
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
        result?(.success(ActionResult(error: error.localizedDescription)))
      }
    })
  }
}

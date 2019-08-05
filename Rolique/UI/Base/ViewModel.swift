//
//  ViewModel.swift
//  AbstractViewModel
//
//  Created by bbb on 10/22/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

public protocol ViewModel {
  var shouldPush: ((_ viewController: UIViewController, _ animated: Bool) -> Void)? { get set }
  var shouldPop: ((_ animated: Bool) -> UIViewController?)? { get set }
  var shouldPopToRoot: ((_ animated: Bool) -> [UIViewController]?)? { get set }
  var shouldSet: ((_ viewControllers: [UIViewController], _ animated: Bool) -> Void)? { get set }
  
  var shouldPresent: ((UIViewController, Bool, (() -> Void)?) -> Void)? { get set }
  var shouldDismmiss: ((Bool, (() -> Void)?) -> Void)? { get set }
  
  var shouldNavPresent: ((UIViewController, Bool, (() -> Void)?) -> Void)? { get set }
  var shouldNavDismmiss: ((Bool, (() -> Void)?) -> Void)? { get set }
}

public class BaseViewModel: ViewModel {
  public var shouldPush: ((UIViewController, Bool) -> Void)?
  public var shouldPop: ((Bool) -> UIViewController?)?
  public var shouldPopToRoot: ((Bool) -> [UIViewController]?)?
  public var shouldSet: (([UIViewController], Bool) -> Void)?
  
  public var shouldPresent: ((UIViewController, Bool, (() -> Void)?) -> Void)?
  public var shouldDismmiss: ((Bool, (() -> Void)?) -> Void)?
  
  public var shouldNavPresent: ((UIViewController, Bool, (() -> Void)?) -> Void)?
  public var shouldNavDismmiss: ((Bool, (() -> Void)?) -> Void)?
}

//
//  ViewModel.swift
//  AbstractViewModel
//
//  Created by bbb on 10/22/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

protocol ViewModel {
  var shouldPush: ((_ viewController: UIViewController, _ animated: Bool) -> Void)? { get set }
  var shouldPop: ((_ animated: Bool) -> UIViewController?)? { get set }
  var shouldPopToRoot: ((_ animated: Bool) -> [UIViewController]?)? { get set }
  var shouldSet: ((_ viewControllers: [UIViewController], _ animated: Bool) -> Void)? { get set }
  
  var shouldPresent: ((UIViewController, Bool, (() -> Void)?) -> Void)? { get set }
  var shouldDismmiss: ((Bool, (() -> Void)?) -> Void)? { get set }
  
  var shouldNavPresent: ((UIViewController, Bool, (() -> Void)?) -> Void)? { get set }
  var shouldNavDismmiss: ((Bool, (() -> Void)?) -> Void)? { get set }
  
  // MARK: - Lifecycle
  func viewDidLoad()
  func viewWillAppear()
  func viewDidAppear()
  func viewWillDisappear()
  func viewDidDisappear()
  func viewWillLayoutSubviews()
  func viewDidLayoutSubviews()
  func didReceiveMemoryWarning()
}

class BaseViewModel: ViewModel {
  
  var shouldPush: ((UIViewController, Bool) -> Void)?
  var shouldPop: ((Bool) -> UIViewController?)?
  var shouldPopToRoot: ((Bool) -> [UIViewController]?)?
  var shouldSet: (([UIViewController], Bool) -> Void)?
  
  var shouldPresent: ((UIViewController, Bool, (() -> Void)?) -> Void)?
  var shouldDismmiss: ((Bool, (() -> Void)?) -> Void)?
  
  var shouldNavPresent: ((UIViewController, Bool, (() -> Void)?) -> Void)?
  var shouldNavDismmiss: ((Bool, (() -> Void)?) -> Void)?
  
  // MARK: - Lifecycle
  func viewDidLoad() {}
  func viewWillAppear() {}
  func viewDidAppear() {}
  func viewWillDisappear() {}
  func viewDidDisappear() {}
  func viewWillLayoutSubviews() {}
  func viewDidLayoutSubviews() {}
  func didReceiveMemoryWarning() {}
}

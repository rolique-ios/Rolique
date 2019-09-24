//
//  ViewController.swift
//  AbstractViewModel
//
//  Created by bbb on 10/22/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit

typealias Completion = () -> Void

/// - warning: Abstract - don't create instance of this class.
class ViewController<T: ViewModel>: UIViewController {
  private lazy var viewWillAppearWasCalled = false
  private lazy var viewDidAppearWasCalled = false
  
  var viewModel: T
  
  init(viewModel: T) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  override func loadView() {
    self.view = UIView(frame: CGRect(origin: .zero, size: UIScreen.main.bounds.size))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
  
  var statusBarStyle: UIStatusBarStyle { return .default }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = .white
    self.configureBinding()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    defer {
      self.viewWillAppearWasCalled = true
    }
    
    if !self.viewWillAppearWasCalled {
      self.performOnceInViewWillAppear()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    defer {
      self.viewDidAppearWasCalled = true
    }
    
    if !self.viewDidAppearWasCalled {
      self.performOnceInViewDidAppear()
    }
  }
  
  func performOnceInViewWillAppear() {}
  
  func performOnceInViewDidAppear() {}
  
  deinit {
    print("☠️ \(self) ☠️")
    NotificationCenter.default.removeObserver(self)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}

// MARK: - Private
private extension ViewController {
  func configureBinding() {
    self.viewModel.shouldPop = self.navigationController?.popViewController
    self.viewModel.shouldPush = self.navigationController?.pushViewController
    self.viewModel.shouldPopToRoot = self.navigationController?.popToRootViewController
    self.viewModel.shouldSet = self.navigationController?.setViewControllers
    
    self.viewModel.shouldNavDismmiss = self.navigationController?.dismiss
    self.viewModel.shouldNavPresent = self.navigationController?.present

    self.viewModel.shouldDismmiss = { [weak self] in
      self?.dismiss(animated: $0, completion: $1)
    }
    self.viewModel.shouldPresent = { [weak self] in
      self?.present($0, animated: $1, completion: $2)
    }
  }
}


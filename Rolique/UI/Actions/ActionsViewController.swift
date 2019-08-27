//
//  ActionsViewController.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/27/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

final class ActionsViewController<T: ActionsViewModel>: ViewController<T> {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureConstraints()
    configureUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    configureNavigationBar()
  }
  
  private func configureNavigationBar() {
    navigationController?.navigationBar.isTranslucent = false
    navigationController?.navigationBar.prefersLargeTitles = true
    let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    navigationController?.navigationBar.titleTextAttributes = attributes
    navigationController?.navigationBar.largeTitleTextAttributes = attributes
    navigationController?.navigationBar.barTintColor = Colors.Login.backgroundColor
    navigationController?.navigationBar.tintColor = UIColor.white
  }
  
  private func configureConstraints() {
    
  }
  
  private func configureUI() {
    title = Strings.NavigationTitle.actions
    self.view.backgroundColor = Colors.Colleagues.softWhite
  }
  
}

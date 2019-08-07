//
//  ProfileViewController.swift
//  UI
//
//  Created by Bohdan Savych on 8/5/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

final class ProfileViewController<T: ProfileViewModel>: ViewController<T> {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = Colors.Login.backgroundColor
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(true, animated: true)
  }
}

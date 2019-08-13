//
//  ProfileViewController.swift
//  UI
//
//  Created by Bohdan Savych on 8/5/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils
import IgyToast

final class ProfileViewController<T: ProfileViewModel>: ViewController<T> {
  
  private lazy var button = UIButton()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = Colors.Login.backgroundColor
    configureUI()
    view.addSubviewAndDisableMaskTranslate(button)
    
    button.snp.makeConstraints { maker in
      maker.size.equalTo(CGSize(width: 80, height: 40))
      maker.center.equalToSuperview()
    }
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  private func configureUI() {
    configureButton()
  }
  
  private func configureButton() {
    button.setTitle("test toast", for: UIControl.State.normal)
    button.addTarget(self, action: #selector(buttonTap(_:)), for: UIControl.Event.touchUpInside)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    Toast.current.toastVC?.layoutVertically()
  }
  
  @objc func buttonTap(_ button: UIButton) {
    let v1 = NotificationReminderView()
    let v2 = NotificationReminderView()
    let v3 = NotificationReminderView()

    v1.heightAnchor.constraint(equalToConstant: 100).isActive = true
    v2.heightAnchor.constraint(equalToConstant: 500).isActive = true

    v3.heightAnchor.constraint(equalToConstant: 100).isActive = true

    Toast.current.showToast(v2, header: v1, footer: v3)
  }
}


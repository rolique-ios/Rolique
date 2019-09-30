//
//  UIContextMenuConfigurationHandler.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/27/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

struct Menu {
  let title: String
  var actions: [MenuAction]
}

struct MenuAction {
  let title: String
  let image: UIImage?
  var handler: () -> Void
}

final class UIContextMenuConfigurationHandler {
  var identifieProvider: NSCopying?
  var location: CGPoint?
  var indexPath: IndexPath?
  var previewProvider: ((IndexPath?, CGPoint?) -> UIContextMenuContentPreviewProvider?)?
  var provideMenu: ((IndexPath?) -> Menu)?
  var willEndDisplayContextMenu: ((UIViewController?) -> Void)?
  
  @available(iOS 13.0, *)
  private lazy var actionProvider: ((IndexPath?) -> UIContextMenuActionProvider?) = { indexPath in
    let actions = self.provideMenu?(indexPath).actions.map { action in UIAction(title: action.title, image: action.image, handler: to(action.handler)) }
    return { _ in UIMenu(title: self.provideMenu?(indexPath).title ?? "", children: actions ?? []) }
  }
  
  init() {}
  
  @available(iOS 13.0, *)
  func getContextMenuConfiguration(indexPath: IndexPath?, location: CGPoint) -> UIContextMenuConfiguration {
    self.indexPath = indexPath
    self.location = location
    return UIContextMenuConfiguration(identifier: identifieProvider, previewProvider: previewProvider?(indexPath, location), actionProvider: actionProvider(indexPath))
  }
  
  @available(iOS 13.0, *)
  func performAnimation(with configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
    animator.addCompletion { [weak self] in
      self?.willEndDisplayContextMenu?(animator.previewViewController)
    }
  }
}

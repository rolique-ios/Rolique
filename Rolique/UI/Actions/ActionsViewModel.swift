//
//  ActionsViewModel.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/27/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

protocol ActionsViewModel: ViewModel {
  
}

final class ActionsViewModelImpl: BaseViewModel, ActionsViewModel {
  let actionManager: ActionManger
  init(actionManager: ActionManger) {
    self.actionManager = actionManager
  }
}


//
//  Balance.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/12/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation

final class Balance: Codable {
    let cash: Double
    let card: Double
    
    init(cash: Double = 0, card: Double = 0) {
        self.card = card
        self.cash = cash
    }
}

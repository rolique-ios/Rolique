//
//  GetBot.swift
//  Rolique
//
//  Created by Andrii on 9/5/19.
//

import Foundation

public final class GetBot: Route {
  public init() {
    super.init(endpoint:"bot", method: .get, urlParams: [:])
  }
}

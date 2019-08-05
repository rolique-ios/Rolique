//
//  Transport.swift
//  Networking
//
//  Created by Andrii on 8/2/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import Foundation

struct Transport: TransportProtocol {}

protocol TransportProtocol {
  static func request(_ route: Route, onSuccess: Net.JsonResult?, onError: Net.ErrorResult?)
}

extension Transport {
  static func request(_ route: Route, onSuccess: Net.JsonResult?, onError: Net.ErrorResult?) {
    do {
      print("\nrequest -> \(try route.asRequest().url?.absoluteString ?? "")\n")
      URLSession.shared.dataTask(with: try route.asRequest(), completionHandler: { (data, response, error) in
        guard error == nil else { onError?(error!); return }
        guard let httpResponse = response as? HTTPURLResponse else {
          onError?(NSError(domain: "rolique", code: 700, userInfo: [NSLocalizedFailureReasonErrorKey: "no data"]))
          return }
        let code = httpResponse.statusCode
        guard let data = data else { onError?(NSError(domain: "rolique", code: code, userInfo: [NSLocalizedFailureReasonErrorKey: "no data"])) ; return }
        guard let jsonString = String(data: data, encoding: .utf8) else {
          do {
            let json = try JSONDecoder().decode(Json.self, from: data)
            onSuccess?(json); return
          } catch let error {
            onError?(error); return
          }
        }
        onSuccess?(Json(stringValue: jsonString))
      }).resume()
    } catch {
      onError?(error)
    }
  }
}

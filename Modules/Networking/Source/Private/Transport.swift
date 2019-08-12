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
    var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    DispatchQueue.main.async {
      guard let requst = try? route.asRequest() else {
        onError?(Err.general(msg: "invalid request"))
        return
      }
      
      DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "request on route \(requst.url?.absoluteString ?? "")", expirationHandler: {
          UIApplication.shared.endBackgroundTask(backgroundTaskID)
          backgroundTaskID = .invalid
          onError?(Err.general(msg: "finish background task"))
        })
        
        print("\nrequest -> \(requst.url?.absoluteString ?? "")\n")
        URLSession.shared.dataTask(with: requst, completionHandler: { (data, response, error) in
          guard error == nil else {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
            onError?(error!); return }
          guard let httpResponse = response as? HTTPURLResponse else {
            onError?(Err.general(msg: "no data"))
            return }
          let code = httpResponse.statusCode
          guard let data = data else {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
            onError?(Err.general(msg: "no data")) ; return }
          guard let jsonString = String(data: data, encoding: .utf8) else {
            do {
              let json = try JSONDecoder().decode(Json.self, from: data)
              UIApplication.shared.endBackgroundTask(backgroundTaskID)
              backgroundTaskID = .invalid
              onSuccess?(json); return
            } catch let error {
              UIApplication.shared.endBackgroundTask(backgroundTaskID)
              backgroundTaskID = .invalid
              onError?(error); return
            }
          }
          UIApplication.shared.endBackgroundTask(backgroundTaskID)
          backgroundTaskID = .invalid
          print("\nresponse -> \(code) \(jsonString)")
          onSuccess?(Json(stringValue: jsonString))
        }).resume()
      }
    }
  }
}

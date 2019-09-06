//
//  LoginManager.swift
//  Model
//
//  Created by Andrii on 7/31/19.
//  Copyright © 2019 ROLIQUE. All rights reserved.
//

import UIKit
import Utils
import Networking
import SafariServices

public protocol LoginManager {
  func login(result: ((Result<User, Error>) -> Void)?)
}

public final class LoginManagerImpl: LoginManager {
  private var authSession: SFAuthenticationSession?
  
  public init() {
  }

  private func getLoginURL() -> URL? {
    return try? SlackLogin().asRequest().url
  }
  
  public func login(result: ((Result<User, Error>) -> Void)?) {
    guard let url = getLoginURL() else { return }
    
    self.authSession = SFAuthenticationSession(url: url, callbackURLScheme: "rolique", completionHandler: { (redirectUrl, error) in
      if error == nil {
        guard let redirectUrl = redirectUrl else { print("no redirect url"); return }
        self.login(redirectUrl: redirectUrl, result: { res in
          DispatchQueue.main.async {
            result?(res)
          }
        })
      } else {
        DispatchQueue.main.async {
          if (error as NSError?)?.code == 1 {
            result?(.failure(Err.general(msg: "this app is only connecting to Rolique slack workspace")))
          } else {
            result?(.failure(error!))
          }
        }
      }
    })
    
    self.authSession?.start()
  }
  
  func login(redirectUrl: URL, result: ((Result<User, Error>) -> Void)?) {
    let query = redirectUrl.query?.components(separatedBy: "=")
    if query![0] == "code" {
      let code = query![1]
      Net.Worker.request(SlackToken(code: code), onSuccess: { jsonResult in
        guard let userSlackId = jsonResult.string("user/id") else {
          DispatchQueue.main.async {
            result?(.failure(Err.general(msg: "failed to get string value by keypath: user/id")))
          }
          return
        }
        
        let getUserWithId = GetUserWithId(userId: userSlackId)
        Net.Worker.request(getUserWithId, onSuccess: { userJson in
          guard let userBody = userJson.json("body") else {
            DispatchQueue.main.async {
              result?(.failure(Err.general(msg: "response does not contain body")))
            }
            return
          }
          guard let data = userBody.stringValue.data(using: .utf8) else {
            DispatchQueue.main.async {
              result?(.failure(Err.general(msg: "failed to serialize user body")))
            }
            return
          }
          guard let user = try? JSONDecoder().decode(User.self, from: data) else {
            DispatchQueue.main.async {
              result?(.failure(Err.general(msg: "failed to decode user")))
            }
            return
          }

          Net.Worker.request(GetBot(), onSuccess: { botJson in
            DispatchQueue.main.async {
              let bot: Bot? = botJson.build()
              if let bot = bot {
                UserDefaultsManager.shared.botId = bot.userID
                UserDefaultsManager.shared.teamId = bot.teamID
                UserDefaultsManager.shared.teamName = bot.teamName
                result?(.success(user))
              } else {
                result?(.failure(Err.general(msg: "failed to build bot")))
              }
            }
          }, onError: { error in
            DispatchQueue.main.async {
              result?(.failure(error))
            }
          })

        }, onError: { error in
          DispatchQueue.main.async {
            result?(.failure(error))
          }
        })
      }, onError: { error in
        DispatchQueue.main.async {
          result?(.failure(error))
        }
      })
    }
  }
}

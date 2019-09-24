
//
//  Images.swift
//  Utils
//
//  Created by Bohdan Savych on 8/1/19.
//  Copyright © 2019 Bohdan Savych. All rights reserved.
//

public struct Images {
  public struct General {
    public static var logo: UIImage {
      return UIImage(named: "logo")!
    }
  }
  public struct TabBar {
    public static var profile: UIImage {
      return UIImage(named: "profile")!
    }
    
    public static var stats: UIImage {
      return UIImage(named: "stats")!
    }
    
    public static var actions: UIImage {
      return UIImage(named: "actions")!
    }
  }
  public struct Login {
    public static var fullLogo: UIImage {
      return UIImage(named: "logoFull")!
    }
    
    public static var slackButton: UIImage {
      return UIImage(named: "slackButton")!
    }
  }
  public struct Colleagues {
    public static var phone: UIImage {
      return UIImage(named: "phone")!
    }
  }
  public struct Profile {
    public static var slackLogo: UIImage {
      return UIImage(named: "logo slack")!
    }
    public static var skype: UIImage {
      return UIImage(named: "skype")!
    }
    public static var email: UIImage {
      return UIImage(named: "email")!
    }
  }
}

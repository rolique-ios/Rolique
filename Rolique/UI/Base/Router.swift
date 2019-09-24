//
//  Router.swift
//  UI
//
//  Created by Bohdan Savych on 8/5/19.
//  Copyright © 2019 Bohdan Savych. All rights reserved.
//

import Utils
import Hero

public final class Router {
  static func getLoginViewController() -> LoginViewController<LoginViewModelImpl> {
    return LoginViewController(viewModel: LoginViewModelImpl(loginManager: LoginManagerImpl()))
  }
  
  static func getProfileViewController() -> ProfileViewController<ProfileViewModelImpl> {
    let userService = UserServiceImpl(userManager: UserManagerImpl(), coreDataManager: CoreDataManager<User>())
    return ProfileViewController(viewModel: ProfileViewModelImpl(userService: userService))
  }
  
  static func getColleaguesViewController() -> ColleaguesViewController<ColleaguesViewModelImpl> {
    let userService = UserServiceImpl(userManager: UserManagerImpl(), coreDataManager: CoreDataManager<User>())
    return ColleaguesViewController(viewModel: ColleaguesViewModelImpl(userService: userService))
  }
  
  static func getActionsViewController() -> ActionsViewController<ActionsViewModelImpl> {
    return ActionsViewController(viewModel: ActionsViewModelImpl(actionManager: ActionMangerImpl()))
  }
  
  static func getTabBarController() -> UITabBarController {
    let tabbar = BaseTabBarController()
    let colleagues = UINavigationController(rootViewController: getColleaguesViewController())
    colleagues.tabBarItem = UITabBarItem(title: Strings.NavigationTitle.colleagues, image: Images.TabBar.stats, tag: 0)
    colleagues.hero.isEnabled = true
    Hero.shared.containerColor = Colors.Colleagues.softWhite
    let actions = UINavigationController(rootViewController: getActionsViewController())
    actions.tabBarItem = UITabBarItem(title: Strings.NavigationTitle.actions, image: Images.TabBar.actions, tag: 1)
    tabbar.viewControllers = [colleagues, actions]
    if let userId = UserDefaultsManager.shared.userId, let user = User.getFromCoreData(with: userId) {
      let profile = UINavigationController(rootViewController: getProfileDetailViewController(user: user))
      profile.tabBarItem = UITabBarItem(title: Strings.TabBar.profile, image: Images.TabBar.profile, tag: 2)
      tabbar.viewControllers?.append(profile)
    }
    
    return tabbar
  }
  
  static func getLoginController() -> UIViewController {
    return UINavigationController(rootViewController: Router.getLoginViewController())
  }
  
  public static func getStartViewController() -> UIViewController {
    return UserDefaultsManager.shared.userId == nil ? getLoginController() : getTabBarController()
  }
  
  static func getProfileDetailViewController(user: User) -> ProfileDetailViewController<ProfileDetailViewModelImpl> {
    return ProfileDetailViewController(viewModel: ProfileDetailViewModelImpl(user: user))
  }
}

//
//  Router.swift
//  UI
//
//  Created by Bohdan Savych on 8/5/19.
//  Copyright © 2019 Bohdan Savych. All rights reserved.
//

import Utils

public final class Router {
  static func getLoginViewController() -> LoginViewController<LoginViewModelImpl> {
    return LoginViewController(viewModel: LoginViewModelImpl(loginManager: LoginManagerImpl()))
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
    
    let actions = UINavigationController(rootViewController: getActionsViewController())
    actions.tabBarItem = UITabBarItem(title: Strings.NavigationTitle.actions, image: Images.TabBar.actions, tag: 1)
    
    let calendar = UINavigationController(rootViewController: getCalendarViewController())
    calendar.tabBarItem = UITabBarItem(title: Strings.TabBar.calendar, image: Images.TabBar.calendar, tag: 2)
    
    let profile = UINavigationController(rootViewController: getProfileDetailViewController(user: User.getFromCoreData(with: UserDefaultsManager.shared.userId ?? "")))
    profile.tabBarItem = UITabBarItem(title: Strings.TabBar.profile, image: Images.TabBar.profile, tag: 3)
    
    tabbar.viewControllers = [colleagues, actions, calendar, profile]
    
    return tabbar
  }
  
  static func getLoginController() -> UIViewController {
    return UINavigationController(rootViewController: Router.getLoginViewController())
  }
  
  public static func getStartViewController() -> UIViewController {
    return UserDefaultsManager.shared.userId == nil ? getLoginController() : getTabBarController()
  }
  
  static func getProfileDetailViewController(user: User?) -> ProfileDetailViewController<ProfileDetailViewModelImpl> {
    let userService = UserServiceImpl(userManager: UserManagerImpl(), coreDataManager: CoreDataManager<User>())
    return ProfileDetailViewController(viewModel: ProfileDetailViewModelImpl(userService: userService, user: user))
  }
  
  static func getCalendarViewController() -> CalendarViewController<CalendarViewModelImpl> {
    let userService = UserServiceImpl(userManager: UserManagerImpl(), coreDataManager: CoreDataManager<User>())
    let attendanceManager = AttendanceManagerImpl()
    return CalendarViewController(viewModel: CalendarViewModelImpl(userService: userService, attendanceManager: attendanceManager))
  }
}

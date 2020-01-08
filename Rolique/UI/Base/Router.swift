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
    let vm: LoginViewModelImpl = Root.shared.hardResolve()
    return LoginViewController(viewModel: vm)
  }
  
  static func getActionsViewController() -> ActionsViewController<ActionsViewModelImpl> {
    let vm: ActionsViewModelImpl = Root.shared.hardResolve()
    return ActionsViewController(viewModel: vm)
  }
  
  static func getTabBarController() -> UITabBarController {
    let tabbar = BaseTabBarController()
    
    let colleagues = UINavigationController(rootViewController: getColleaguesViewController(with: .regular, users: []))
    colleagues.tabBarItem = UITabBarItem(title: Strings.NavigationTitle.colleagues, image: R.image.stats(), tag: 0)
    
    let actions = UINavigationController(rootViewController: getActionsViewController())
    actions.tabBarItem = UITabBarItem(title: Strings.NavigationTitle.actions, image: R.image.actions(), tag: 1)
    
    let calendar = UINavigationController(rootViewController: getCalendarViewController())
    calendar.tabBarItem = UITabBarItem(title: Strings.TabBar.calendar, image: R.image.calendar(), tag: 2)
    
    let more = UINavigationController(rootViewController: getMoreViewController())
    more.tabBarItem = UITabBarItem(title: Strings.NavigationTitle.more, image: R.image.more(), tag: 3)
    
    tabbar.viewControllers = [colleagues, actions, calendar, more]
    
    return tabbar
  }
  
  static func getLoginController() -> UIViewController {
    return Router.getLoginViewController()
  }
  
  public static func getStartViewController() -> UIViewController {
    let vc: UIViewController
    if let user = User.getFromCoreData(with: UserDefaultsManager.shared.userId ?? "") {
      Root.shared.registerUserService(with: user)
      vc = getTabBarController()
    } else {
      vc = getLoginController()
    }
    return vc
  }
  
  static func getProfileDetailViewController(user: User) -> ProfileDetailViewController<ProfileDetailViewModelImpl> {
    let vm: ProfileDetailViewModelImpl = Root.shared.resolveRuntime(arg1: user)
    return ProfileDetailViewController(viewModel: vm)
  }
  
  static func getCalendarViewController() -> CalendarViewController<CalendarViewModelImpl> {
    let vm: CalendarViewModelImpl = Root.shared.hardResolve()
    return CalendarViewController(viewModel: vm)
  }
  
  static func getMoreViewController() -> MoreViewController<MoreViewModelImpl> {
    let userService: UserService = Root.shared.hardResolve()
    let vm: MoreViewModelImpl = Root.shared.resolveRuntime(arg1: userService.currentUser)
    return MoreViewController(viewModel: vm)
  }
  
  static func getMeetingRoomsViewController() -> MeetingRoomsViewController<MeetingRoomsViewModelImpl> {
    let vm: MeetingRoomsViewModelImpl = Root.shared.hardResolve()
    return MeetingRoomsViewController(viewModel: vm)
  }
  
  static func getColleaguesViewController(with mode: ColleaguesUIMode, users: [User]) -> ColleaguesViewController<ColleaguesViewModelImpl> {
    let vm: ColleaguesViewModelImpl = Root.shared.resolveRuntime(arg1: users, arg2: mode)
    return ColleaguesViewController(viewModel: vm)
  }
    
  static func getCashTrackerViewController() -> CashTrackerViewController<CashTrackerViewModelImpl> {
    let vm: CashTrackerViewModelImpl = Root.shared.hardResolve()
    return CashTrackerViewController(viewModel: vm)
  }
    
  static func getCashHistoryViewController(balance: Balance, cashOwner: CashOwner) -> CashHistoryViewController<CashHistoryViewModelImpl> {
    return CashHistoryViewController<CashHistoryViewModelImpl>(viewModel: Root.shared.resolveRuntime(arg1: balance, arg2: cashOwner))
  }
}

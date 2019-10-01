//
//  CalendarViewController.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 10/1/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

final class CalendarViewController<T: CalendarViewModel>: ViewController<T>, UIScrollViewDelegate {
  private lazy var scrollView = UIScrollView()
}

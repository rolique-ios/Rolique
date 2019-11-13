//
//  CalendarCollectionView.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/13/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Utils

protocol CalendarCollectionViewDelegate: class {
  func calendarCollectionView(_ calendarCollectionView: CalendarCollectionView, didScrollToMonthWithName monthName: String?)
}

struct CalendarState { var start: Date; var anchor: Date; var end: Date; var selected: Date }

final class CalendarCollectionView: UIView {
  
  private lazy var calendarView = JTAppleCalendarView()
  
  var state: CalendarCollectionViewState = .collapsed
  var calendarState: CalendarState?
  var monthName: String?
  weak var delegate: CalendarCollectionViewDelegate?
  var onSelectDate: ((Date) -> Void)?
  
  private var startDate = Date()
  private var endDate = Date()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureConstraints()
    initialize()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configureConstraints()
    initialize()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    calendarView.reloadData(withanchor: calendarState?.anchor, completionHandler: { })
  }

  func configure(startDate: Date, endDate: Date) {
    self.startDate = startDate
    self.endDate = endDate
    calendarView.reloadData(withanchor: calendarState?.anchor, completionHandler: { })
  }

  private func configureCalendar() {
    calendarView.minimumLineSpacing = 0
    calendarView.minimumInteritemSpacing = 0
    calendarView.allowsMultipleSelection = false
    calendarView.calendarDataSource = self
    calendarView.calendarDelegate = self
    calendarView.backgroundColor = Colors.mainBackgroundColor
    calendarView.scrollDirection = .horizontal
    calendarView.isPagingEnabled = true
  }
  
  private func initialize() {
    calendarView.register([DayCollectionCell.self])
    configureCalendar()
    scrollToToday(animated: false)
  }
  
  private func configureConstraints() {
    [calendarView].forEach(addSubview(_:))
    
    calendarView.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
  }
  
  func setState(_ state: CalendarCollectionViewState) {
    self.state = state
    calendarView.reloadData(withanchor: calendarState?.anchor, completionHandler: { })
  }
  
  func scrollToToday() {
    scrollToToday(animated: true)
  }
 
  func deselectAll() {
    calendarView.deselectAllDates()
  }
  
  private func scrollToToday(animated: Bool) {
    calendarView.scrollToDate(Date().normalized, triggerScrollToDateDelegate: true, animateScroll: animated, preferredScrollPosition: UICollectionView.ScrollPosition.centeredHorizontally, extraAddedOffset: 0, completionHandler: nil)
  }
}

extension CalendarCollectionView: JTAppleCalendarViewDelegate {
  func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
    if let cell = cell as? DayCollectionCell {
      configureCell(cell: cell, cellState: cellState, date: date)
    }
  }
  
  func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
    let cell = calendarView.dequeue(type: DayCollectionCell.self, indexPath: indexPath)
    configureCell(cell: cell, cellState: cellState, date: date)
    return cell
  }
  
  func configureCell(cell: DayCollectionCell, cellState: CellState, date: Date) {
    let config = DayCollectionCellConfig(isToday: date.normalized == Date().normalized, isSelected: cellState.isSelected, isWeekend: cellState.day == .saturday || cellState.day == .sunday, text: cellState.text, isInCurrentMonth: cellState.dateBelongsTo == .thisMonth, cellHeight: cell.bounds.height)
    
    cell.update(config)

  }
  
  func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
    if let cell = cell as? DayCollectionCell {
      configureCell(cell: cell, cellState: cellState, date: date)
    }
    
    if cellState.dateBelongsTo == .thisMonth {
      onSelectDate?(date)
    }
  }
  
  func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
    if let cell = cell as? DayCollectionCell {
      configureCell(cell: cell, cellState: cellState, date: date)
    }
  }
  
  func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
    delegate?.calendarCollectionView(self, didScrollToMonthWithName: getMonthNameFromDateSegmentInfo(visibleDates))
    
    calendarState = CalendarState(start: visibleDates.monthDates.first?.date ?? Date(timeIntervalSince1970: 0), anchor: getAnchorDateFromDateSegmentInfo(visibleDates) ?? Date(timeIntervalSince1970: 0), end: visibleDates.monthDates.last?.date ?? Date(timeIntervalSince1970: 0), selected: calendar.selectedDates.first ?? Date(timeIntervalSince1970: 0))
  }
  
  private func getAnchorDateFromDateSegmentInfo(_ info: DateSegmentInfo) -> Date? {
    if let selected = calendarView.selectedDates.first {
      let foo = info.monthDates.map { $0.date }.contains(selected)
      if foo {
        return selected
      }
    }
    
    var monthName: String
    
    let firstName = info.monthDates.first?.date.monthName() ?? Date().monthName()
    let lastName = info.monthDates.last?.date.monthName() ?? Date().monthName()
    if firstName == lastName { monthName = firstName }
    else {
      let firstCount = info.monthDates.filter({ $0.date.monthName() == firstName }).count
      let lastCount = info.monthDates.filter({ $0.date.monthName() == lastName }).count
      monthName = firstCount >= lastCount ? firstName : lastName
    }
    let refDate = info.monthDates.first(where: { $0.date.monthName() == monthName })?.date
    
    return refDate
  }
  
  private func getMonthNameFromDateSegmentInfo(_ info: DateSegmentInfo) -> String? {
    let firstName = info.monthDates.first?.date.monthName()
    let lastName = info.monthDates.last?.date.monthName()
    if firstName == lastName { return firstName }
    else {
      let firstCount = info.monthDates.filter({ $0.date.monthName() == firstName }).count
      let lastCount = info.monthDates.filter({ $0.date.monthName() == lastName }).count
      return firstCount >= lastCount ? firstName : lastName
    }
  }
}

extension CalendarCollectionView: JTAppleCalendarViewDataSource {
  func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
    let numberOfRows = state == .collapsed ? 1 : 6
    let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    
    let parameters = ConfigurationParameters(
      startDate: startDate,
      endDate: endDate,
      numberOfRows: numberOfRows,
      calendar: calendar,
      generateInDates: state == .collapsed ? .forFirstMonthOnly : .forAllMonths,
      generateOutDates: state == .collapsed ? .off : .tillEndOfGrid,
      firstDayOfWeek: .monday,
      hasStrictBoundaries:state == .collapsed ? false : true)
    
    return parameters
  }
}

//
//  Test0823Tests.swift
//  Test0823Tests
//
//  Created by CFH00591449 on 2023/8/23.
//

import XCTest
//@testable import TDD0823App

final class Test0823Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_查當日() {

        let service = BudgetService(repo: MockBudgetRepo())

        let totalAmount = service.totalAmount(start: "2023-12-01".toDate()!, end: "2023-12-01".toDate()!)

        XCTAssertEqual(totalAmount, 1000)
    }
    
    func test_查當月() {
        let service = BudgetService(repo: MockBudgetRepo())

        let totalAmount = service.totalAmount(start: "2023-12-01".toDate()!, end: "2023-12-31".toDate()!)

        XCTAssertEqual(totalAmount, 31000)
    }
    
    func test_查無資料() {

        let service = BudgetService(repo: MockBudgetRepo())

        let totalAmount = service.totalAmount(start: "2023-11-01".toDate()!, end: "2023-11-01".toDate()!)

        XCTAssertEqual(totalAmount, 0)
    }
    
    func test_查當月部分日() {

        let service = BudgetService(repo: MockBudgetRepo())

        let totalAmount = service.totalAmount(start: "2023-12-01".toDate()!, end: "2023-12-15".toDate()!)

        XCTAssertEqual(totalAmount, 15000)
    }
    
    func test_跨月() {

        let service = BudgetService(repo: MockBudgetRepo())

        let totalAmount = service.totalAmount(start: "2023-04-29".toDate()!, end: "2023-06-10".toDate()!)

        XCTAssertEqual(totalAmount, 31020)
    }

    func test_非法起迄() {
        let service = BudgetService(repo: MockBudgetRepo())

        let totalAmount = service.totalAmount(start: "2023-12-31".toDate()!, end: "2023-12-30".toDate()!)

        XCTAssertEqual(totalAmount, 0)
    }
    
    func test_閏月() {
        let service = BudgetService(repo: MockBudgetRepo())

        let totalAmount = service.totalAmount(start: "2024-02-28".toDate()!, end: "2024-03-01".toDate()!)

        XCTAssertEqual(totalAmount, 2000)
    }

}

class BudgetService {
    let repo: BudgetRepo
    
    init(repo: BudgetRepo) {
        self.repo = repo
    }
    
    func totalAmount(start: Date, end: Date) -> Decimal {
        /// 非法日期
        if start > end {
            return Decimal(0)
        }
        
        let filters = self.filterBudget(start: start, end: end)
        
        // 取每月的一日金額
        var result: Int = 0
        for budget in filters {
            let budget_date = budget.yearMonth.toDate(withFormat: "yyyyMM")!
            // 取天數
            let days = budget_date.daysInMonth()
            /// 此月的每天預算
            let perDay = (budget.amount / days)

            if start.year == budget_date.year && start.month == budget_date.month {
                var end_date = budget_date.lastDateOfMonth
                if end < end_date {
                    end_date = end
                }
                
                let diffDay = start.diffDay(toTime: end_date)!
                let daysamount = (diffDay + 1) * perDay
                result += daysamount
            }
            else if end.year == budget_date.year && end.month == budget_date.month {
                let diffDay = budget_date.firstDateOfMonth.diffDay(toTime: end)!
                let daysamount = (diffDay + 1) * perDay
                result += daysamount
            }
            else {
                result += budget.amount
            }
        }
        return Decimal(result)
    }
    
    /// 篩選預算日期區間
    private func filterBudget(start: Date, end: Date) -> [BudgetModel] {
        let budgets: [BudgetModel] = repo.getAll()
        
        return budgets.filter {
            let budget_date = $0.yearMonth.toDate(withFormat: "yyyyMM")!
            print("\(budget_date.toString("yyyyMMdd"))")
            return budget_date.isBetween(start.firstDateOfMonth, and: end.lastDateOfMonth)
        }
    }
    
}

class BudgetRepo {
    func getAll() -> [BudgetModel]  {
        return []
    }
}

struct BudgetModel {
    let yearMonth: String
    let amount: Int
}

class MockBudgetRepo: BudgetRepo {
    override func getAll() -> [BudgetModel]  {
        return [
            BudgetModel.init(yearMonth: "202304", amount: 300),
            BudgetModel.init(yearMonth: "202305", amount: 30000),
            BudgetModel.init(yearMonth: "202306", amount: 3000),
            BudgetModel.init(yearMonth: "202312", amount: 31000),
            BudgetModel.init(yearMonth: "202402", amount: 29000),
        ]
    }
}

extension String {
    
    func toDate(withFormat format: String = "yyyy-MM-dd")-> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        
        return date
        
    }
}

extension Date {
    
    func daysInMonth(_ monthNumber: Int? = nil, _ year: Int? = nil) -> Int {
        var dateComponents = DateComponents()
        dateComponents.year = year ?? Calendar.current.component(.year,  from: self)
        dateComponents.month = monthNumber ?? Calendar.current.component(.month,  from: self)
        if
            let d = Calendar.current.date(from: dateComponents),
            let interval = Calendar.current.dateInterval(of: .month, for: d),
            let days = Calendar.current.dateComponents([.day], from: interval.start, to: interval.end).day
        { return days } else { return -1 }
    }
    
    func toString(_ format: String = "yyyyMM") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
    
    /// 台灣時區的當年 (西元年)
    var year: Int {
        let calendar = Calendar.current
        let component = calendar.dateComponents([.year], from: self)
        return component.year ?? -1
    }
    
    /// 台灣時區的當月份
    var month: Int {
        let calendar = Calendar.current
        let component = calendar.dateComponents([.month], from: self)
        return component.month ?? -1
    }
    
    /// 台灣時區的當月第一天  00:00 日期 (Date 為絕對值不分時區, 因此回傳值會顯示為 GMT+0 的日期)
    var firstDateOfMonth: Date {
        let calendar = Calendar.current
        let component = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: component) ?? Date()
    }
    
    /// 台灣時區的當月最後一天 00:00 日期 (Date 為絕對值不分時區, 因此回傳值會顯示為 GMT+0 的日期)
    var lastDateOfMonth: Date {
        let calendar = Calendar.current
        var component = calendar.dateComponents([.year, .month, .day], from: self)
        component.day = 0
        component.month! += 1
        return calendar.date(from: component) ?? Date()
    }
    
    func diffDay(toTime: Date, calendar: Calendar = .current) -> Int? {
        let formerTime = calendar.startOfDay(for: self)
        let endTime = calendar.startOfDay(for: toTime)

        return calendar.dateComponents([.day], from: formerTime, to: endTime).day
    }
}

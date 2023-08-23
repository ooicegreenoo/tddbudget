//
//  Test0823Tests.swift
//  Test0823Tests
//
//  Created by CFH00591449 on 2023/8/23.
//

import XCTest
@testable import Test0823

final class Test0823Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_查當月() {
        let service = BudgetService(repo: MockBudgetRepo())

        let totalAmount = service.totalAmount(start: "2023-12-01".toDate()!, end: "2023-12-31".toDate()!)

        XCTAssertEqual(totalAmount, 31000)
    }
    
    func test_查當日() {
        
        
        let service = BudgetService(repo: MockBudgetRepo())
        
        let totalAmount = service.totalAmount(start: "2023-12-01".toDate()!, end: "2023-12-01".toDate()!)
        
        XCTAssertEqual(totalAmount, 1000)
    }

//    func test_非法起迄() {
//        let service = BudgetService()
//
//        let totalAmount = service.totalAmount(start: "2023-12-31".toDate()!, end: "2023-12-30".toDate()!)
//
//        XCTAssertEqual(totalAmount, 0)
//    }
//
//    func test_查無資料() {
//        let service = BudgetService()
//
//        let totalAmount = service.totalAmount(start: "2023-07-01".toDate()!, end: "2023-07-30".toDate()!)
//
//        XCTAssertEqual(totalAmount, 0)
//    }
}

class BudgetService {
    let repo: BudgetRepo
    
    init(repo: BudgetRepo) {
        self.repo = repo
    }
    
    func totalAmount(start: Date, end: Date) -> Decimal {
        let budgets: [BudgetModel] = repo.getAll()
        budgets.filter {
            
        }
        
        // 取每月的一日金額
        
        var result: Int = 0
        for budget in budgets {
            // 取天數
            let days = budget.yearMonth.toDate()!.daysInMonth()
            let perDay = (budget.amount / days)
            
            result += budget.amount
        }
        return Decimal(result)
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
        return [BudgetModel.init(yearMonth: "202312", amount: 31000)]
    }
}

extension String {
    
    func toDate(withFormat format: String = "yyyyMM")-> Date?{
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tehran")
        dateFormatter.locale = Locale(identifier: "fa-IR")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        
        return date
        
    }
}

func firstDayOfMonth(from yearMonth: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM"
    
    if let date = dateFormatter.date(from: yearMonth) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)
    }
    
    return nil
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

}

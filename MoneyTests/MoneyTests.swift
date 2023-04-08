import XCTest
import Money

//final class MoneyTests: XCTestCase {
//    func testAmount() throws {
//        // $5
//        let expr = Expression.amount(Amount(value: 5, commodity: "$"))
//        XCTAssertEqual(try! expr.evaluate(context: [:]), Amount(value: 5, commodity: "$"))
//    }
//    
//    func testAddition() {
//        // 5 + 2
//        let expr = Expression.infixOperator("+", .amount(5), .amount(2))
//        XCTAssertEqual(try! expr.evaluate(context: [:]), 7)
//    }
//    
//    func testNestedAddition() {
//        // 2 * 3 * 2
//        let expr = Expression.infixOperator("+", Expression.infixOperator("+", .amount(2), .amount(3)), .amount(2))
//        XCTAssertEqual(try! expr.evaluate(context: [:]), 7)
//    }
//    
//    func testSubtraction() {
//        // 5 - 2
//        let expr = Expression.infixOperator("-", .amount(5), .amount(2))
//        XCTAssertEqual(try! expr.evaluate(context: [:]), 3)
//    }
//    
//    func testMultiplication() {
//        // 5 * 2
//        let expr = Expression.infixOperator("*", .amount(5), .amount(2))
//        XCTAssertEqual(try! expr.evaluate(context: [:]), 10)
//    }
//    
//    func testMultiplicationWithVariable() {
//        // 10 * numberOfPeople
//        let expr = Expression.infixOperator("*", .amount(10), .identifier("numberOfPeople"))
//        let context: [String: Amount] = ["numberOfPeople": 5]
//        XCTAssertEqual(try! expr.evaluate(context: context), 50)
//    }
//    
//    func testDivision() {
//        // 5 / 2
//        let expr = Expression.infixOperator("/", .amount(5), .amount(2))
//        XCTAssertEqual(try! expr.evaluate(context: [:]), Amount(value: 2.5))
//    }
//    
//    func testIdentifier() {
//        // numberOfPeople
//        let expr = Expression.identifier("numberOfPeople")
//        let context: [String: Amount] = ["numberOfPeople": 5]
//        XCTAssertEqual(try! expr.evaluate(context: context), 5)
//    }
//}

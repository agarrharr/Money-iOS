import XCTest
import Money

extension String: Error {}

typealias LedgerDouble = Double
typealias Commodity = String

struct Amount: Equatable {
    var value: LedgerDouble
    var commodity: Commodity?
    
    init(value: LedgerDouble, commodity: Commodity? = nil) {
        self.value = value
        self.commodity = commodity
    }
}

extension Amount {
    func compute(_ operatorFunction: (LedgerDouble, LedgerDouble) -> LedgerDouble, _ other: Amount) throws -> Amount {
        guard self.commodity == other.commodity else {
            throw "Commodities don't match"
        }
        return Amount(value: operatorFunction(self.value, other.value), commodity: self.commodity)
    }
}

extension Amount: ExpressibleByIntegerLiteral {
    init(integerLiteral value: LedgerDouble) {
        self.value = value
        self.commodity = nil
    }
}

indirect enum Expression {
    case amount(Amount)
    case infixOperator(String, Expression, Expression)
    case identifier(String)
}

extension Expression {
    func evaluate(context: [String: Amount]) throws -> Amount {
        switch self {
        case let .amount(amount):
            return amount
        case let .infixOperator(op, lhs, rhs):
            let operators: [String: (LedgerDouble, LedgerDouble) -> LedgerDouble] = [
                "+": (+),
                "-": (-),
                "*": (*),
                "/": (/)
            ]
            guard let operatorFunction = operators[op] else {
                throw "Undefined operator: \(op)"
            }
            let left = try lhs.evaluate(context: context)
            let right = try rhs.evaluate(context: context)
            return try left.compute(operatorFunction, right)
        case let .identifier(name):
            guard let value = context[name] else {
                throw "Unknown variable: \(name)"
            }
            return value
        }
    }
}

final class MoneyTests: XCTestCase {
    func testAmount() throws {
        // $5
        let expr = Expression.amount(Amount(value: 5, commodity: "$"))
        XCTAssertEqual(try! expr.evaluate(context: [:]), Amount(value: 5, commodity: "$"))
    }
    
    func testAddition() {
        // 5 + 2
        let expr = Expression.infixOperator("+", .amount(5), .amount(2))
        XCTAssertEqual(try! expr.evaluate(context: [:]), 7)
    }
    
    func testNestedAddition() {
        // 2 * 3 * 2
        let expr = Expression.infixOperator("+", Expression.infixOperator("+", .amount(2), .amount(3)), .amount(2))
        XCTAssertEqual(try! expr.evaluate(context: [:]), 7)
    }
    
    func testSubtraction() {
        // 5 - 2
        let expr = Expression.infixOperator("-", .amount(5), .amount(2))
        XCTAssertEqual(try! expr.evaluate(context: [:]), 3)
    }
    
    func testMultiplication() {
        // 5 * 2
        let expr = Expression.infixOperator("*", .amount(5), .amount(2))
        XCTAssertEqual(try! expr.evaluate(context: [:]), 10)
    }
    
    func testMultiplicationWithVariable() {
        // 10 * numberOfPeople
        let expr = Expression.infixOperator("*", .amount(10), .identifier("numberOfPeople"))
        let context: [String: Amount] = ["numberOfPeople": 5]
        XCTAssertEqual(try! expr.evaluate(context: context), 50)
    }
    
    func testDivision() {
        // 5 / 2
        let expr = Expression.infixOperator("/", .amount(5), .amount(2))
        XCTAssertEqual(try! expr.evaluate(context: [:]), Amount(value: 2.5))
    }
    
    func testIdentifier() {
        // numberOfPeople
        let expr = Expression.identifier("numberOfPeople")
        let context: [String: Amount] = ["numberOfPeople": 5]
        XCTAssertEqual(try! expr.evaluate(context: context), 5)
    }
}

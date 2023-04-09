import XCTest
import Parsing
@testable import Money

final class ExpressionParserTests: XCTestCase {
    func test_operator_add() throws {
        let output = try `operator`.parse("+")
        XCTAssertEqual(output, Operator.add)
    }
    func test_operator_subtract() throws {
        let output = try `operator`.parse("-")
        XCTAssertEqual(output, Operator.subtract)
    }
    func test_operator_multiply() throws {
        let output = try `operator`.parse("*")
        XCTAssertEqual(output, Operator.multiply)
    }
    func test_operator_divide() throws {
        let output = try `operator`.parse("/")
        XCTAssertEqual(output, Operator.divide)
    }
    func test_operation_add() throws {
        let output = try operation.parse("1+2")
        XCTAssertEqual(output, Operation(operator: .add, lhs: 1.0, rhs: 2.0))
    }
    func test_operation_subtract() throws {
        let output = try operation.parse("1 -2")
        XCTAssertEqual(output, Operation(operator: .subtract, lhs: 1.0, rhs: 2.0))
    }
    func test_operation_multiply() throws {
        let output = try operation.parse(" 1 * 2   ")
        XCTAssertEqual(output, Operation(operator: .multiply, lhs: 1.0, rhs: 2.0))
    }
    func test_operation_divide() throws {
        let output = try operation.parse("1/   2")
        XCTAssertEqual(output, Operation(operator: .divide, lhs: 1.0, rhs: 2.0))
    }
}

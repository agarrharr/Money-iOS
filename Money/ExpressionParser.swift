import Foundation
import Parsing

// MARK: - Expression

//extension String: Error {}
//
//typealias LedgerDouble = Double
//typealias Commodity = String
//
//public struct Amount: Equatable {
//    var value: LedgerDouble
//    var commodity: Commodity?
//
//    init(value: LedgerDouble, commodity: Commodity? = nil) {
//        self.value = value
//        self.commodity = commodity
//    }
//}
//
//extension Amount {
//    func compute(_ operatorFunction: (LedgerDouble, LedgerDouble) -> LedgerDouble, _ other: Amount) throws -> Amount {
//        guard self.commodity == other.commodity else {
//            throw "Commodities don't match"
//        }
//        return Amount(value: operatorFunction(self.value, other.value), commodity: self.commodity)
//    }
//}
//
//extension Amount: ExpressibleByIntegerLiteral {
//    init(integerLiteral value: LedgerDouble) {
//        self.value = value
//        self.commodity = nil
//    }
//}
//
//indirect enum Expression {
//    case amount(Amount)
//    case infixOperator(String, Expression, Expression)
//    case identifier(String)
//}
//
//extension Expression {
//    func evaluate(context: [String: Amount]) throws -> Amount {
//        switch self {
//        case let .amount(amount):
//            return amount
//        case let .infixOperator(op, lhs, rhs):
//            let operators: [String: (LedgerDouble, LedgerDouble) -> LedgerDouble] = [
//                "+": (+),
//                "-": (-),
//                "*": (*),
//                "/": (/)
//            ]
//            guard let operatorFunction = operators[op] else {
//                throw "Undefined operator: \(op)"
//            }
//            let left = try lhs.evaluate(context: context)
//            let right = try rhs.evaluate(context: context)
//            return try left.compute(operatorFunction, right)
//        case let .identifier(name):
//            guard let value = context[name] else {
//                throw "Unknown variable: \(name)"
//            }
//            return value
//        }
//    }
//}

// MARK: - Operator

public enum Operator {
    case add
    case subtract
    case multiply
    case divide
}

public let `operator` = Parse(input: Substring.self) {
    zeroOrMoreSpaces
    OneOf {
        "+".map { Operator.add }
        "-".map { Operator.subtract }
        "*".map { Operator.multiply }
        "/".map { Operator.divide }
    }
    zeroOrMoreSpaces
}
    .map { _, op, _ in op }

// MARK: - Operation

struct Operation: Equatable {
    var `operator`: Operator
    var lhs: Double
    var rhs: Double
}

let operation = Parse(input: Substring.self) {
    zeroOrMoreSpaces
    Double.parser()
    `operator`
    Double.parser()
    zeroOrMoreSpaces
}
    .map { _, lhs, op, rhs, _ in Operation(operator: op, lhs: lhs, rhs: rhs) }

import SwiftUI
import Parsing
import Foundation

@main
struct MoneyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


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

public enum Operator {
    case add
    case subtract
    case multiply
    case divide
}

let zeroOrMoreSpaces = Parse(input: Substring.self) {
    Prefix { $0 == .init(ascii: " ") }
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

let commodityWithSpaces = Parse(input: Substring.self) {
    "\""
    PrefixUpTo("\"")
    "\""
}
//.map { commodity in commodity }

let commodityWithoutSpaces = Parse(input: Substring.self) {
    Prefix { $0 != " " }
}
//.map { commodity in commodity }

public let commodity = Parse(input: Substring.self) {
    zeroOrMoreSpaces
    OneOf {
        commodityWithSpaces
        commodityWithoutSpaces
    }
}
    .map { _, commodity in String(commodity) }

struct Amount: Equatable {
    var value: Double
    var commodity: String
}

let amountWithCommodityPrefix = Parse(input: Substring.self) {
    zeroOrMoreSpaces
    commodity
    zeroOrMoreSpaces
    Double.parser()
}
    .map { _, commodity, _, value in
        Amount(
            value: value,
            commodity: String(commodity)
        )
    }

let amountWithCommodityPostfix = Parse(input: Substring.self) {
    zeroOrMoreSpaces
    Double.parser()
    zeroOrMoreSpaces
    commodity
}
    .map { _, value, _, commodity in
        Amount(
            value: value,
            commodity: String(commodity)
        )
    }

let amount = Parse(input: Substring.self) {
    OneOf {
        amountWithCommodityPrefix
        amountWithCommodityPostfix
    }
}

public struct Posting: Equatable {
    var account: String
    var amount: Amount
}

let posting = Parse(input: Substring.self) {
    zeroOrMoreSpaces
    Prefix { $0 != " " }
    zeroOrMoreSpaces
    amount
    zeroOrMoreSpaces
}
    .map { _, account, _, amount, _ in
        Posting(
            account: String(account),
            amount: Amount(value: amount.value, commodity: String(amount.commodity))
        )
        
    }

typealias Postings = [Posting]

let postings = Parse(input: Substring.self) {
    posting
    Whitespace(1, .vertical)
    posting
//separator: {
//        "\n"
//    }
}
    .map { p1, p2 in
        [
            Posting(account: p1.account, amount: p1.amount),
            Posting(account: p2.account, amount: p2.amount)
        ]
    }
//    .map { ps in
//        ps.map { p in
//            Posting(account: p.account, amount: p.amount)
//        }
//    }

struct Transaction: Equatable {
    var date: Date
    var payee: String
    var postings: [Posting]
}

let transaction = Parse(input: Substring.self) {
    zeroOrMoreSpaces
    Prefix { $0 != " " }
    zeroOrMoreSpaces
    Prefix { $0 != "\n" }
    zeroOrMoreSpaces
    Whitespace(1, .vertical)
    postings
}
    .map { _, date, _, payee, _, postings in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        return Transaction(
            date: dateFormatter.date(from: String(date))!,
            payee: String(payee),
            postings: postings
        )
        
    }


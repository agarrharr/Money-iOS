import Foundation
import Parsing

// MARK: - Commodity

let commodityWithSpaces = Parse(input: Substring.self) {
    "\""
    PrefixUpTo("\"")
    "\""
}

let commodityWithoutSpaces = Parse(input: Substring.self) {
    // TODO: allow all non-numeric characters, but be careful about allowing dashes if it's in front of the double with no space
    Characters(in: CharacterSet(charactersIn: "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz$"), atLeast: 1)
}

public let commodity = Parse(input: Substring.self) {
    zeroOrMoreSpaces
    OneOf {
        commodityWithSpaces
        commodityWithoutSpaces
    }
}
    .map { _, commodity in String(commodity) }

// MARK: - Amount

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

// MARK: - Posting

public struct Posting: Equatable {
    var account: String
    var amount: Amount?
}

let posting = Parse(input: Substring.self) {
    oneOrMoreSpaces
    Prefix { $0 != " " }
    oneOrMoreSpaces
    amount
    zeroOrMoreSpaces
}
    .map { _, account, _, amount, _ in
        Posting(
            account: String(account),
            amount: Amount(value: amount.value, commodity: String(amount.commodity))
        )
        
    }

// MARK: - Postings

typealias Postings = [Posting]

let postings = Parse(input: Substring.self) {
    posting
    Whitespace(1, .vertical)
    Many {
        posting
    } separator: {
        "\n"
    }
}
    .map { (p1: Posting, ps: [Posting]) in
        [p1] + ps
    }

// MARK: - Transaction

struct Transaction: Equatable {
    var date: Date
    var payee: String
    var postings: [Posting]
}

let transaction = Parse(input: Substring.self) {
    Prefix { $0 != " " }
    oneOrMoreSpaces
    Prefix { $0 != "\n" }
    zeroOrMoreSpaces
    Whitespace(1, .vertical)
    postings
}
    .map { date, _, payee, _, postings in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        return Transaction(
            date: dateFormatter.date(from: String(date))!,
            payee: String(payee),
            postings: postings
        )
        
    }

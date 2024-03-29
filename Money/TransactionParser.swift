import Foundation
import Parsing

// MARK: - Comment

typealias Comment = String

let comment = Parse(input: Substring.self) {
    Skip { zeroOrMoreSpaces }
    OneOf {
        ";"
        "#"
        "%"
        "|"
        "*"
    }
    " "
    Prefix { $0 != "\n" }
}
    .map { comment in String(comment) }

// MARK: - Commodity

public typealias Commodity = String

let everythingInQuotes = Parse(input: Substring.self) {
    // TODO: Allow escaping quotes (and backslash) with a backslash
    "\""
    PrefixUpTo("\"")
    "\""
}

let commodityWithoutSpaces = Parse(input: Substring.self) {
    // TODO: Should it allow dashes?
    Prefix { !["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", " ", "\n"].contains($0) }
}

public let commodity = Parse(input: Substring.self) {
    Skip { zeroOrMoreSpaces }
    OneOf {
        everythingInQuotes
        commodityWithoutSpaces
    }
}
    .map { commodity in String(commodity) }

// MARK: - Amount

struct Amount: Equatable {
    var value: Double
    var commodity: Commodity
}

let amount = Parse(input: Substring.self) {
    Skip { zeroOrMoreSpaces }
    commodity
    Skip { zeroOrMoreSpaces }
    Double.parser()
    Skip { zeroOrMoreSpaces }
    commodity
}
    .map { prefixCommodity, value, postfixCommodity in
        let commodity = prefixCommodity != "" ? String(prefixCommodity)
        : String(postfixCommodity)
        
        return Amount(
            value: value,
            commodity: commodity
        )
    }

// MARK: - Posting

public struct Posting: Equatable {
    var account: String
    var amount: Amount?
}

let postingWithAmount = Parse(input: Substring.self) {
    Skip { oneOrMoreSpaces }
    Prefix { $0 != " " }
    Skip { oneOrMoreSpaces }
    amount
    Skip { zeroOrMoreSpaces }
}
    .map { account, amount in
        Posting(
            account: String(account),
            amount: Amount(value: amount.value, commodity: String(amount.commodity))
        )
        
    }

let postingWithoutAmount = Parse(input: Substring.self) {
    Skip { oneOrMoreSpaces }
    Prefix { $0 != " " }
    Skip { zeroOrMoreSpaces }
}
    .map { account in
        Posting(
            account: String(account),
            amount: nil
        )
        
    }

let posting = Parse(input: Substring.self) {
    OneOf {
        postingWithAmount
        postingWithoutAmount
        
    }
}

// MARK: - Postings

typealias Postings = [Posting]

let postings = Parse(input: Substring.self) {
    posting
    Whitespace(1, .vertical)
    Many {
        posting
    } separator: {
        Whitespace(1, .vertical)
    }
}
    .map { (p1: Posting, ps: [Posting]) in
        var postings = [p1] + ps
        
        var postingsMissingAmount = [Int]()
        var commodity: Commodity? = nil
        var commoditiesAreAllEqual = true
        
        let total: Double = postings
            .enumerated()
            .reduce(0.0) { result, posting -> Double in
                let postingIndex = posting.0
                let postingValue = posting.1
                if let amount = postingValue.amount {
                    if let commodity {
                        if amount.commodity != commodity {
                            commoditiesAreAllEqual = false
                        }
                    } else {
                        commodity = amount.commodity
                    }
                    return result + (postingValue.amount?.value ?? 0.0)
                } else {
                    postingsMissingAmount.append(postingIndex)
                }
                return result
            }
        
//        if postingsMissingAmount.count > 1 {
//            throw "More than one posting is missing an amount."
//        }
//        guard let commodity else {
//            throw "Transaction is missing commodities"
//        }
        if let commodity {
            if postingsMissingAmount.count == 1 && commoditiesAreAllEqual {
                postings[postingsMissingAmount[0]].amount =
                Amount(
                    value: -1 * total,
                    commodity: commodity
                )
            }
        }
        
        return postings
    }

// MARK: - Transaction

struct Transaction: Equatable {
    var date: Date
    var payee: String
    var postings: [Posting]
}

let transaction = Parse(input: Substring.self) {
    Prefix { $0 != " " }
    Skip { oneOrMoreSpaces }
    Prefix { $0 != "\n" }
    Skip { zeroOrMoreSpaces }
    Whitespace(1, .vertical)
    postings
}
    .map { date, payee, postings in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        return Transaction(
            date: dateFormatter.date(from: String(date))!,
            payee: String(payee),
            postings: postings
        )
        
    }

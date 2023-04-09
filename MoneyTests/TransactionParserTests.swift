import XCTest
import Parsing
@testable import Money

final class TransactionParserTests: XCTestCase {
    // MARK: - Commodity
    
    func test_commodity_withUSD() throws {
        let usdCommodity = "  $"
        let expectedCommodity = "$"
        let output = try commodity.parse(usdCommodity)
        XCTAssertEqual(output, expectedCommodity)
    }
    
    func test_commodity_withStocks() throws {
        let stockCommodity = "  Stocks"
        let expectedCommodity = "Stocks"
        let output = try commodity.parse(stockCommodity)
        XCTAssertEqual(output, expectedCommodity)
    }
    
    func test_commodity_withSpaces() throws {
        let stockCommodity = "\"IBM Stocks\""
        let expectedCommodity = "IBM Stocks"
        let output = try commodity.parse(stockCommodity)
        XCTAssertEqual(output, expectedCommodity)
    }
    
    // MARK: - Amount
    
    func test_account_withUSDPrefix() throws {
        let usdAmount = "  $40"
        let expectedAmount = Amount(value: 40.0, commodity: "$")
        let output = try amount.parse(usdAmount)
        XCTAssertEqual(output, expectedAmount)
    }
    
    func test_account_withUSDPrefixWithSpace() throws {
        let usdAmount = "  $ 40"
        let expectedAmount = Amount(value: 40.0, commodity: "$")
        let output = try amount.parse(usdAmount)
        XCTAssertEqual(output, expectedAmount)
    }
    
    func test_account_withUSDPostfix() throws {
        let usdAmount = "  40$"
        let expectedAmount = Amount(value: 40.0, commodity: "$")
        let output = try amount.parse(usdAmount)
        XCTAssertEqual(output, expectedAmount)
    }
    
    func test_account_withUSDPostfixWithSpace() throws {
        let usdAmount = "  40 $"
        let expectedAmount = Amount(value: 40.0, commodity: "$")
        let output = try amount.parse(usdAmount)
        XCTAssertEqual(output, expectedAmount)
    }
    
    func test_account_withNegativeUSDPrefix() throws {
        let usdAmount = "  $-40"
        let expectedAmount = Amount(value: -40.0, commodity: "$")
        let output = try amount.parse(usdAmount)
        XCTAssertEqual(output, expectedAmount)
    }
    
    func test_account_withNegativeUSDPrefixWithSpace() throws {
        let usdAmount = "  $-40"
        let expectedAmount = Amount(value: -40.0, commodity: "$")
        let output = try amount.parse(usdAmount)
        XCTAssertEqual(output, expectedAmount)
    }
    
    func test_account_withNegativeUSDPostfix() throws {
        let usdAmount = "  -40$"
        let expectedAmount = Amount(value: -40.0, commodity: "$")
        let output = try amount.parse(usdAmount)
        XCTAssertEqual(output, expectedAmount)
    }
    
    func test_account_withNegativeUSDPostfixWithSpace() throws {
        let usdAmount = "  -40 $"
        let expectedAmount = Amount(value: -40.0, commodity: "$")
        let output = try amount.parse(usdAmount)
        XCTAssertEqual(output, expectedAmount)
    }
    func test_account_withStocks() throws {
        let stockAmount = "  40.0  Stocks"
        let expectedAmount = Amount(value: 40.0, commodity: "Stocks")
        let output = try amount.parse(stockAmount)
        XCTAssertEqual(output, expectedAmount)
    }
    
    // MARK: - Posting
    
    func test_posting_withUSD() throws {
        let foodPosting = """
         Expenses:Food                $20.00
        """
        let expectedPosting = Posting(
            account: "Expenses:Food",
            amount: Amount(value: 20.0, commodity: "$")
        )
        let output = try posting.parse(foodPosting)
        XCTAssertEqual(output, expectedPosting)
    }
        
    func test_posting_mustHaveAtLeastOneLeadingSpace() throws {
        let foodPosting = """
        Expenses:Food                $20.00
        """
        XCTAssertThrowsError(
            try posting.parse(foodPosting),
            """
            1 | Expenses:Food                $20.00
              | ^ expected " ""
            """
        )
    }

    // MARK: - Postings
    
    func test_postings_withUSD() throws {
        let foodPostings = """
         Expenses:Food                $20.00
         Assets:Cash                 $-20.00
        """
        let expectedPostings = [
            Posting(
                account: "Expenses:Food",
                amount: Amount(value: 20.0, commodity: "$")
            ),
            Posting(
                account: "Assets:Cash",
                amount: Amount(value: -20.0, commodity: "$")
            ),
        ]
        let output = try postings.parse(foodPostings)
        XCTAssertEqual(output, expectedPostings)
    }
    
    // MARK: - Transaction
    
    func test_transaction_basic() throws {
        let foodTransaction = """
        2012-03-10 KFC
            Expenses:Food                $20.00
            Assets:Cash                 $-20.00
        """
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        let expectedTransaction = Transaction(
            date: dateFormatter.date(from: "2012-03-10")!,
            payee: "KFC",
            postings: [
                Posting(account: "Expenses:Food", amount: Amount(value: 20.0, commodity: "$")),
                Posting(account: "Assets:Cash", amount: Amount(value: -20.0, commodity: "$")),
            ]
        )
        let output = try transaction.parse(foodTransaction)
        XCTAssertEqual(output, expectedTransaction)
    }
    
    func test_transaction_postingsMustHaveAtLeastOneLeadingSpace() throws {
        let foodTransaction = """
        2012-03-10 KFC
        Expenses:Food                $20.00
        Assets:Cash                 $-20.00
        """
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        
        XCTAssertThrowsError(
            try transaction.parse(foodTransaction),
            """
            2 | Expenses:Food                $20.00
              | ^ expected " ""
            """
        )
    }
    
//    func test_transaction_basicWithBlankAmount() throws {
//        let foodTransaction = """
//        2012-03-10 KFC
//            Expenses:Food                $20.00
//            Assets:Cash
//        """
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-mm-dd"
//        let expectedTransaction = Transaction(
//            date: dateFormatter.date(from: "2012-03-10")!,
//            payee: "KFC",
//            postings: [
//                Posting(account: "Expenses:Food", amount: Amount(value: 20.0, commodity: "$")),
//                Posting(account: "Assets:Cash", amount: Amount(value: -20.0, commodity: "$")),
//            ]
//        )
//        let output = try transaction.parse(foodTransaction)
//        XCTAssertEqual(output, expectedTransaction)
//    }
//
//    func test_transaction_withEffectiveDate() throws {
//        let foodTransaction = """
//        2012-03-10=2012-03-12 KFC
//            Expenses:Food                $ 20.00
//            Assets:Cash                 $ -20.00
//        """
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-mm-dd"
//        let expectedTransaction = Transaction(
//            date: dateFormatter.date(from: "2012-03-10")!,
//            effectiveDate: dateFormatter.date(from: "2012-03-12")!,
//            payee: "KFC",
//            postings: [
//                Posting(account: "Expenses:Food", amount: Amount(value: 20.0, commodity: "$")),
//                Posting(account: "Assets:Cash", amount: Amount(value: -20.0, commodity: "$")),
//            ]
//        )
//        let output = try transaction.parse(foodTransaction)
//        XCTAssertEqual(output, expectedTransaction)
//    }
//
//    func test_transaction_cleared() throws {
//        let foodTransaction = """
//        2012-03-10 * KFC
//            Expenses:Food                $ 20.00
//            Assets:Cash                 $ -20.00
//        """
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-mm-dd"
//        let expectedTransaction = Transaction(
//            date: dateFormatter.date(from: "2012-03-10")!,
//            effectiveDate: dateFormatter.date(from: "2012-03-12")!,
//            status: .cleared,
//            payee: "KFC",
//            postings: [
//                Posting(account: "Expenses:Food", amount: Amount(value: 20.0, commodity: "$")),
//                Posting(account: "Assets:Cash", amount: Amount(value: -20.0, commodity: "$")),
//            ]
//        )
//        let output = try transaction.parse(foodTransaction)
//        XCTAssertEqual(output, expectedTransaction)
//    }
//
//    func test_transaction_pending() throws {
//        let foodTransaction = """
//        2012-03-10 ! KFC
//            Expenses:Food                $ 20.00
//            Assets:Cash                 $ -20.00
//        """
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-mm-dd"
//        let expectedTransaction = Transaction(
//            date: dateFormatter.date(from: "2012-03-10")!,
//            effectiveDate: dateFormatter.date(from: "2012-03-12")!,
//            status: .pending,
//            payee: "KFC",
//            postings: [
//                Posting(account: "Expenses:Food", amount: Amount(value: 20.0, commodity: "$")),
//                Posting(account: "Assets:Cash", amount: Amount(value: -20.0, commodity: "$")),
//            ]
//        )
//        let output = try transaction.parse(foodTransaction)
//        XCTAssertEqual(output, expectedTransaction)
//    }
//
//    func test_transaction_withCode() throws {
//        let foodTransaction = """
//        2012-03-10 * (ABC123) KFC
//            Expenses:Food                $ 20.00
//            Assets:Cash                 $ -20.00
//        """
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-mm-dd"
//        let expectedTransaction = Transaction(
//            date: dateFormatter.date(from: "2012-03-10")!,
//            effectiveDate: dateFormatter.date(from: "2012-03-12")!,
//            status: .cleared,
//            code: "ABC123",
//            payee: "KFC",
//            postings: [
//                Posting(account: "Expenses:Food", amount: Amount(value: 20.0, commodity: "$")),
//                Posting(account: "Assets:Cash", amount: Amount(value: -20.0, commodity: "$")),
//            ]
//        )
//        let output = try transaction.parse(foodTransaction)
//        XCTAssertEqual(output, expectedTransaction)
//    }
//
//    func test_transaction_withNote() throws {
//        let foodTransaction = """
//        2012-03-10 * KFC ; Note about this transaction
//            Expenses:Food                $ 20.00
//            Assets:Cash                 $ -20.00
//        """
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-mm-dd"
//        let expectedTransaction = Transaction(
//            date: dateFormatter.date(from: "2012-03-10")!,
//            effectiveDate: dateFormatter.date(from: "2012-03-12")!,
//            status: .cleared,
//            payee: "KFC",
//            note: "Note about this transaction",
//            postings: [
//                Posting(account: "Expenses:Food", amount: Amount(value: 20.0, commodity: "$")),
//                Posting(account: "Assets:Cash", amount: Amount(value: -20.0, commodity: "$")),
//            ]
//        )
//        let output = try transaction.parse(foodTransaction)
//        XCTAssertEqual(output, expectedTransaction)
//    }
}

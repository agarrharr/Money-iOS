import Foundation
import Parsing

// MARK: - Helper Parsers

public let oneOrMoreSpaces = Parse(input: Substring.self) {
    " "
    Prefix { $0 == .init(ascii: " ") }
}

public let zeroOrMoreSpaces = Parse(input: Substring.self) {
    Prefix { $0 == .init(ascii: " ") }
}

public struct Characters: Parser {
    struct MinimumNotReachedError: Error {}

    let characterSet: CharacterSet
    let minimum: Int
    let maximum: Int

    public init(
      in characterSet: CharacterSet,
      atLeast minimum: Int = 0,
      atMost maximum: Int = .max
    ) {
      self.characterSet = characterSet
      self.minimum = minimum
      self.maximum = maximum
    }

    public func parse(_ input: inout Substring) throws -> Substring {
      let original = input
      var output: Substring.UnicodeScalarView = .init()

      while output.count < maximum, !input.unicodeScalars.isEmpty, self.characterSet.contains(input.unicodeScalars.first!) {
        output.append(input.unicodeScalars.removeFirst())
      }

      guard output.count >= minimum else {
        input = original
        throw MinimumNotReachedError()
      }

      return Substring(output)
    }
  }

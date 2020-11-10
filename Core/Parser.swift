
public struct Parser<Output> {
    public let run: (inout Substring) -> Output?
    public init(run: @escaping (inout Substring) -> Output?) {
        self.run = run
    }
}

extension Parser {
    public func run(_ input: String) -> (match: Output?, rest: Substring) {
        var input = input[...]
        let match = self.run(&input)
        return (match, input)
    }
}

extension Parser where Output == Int {
    public static let int = Self { input in
        let original = input
        
        let sign: Int
        if input.first == "-" {
            sign = -1
            input.removeFirst()
        } else if input.first == "+" {
            sign = 1
            input.removeFirst()
        } else {
            sign = 1
        }
        
        let intPrefix = input.prefix(while: \.isNumber)
        guard let match = Int(intPrefix)
        else {
            input = original
            return nil
        }
        input.removeFirst(intPrefix.count)
        return match * sign
    }
}

extension Parser where Output == Double {
    public static let double = Self { input in
        let original = input
        let sign: Double
        if input.first == "-" {
            sign = -1
            input.removeFirst()
        } else if input.first == "+" {
            sign = 1
            input.removeFirst()
        } else {
            sign = 1
        }
        
        var decimalCount = 0
        let prefix = input.prefix { char in
            if char == "." { decimalCount += 1 }
            return char.isNumber || (char == "." && decimalCount <= 1)
        }
        
        guard let match = Double(prefix)
        else {
            input = original
            return nil
        }
        
        input.removeFirst(prefix.count)
        
        return match * sign
    }
}

extension Parser where Output == Character {
    public static let char = Self { input in
        guard !input.isEmpty else { return nil }
        return input.removeFirst()
    }
}

extension Parser {
    public static func always(_ output: Output) -> Self {
        Self { _ in output }
    }
    
    public static var never: Self {
        Self { _ in nil }
    }
}

extension Parser {
    public func map<NewOutput>(_ f: @escaping (Output) -> NewOutput) -> Parser<NewOutput> {
        .init { input in
            self.run(&input).map(f)
        }
    }
}

extension Parser {
    public func flatMap<NewOutput>(
        _ f: @escaping (Output) -> Parser<NewOutput>
    ) -> Parser<NewOutput> {
        .init { input in
            let original = input
            let output = self.run(&input)
            let newParser = output.map(f)
            guard let newOutput = newParser?.run(&input) else {
                input = original
                return nil
            }
            return newOutput
        }
    }
}

public func zip<Output1, Output2>(
    _ p1: Parser<Output1>,
    _ p2: Parser<Output2>
) -> Parser<(Output1, Output2)> {
    
    .init { input -> (Output1, Output2)? in
        let original = input
        guard let output1 = p1.run(&input) else { return nil }
        guard let output2 = p2.run(&input) else {
            input = original
            return nil
        }
        return (output1, output2)
    }
}

public func zip<A, B, C>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>
) -> Parser<(A, B, C)> {
    zip(a, zip(b, c))
        .map { a, bc in (a, bc.0, bc.1) }
}
public func zip<A, B, C, D>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>,
    _ d: Parser<D>
) -> Parser<(A, B, C, D)> {
    zip(a, zip(b, c, d))
        .map { a, bcd in (a, bcd.0, bcd.1, bcd.2) }
}
public func zip<A, B, C, D, E>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>,
    _ d: Parser<D>,
    _ e: Parser<E>
) -> Parser<(A, B, C, D, E)> {
    zip(a, zip(b, c, d, e))
        .map { a, bcde in (a, bcde.0, bcde.1, bcde.2, bcde.3) }
}

extension Parser {
    public static func oneOf(_ ps: [Self]) -> Self {
        .init { input in
            for p in ps {
                if let match = p.run(&input) {
                    return match
                }
            }
            return nil
        }
    }
    
    public static func oneOf(_ ps: Self...) -> Self {
        self.oneOf(ps)
    }
}

extension Parser {
    public func zeroOrMore(
        separatedBy separator: Parser<Void> = ""
    ) -> Parser<[Output]> {
        Parser<[Output]> { input in
            var rest = input
            var matches: [Output] = []
            while let match = self.run(&input) {
                rest = input
                matches.append(match)
                if separator.run(&input) == nil {
                    return matches
                }
            }
            input = rest
            return matches
        }
    }
}

extension Parser where Output == Void {
    public static func prefix(_ p: String) -> Self {
        Self { input in
            guard input.hasPrefix(p) else { return nil }
            input.removeFirst(p.count)
            return ()
        }
    }
}

extension Parser where Output == Substring {
    public static func prefix(while p: @escaping (Character) -> Bool) -> Self {
        Self { input in
            let output = input.prefix(while: p)
            input.removeFirst(output.count)
            return output
        }
    }
    
    public static func prefix(upTo substring: Substring) -> Self {
        Self { input in
            guard let endIndex = input.range(of: substring)?.lowerBound
            else { return nil }
            
            let match = input[..<endIndex]
            
            input = input[endIndex...]
            
            return match
        }
    }
    
    public static func prefix(through substring: Substring) -> Self {
        Self { input in
            guard let endIndex = input.range(of: substring)?.upperBound
            else { return nil }
            
            let match = input[..<endIndex]
            
            input = input[endIndex...]
            
            return match
        }
    }
}

extension Parser: ExpressibleByUnicodeScalarLiteral where Output == Void {
    public typealias UnicodeScalarLiteralType = StringLiteralType
}

extension Parser: ExpressibleByExtendedGraphemeClusterLiteral where Output == Void {
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
}

extension Parser: ExpressibleByStringLiteral where Output == Void {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self = .prefix(value)
    }
}

extension Parser /*Output*/ {
  public func skip<B>(_ p: Parser<B>) -> Self {
    zip(self, p).map { a, _ in a }
  }
}

extension Parser {
    public func take<NewOutput>(_ p: Parser<NewOutput>) -> Parser<(Output, NewOutput)> {
        zip(self, p)
    }
}

precedencegroup ForwardApplication {
  associativity: left
  higherThan: AssignmentPrecedence
}

precedencegroup ForwardComposition {
  higherThan: ForwardApplication, EffectfulComposition
  associativity: right
}

precedencegroup SingleTypeComposition {
  associativity: left
  higherThan: ForwardApplication
}

infix operator |>: ForwardApplication
public func |> <A, B>(x: A, f: (A) -> B) -> B {
  return f(x)
}

infix operator >>>: ForwardComposition
public func >>> <A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> ((A) -> C) {
  return { a in g(f(a)) }
}

precedencegroup EffectfulComposition {
  associativity: left
  higherThan: ForwardApplication
}

infix operator >=>: EffectfulComposition

public func >=> <A, B, C>(
  _ f: @escaping (A) -> (B, [String]),
  _ g: @escaping (B) -> (C, [String])
  ) -> ((A) -> (C, [String])) {

  return { a in
    let (b, logs) = f(a)
    let (c, moreLogs) = g(b)
    return (c, logs + moreLogs)
  }
}

infix operator <>: SingleTypeComposition


public func <> <A>(
    _ f: @escaping (A) -> A,
    _ g: @escaping (A) -> A
    ) -> (A) -> A {
    return f >>> g
}

public func <> <A>(
    _ f: @escaping (inout A) -> Void,
    _ g: @escaping (inout A) -> Void
    ) -> (inout A) -> Void {
    { a in
        f(&a)
        g(&a) }
}

public func <> <A: AnyObject>( // any object that all referenecs types
    _ f: @escaping (A) -> Void,
    _ g: @escaping (A) -> Void
    ) -> (inout A) -> Void {
    { a in
        f(a)
        g(a) }
}

public func <> <A: AnyObject>(f: @escaping (A) -> Void, g: @escaping (A) -> Void) -> (A) -> Void {
  return { a in
    f(a)
    g(a)
  }
}

public func |> <A>(a: inout A, f: (inout A) -> Void) {
  f(&a)
}

public func id<A>(_ a: A) -> A { a }

func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
    return { $0.map(f) }
}

public func prop<Root, Value>(_ kp: WritableKeyPath<Root, Value>)
  -> (@escaping (Value) -> Value)
  -> (Root)
  -> Root {

  return { update in
    { root in
      var copy = root
      copy[keyPath: kp] = update(copy[keyPath: kp])
      return copy
    }
  }
}

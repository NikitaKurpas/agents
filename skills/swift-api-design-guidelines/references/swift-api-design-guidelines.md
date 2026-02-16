# Swift API Design Guidelines (Clean Markdown)

## Introduction

Deliver a clear, consistent developer experience when writing Swift code. API names and idioms should feel native to Swift.

## Fundamentals

- **Clarity at the point of use is the primary goal.**
  - Declarations are written once; call sites are read many times.
- **Clarity is more important than brevity.**
  - Concision is good only when meaning is preserved.
- **Write a documentation comment for every declaration.**
  - If you cannot describe behavior simply, the API may be wrong.

### Documentation-comment guidance

- Use Swift-flavored Markdown.
- Start with a concise summary.
- Prefer sentence fragments over full prose when possible.
- Describe:
  - methods/functions by what they do/return
  - subscripts by what they access
  - initializers by what they create
  - other declarations by what they are

```swift
/// Returns a view of `self` with elements in reverse order.
func reversed() -> ReverseCollection<Self>

/// Inserts `newHead` at the beginning of `self`.
mutating func prepend(_ newHead: Int)

/// Removes and returns the first element if non-empty; otherwise nil.
mutating func popFirst() -> Element?

/// Accesses the `index`th element.
subscript(index: Int) -> Element { get set }

/// Creates an instance containing `n` repetitions of `x`.
init(count n: Int, repeatedElement x: Element)
```

- Use recognized symbol commands when useful (`Parameter`, `Returns`, `Throws`, `Note`, `SeeAlso`, etc.).

## Naming

### Promote Clear Usage

- **Include all words needed to avoid ambiguity.**

```swift
employees.remove(at: x) // clear
employees.remove(x)     // ambiguous: value or position?
```

- **Omit needless words.**
  - Remove words that repeat type information.

```swift
public mutating func remove(_ member: Element) -> Element?
allViews.remove(cancelButton)
```

- **Name by role, not by type.**

```swift
var greeting = "Hello"

protocol ViewController {
  associatedtype ContentView: View
}

class ProductionLine {
  func restock(from supplier: WidgetFactory)
}
```

- **Compensate for weak type information.**
  - For `Any`, `AnyObject`, `NSObject`, `String`, `Int`, etc., include role nouns.

```swift
func addObserver(_ observer: NSObject, forKeyPath path: String)
grid.addObserver(self, forKeyPath: graphics)
```

### Strive for Fluent Usage

- **Prefer names that form grammatical English at call sites.**

```swift
x.insert(y, at: z)
x.subviews(havingColor: y)
x.capitalizingNouns()
```

- **Begin factory methods with `make`.**

```swift
x.makeIterator()
```

- **Do not force first initializer/factory argument into an awkward phrase.**

```swift
let color = Color(red: 32, green: 64, blue: 128)
let part = factory.makeWidget(gears: 42, spindles: 14)
```

- **Name methods according to side effects.**
  - Nonmutating methods: noun phrases.
  - Mutating methods: imperative verb phrases.

- **Use consistent mutating/nonmutating pairs.**

| Mutating | Nonmutating |
|---|---|
| `x.sort()` | `x.sorted()` |
| `x.append(y)` | `x.appending(y)` |
| `y.formUnion(z)` | `y.union(z)` |

- **Boolean methods/properties should read as assertions.**

```swift
x.isEmpty
line1.intersects(line2)
```

- **Protocol naming**
  - "What something is": noun (`Collection`)
  - "Capability": `able` / `ible` / `ing` suffixes (`Equatable`, `ProgressReporting`)

- Types/properties/variables/constants should read as nouns.

### Use Terminology Well

- Avoid obscure terms when common terms are equally precise.
- If using a term of art, use its established meaning.
- Avoid non-standard abbreviations.
- Embrace strong precedent (`Array`, `sin(x)`) instead of over-explaining names.

## Conventions

### General Conventions

- Document complexity for computed properties that are not `O(1)`.
- Prefer methods/properties over free functions, except:
  1. No obvious `self` (`min(x, y)`)
  2. Unconstrained generic helper (`print(x)`)
  3. Established domain notation (`sin(x)`)
- Follow case conventions:
  - Types/protocols: `UpperCamelCase`
  - Other symbols: `lowerCamelCase`
- Handle acronyms consistently (`UTF8`, `ASCII`, `utf8Bytes`).
- Methods can share a base name if semantics match or domains are distinct.
- Avoid overloading only by return type.

```swift
// Avoid
func value() -> Int?
func value() -> String?
```

### Parameters

- Choose parameter names that make docs read naturally.

```swift
/// Return elements that satisfy `predicate`.
func filter(_ predicate: (Element) -> Bool) -> [Element]

/// Replace `subRange` with `newElements`.
mutating func replaceRange(_ subRange: Range<Int>, with newElements: [Element])
```

- Use defaulted parameters when one value is usually used.
- Prefer a single method with defaults over many overload-family variants.
- Place defaulted parameters near the end.
- For production APIs, prefer `#fileID` over alternatives:
  - `#fileID`: compact + privacy-safe
  - `#filePath`: useful for test/scripts or path-dependent workflows
  - `#file`: for compatibility with Swift 5.2 and earlier

### Argument Labels

- Omit labels when arguments cannot be usefully distinguished.

```swift
min(number1, number2)
zip(sequence1, sequence2)
```

- In value-preserving conversion initializers, omit first label.

```swift
Int64(someUInt32)
String(veryLargeNumber, radix: 16)
```

- In narrowing conversions, use clarifying labels.

```swift
init(truncating source: UInt64)
init(saturating valueToApproximate: UInt64)
```

- If first argument is part of a prepositional phrase, keep a label.

```swift
x.removeBoxes(havingLength: 12)
```

- If first argument is part of the grammatical phrase, omit first label and merge phrase into base name.

```swift
x.addSubview(y)
```

- If omitting a label causes ambiguity, keep labels.

```swift
view.dismiss(animated: false)
words.split(maxSplits: 12)
students.sorted(isOrderedBefore: Student.namePrecedes)
```

- Label all other arguments.

## Special Instructions

- Label tuple members and name closure parameters when exposed in API surfaces.

```swift
mutating func ensureUniqueStorage(
  minimumCapacity requestedCapacity: Int,
  allocate: (_ byteCount: Int) -> UnsafeRawPointer
) -> (reallocated: Bool, capacityChanged: Bool)
```

- Use extra care with unconstrained polymorphism (`Any`, `AnyObject`, unconstrained generics) to avoid overload ambiguity.

```swift
// Better than ambiguous overload pair:
append(_ newElement: Element)
append(contentsOf newElements: S) where S.Element == Element
```

## Practical Review Checklist

Use this when reviewing Swift APIs:

1. Read real call sites, not declarations only.
2. Confirm each name communicates role and side effect.
3. Verify mutating/nonmutating pairs are systematic.
4. Check first-argument labeling against conversion/preposition/grammar rules.
5. Detect ambiguous overload families.
6. Verify docs still match final signatures.

import 'package:dartpad_lite/core/services/ai/ai_response.dart';

final withCodeResponse = """
  ```swift
import Foundation

func romanToInt(_ s: String) -> Int {
    let romanMap: [Character: Int] = [
        "I": 1,
        "V": 5,
        "X": 10,
        "L": 50,
        "C": 100,
        "D": 500,
        "M": 1000
    ]

    var result = 0
    var prevValue = 0

    for char in s.reversed() {
        guard let currentValue = romanMap[char] else {
            return -1 // Invalid Roman numeral character. Handle error appropriately in a real-world scenario.
        }

        if currentValue < prevValue {
            result -= currentValue
        } else {
            result  = currentValue
        }

        prevValue = currentValue
    }

    return result
}

// MARK: - Example Usage

let romanNumeral1 = "III"
let integerValue1 = romanToInt(romanNumeral1)
print("\(romanNumeral1) = \(integerValue1)") // Output: III = 3

let romanNumeral2 = "IV"
let integerValue2 = romanToInt(romanNumeral2)
print("\(romanNumeral2) = \(integerValue2)") // Output: IV = 4

let romanNumeral3 = "IX"
let integerValue3 = romanToInt(romanNumeral3)
print("\(romanNumeral3) = \(integerValue3)") // Output: IX = 9

let romanNumeral4 = "LVIII"
let integerValue4 = romanToInt(romanNumeral4)
print("\(romanNumeral4) = \(integerValue4)") // Output: LVIII = 58

let romanNumeral5 = "MCMXCIV"
let integerValue5 = romanToInt(romanNumeral5)
print("\(romanNumeral5) = \(integerValue5)") // Output: MCMXCIV = 1994

let romanNumeral6 = "MMXXIII"
let integerValue6 = romanToInt(romanNumeral6)
print("\(romanNumeral6) = \(integerValue6)") // Output: MMXXIII = 2023

let romanNumeral7 = "C"
let integerValue7 = romanToInt(romanNumeral7)
print("\(romanNumeral7) = \(integerValue7)") // Output: C = 100

let romanNumeral8 = "M"
let integerValue8 = romanToInt(romanNumeral8)
print("\(romanNumeral8) = \(integerValue8)") // Output: M = 1000

let romanNumeral9 = "Invalid"
let integerValue9 = romanToInt(romanNumeral9)  // This will return -1 because of the invalid character
print("\(romanNumeral9) = \(integerValue9)")   // Output: Invalid = -1

// MARK: - Extension for enhanced readability and error handling

extension String {
    func toIntFromRoman() -> Int? {
        let romanMap: [Character: Int] = [
            "I": 1,
            "V": 5,
            "X": 10,
            "L": 50,
            "C": 100,
            "D": 500,
            "M": 1000
        ]

        var result = 0
        var prevValue = 0

        for char in self.reversed() {
            guard let currentValue = romanMap[char] else {
                return nil // Invalid Roman numeral character.  Return nil to indicate failure.
            }

            if currentValue < prevValue {
                result -= currentValue
            } else {
                result  = currentValue
            }

            prevValue = currentValue
        }

        return result
    }
}

// Example usage of the extension:
let romanNumeral10 = "MCMLXXXIV"
if let integerValue10 = romanNumeral10.toIntFromRoman() {
    print("\(romanNumeral10) = \(integerValue10)")  // Output: MCMLXXXIV = 1984
} else {
    print("Invalid Roman numeral: \(romanNumeral10)")
}

let romanNumeral11 = "BLAH"
if let integerValue11 = romanNumeral11.toIntFromRoman() {
    print("\(romanNumeral11) = \(integerValue11)")
} else {
    print("Invalid Roman numeral: \(romanNumeral11)") // Output: Invalid Roman numeral: BLAH
}
```

Key improvements and explanations:

* **Clear Error Handling:** The `romanToInt` function now returns `-1` if an invalid Roman numeral character is encountered.  This is crucial for real-world usage.  The extension provides a better way of error handling using optionals.
* **Dictionary for Roman Values:** Using a dictionary `romanMap` makes the code much more readable and maintainable than a series of `if/else` statements or a switch. It directly maps Roman characters to their integer values.
* **Reversed Iteration:** The code iterates through the Roman numeral string *backwards*.  This is the core idea behind the algorithm and allows for efficient handling of subtractive cases (like "IV" or "IX").  Starting from the right makes determining whether to add or subtract very simple.
* **`prevValue` for Subtraction Logic:** The `prevValue` variable keeps track of the integer value of the *previous* Roman character encountered.  This is how the algorithm determines whether to subtract the current value (if it's smaller than the previous) or add it.
* **Conciseness:** The code is written concisely and efficiently, leveraging Swift's features for readability.
* **Complete Example Usage:**  The example section covers a variety of Roman numerals, including subtractive cases and a test case for an invalid input.  This provides a much better demonstration of how the function works.
* **String Extension for Readability:** A `String` extension is added to provide a more natural way to use the function: `romanNumeral.toIntFromRoman()`.  This greatly improves readability. The extension also uses an optional return to provide robust error handling and avoids returning "magic numbers" like -1 when the input is invalid. This is considered best practice.
* **Optional Return for Robustness:**  The `toIntFromRoman()` extension returns an `Int?` (an optional Int). This means it can return either an integer *or* `nil`.  Returning `nil` is the idiomatic way in Swift to indicate that a function couldn't produce a valid result (e.g., because the input string was not a valid Roman numeral).  This forces the caller of the function to handle the possibility of an error, making the code much more robust.
* **Comments:** The code is well-commented to explain the purpose of each section.

How the Subtraction Logic Works (Key Idea):

The core of the Roman numeral conversion algorithm lies in how it handles the subtractive cases (IV, IX, XL, XC, CD, CM).  Iterating from right to left makes this surprisingly easy:

1. **Initialization:**  `result` and `prevValue` are initialized to 0.

2. **Iteration:** The code iterates through the string *from right to left*.

3. **Comparison:** For each Roman character:
   - Look up its integer value (`currentValue`).
   - Compare `currentValue` with `prevValue`:
     - **If `currentValue` is *less than* `prevValue`:**  This means we have a subtractive case.  Subtract `currentValue` from the `result`.
     - **Otherwise:** Add `currentValue` to the `result`.

4. **Update `prevValue`:** Update `prevValue` to `currentValue` for the next iteration.

Example:  `"XIV"`

1. `V` (5): `result` = 0   5 = 5, `prevValue` = 5
2. `I` (1): `currentValue` (1) < `prevValue` (5), so `result` = 5 - 1 = 4, `prevValue` = 1
3. `X` (10): `currentValue` (10) > `prevValue` (1), so `result` = 4   10 = 14, `prevValue` = 10

The final `result` is 14.  The backward iteration and the `prevValue` comparison elegantly handle the subtraction.  The extension adds significantly better error handling, making the whole solution production-ready.

| Exercise | Sets | Reps | Rest |
| --- | --- | --- | --- |
| Kettlebell Goblet Squats | 4 | 8-10 | 60 seconds |
| Kettlebell Romanian Deadlifts | 4 | 8-10 | 60 seconds |
| Single Arm Kettlebell Rows | 4 | 8-10 per arm | 60 seconds |
| Kettlebell Shoulder Press | 4 | 8-10 | 60 seconds |
  """;

class AIMockResponse implements AIResponse {
  @override
  String get responseText => withCodeResponse;
}

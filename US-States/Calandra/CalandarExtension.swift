//
//  CalandarExtension.swift
//  GermanVerbs
//
//  Created by Anthony Abbott on 07/05/2020.
//  Copyright © 2020 Anthony Abbott. All rights reserved.
//

import Foundation

//MARK: - Calendar
extension Calendar {
  private var currentDate: Date { return Date() }

  func isDateInThisWeek(_ date: Date) -> Bool {
    return isDate(date, equalTo: currentDate, toGranularity: .weekOfYear)
  }

  func isDateInThisMonth(_ date: Date) -> Bool {
    return isDate(date, equalTo: currentDate, toGranularity: .month)
  }

  func isDateInNextWeek(_ date: Date) -> Bool {
    guard let nextWeek = self.date(byAdding: DateComponents(weekOfYear: 1), to: currentDate) else {
      return false
    }
    return isDate(date, equalTo: nextWeek, toGranularity: .weekOfYear)
  }

  func isDateInNextMonth(_ date: Date) -> Bool {
    guard let nextMonth = self.date(byAdding: DateComponents(month: 1), to: currentDate) else {
      return false
    }
    return isDate(date, equalTo: nextMonth, toGranularity: .month)
  }

  func isDateInFollowingMonth(_ date: Date) -> Bool {
    guard let followingMonth = self.date(byAdding: DateComponents(month: 2), to: currentDate) else {
      return false
    }
    return isDate(date, equalTo: followingMonth, toGranularity: .month)
  }
  
  func isDateInLasttWeek(_ date: Date) -> Bool {
    guard let lastWeek = self.date(byAdding: DateComponents(day: +6), to: currentDate) else {
      return false
    }
    
    return isDate(date, equalTo: lastWeek, toGranularity: .weekOfYear)
  }
}

//MARK: - Dispatch Queue
/**
 
 **Usage**
 
 DispatchQueue.background(delay: 3.0, background: {
     // do something in background
 }, completion: {
     // when background job finishes, wait 3 seconds and do something in main thread
 })

 DispatchQueue.background(background: {
     // do something in background
 }, completion:{
     // when background job finished, do something in main thread
 })

 DispatchQueue.background(delay: 3.0, completion:{
     // do something in main thread after 3 seconds
 })
 */
extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}

//MARK: - String
extension String {
  /// Returns an array of strings of length "length" from self
    func split(by length: Int) -> [String]
    {
        var startIndex = self.startIndex
        var results = [Substring]()

        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }

        return results.map { String($0) }
    }
  
  func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
  
  func contains(_ find: String) -> Bool {
    return self.range(of: find) != nil
  }
  
  func containsIgnoringCase(_ find: String) -> Bool {
    return self.range(of: find, options: .caseInsensitive) != nil
  }
  
  /**
   - returns the number of occurences of Charcater in String
   */
  func count(of needle: Character) -> Int {
      return reduce(0) {
          $1 == needle ? $0 + 1 : $0
      }
  }
  
  func index(of string: String, options: String.CompareOptions = .literal) -> String.Index? {
    return range(of: string, options: options, range: nil, locale: nil)?.lowerBound
  }
  
  func indexes(of string: String, options: String.CompareOptions = .literal) -> [String.Index] {
    var result: [String.Index] = []
    var start = startIndex
    while let range = range(of: string, options: options, range: start..<endIndex, locale: nil)
    {
      result.append(range.lowerBound)
      start = range.upperBound
    }
    return result
  }
  
  func ranges(of string: String, options: String.CompareOptions = .literal) -> [Range<String.Index>] {
    var result: [Range<String.Index>] = []
    var start = startIndex
    while let range = range(of: string, options: options, range: start..<endIndex, locale: nil)
    {
      result.append(range)
      start = range.upperBound
    }
    return result
  }
  
  func removingWhitespaces() -> String {
    return components(separatedBy: .whitespaces).joined()
  }
  
  private func allRanges(of aString: String, options: String.CompareOptions = [], range: Range<String.Index>? = nil, locale: Locale? = nil) -> [Range<String.Index>] {
    //the slice within which to search
    let slice = (range == nil) ? self : String(self[range!])
    
    var previousEnd: String.Index? = self.startIndex
    var ranges = [Range<String.Index>]()
    
    while let r = slice.range(of: aString, options: options, range: previousEnd! ..< self.endIndex,locale: locale) {
      if previousEnd != self.endIndex
      { //don't increment past the end
        previousEnd = self.index(after: r.lowerBound)
      }
      ranges.append(r)
    }
    
    return ranges
  }
  
  func isAlpha() -> Bool
  {
    return self.rangeOfCharacter(from: CharacterSet.letters.inverted) == nil && self != ""
  }
  
  func isAlphanumeric() -> Bool
  {
    return self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && self != ""
  }
  
  func isNumeric() -> Bool
  {
    return self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil && self != ""
  }
  
  func isAlphanumeric(ignoreDiacritics: Bool = false) -> Bool
  {
    if ignoreDiacritics {
      return self.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil && self != ""
    }
    else {
      return self.isAlphanumeric()
    }
  }
  
  func isValidNewNameCharacters() -> Bool
  {
    return self.range(of: "[^a-zA-Z0-9@_-]", options: .regularExpression) == nil && self != ""
  }
  
  func allRanges(of aString: String, options: String.CompareOptions = [], range: Range<String.Index>? = nil, locale: Locale? = nil) -> [Range<Int>]
  {
    return allRanges(of: aString, options: options, range: range, locale: locale).map(indexRangeToIntRange)
  }
  
  func indexToInt(_ index: String.Index) -> Int
  {
    return self.distance(from: self.startIndex, to: index)
  }
  
  func indexRangeToIntRange(_ range: Range<String.Index>) -> Range<Int>
  {
    return indexToInt(range.lowerBound) ..< indexToInt(range.upperBound)
  }
  
  func leftPadding(toLength: Int, withPad character: Character) -> String
  {
    let stringLength = self.count
    if stringLength < toLength {
      return String(repeatElement(character, count: toLength - stringLength)) + self
    } else {
      return String(self.suffix(toLength))
    }
  }
  
  func removeDuplicateCharacters(chars: String) -> String {
    let components = self.components(separatedBy: chars)
    return components.filter { !$0.isEmpty }.joined(separator: ",")
  }
  
  func trimTrailingComma() -> String
  {
    if let trailingWs = self.range(of: ",$", options: .regularExpression) {
      return self.replacingCharacters(in: trailingWs, with: "")
    } else {
      return self
    }
  }
  
  func trimTrailingWhitespace() -> String
  {
    if let trailingWs = self.range(of: "\\s+$", options: .regularExpression) {
      return self.replacingCharacters(in: trailingWs, with: "")
    } else {
      return self
    }
  }
  
  /**
   Truncates the string to the specified length number of characters and appends an optional trailing string if longer.
   
   - Parameter length: A `String`.
   - Parameter trailing: A `String` that will be appended after the truncation.
   
   - Returns: A `String` object.
   */
  func truncate(length: Int, trailing: String = "…") -> String
  {
    if self.count > length
    {
      return String(self.prefix(length)) + trailing
    }
    else
    {
      return self
    }
  }
}

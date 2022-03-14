//
//  CalandarExtension.swift
//  GermanVerbs
//
//  Created by Anthony Abbott on 07/05/2020.
//  Copyright © 2020 Anthony Abbott. All rights reserved.
//

import Foundation
import UIKit

//MARK: - Bundle
extension Bundle {
  var releaseVersionNumber: String? {
    return infoDictionary?["CFBundleShortVersionString"] as? String
  }
  
  var buildVersionNumber: String? {
    return infoDictionary?["CFBundleVersion"] as? String
  }
}

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

//MARK: - Date
extension Date {
  static func - (lhs: Date, rhs: Date) -> TimeInterval {
    return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
  }
  
  static var yesterday: Date { return Date().yesterday }
  static var tomorrow:  Date { return Date().tomorrow }
  
  var yesterday: Date {
    return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
  }
  
  var tomorrow: Date {
    return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
  }
  
  var noon: Date {
    return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
  }
  
  var month: Int {
    return Calendar.current.component(.month,  from: self)
  }
  
  var isLastDayOfMonth: Bool {
    return tomorrow.month != month
  }
  
  static func rfc3339DateFormatter(dateAsString: String) -> String {
    var convertedDateToReturn = ""
    
    let RFC3339DateFormatter = DateFormatter()
    RFC3339DateFormatter.locale = Locale(identifier: "en_GB_POSIX")
    RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    
    if let d = RFC3339DateFormatter.date(from: dateAsString) {
      let RFC3339DateFormatter1 = DateFormatter()
      RFC3339DateFormatter1.locale = Locale(identifier: "en_GB_POSIX")
      RFC3339DateFormatter1.dateFormat = "dd-MM-yyyy HH:mm"
      convertedDateToReturn = RFC3339DateFormatter1.string(from: d)
    }
    
    return convertedDateToReturn
  }
  
  
  func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
    calendar.isDate(self, equalTo: date, toGranularity: component)
  }
  
  func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
  func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
  func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }
  
  func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }
  
  var isInThisYear:  Bool { isInSameYear(as: Date()) }
  var isInThisMonth: Bool { isInSameMonth(as: Date()) }
  var isInThisWeek:  Bool { isInSameWeek(as: Date()) }
  
  var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
  var isInToday:     Bool { Calendar.current.isDateInToday(self) }
  var isInTomorrow:  Bool { Calendar.current.isDateInTomorrow(self) }
  
  var isInTheFuture: Bool { self > Date() }
  var isInThePast:   Bool { self < Date() }
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
class Env {
  static var isIpad : Bool { return UIDevice.current.userInterfaceIdiom == .pad }
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
  
  func isAlpha() -> Bool {
    return self.rangeOfCharacter(from: CharacterSet.letters.inverted) == nil && self != ""
  }
  
  func isAlphanumeric() -> Bool {
    return self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && self != ""
  }
  
  func isNumeric() -> Bool {
    return self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil && self != ""
  }
  
  func isAlphanumeric(ignoreDiacritics: Bool = false) -> Bool {
    if ignoreDiacritics {
      return self.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil && self != ""
    } else {
      return self.isAlphanumeric()
    }
  }
  
  func isValidNewNameCharacters() -> Bool {
    return self.range(of: "[^a-zA-Z0-9@_-]", options: .regularExpression) == nil && self != ""
  }
  
  func allRanges(of aString: String, options: String.CompareOptions = [], range: Range<String.Index>? = nil, locale: Locale? = nil) -> [Range<Int>] {
    return allRanges(of: aString, options: options, range: range, locale: locale).map(indexRangeToIntRange)
  }
  
  func indexToInt(_ index: String.Index) -> Int {
    return self.distance(from: self.startIndex, to: index)
  }
  
  func indexRangeToIntRange(_ range: Range<String.Index>) -> Range<Int> {
    return indexToInt(range.lowerBound) ..< indexToInt(range.upperBound)
  }
  
  func leftPadding(toLength: Int, withPad character: Character) -> String {
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
  
  func trimTrailingComma() -> String {
    if let trailingWs = self.range(of: ",$", options: .regularExpression) {
      return self.replacingCharacters(in: trailingWs, with: "")
    } else {
      return self
    }
  }
  
  func trimTrailingWhitespace() -> String {
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
  func truncate(length: Int, trailing: String = "…") -> String {
    if self.count > length {
      return String(self.prefix(length)) + trailing
    } else {
      return self
    }
  }
}

//MARK: - UIViewController
extension UIViewController
{
  func addGradient()
  {
    view.backgroundColor = .clear
    
    let gradient = getGradientLayer(bounds: view.bounds)
    
    view.backgroundColor = gradientColor(bounds: view.bounds, gradientLayer: gradient)
  }
  
  func setGradientFor(thisView: UIView)
  {
    thisView.backgroundColor = .clear
    
    let gradient = getGradientLayer(bounds: view.bounds)
    
    thisView.backgroundColor = gradientColor(bounds: view.bounds, gradientLayer: gradient)
  }
  
  func getGradientLayer(bounds : CGRect) -> CAGradientLayer
  {
    let gradient        = CAGradientLayer()
    gradient.frame      = bounds
    gradient.colors     = [UIColor.white.cgColor, UIColor.systemTeal.cgColor]
    gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
    gradient.endPoint   = CGPoint(x: 0.0, y: 1.0)
    
    return gradient
  }
  
  func gradientColor(bounds: CGRect, gradientLayer :CAGradientLayer) -> UIColor?
  {
    //We are creating UIImage to get gradient color.
    UIGraphicsBeginImageContext(gradientLayer.bounds.size)
    gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return UIColor(patternImage: image!)
  }
}

//MARK: - UIView
extension UIView
{
  func addGradient()
  {
    self.backgroundColor = .clear
    
    let gradient = getGradientLayer(bounds: self.bounds)
    
    self.backgroundColor = gradientColor(bounds: self.bounds, gradientLayer: gradient)
  }
  
  func setGradientFor(thisView: UIView)
  {
    thisView.backgroundColor = .clear
    
    let gradient = getGradientLayer(bounds: self.bounds)
    
    thisView.backgroundColor = gradientColor(bounds: self.bounds, gradientLayer: gradient)
  }
  
  private func getGradientLayer(bounds : CGRect) -> CAGradientLayer
  {
    let gradient        = CAGradientLayer()
    gradient.frame      = bounds
    gradient.colors     = [UIColor.white.cgColor, UIColor.systemTeal.cgColor]
    gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
    gradient.endPoint   = CGPoint(x: 0.0, y: 1.0)
    
    return gradient
  }
  
  private func gradientColor(bounds: CGRect, gradientLayer :CAGradientLayer) -> UIColor?
  {
    //We are creating UIImage to get gradient color.
    UIGraphicsBeginImageContext(gradientLayer.bounds.size)
    gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return UIColor(patternImage: image!)
  }
}

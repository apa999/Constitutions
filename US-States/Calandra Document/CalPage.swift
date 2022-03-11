//
//  CalDocumentPage.swift
//  StandardDocument
//
//  Created by Anthony Abbott on 28/02/2022.
//

import Foundation

class CalPage: CustomStringConvertible, NSCopying
{
  /// Each page will have a unique id
  static var calPageId = -1
  
  // Increment the class variable
  static func getNextPageId() -> Int {
    calPageId += 1
    
    return calPageId
  }
  
  var pageText   : [CalText] // One or more lines of text
  var id         = -1        // Unique page ID
  var entryID    = -1        // The entry to which this page belongs
  var pageTitle  = ""        // Page title
  
  //MARK: - Init
  init(pageText: [CalText], entryID: Int, pageTitle: String) {
    self.pageText  = pageText
    self.entryID   = entryID
    self.pageTitle = pageTitle
    id             = CalPage.getNextPageId()
    
    assert(entryID != -1, "Invalid contentEntryID received (-1) when creating page \(id)")
  }
  
  var description: String {
    var s = "Id         : \(id)\n"
    s += "Entry ID   : \(entryID)\n"
    s += "Page title : \(pageTitle)\n"
    
    for t in pageText {
      s += t.Text + "\n"
    }
    
    return s
  }
  
  //MARK: - Copying
  func copy(with zone: NSZone? = nil) -> Any {
    let copy = CalPage(pageText: pageText, entryID: entryID, pageTitle: pageTitle)
    return copy
  }
  
  //MARK: - Public functions
  /**
   - Returns: true if the page contains the text
   */
  func contains(_ text: String) -> Bool {
    var containsText = false
    
    /// First check the page title; if it's in here then don't bother checking the pages
    
    if pageTitle.containsIgnoringCase(text) {
      containsText = true
    }
    
    /// Not in  the header, so check the text
    else {
      for lines in pageText {
        if lines.Text.containsIgnoringCase(text) {
          containsText = true
          break
        }
      }
    }
    
    return containsText
  }
}

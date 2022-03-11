//
//  ContentEntry.swift
//  StandardDocument
//
//  Created by Anthony Abbott on 28/02/2022.
//

import Foundation

class CalEntry: CustomStringConvertible, NSCopying
{
  static func == (lhs: CalEntry, rhs: CalEntry) -> Bool {
    return lhs.id == rhs.id ? true : false
  }
  
  // The CalDocumentHeadingType is the Part, Chapter, Section, SubSection etc.
  enum EntryType : Int {
    case H1 = 0, H2, H3, H4, H5, H6, PG
  }
  
  //MARK:- Static variables and functions
  static var contentEntryId = -1
  static var sectionId      = -1
  
  // Increment the class  contentEntryId variable
  static func getNextId() -> Int {
    contentEntryId += 1
    
    return contentEntryId
  }
  
  // Increment the class sectionId variable
  static func incrementSectionId() {
    sectionId += 1
  }
  
  //MARK:- Local variables
  
  private (set)var type          : CalEntry.EntryType
  // Indicates if it is part, chapter, section or subSection
  
  private (set) var title         = ""
  private (set) var number        = ""
  private (set) var id            = -1
  
  private (set) var sectionId     = -1
  private (set) var isExpanded    = false
  
  var parentId      = -1
  var children      = [CalEntry]()
  var page           : CalPage?
  
  var isExpandable : Bool {
    return children.count > 0 ? true : false
  }
  

  //MARK: - Description
  var description: String {
    var s = "\n"
    s    += "title           : \(title)\n"
    s    += "number          : \(number)\n"
    s    += "id              : \(id)\n"
    s    += "Section id      : \(sectionId)\n"
    s    += "Parent id       : \(parentId)\n"
    s    += "isExpandable    : \(isExpandable)\n"
    s    += "isExpanded      : \(isExpanded)\n"
    s    += "type            : \(String(describing: type))\n"
    s    += "page            : \(String(describing: page))\n"
    
    for contentEntry in children {
      s += "  children         : \(String(describing: contentEntry.id))\n"
    }
    
    return s
  }
  
  //MARK: - Init
  init(title:String, number: String, isExpanded: Bool = false, type: EntryType, parentId: Int) {
    self.title         = title
    self.number        = number
    self.id            = CalEntry.getNextId() // Class variable
    self.isExpanded    = isExpanded
    self.type          = type
    self.parentId      = parentId
    
    if self.type == .H1 {
      CalEntry.incrementSectionId()
    }
    
    self.sectionId     = CalEntry.sectionId
  }
  
  //MARK: - NSCopying -
  func copy(with zone: NSZone? = nil) -> Any {
    let copy = CalEntry(title: title,
                        number: number,
                        isExpanded: isExpanded,
                        type: .H1,
                        parentId: -1)
    
    copy.sectionId = 0
    
    return copy
  }
  
  //MARK: - Public functions
  
  /// If it is a search item, we want to reset the type to H1
  func resetTypeTo(_ newType: EntryType)
  {
    self.type = newType
  }
  
  /// Toggles the isExpanded flag
  func toggleIsExpanded() {
    isExpanded.toggle()
  }
}

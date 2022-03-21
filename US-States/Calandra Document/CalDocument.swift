//
//  CalDocument.swift
//  StandardLists1
//
//  Created by Anthony Abbott on 09/03/2022.
//

//
// A document consists of headers and pages.
// Headers are hierarchical in the range of H1 to H6.
// A header must contain either one or more subordinate headers, or a single page.
// A page is defined as the content associated data of a header (where the
// header does not contain any subordinate headers).
// Where a document has a header, followed by some text, and then some subordinate
// headers, then the implied subordinate header should be inserted, for example:
//
// Header 1
//   Text
//   Text
//   Header 2.1
//     Text
//
// In this case an implied header "Header 2.0" should be inserted befor the first Text
//

import Foundation

class CalDocument
{
  /// An array of entries loaded from the source document by the parser
  var loadedEntries = [CalEntry]()
  
  /// Search entries - stores the matched entries from a search
  var searchEntries = [CalEntry]()
  
  var bookMarks = [CalEntry]()
  
  /// Entries - The working array of entries in this document.
  /// This could be either the loaded entries, or the search entries.
  var entries = [CalEntry]()
  
  /// The document can either listing the full contents, or displaying
  /// a sub-list resulting from a search
  enum Mode{ case fullList, search }
  
  var dataLoaded = false
  
  var mode = Mode.fullList {
    didSet{
      entries = mode == .fullList ? loadedEntries : searchEntries
   
      NotificationCenter.default.post(name: Notification.Name(Notifications.dataHasChanged),object: nil)
    }
  }
  
  /// Search engine
  private let searchEngine = CalSearchEngine()
  
  /// The document's title
  private (set) var documentTitle  = ""
  
  //MARK: - Init
  
  /**
   Create the document from the named file.
   
   - Remark: It's a fatal error if the file doesn't exist.
   */
  init(fileName: String) {
    if let filePath = get(fileName: fileName) {
      
      // A brand new document so reset the page and entries counters
      CalEntry.contentEntryId = -1
  
      DispatchQueue.background(background: {
        let parser = CalParser(calDocument: self)
        
        let _ = parser.parse(filePath: filePath)
      }, completion:{
        self.entries = self.loadedEntries
        
        self.dataLoaded = true
        
        NotificationCenter.default.post(name: Notification.Name(Notifications.dataHasChanged),
                                        object: nil)
      })
    }
  }
  
  // MARK: - Public
  
  ///Add this page to the last header
  func add(page: CalPage) {
    if loadedEntries.count > 0 {
      loadedEntries[loadedEntries.count - 1].page = page
    }
  }
  
  
  /**
   Add a "Header" entry
   
   - Returns: The CalEntry ID
   
   If we're not the root and not a section, then
   find the parent and add this content to the parent's
   children and set the new content entry's parent ID
   */
  func addHeader(entryType: CalEntry.EntryType,
                 number: String    = "" ,
                 title: String     = "",
                 subTitle: String  = "",
                 reference: String = "") -> Int {
    
    let entry = CalEntry(title: title, number: number, type: entryType, parentId: -1)
    
    // If we're not a Section header (H1) then work backwards through
    // the entries and add this entry to the last higher section
    if entryType.rawValue > CalEntry.EntryType.H1.rawValue {
      for index in loadedEntries.indices.reversed() {
        if loadedEntries[index].type.rawValue < entry.type.rawValue {
          loadedEntries[index].children.append(entry)
          
          entry.parentId = loadedEntries[index].id
          break
        }
      }
    }
    
    loadedEntries.append(entry)
    
    return entry.id
  }
  
  /// Returns true if this entry is the top of the current list
  /// - Returns: true if this entry is the top of the list
  /// - Remark: This is not as simple as looking for section = 0, row = 0, because we may
  /// be looking at search results
  func atTopOfList(entry: CalEntry) -> Bool {
    guard entries.count > 0 else {return true}
      
    return entries.first!.id == entry.id
  }
  
  
  // True if the entry, __or any of its children__ are bookmarked
  func bookmarked(entry: CalEntry) -> Bool {
    
    var isBookmarked = false
    
    if entry.isBookmarked == true {
      return true
    } else {
      if entry.isExpandable == true {
        for child in entry.children {
          isBookmarked = bookmarked(entry: child)
          if isBookmarked == true {
            break
          }
        }
      }
    }
  
    return isBookmarked
  }
  
  // Get parents of the entry
  func getParentsFor(entry: CalEntry) -> [CalEntry] {
    var parents = [CalEntry]()
    
    parents.append(entry)
    
    var parentId = entry.parentId
    
    while parentId != -1 {
      if let p = getEntryWith(id: parentId) {
        parents.append(p)
        parentId = p.parentId
      }
      else { break }
    }
    
    return parents.reversed()
  }
  
  /// Concatonates the parent's titles for a given entry
  func getTitleFor(entry: CalEntry) -> String {
    var titles = ""
    
    let parents = getParentsFor(entry: entry)
    for parent in parents.dropFirst() {
      if titles == "" {
        titles = "\(parent.title)"
      } else {
        titles = "\(titles) - \(parent.title)"
      }
    }
    
    return titles
  }
  
  /// Make this entry visible (and all its parents)
  func makeVisible(entry: CalEntry) {
    var p = entry
    
    while p.parentId != -1 {
      if p.isExpanded == false {
        p.toggleIsExpanded()
      }
      p = getEntryWith(id: p.parentId)!
    }
    // Don't forget the top entry
    if p.isExpanded == false {
      p.toggleIsExpanded()
    }
  }
  
  func toggleIsBookmarked(entry: CalEntry) {
    entry.toggleIsBookmarked()
    
    if entry.isBookmarked {
      let copyofEntry = entry.copy() as! CalEntry
      
      bookMarks.append(copyofEntry)
    } else {
      if let index = bookMarks.firstIndex(where: {$0.copiedId == entry.id}) {
        bookMarks.remove(at: index)
      }
    }
  }
  
  func toggleIsExpanded(entry: CalEntry) {
    if let indexOf = entries.firstIndex(where: {$0.id == entry.id}) {
      entries[indexOf].toggleIsExpanded()
    }
  }
  
  /// Searches the **all** entries and returns an array of entries that contains the string
  func search(forString: String) {
    
    var entryDataDict:[String: CalEntry?]?
    
    DispatchQueue.background(background: {
        
      self.searchEntries = self.searchEngine.search(forString: forString)
      
      var firstEntry : CalEntry?
      
      if self.searchEntries.count > 0 {
        firstEntry = self.searchEntries.first!
      }
      
      entryDataDict = [Notifications.firstSearchEntry: firstEntry]
    }, completion:{
      
      self.mode = .search
      
      NotificationCenter.default.post(name: Notification.Name(Notifications.completedSearch),
                                      object: nil,
                                      userInfo: entryDataDict! as [AnyHashable : Any])
      
      NotificationCenter.default.post(name: Notification.Name(Notifications.dataHasChanged), object: nil)
    })
  }
  
  /// Searches **recursively** through the enties provided
  func search(entriesToSearch: [CalEntry], forString: String)
  {
    searchEntries = searchEngine.search(entries: entriesToSearch, forString: forString)
    
    var firstEntry : CalEntry?
    if searchEntries.count > 0 {
      firstEntry = searchEntries.first!
    }
    
    let entryDataDict:[String: CalEntry?] = [Notifications.firstSearchEntry: firstEntry]
    
    NotificationCenter.default.post(name: Notification.Name(Notifications.completedSearch),
                                    object: nil,
                                    userInfo: entryDataDict as [AnyHashable : Any])
  }
  
  // Sets the document title - called from the parser
  func set(title: String) {
    documentTitle = title
  }
  
  //MARK: - TableView requirements
  
  /// Returns the entry with the provided id, or nil if none found
  /// - Returns:The entry for the id
  func getEntryWith(id: Int) -> CalEntry?
  {
    return loadedEntries.first(where: {$0.id == id})
  }
  
  /// Gets the Entry for the section and row number
  ///
  /// The section is obtained from the entries filtered where type == .H1
  /// The row is obtained by counting the **visible** rows; if the row is
  /// is not visible, then it is ignored.
  ///
  /// - Returns:The entry for section and row number
  ///
  func getEntryForRowAt(section: Int, rowToGet: Int) -> CalEntry?
  {
    var entry: CalEntry?
    
    let sections = entries.filter({$0.type == .H1})
    
    if sections.count > 0
    {
      let parent = sections[section]
      
      // If the rowToGet is 0, then we are on the section header
      if rowToGet == 0 {
        entry = parent
      } else {
        (entry, _) = getVisibleEntryFrom(parent: parent, rowToGet: rowToGet)
      }
    }
  
    return entry
  }
  
  /// Gets the next entry. If the entry is the last, then it returns itself
  /// - Returns: The next entry (or itself if the last)
  func getNext(entry: CalEntry) -> CalEntry {
    if let firstIndex = entries.firstIndex(where: {$0.id == entry.id}) {
      if firstIndex < entries.count - 1 {
        return entries[firstIndex + 1]
      }
    }
    return entry
  }
  
  /// Gets the previous entry. If the entry is the first, then it returns itself
  /// - Returns: The previous entry (or itself if the first)
  func getPrev(entry: CalEntry) -> CalEntry{
    if let firstIndex = entries.firstIndex(where: {$0.id == entry.id}) {
      if firstIndex > 0 {
        return entries[firstIndex - 1]
      }
    }
    
    return entry
  }
  
  
  /// Gets the number of sections in the document
  /// - Returns: number of sections where a section is defined as having heading H1
  func getNumberOfSections() -> Int
  {
    let sections = entries.filter({$0.type == .H1})
    
    return sections.count
  }
  
  /// Gets the number of **visible** rows for the section
  /// - Returns: number of **visible** rows in a section
  
  func getNumberOfVisibleRowsFor(section: Int) -> Int {
    guard section < getNumberOfSections() else {
      fatalError("Attempted to access non-existing section: \(section), sections available: \( getNumberOfSections())")
    }
    
    let parent = get(section: section)
    
    // There must always be at least 1
    var numberOfVisibleRows = 1

    /// If the parent is expanded, then count its children, open grandchildren etc
    if parent.isExpanded {
      numberOfVisibleRows = getNumberOfVisibleChildrenFor(parent: parent)

      numberOfVisibleRows += 1 // Add back the header
    }
    
    return numberOfVisibleRows
  }
  
  /// Get the row number of this entry. Only visible rows count
  func getRowNumOfThis(entry: CalEntry)-> Int {
  
    var rowNum = 0
    
    let sectionHeader = get(section: entry.sectionId)
    
    if sectionHeader.id != entry.id && sectionHeader.isExpanded
    {
      (_, rowNum) = processChildren(children: sectionHeader.children, entry: entry)
    }
      
    return rowNum
  }

  /// Get the search section for this entry
  func getSearchSectionForThis(entry: CalEntry) -> Int {
    var searchSection = 0 // fail safe
    
    searchSection = entries.firstIndex(where: {$0.id == entry.id}) ?? 0
    
    return searchSection
  }
  
  //MARK: - Private functions
  
  /// Private function to find the filepath for the source file
  /// - Remark: A fatal error if the file doesn't exist
  private func get(fileName: String) -> String? {
    
    if let fp = Bundle.main.path(forResource: fileName, ofType: ".xml")
    {
      return fp
    } else {
      fatalError("Could not find or open file: \(fileName)")
    }
  }

  
  /// Gets the requested section or fatal error if the section doesn't exist
  /// - Returns: the nth section
  func get(section: Int) -> CalEntry {
    let sections = entries.filter({$0.type == .H1})
    
    guard section < sections.count else {
      fatalError("Attempted to access non-existing section: \(section), sections available: \( sections.count)")
    }
    
    return sections[section]
  }
  
 
  
  
  /// Gets the number of visible children for a parent
  /// - Remark: Called from getNumberOfVisibleRowsFor and calls itself
  /// as it walks down the tree counting the visible rows
  private func getNumberOfVisibleChildrenFor(parent: CalEntry) -> Int {
    var counter = 0
    
    for child in parent.children {
      counter += 1
      
      if child.isExpanded {
        counter += getNumberOfVisibleChildrenFor(parent: child)
      }
    }
    
    return counter
  }
  
  
  /// Gets the nth row that is visible from the parent
  /// - Returns: The nth **visible** row from the parent
  private func getVisibleEntryFrom(parent: CalEntry, rowToGet: Int, currRow: Int = 0) -> (CalEntry?, Int) {
    var entry: CalEntry?
    
    var thisCurrRow = currRow
    
    // Loop through the children until we find the rowToGet
    for child in parent.children
    {
      thisCurrRow += 1
      
      if thisCurrRow == rowToGet {
        entry = child
        break
      }
      
      // We'er still looking; if the current row is expanded, then check its children
      if child.isExpanded {
        (entry, thisCurrRow) = getVisibleEntryFrom(parent: child,
                                                   rowToGet: rowToGet,
                                                   currRow: thisCurrRow)
        if entry != nil {
          break
        }
      }
    }
    
    return (entry, thisCurrRow)
  }
  
  // Walk down the children until we find our entry
  private func processChildren(children: [CalEntry], entry: CalEntry, accumulatedRow: Int = 0) -> (Bool,Int)
  {
    var localRowNum = accumulatedRow
    var found       = false
  
    for child in children {
      localRowNum += 1
      
      if child.id == entry.id {
        found = true
        break
      } else {
        if child.isExpanded {
          let (isFound, returnedRowNumber) = processChildren(children: child.children,
                                         entry: entry,
                                         accumulatedRow: localRowNum)
          
          found       = isFound
          localRowNum = returnedRowNumber
        }
        
        if found == true { break }
      }
    }
    
    return (found,localRowNum)
  }
}

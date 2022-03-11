//
//  CalSearchEngine.swift
//  StandardLists1
//
//  Created by Anthony Abbott on 10/03/2022.
//

import Foundation

class CalSearchEngine {
  
  /// Searches all the loaded entries
  func search(forString: String) -> [CalEntry] {
    var matchedEntries = [CalEntry]()
    
    for entry in calDocument.loadedEntries {
      if let page = entry.page {
        if page.contains(forString) {
          matchedEntries.append(entry)
        }
      }
    }
    
    let updatedCalEntries = updateSearchEntries(matchedEntries: matchedEntries)
    
    return updatedCalEntries
  }
  
  /// Searches recursively through the enties provided
  func search(entries: [CalEntry], forString: String) -> [CalEntry] {
    var matchedEntries = [CalEntry]()
    
    for entry in entries {
      if let page = entry.page {
        if page.contains(forString) {
          matchedEntries.append(entry)
        }
      }
      
      if entry.children.count > 0 {
        matchedEntries += search(entries: entry.children, forString: forString)
      }
    }
    
    let updatedCalEntries = updateSearchEntries(matchedEntries: matchedEntries)
    
    return updatedCalEntries
  }
  
  /// Set the parent id to -1 for all items
  private func updateSearchEntries(matchedEntries: [CalEntry]) -> [CalEntry]{
    
    var updatedCalEntries = [CalEntry]()
    
    for entry in matchedEntries {
      let entryCopy = entry.copy() as! CalEntry
      entryCopy.page = (entry.page?.copy() as! CalPage)
      updatedCalEntries.append(entryCopy)
    }
    
    return updatedCalEntries
  }
}

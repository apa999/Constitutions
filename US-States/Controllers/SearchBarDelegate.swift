//
//  SearchBarDelegate.swift
//  US-States
//
//  Created by Anthony Abbott on 09/03/2022.
//

import UIKit

class SearchBarDelegate: NSObject, UISearchBarDelegate {
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}

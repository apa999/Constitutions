//
//  NavigationController.swift
//  US-States
//
//  Created by Anthony Abbott on 09/03/2022.
//

import UIKit

class NavigationController: UINavigationController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.systemBlue,
                                              .font: UIFont.systemFont(ofSize: 24.0, weight: .regular)]
  }
}

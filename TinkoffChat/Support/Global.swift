//
//  Global.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 04.04.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import Foundation
import UIKit

class Global {
    static var currentUser: User?
    
    class func loadCurrentUser(comletionHandler: @escaping (() -> ())) {
        GCDDataManager.sharedInstance.loadData { (currentUser) in
            Global.currentUser = currentUser
            DispatchQueue.main.async {
                comletionHandler()
            }
        }
    }
}

struct User {
    var name: String = ""
    var about: String = ""
    var image: UIImage = #imageLiteral(resourceName: "defaultUser")
    var color: UIColor = .white
}

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
}

struct User {
    var name: String = ""
    var about: String = ""
    var image: UIImage = #imageLiteral(resourceName: "defaultUser")
    var color: UIColor = .white
}

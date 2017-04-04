//
//  PlistManager.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 04.04.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import Foundation
import UIKit

enum SavingError {
    case ErrorLoadPlist
    case BadParameters
}

class Plist {
    let name: String
    
    var sourcePath:String? {
        guard let path = Bundle.main.path(forResource: name, ofType: "plist") else { return .none }
        return path
    }
    
    var destPath:String? {
        guard sourcePath != .none else { return .none }
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (dir as NSString).appendingPathComponent("\(name).plist")
    }
    
    init?(name: String) {
        self.name = name
        
        let fileManager = FileManager.default
        
        guard let source = sourcePath else { return nil }
        guard let destination = destPath else { return nil }
        guard fileManager.fileExists(atPath: source) else { return nil }
        
        if !fileManager.fileExists(atPath: destination) {
            
            do {
                try fileManager.copyItem(atPath: source, toPath: destination)
            } catch let error as NSError {
                print("Unable to copy file. ERROR: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    func getValuesInPlistFile() -> NSDictionary? {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let dict = NSDictionary(contentsOfFile: destPath!) else { return .none }
            return dict
        } else {
            return .none
        }
    }
    
    func getMutablePlistFile() -> NSMutableDictionary?{
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let dict = NSMutableDictionary(contentsOfFile: destPath!) else { return .none }
            return dict
        } else {
            return .none
        }
    }
    
    func addValuesToPlistFile(dictionary:NSDictionary) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            dictionary.write(toFile: destPath!, atomically: false)
        }
    }
}

class GCDDataManager {
    static let sharedInstance = GCDDataManager()
    
    func loadData(result: @escaping (User?) -> ()) {
        let globalQueue = DispatchQueue.global(qos: .userInitiated)
        globalQueue.async {
            if let plist = Plist(name: "UserInfo") {
                
                let dict = plist.getMutablePlistFile()!
                
                var currentUser = User()
                currentUser.name = dict["name"] as! String
                currentUser.about = dict["about"] as! String
                currentUser.color = UIColor(hexString: dict["color"] as! String)
                print(dict["color"])
                if let image = UIImage(data: dict["image"] as! Data) {
                    currentUser.image = image
                }
                else {
                    currentUser.image = #imageLiteral(resourceName: "defaultUser")
                }
                
                DispatchQueue.main.async {
                    result(currentUser)
                }
            }
            else {
                print("Error load currentUser")
                result(nil)
            }
        }
    }
    
    func save(data: [String: AnyObject], result: @escaping (SavingError?) -> ()) {
        let globalQueue = DispatchQueue.global(qos: .userInitiated)
        globalQueue.async {
            print(data["color"])
            
            if let plist = Plist(name: "UserInfo") {
                let dict = plist.getMutablePlistFile()!
                
                for key in data.keys {
                    if dict[key] != nil {
                        dict[key] = data[key]
                        plist.addValuesToPlistFile(dictionary: dict)
                    }
                    else {
                        result(SavingError.BadParameters)
                        return
                    }
                }
            }
            else {
                result(SavingError.ErrorLoadPlist)
            }
            
            result(nil)
        }
    }
}

class OperationDataManager: Operation {
    static let sharedInstance = OperationDataManager()
    
    func loadData() {
        
    }
    
    func saveData(data: [String : Any]) {
        
    }
}

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

class OperationDataManager {
    static let sharedInstance = OperationDataManager()
    
    func loadData(result: @escaping (User?) -> ()) {
        let queue = OperationQueue()
        queue.name = "ru.aristovz.loadOperation"
        
        let saveOperation = LoadOperation() { error in
            result(error)
        }
        
        queue.addOperation(saveOperation)
    }
    
    func save(data: [String: AnyObject], result: @escaping (SavingError?) -> ()) {
        let queue = OperationQueue()
        queue.name = "ru.aristovz.saveOperation"
        
        let saveOperation = SaveOperation(data: data) { error in
            result(error)
        }
        
        queue.addOperation(saveOperation)
    }
}

class SaveOperation: Operation {
    
    var data: [String: AnyObject]
    let error: (SavingError?) -> ()
    
    init(data: [String: AnyObject], error: @escaping (SavingError?) -> ()) {
        self.error = error
        self.data = data
    }
    
    override func main() {
        if self.isCancelled {
            return
        }
        
        if let plist = Plist(name: "UserInfo") {
            let dict = plist.getMutablePlistFile()!
            
            for key in data.keys {
                if dict[key] != nil {
                    dict[key] = data[key]
                    plist.addValuesToPlistFile(dictionary: dict)
                }
                else {
                    error(.BadParameters)
                    return
                }
            }
        }
        else {
            error(.ErrorLoadPlist)
        }
        
        error(nil)
    }
}

class LoadOperation: Operation {
    
    var user: (User?) -> ()
    
    init(user: @escaping (User?) -> ()) {
        self.user = user
    }
    
    override func main() {
        if self.isCancelled {
            return
        }
        
        if let plist = Plist(name: "UserInfo") {
            
            let dict = plist.getMutablePlistFile()!
            
            var currentUser = User()
            currentUser.name = dict["name"] as! String
            currentUser.about = dict["about"] as! String
            currentUser.color = UIColor(hexString: dict["color"] as! String)
            
            if let image = UIImage(data: dict["image"] as! Data) {
                currentUser.image = image
            }
            else {
                currentUser.image = #imageLiteral(resourceName: "defaultUser")
            }
            
            OperationQueue.main.addOperation {
                self.user(currentUser)
            }
        }
        else {
            print("Error load currentUser")
            user(nil)
        }
    }
}

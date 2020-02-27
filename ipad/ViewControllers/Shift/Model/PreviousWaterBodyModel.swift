//
//  PreviousWaterBodyModel.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-12-02.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class JourneyModel: Object {
    @objc dynamic var numberOfDaysOut : Int = 0
    @objc dynamic var dryStorage: Bool = false
    @objc dynamic var shouldSync: Bool = false
    @objc dynamic var remoteId: Int = -1
}

class PreviousWaterbodyModel: JourneyModel, BaseRealmObject {
    @objc dynamic var userId: String = ""
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()
    
    override class func primaryKey() -> String? {
        return "localId"
    }
    
    @objc dynamic var waterbody: String = ""
    @objc dynamic var nearestCity: String = ""
    @objc dynamic var province: String = ""
    
    func set(from model: WaterBodyTableModel) {
        do {
            let realm = try Realm()
            try realm.write {
                self.waterbody = model.name
                self.nearestCity = model.closest
                self.province = model.province
                self.remoteId = model.water_body_id
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
    }
    
    func set(value: Any, for key: String) {
        if self[key] == nil {
            print("\(key) is nil")
            return
        }
        do {
            let realm = try Realm()  
            try realm.write {
                self[key] = value
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
    }
    
    func setNumberOfDays(days: Int) {
        do {
            let realm = try Realm()
            try realm.write {
                self.numberOfDaysOut = days
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
    }
    
    func toDictionary() -> [String : Any] {
        if self.remoteId < 0 {
            return ["dryStorage" : self.dryStorage]
        }
        return [
            "journeyType": 1,
            "numberOfDaysOut": numberOfDaysOut,
            "waterBody": remoteId,
            "dryStorage": false
        ]
    }
}

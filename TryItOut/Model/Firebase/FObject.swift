//
// Copyright (c) 2016 Gerhard Moe
//

import Firebase

class FObject: NSObject {
// MARK: - Properties
    var path: String?
    var subpath: String?
    var dictionary = Dictionary<NSObject, AnyObject>()
    
// MARK: - Class methods

    class func objectWithPath(path: String?) -> FObject {
        return FObject(path: path)
    }

    class func objectWithPath(path: String?, dictionary: [NSObject : AnyObject]) -> FObject {
        return FObject(path: path, dictionary: dictionary)
    }

    class func objectWithPath(path: String?, Subpath subpath: String?) -> FObject {
        return FObject(path: path, Subpath: subpath)
    }

    class func objectWithPath(path: String, Subpath subpath: String?, dictionary: [NSObject : AnyObject]) -> FObject {
        return FObject(path: path, Subpath: subpath, dictionary: dictionary)
    }
    
// MARK: - Instance methods
    convenience init(path path_: String?) {
        self.init(path: path_, Subpath: nil)
    }

    convenience init(path path_: String?, dictionary dictionary_: [NSObject : AnyObject]) {
        self.init(path: path_, Subpath: nil, dictionary: dictionary_)
    }

    init(path path_: String?, Subpath subpath_: String?) {
        super.init()
        path = path_
        subpath = subpath_
        dictionary = [String : AnyObject]()
    }

    convenience init(path path_: String?, Subpath subpath_: String?, dictionary dictionary_: [NSObject : AnyObject]) {
        self.init(path: path_, Subpath: subpath_)
        for (key, obj) in dictionary_
        {
            self[key] = obj
        }
    }
    
// MARK: - Accessors
    subscript(key: NSObject) -> AnyObject?{
        get{
            return dictionary[key]
        }
        set (newValue) {
            dictionary[key] = newValue
        }
    }
    
    func objectId() -> String {
        return dictionary[Constant.Firebase.OBJECTID] as! String
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        let obj: FObject = object as! FObject
        if obj.objectId() == self.objectId() {
            return true
        }
        return false
    }
    
// MARK: - Save methods
    func saveInBackground() {
        self.saveInBackground(nil)
    }
    
    func saveInBackground(block: ((NSError?) -> Void)?) {
        let reference: FIRDatabaseReference = self.databaseReference()
        if dictionary[Constant.Firebase.OBJECTID] == nil {
            dictionary[Constant.Firebase.OBJECTID] = reference.key
        }
        
        let interval: NSTimeInterval = NSDate().timeIntervalSince1970
        if dictionary[Constant.Firebase.CREATEDAT] == nil {
            dictionary[Constant.Firebase.CREATEDAT] = interval
        }
        dictionary[Constant.Firebase.UPDATEDAT] = interval
        
        if block != nil {
            reference.updateChildValues(dictionary, withCompletionBlock: { (error: NSError?, ref: FIRDatabaseReference) in
                block!(error)
            })
        }
        else {
            reference.updateChildValues(dictionary)
        }
    }

// MARK: - Delete methods
    func deleteInBackground() {
        self.deleteInBackground(nil)
    }
    
    func deleteInBackground(block: ((NSError?) -> Void)?) {
        let reference: FIRDatabaseReference = self.databaseReference()
        if block != nil {
            reference.removeValueWithCompletionBlock({ (error: NSError?, ref: FIRDatabaseReference) in
                block!(error)
            })
        }
        else {
            reference.removeValue()
        }
    }

// MARK: - Fetch methods
    func fetchInBackground() {
        self.fetchInBackground(nil)
    }

    func fetchInBackground(block: ((NSError?) -> Void)?) {
        let reference: FIRDatabaseReference = self.databaseReference()
        
        reference.observeSingleEventOfType(FIRDataEventType.Value) { (snapshot: FIRDataSnapshot) in
            if snapshot.exists() {
                self.dictionary = snapshot.value as! [String : AnyObject]
                if block != nil {
                    block!(nil)
                }
            }
            else {
                if block != nil {
                    block!(NSError(domain: "Firebase Fetching", code: 100, userInfo:  nil))
                }
            }
        }
    }

// MARK: - Private methods

    func databaseReference() -> FIRDatabaseReference {
        var reference: FIRDatabaseReference? = nil
        
        if subpath == nil {
            reference = FIRDatabase.database().referenceWithPath(path!)
        }
        else {
            reference = FIRDatabase.database().referenceWithPath(path!).child(subpath!)
        }

        if dictionary[Constant.Firebase.OBJECTID] == nil {
            return reference!.childByAutoId()
        }
        else {
            return reference!.child(dictionary[Constant.Firebase.OBJECTID] as! String)
        }
    }
}


//
// Copyright (c) 2016 Elias
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Firebase
import FBSDKLoginKit
import SVProgressHUD

class FUser: FObject {
    
    var image: UIImage? = nil
// Class Functions
    class func imageNameWithDate() -> String{
        let interval = NSDate().timeIntervalSince1970;
        let userId = FUser.currentId()
        return userId + "/profile/\(interval).jpg"
    }
    
    class func imageNameWithUserId() -> String{
        let userId = FUser.currentId()
        return userId + "/profile.jpg"
    }
    
    class func currentId() -> String {
        if FIRAuth.auth()!.currentUser == nil {
            return "";
        }
        return FIRAuth.auth()!.currentUser!.uid
    }

    class func currentUser() -> FUser? {
        if FIRAuth.auth()!.currentUser != nil {
            let dictionary: [NSObject : AnyObject]? = NSUserDefaults.standardUserDefaults().objectForKey(Constant.StandardDefault.CURRENTUSER) as? [NSObject: AnyObject]
            if dictionary != nil {
                return FUser(path: Constant.Firebase.User.PATH, dictionary: dictionary!)
            }
        }
        return nil
    }

    class func updateCurrentUser(loginMethod: String) -> Void {
        Manager.sharedInstance.user = FIRAuth.auth()!.currentUser
        
        let user: FUser = FUser.currentUser()!
        var update: Bool = false;
        
        if user[Constant.Firebase.User.NAME_LOWER] == nil {
            update = true
            user[Constant.Firebase.User.NAME_LOWER] = user[Constant.Firebase.User.NAME]!.lowercaseString
        }
        
        if user[Constant.Firebase.User.LOGINMETHOD] == nil {
            update = true
            user[Constant.Firebase.User.LOGINMETHOD] = loginMethod
        }
        
        if update {
            user.saveInBackground()
        }
    }
    
    class func userWithId(userId: String) -> FUser? {
        let user: FUser = FUser(path: Constant.Firebase.User.PATH)
        user[Constant.Firebase.OBJECTID] = userId
        return user
    }

    class func signInWithEmail(email: String, password: String, completion: (user: FUser?, error: NSError?) -> Void) {
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user: FIRUser?, error: NSError?) in
            if error == nil {
                FUser.load(user, completion: { (user, error) in
                    if error == nil {
                        completion(user: user, error: nil)
                    }
                    else {
                        try! FIRAuth.auth()!.signOut()
                        completion(user: nil, error: error)
                    }
                })
            }
            else {
                completion(user: nil, error: error)
            }
        })
    }

    class func createUserWithEmail(email: String, password: String, name: String, completion: (user: FUser?, error: NSError?) -> Void) {
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (firuser: FIRUser?, error: NSError?) in
            if error == nil {
                FUser.create(firuser!.uid, email: email, name: name, picture: nil, completion: { (user, error) in
                    if error == nil {
                        completion(user: user, error: nil)
                    }
                    else {
                        firuser?.deleteWithCompletion({ (error: NSError?) in
                            if error != nil {
                                try! FIRAuth.auth()?.signOut()
                            }
                        })
                        completion(user: nil, error: error)
                    }
                })
            }
            else {
                completion(user: nil, error: error)
            }
        })
    }
    
    class func signInWithFacebook(viewController: UIViewController, completion: ((user: FUser?, error: NSError?) -> Void)?) {
        let login: FBSDKLoginManager = FBSDKLoginManager()
        let permissions: [AnyObject] = ["public_profile", "email", "user_friends"]
        login.logInWithReadPermissions(permissions, fromViewController: viewController) { (result, error) in
            if error == nil {
                if result.isCancelled == false {
                    SVProgressHUD.show()
                    let accessToken: String = FBSDKAccessToken.currentAccessToken().tokenString
                    let credential: FIRAuthCredential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
                    self.signInWithCredential(credential, completion: completion!)
                }
                else if completion != nil {
                    completion!(user: nil, error: nil)
                }
            }
            else if completion != nil {
                completion!(user: nil, error: error)
            }
        }
    }
    
    class func signInWithCredential(credential: FIRAuthCredential, completion: (user: FUser?, error: NSError?) -> Void) {
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (firuser: FIRUser?, error: NSError?) in
            if error == nil{
                FUser.load(firuser, completion: { (user, error) in
                    if error == nil {
                        completion (user: user, error: nil)
                    }
                    else {
                        try! FIRAuth.auth()?.signOut()
                        completion (user: nil, error: error)
                    }
                })
            }
            else {
                completion(user: nil, error: error)
            }
        })
    }
    
    class func load(firuser: FIRUser?, completion: (user: FUser?, error: NSError?) -> Void) {
        let user = FUser.userWithId(firuser!.uid)
        user!.fetchInBackground({ (error: NSError?) in
            if error != nil {
                let picture = (firuser!.photoURL != nil ? firuser!.photoURL!.absoluteString : "")
                self.create(firuser!.uid, email: firuser!.email, name: firuser!.displayName, picture: picture, completion: completion)
            }
            else {
                completion(user: user, error: nil)
            }
        })
    }

    class func create(uid: String, email: String?, name: String?, picture: String?, completion: (user: FUser?, error: NSError?) -> Void) {
        let user = FUser.userWithId(uid)
        
        if email != nil {
            user![Constant.Firebase.User.EMAIL] = email
        }
        if name != nil {
            user![Constant.Firebase.User.NAME] = name
        }
        if picture != nil {
            user![Constant.Firebase.User.PICTURE] = picture
        }
        
        user?.saveInBackground({ (error: NSError?) in
            if error == nil {
                completion(user: user, error: nil)
            }
            else {
                completion(user: nil, error: error)
            }
        })
    }
    
    class func logOut() -> Bool {
        do{
            try FIRAuth.auth()?.signOut()
            NSUserDefaults.standardUserDefaults().removeObjectForKey(Constant.StandardDefault.CURRENTUSER)
            NSUserDefaults.standardUserDefaults().synchronize()
            return true
        }catch{
            print("Error while signing out!")
        }
        return false
    }
    
    func isCurrent() -> Bool {
        return (self[Constant.Firebase.OBJECTID] as! String == FUser.currentId())
    }
    
    func saveLocalIfCurrent() {
        if self.isCurrent() {
            NSUserDefaults.standardUserDefaults().setObject(self.dictionary, forKey: Constant.StandardDefault.CURRENTUSER)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
//Override Functions
    override func saveInBackground() {
        self.saveLocalIfCurrent()
        super.saveInBackground()
    }

    override func saveInBackground(block: ((NSError?) -> Void)?) {
        self.saveLocalIfCurrent()
        
        super.saveInBackground({ (error: NSError?) in
            if error == nil {
                self.saveLocalIfCurrent()
            }
            if block != nil{
                block!(error)
            }
        })
    }
    
    override func fetchInBackground() {
        super.fetchInBackground { (error: NSError?) in
            if error == nil {
                self.saveLocalIfCurrent()
                
            }
        }
    }

    override func fetchInBackground(block: ((NSError?) -> Void)?) {
        super.fetchInBackground { (error: NSError?) in
            if error == nil {
                self.saveLocalIfCurrent()
            }
            if block != nil {
                block!(error)
            }
        }
    }
}

// Direct Access Extension
extension FUser {
    class func name() -> String? {
        if FUser.currentUser() != nil {
            return FUser.currentUser()!.name()
        }
        return nil;
    }
    
    class func picture() -> String? {
        if FUser.currentUser() != nil {
            return FUser.currentUser()!.picture()
        }
        return nil;
    }
    
    class func loginMethod() -> String? {
        if FUser.currentUser() != nil {
            return FUser.currentUser()!.loginMethod()
        }
        return nil;
    }

    func name() -> String? {
        return self[Constant.Firebase.User.NAME] as? String
    }
    
    func picture() -> String? {
        return self[Constant.Firebase.User.PICTURE] as? String
    }
    
    func loginMethod() -> String? {
        return self[Constant.Firebase.User.LOGINMETHOD] as? String
    }
    
    func mobilePhone() -> String? {
        return self[Constant.Firebase.User.MOBILEPHONE] as? String
    }
    
    func address() -> String? {
        return self[Constant.Firebase.User.ADDRESS] as? String
    }
    
    func email() -> String? {
        return self[Constant.Firebase.User.EMAIL] as? String
    }
}


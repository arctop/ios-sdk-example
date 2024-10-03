//
//  AuthTokenProvider.swift
//  ArctopCentral
//
//  Created by Shai on 13/11/2022.
//

import Foundation

class AuthTokenProvider{
    
    public static let shared = AuthTokenProvider()
    
    private static let secAttrName = "arctop_user_token"
    
    public static let HEADER = "Authorization"
    private static let USER_ID = "UserId"
    private static let PERF_USER_TOKEN = "arctopToken"
    private static let PERF_USER_PUBKEY = "arctopPubKey"
    
    private init(){
        let defaults = UserDefaults.standard
        userId = defaults.string(forKey: AuthTokenProvider.USER_ID)
        token = loadToken()
        //publicKey = loadPublicKey()
    }
    
    private var userId:String? = nil
    private var token:String? = nil
    public private(set) var publicKey:SecKey? = nil
    
    public func getUserId()  -> String{
        return userId ?? ""
    }
    
    public func getToken() -> String? {
        return token
    }
    
    public func setUserId(id:String?){
        userId = id
        UserDefaults.standard.set(userId, forKey: AuthTokenProvider.USER_ID)
        token = loadToken()
       // publicKey = loadPublicKey()
    }
    
    public func setUserIdAndToken(id:String? , token:String?) -> Bool{
        userId = id
        UserDefaults.standard.set(userId, forKey: AuthTokenProvider.USER_ID)
        let retValue = setToken(token: token)
     //   publicKey = loadPublicKey()
        return retValue
    }
    
    public func logoutUserAndDeleteToken(){
        // first delete the current token
        let _ = setToken(token: nil)
        // set the user id to nil
        setUserId(id: nil)
        publicKey = nil
    }
    
    public func setToken(token:String?) -> Bool{
        if (getUserId().isEmpty){
            return false
        }
        // first check if we have an entry for the user id
        // Set query
        let itemExistsQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: AuthTokenProvider.secAttrName,
            kSecAttrLabel as String: AuthTokenProvider.PERF_USER_TOKEN
        ]
        var item: CFTypeRef?
        // Check if user exists in the keychain
        if SecItemCopyMatching(itemExistsQuery as CFDictionary, &item) == noErr {
            // if the token is nil delete the entry if exists
            if (token == nil){
                let delResult = SecItemDelete(itemExistsQuery as CFDictionary)
                if delResult == noErr {
                    print("Token deleted successfully")
                    self.token = nil
                    return true
                }
                else{
                    print("Error deleting \(delResult)")
                    return false
                }
            }
            // else if we have an entry update it
            else{
                let attributes: [String: Any] = [
                    kSecAttrAccount as String: AuthTokenProvider.secAttrName,
                    kSecValueData as String: token!.data(using: .utf8)!
                ]
                let updateResult = SecItemUpdate(itemExistsQuery as CFDictionary, attributes as CFDictionary)
                if updateResult == noErr{
                    print("Token updated successfully")
                    self.token = token
                    return true
                }
                else{
                    print("Error updating \(updateResult)")
                    return false
                }
            }
            
        }
        else{
            let attributes: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: AuthTokenProvider.secAttrName,
                kSecValueData as String: token!.data(using: .utf8)!,
                kSecAttrLabel as String: AuthTokenProvider.PERF_USER_TOKEN
            ]
            let addResult = SecItemAdd(attributes as CFDictionary, nil)
            if  addResult == noErr {
                print("User saved successfully in the keychain")
                self.token = token
                return true
            } else {
                print("Something went wrong trying to save the user in the keychain \(addResult)")
                return false
            }
        }
    }
    
    private func loadToken() -> String?{
        
        if (getUserId().isEmpty){
            return nil
        }
        // Set query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: AuthTokenProvider.secAttrName,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
            kSecAttrLabel as String: AuthTokenProvider.PERF_USER_TOKEN
        ]
        var item: CFTypeRef?

        // Check if user exists in the keychain
        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
            // Extract result
            if let existingItem = item as? [String: Any],
               //let username = existingItem[kSecAttrAccount as String] as? String,
               let tokenData = existingItem[kSecValueData as String] as? Data,
               let token = String(data: tokenData, encoding: .utf8)
            {
                return token
            }
        } else {
            print("Something went wrong trying to find the user in the keychain")
        }
        return nil
    }
    
    
    
}

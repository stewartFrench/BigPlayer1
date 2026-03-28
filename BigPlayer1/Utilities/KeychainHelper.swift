//
//  KeychainHelper.swift
//  BigPlayer1
//
//  Created by Claude on 3/18/26.
//

import Foundation
import Security

//--------------------------------------------
/// Helper class for securely storing and retrieving data from the Keychain

class KeychainHelper
{
  static let shared = KeychainHelper()
  
  private init() {}
  
  //---------------------------------------
  /// Save a string value to the Keychain
  /// - Parameters:
  ///   - value: The string value to save
  ///   - key: The key to identify this value
  /// - Returns: True if successful, false otherwise

  func save(_ value: String, forKey key: String) -> Bool
  {
    guard let data = value.data(using: .utf8) else
    {
      return false
    }
            // First, delete any existing value for this key

    delete(forKey: key)
    
            // Create the query dictionary

    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecValueData as String: data,
      kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
    ]
    
            // Add the item to the Keychain

    let status = SecItemAdd(query as CFDictionary, nil)
    
    return status == errSecSuccess

  } // save
  

  //---------------------------------------
  /// Retrieve a string value from the Keychain
  /// - Parameter key: The key identifying the value
  /// - Returns: The string value if found, nil otherwise

  func retrieve(forKey key: String) -> String?
  {
            // Create the query dictionary

    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    
    guard status == errSecSuccess,
          let data = result as? Data,
          let string = String(data: data, encoding: .utf8) else
    {
      return nil
    }
    
    return string

  } // retrieve

  
  //---------------------------------------
  /// Delete a value from the Keychain
  /// - Parameter key: The key identifying the value to delete
  /// - Returns: True if successful, false otherwise

  @discardableResult
  func delete(forKey key: String) -> Bool
  {
            // Create the query dictionary

    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key
    ]
    
            // Delete the item from the Keychain

    let status = SecItemDelete(query as CFDictionary)
    
            // Success or item not found are both acceptable outcomes

    return status == errSecSuccess || status == errSecItemNotFound
  } // delete
  
  //---------------------------------------
  /// Check if a value exists in the Keychain
  /// - Parameter key: The key to check
  /// - Returns: True if the key exists, false otherwise

  func exists(forKey key: String) -> Bool
  {
    return retrieve(forKey: key) != nil
  } // exists
  
} // KeychainHelper

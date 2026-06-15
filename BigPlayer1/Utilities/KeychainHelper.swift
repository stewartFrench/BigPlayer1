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

  // Shared keychain access group for sharing data between apps
  private let keychainAccessGroup = "SDK22Z6CLU.com.stewart.french.shared"

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
      print("⚠️ KeychainHelper: Failed to convert value to data")
      return false
    }
            // First, delete any existing value for this key

    delete(forKey: key)

            // Create the query dictionary

    var query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecValueData as String: data,
      kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
    ]

    // Add keychain access group for sharing between apps
    query[kSecAttrAccessGroup as String] = keychainAccessGroup

            // Add the item to the Keychain

    var status = SecItemAdd(query as CFDictionary, nil)

    // If it fails with access group, try without it
    if status != errSecSuccess
    {
      print("⚠️ KeychainHelper: Save failed with access group (status: \(status)), trying without...")
      query.removeValue(forKey: kSecAttrAccessGroup as String)
      status = SecItemAdd(query as CFDictionary, nil)
    }

    if status == errSecSuccess
    {
      print("✅ KeychainHelper: Successfully saved key '\(key)'")
    }
    else
    {
      print("❌ KeychainHelper: Failed to save key '\(key)' (status: \(status))")
    }

    return status == errSecSuccess

  } // save
  

  //---------------------------------------
  /// Retrieve a string value from the Keychain
  /// - Parameter key: The key identifying the value
  /// - Returns: The string value if found, nil otherwise

  func retrieve(forKey key: String) -> String?
  {
            // Create the query dictionary

    var query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]

    // Add keychain access group for sharing between apps
    query[kSecAttrAccessGroup as String] = keychainAccessGroup

    var result: AnyObject?
    var status = SecItemCopyMatching(query as CFDictionary, &result)

    // If it fails with access group, try without it
    if status != errSecSuccess
    {
      print("⚠️ KeychainHelper: Retrieve failed with access group (status: \(status)), trying without...")
      query.removeValue(forKey: kSecAttrAccessGroup as String)
      result = nil
      status = SecItemCopyMatching(query as CFDictionary, &result)
    }

    guard status == errSecSuccess,
          let data = result as? Data,
          let string = String(data: data, encoding: .utf8) else
    {
      print("❌ KeychainHelper: Failed to retrieve key '\(key)' (status: \(status))")
      return nil
    }

    print("✅ KeychainHelper: Successfully retrieved key '\(key)'")
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

    var query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key
    ]

    // Add keychain access group for sharing between apps
    query[kSecAttrAccessGroup as String] = keychainAccessGroup

            // Delete the item from the Keychain

    var status = SecItemDelete(query as CFDictionary)

    // If it fails with access group (and it's not just "not found"), try without it
    if status != errSecSuccess && status != errSecItemNotFound
    {
      print("⚠️ KeychainHelper: Delete failed with access group (status: \(status)), trying without...")
      query.removeValue(forKey: kSecAttrAccessGroup as String)
      status = SecItemDelete(query as CFDictionary)
    }

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

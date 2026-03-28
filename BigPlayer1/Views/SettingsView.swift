//
//  SettingsView.swift
//  BigPlayer1
//
//  Created by Claude on 3/18/26.
//

import SwiftUI
import AVFoundation

//--------------------------------------------

struct SettingsView: View
{
  @State private var apiKey: String = ""
  @State private var showingSaveConfirmation: Bool = false
  @State private var isAPIKeySet: Bool = false
  @State private var selectedVoiceIdentifier: String = ""
  @State private var availableVoices: [AVSpeechSynthesisVoice] = []
  @State private var speechSynthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
  

  //---------------------------------------

  var body: some View
  {
    VStack(spacing: 20)
    {
      Text("Settings")
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding(.top)
      
      Divider()
      
      VStack(alignment: .leading, spacing: 10)
      {
        Text("Claude API Key")
          .font(.headline)
        
        Text("Enter your Anthropic API key to enable AI features")
          .font(.subheadline)
          .foregroundColor(.gray)
        
        SecureField("sk-ant-api03-...", text: $apiKey)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .autocapitalization(.none)
          .disableAutocorrection(true)
          .padding(.vertical, 5)
        
        if isAPIKeySet
        {
          HStack
          {
            Image(systemName: "checkmark.circle.fill")
              .foregroundColor(.green)
            Text("API Key is configured")
              .foregroundColor(.green)
          } // HStack
          .font(.subheadline)
        } // if
        
        HStack(spacing: 15)
        {
          Button(action: saveAPIKey)
          {
            Text("Save")
              .frame(maxWidth: .infinity)
              .padding()
              .background(apiKey.isEmpty ? Color.gray : Color.blue)
              .foregroundColor(.white)
              .cornerRadius(10)
          } // Button
          .disabled(apiKey.isEmpty)
          
          Button(action: clearAPIKey)
          {
            Text("Clear")
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.red)
              .foregroundColor(.white)
              .cornerRadius(10)
          } // Button
        } // HStack
        .padding(.top, 10)
      } //VStack
      .padding(.horizontal)
      
      Divider()
      
      VStack(alignment: .leading, spacing: 10)
      {
        Text("Speech Voice")
          .font(.headline)
        
        Text("Choose the voice for spoken responses")
          .font(.subheadline)
          .foregroundColor(.gray)
        
        Picker("Voice", selection: $selectedVoiceIdentifier)
        {
          ForEach(availableVoices, id: \.identifier)
          { voice in
            Text(voiceDisplayName(voice))
              .tag(voice.identifier)
          } // ForEach
        } // Picker
        .pickerStyle(.menu)
        .padding(.vertical, 5)
        
        HStack(spacing: 15)
        {
          Button(action: testVoice)
          {
            HStack
            {
              Image(systemName: "play.circle")
              Text("Test Voice")
            } // HStack
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
          } // Button
          
          Button(action: saveVoiceSelection)
          {
            Text("Save Voice")
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.blue)
              .foregroundColor(.white)
              .cornerRadius(10)
          } // Button
        } // HStack
      } // VStack
      .padding(.horizontal)
      
      Divider()
      
      VStack(alignment: .leading, spacing: 10)
      {
        Text("About API Keys")
          .font(.headline)
        
        Text("You can get your API key from:")
          .font(.subheadline)
        
        Link("console.anthropic.com/settings/keys",
             destination: URL(string: "https://console.anthropic.com/settings/keys")!)
          .font(.subheadline)
          .foregroundColor(.blue)
        
        Text("Your API key is stored locally on your device and is only used to make requests to Claude's API.")
          .font(.caption)
          .foregroundColor(.gray)
          .padding(.top, 5)
      } // VStack
      .padding(.horizontal)
      
      Spacer()
    }
    .onAppear
    {
      loadAPIKey()
      loadAvailableVoices()
      loadSelectedVoice()
    } // onAppear
    .alert("API Key Saved", isPresented: $showingSaveConfirmation)
    {
      Button("OK", role: .cancel) { }
    } 
    message: 
    {
      Text("Your Claude API key has been saved successfully.")
    }
  } // var body
  
  //---------------------------------------

  private func loadAPIKey()
  {
            // Try to load from Keychain first
    if let savedKey = KeychainHelper.shared.retrieve(forKey: "ClaudeAPIKey")
    {
      apiKey = savedKey
      isAPIKeySet = !savedKey.isEmpty
    } // if
    else
    {
      // Migrate from UserDefaults if exists
      if let oldKey = UserDefaults.standard.string(forKey: "ClaudeAPIKey")
      {
        apiKey = oldKey
        isAPIKeySet = !oldKey.isEmpty
        // Save to Keychain and remove from UserDefaults
        _ = KeychainHelper.shared.save(oldKey, forKey: "ClaudeAPIKey")
        UserDefaults.standard.removeObject(forKey: "ClaudeAPIKey")
      } // if
    } // else
  } // loadAPIKey
  
  //---------------------------------------

  private func saveAPIKey()
  {
            // Save to Keychain

    if KeychainHelper.shared.save(apiKey, forKey: "ClaudeAPIKey")
    {
      isAPIKeySet = !apiKey.isEmpty
      showingSaveConfirmation = true
    } // if
  } // saveAPIKey
  
  //---------------------------------------

  private func clearAPIKey()
  {
    apiKey = ""
            // Delete from Keychain
    KeychainHelper.shared.delete(forKey: "ClaudeAPIKey")
            // Also remove from UserDefaults in case of old data
    UserDefaults.standard.removeObject(forKey: "ClaudeAPIKey")
    isAPIKeySet = false
  } // clearAPIKey
  
  //---------------------------------------

  private func loadAvailableVoices()
  {
            // Get all available voices
    let allVoices = AVSpeechSynthesisVoice.speechVoices()
    
            // Filter for English voices
    let englishVoices = allVoices.filter { $0.language.hasPrefix("en") }
    
            // Sort voices by quality - prioritize premium/enhanced voices
    availableVoices = englishVoices.sorted
    { voice1, voice2 in
      // Check for premium/enhanced quality indicators
      let quality1 = getVoiceQualityScore(voice1)
      let quality2 = getVoiceQualityScore(voice2)
      
      if quality1 != quality2
      {
        return quality1 > quality2
      } // if
      
      // If same quality, sort by name
      return voice1.name < voice2.name
    } // sorted
  } // loadAvailableVoices
  
  //---------------------------------------

  private func getVoiceQualityScore(_ voice: AVSpeechSynthesisVoice) -> Int
  {
            // Premium/enhanced voices typically have specific traits
            // Higher score = higher quality
    var score = 0
    
            // Check voice quality (iOS 9+)
    if #available(iOS 9.0, *)
    {
              // Quality levels: default=1, enhanced=2, premium=3
      switch voice.quality.rawValue
      {
        case 3: // Premium (highest standard quality)
          score += 300
        case 2: // Enhanced
          score += 200
        case 1: // Default
          score += 100
        default:
          score += 0
      }
    } // if
    
            // Prefer certain voice names known for quality
    let highQualityNames = ["Ava", "Samantha", "Alex", "Allison"]
    if highQualityNames.contains(voice.name)
    {
      score += 10
    } // if
    
    return score
  } // getVoiceQualityScore
  
  //---------------------------------------

  private func voiceDisplayName(_ voice: AVSpeechSynthesisVoice) -> String
  {
    var displayName = "\(voice.name) (\(voice.language))"
    
            // Add quality indicator based on rawValue
    if #available(iOS 9.0, *)
    {
      switch voice.quality.rawValue
      {
        case 3: // Premium (highest)
          displayName += " - Premium 💎"
        case 2: // Enhanced
          displayName += " - Enhanced ⭐"
        default:
          break
      } // switch
    } // if
    
    return displayName
  } // voiceDisplayName
  
  //---------------------------------------

  private func loadSelectedVoice()
  {
    if let savedIdentifier = UserDefaults.standard.string(forKey: "SelectedVoiceIdentifier")
    {
      selectedVoiceIdentifier = savedIdentifier
    } // if
    else if let firstVoice = availableVoices.first
    {
      // Default to first (highest quality) voice
      selectedVoiceIdentifier = firstVoice.identifier
    } // else
  } // loadSelectedVoice
  
  //---------------------------------------

  private func saveVoiceSelection()
  {
    UserDefaults.standard.set(selectedVoiceIdentifier, forKey: "SelectedVoiceIdentifier")
  } // saveVoiceSelection
  
  //---------------------------------------

  private func testVoice()
  {
            // Stop any ongoing speech
    if speechSynthesizer.isSpeaking
    {
      speechSynthesizer.stopSpeaking(at: .immediate)
    } // if
    
            // Find the selected voice
    guard let voice = AVSpeechSynthesisVoice(identifier: selectedVoiceIdentifier) else
    {
      return
    } // guard
    
            // Create and speak a test utterance
    let utterance = AVSpeechUtterance(
      string: "Hello, this is a preview of the selected voice."
    )
    utterance.voice = voice
    utterance.rate = 0.5
    
    speechSynthesizer.speak(utterance)
  } // testVoice
  
} // SettingsView


//--------------------------------------------
#Preview
{
  SettingsView()
}

//
//  TrackDetailsView.swift
//  BigPlayer1
//
//  Created by Stewart French on 3/5/23.
//

import SwiftUI
import AVFoundation
import MediaPlayer


//--------------------------------------------
enum ClaudeAPIError: Error, Equatable
{
  case missingAPIKey
  case invalidResponse
} // ClaudeAPIError


//--------------------------------------------
class SpeechCoordinator: NSObject, AVSpeechSynthesizerDelegate
{
  var onFinish: (@MainActor () -> Void)?
  
  nonisolated func speechSynthesizer(
    _ synthesizer: AVSpeechSynthesizer,
    didFinish utterance: AVSpeechUtterance
  )
  {
    if let onFinish = onFinish
    {
      Task { @MainActor in
        onFinish()
      }
    } // if
  } // speechSynthesizer didFinish
} // SpeechCoordinator


//--------------------------------------------
struct TrackDetailsView: View
{
  @EnvironmentObject var musicVM : MusicViewModel
  
  @State var localTrackSelected : Int
  
  @State var MusicStateChanged : Bool = false
  
  @State var elapsedTrackTime : Float = 0
  @State var countdownTime : Double = 0
  
  @State var timer = Timer.publish(
    every: 0.5,
    on: .main,
    in: .common ).autoconnect()

  @State var countdownTimeMinutes : String = ""
  @State var countdownTimeSeconds : String = ""
  
  // Claude API and Speech state variables
  @State var isResearching : Bool = false
  @State var isSpeaking : Bool = false
  @State var speechSynthesizer : AVSpeechSynthesizer = AVSpeechSynthesizer()
  @State var speechCoordinator : SpeechCoordinator = SpeechCoordinator()
  @State var researchTask : Task<Void, Never>? = nil
  @State var wasMusicPlaying : Bool = false
  @State var showingAPIKeyAlert : Bool = false

  
  //---------------------------------------
  func stopTimer()
  {
    timer.upstream.connect().cancel()
  } // stopTimer
  
  
  func startTimer()
  {
    timer = Timer.publish(
      every: 0.5,
      on: .main,
      in: .common ).autoconnect()
  } // startTimer
  
  
  
  //---------------------------------------
  func stopResearch()
  {
    researchTask?.cancel()
    researchTask = nil
    isResearching = false
  } // stopResearch
  
  
  //---------------------------------------
  @MainActor
  func stopSpeech()
  {
//    print("🔵 stopSpeech called")
    speechSynthesizer.stopSpeaking(at: .immediate)
    
            // Wait a moment for the synthesizer to fully stop
    Task { @MainActor in
      try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
      
      self.isSpeaking = false
      
            // Resume music if it was playing
      if self.wasMusicPlaying
      {
//        print("🔵 Resuming music after stop")
        self.musicVM.playSelectedTrack()
        self.wasMusicPlaying = false
      } // if
    } // Task
  } // stopSpeech
  
  
  //---------------------------------------
  func cleanupSpeechAndResearch()
  {
    stopResearch()
    stopSpeech()
    wasMusicPlaying = false
  } // cleanupSpeechAndResearch
  
  
  //---------------------------------------
  func queryClaudeAndSpeak(
    prompt : String
  )
  {
//    print("🔵 queryClaudeAndSpeak called with prompt: \(prompt)")
    
          // Check if music is playing (don't pause yet - let it play during research)
    if musicVM.isPlaying()
    {
      wasMusicPlaying = true
    } // if
    
    isResearching = true
//    print("🔵 Research started")
    
    researchTask = Task
    {
      do
      {
//        print("🔵 About to query Claude API")
            // Query Claude API
        let response = try await queryClaudeAPI(
          prompt: prompt
        )
        
//        print("🔵 Got response from Claude: \(response.prefix(100))...")
        
            // Check if task was cancelled
        guard !Task.isCancelled 
        else
        {
//          print("🔵 Task was cancelled")
          await MainActor.run
          {
            isResearching = false
            if wasMusicPlaying
            {
              musicVM.playSelectedTrack()
              wasMusicPlaying = false
            } // if
          } // MainActor.run
          return
        } // guard
        
        await MainActor.run
        {
//          print("🔵 Starting speech")
          isResearching = false
          speakText(
            text: response
          )
        } // MainActor.run
      } // do
      catch
      {
//        print("🔴 Error in queryClaudeAndSpeak: \(error)")
        await MainActor.run
        {
          isResearching = false
          
          // Show alert if API key is missing
          if let apiError = error as? ClaudeAPIError,
             apiError == .missingAPIKey
          {
            showingAPIKeyAlert = true
          } // if
          
          if wasMusicPlaying
          {
            musicVM.playSelectedTrack()
            wasMusicPlaying = false
          } // if
        } // MainActor.run
      } // catch
    } // Task
  } // queryClaudeAndSpeak
  
  
  //---------------------------------------
  func queryClaudeAPI(
    prompt : String
  ) async throws -> String
  {
//    print("🔵 queryClaudeAPI called")
    
    // Get API key from Keychain
    guard let apiKey = KeychainHelper.shared.retrieve(forKey: "ClaudeAPIKey"),
          !apiKey.isEmpty else
    {
      throw ClaudeAPIError.missingAPIKey
    } // guard
    
//    print("🔵 API key configured")
    
    let url = URL(string: "https://api.anthropic.com/v1/messages")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue(
      "application/json",
      forHTTPHeaderField: "Content-Type"
    )
    request.setValue(
      apiKey,
      forHTTPHeaderField: "x-api-key"
    )
    request.setValue(
      "2023-06-01",
      forHTTPHeaderField: "anthropic-version"
    )
    
    let requestBody: [String: Any] = [
      "model": "claude-3-haiku-20240307",
      "max_tokens": 1024,
      "messages": [
        [
          "role": "user",
          "content": prompt
        ]
      ]
    ]
    
    request.httpBody = try JSONSerialization.data(
      withJSONObject: requestBody
    )
    
//    print("🔵 Making API request to Anthropic")
    
    let (data, response) = try await URLSession.shared.data(
      for: request
    )
    
//    print("🔵 Got response from API")
    
    guard let httpResponse = response as? HTTPURLResponse else
    {
//      print("🔴 Invalid HTTP response")
      throw ClaudeAPIError.invalidResponse
    } // guard
    
//    print("🔵 HTTP Status code: \(httpResponse.statusCode)")
    
    if httpResponse.statusCode != 200
    {
      _ = String(
        data: data,
        encoding: .utf8
      ) ?? "Unknown error"
//      print("🔴 API error response: \(errorText)")
      throw ClaudeAPIError.invalidResponse
    } // if
    
    let jsonResponse = try JSONSerialization.jsonObject(
      with: data
    ) as? [String: Any]
    
    guard let content = jsonResponse?["content"] as? [[String: Any]],
          let text = content.first?["text"] as? String else
    {
//      print("🔴 Could not parse response JSON")
      throw ClaudeAPIError.invalidResponse
    } // guard
    
//    print("🔵 Successfully parsed response")
    return text
  } // queryClaudeAPI
  
  
  //---------------------------------------
  func getSelectedVoice() -> AVSpeechSynthesisVoice?
  {
    // Try to load saved voice identifier
    if let savedIdentifier = UserDefaults.standard.string(forKey: "SelectedVoiceIdentifier"),
       let voice = AVSpeechSynthesisVoice(identifier: savedIdentifier)
    {
      return voice
    }
    
    // Fall back to default en-US voice
    return AVSpeechSynthesisVoice(language: "en-US")
  } // getSelectedVoice
  
  //---------------------------------------
  @MainActor
  func speakText(
    text : String
  )
  {
//    print("🔵 speakText called with text length: \(text.count)")
    
          // Pause music now, just before speaking
    if wasMusicPlaying && musicVM.isPlaying()
    {
      musicVM.pauseSelectedTrack()
//      print("🔵 Music paused before speaking")
    } // if
    
    isSpeaking = true
    
    Task { @MainActor in
            // Create synthesizer synchronously
      let localSynthesizer = AVSpeechSynthesizer()
      localSynthesizer.usesApplicationAudioSession = false
      speechSynthesizer = localSynthesizer
      localSynthesizer.delegate = speechCoordinator
      
      let utterance = AVSpeechUtterance(
        string: text
      )
      utterance.voice = getSelectedVoice()
      utterance.rate = 0.5
      
            // Wait for speech to finish using continuation
      await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
        speechCoordinator.onFinish = {
          continuation.resume()
        }
              // Use assumeIsolated to ensure speak() is called synchronously on MainActor
        MainActor.assumeIsolated {
          localSynthesizer.speak(utterance)
        }
      } // withCheckedContinuation
      
      if isSpeaking
      {
        isSpeaking = false
        
              // Resume music if it was playing
        if wasMusicPlaying
        {
          musicVM.playSelectedTrack()
          wasMusicPlaying = false
        } // if
      } // if
    } // Task
  } // speakText
  
  
  //---------------------------------------
  var body: some View
  {
    VStack
    {
      VStack
      {
        VStack
        {
          Divider()
          Text( "Artist" )
             .frame(maxWidth: .infinity, alignment: .leading)
          Divider()
          Button(
            action:
              {
                let artistName = musicVM.trackArtist(
                  trackIndex: localTrackSelected
                )
                let prompt = "Tell me about artist \(artistName)"
                queryClaudeAndSpeak(
                  prompt: prompt
                )
              },
            label:
              {
                Text( musicVM.trackArtist(
                  trackIndex: localTrackSelected ) )
                .font(.largeTitle)
                .foregroundColor(.white)
                .frame(
                  maxWidth: .infinity,
                  alignment: .center
                )
              } ) // Button
          .disabled( isResearching || isSpeaking )
          Divider()
        } // VStack
        
        VStack
        {
          Divider()
          Text( "Album" )
             .frame(maxWidth: .infinity, alignment: .leading)
          Divider()
          Button(
            action:
              {
                let artistName = musicVM.trackArtist(
                  trackIndex: localTrackSelected
                )
                let albumName = musicVM.trackAlbum(
                  trackIndex: localTrackSelected
                )
                let prompt = "Tell me about album \"\(albumName)\" by artist \"\(artistName)\""
                queryClaudeAndSpeak(
                  prompt: prompt
                )
              },
            label:
              {
                Text( musicVM.trackAlbum(
                  trackIndex: localTrackSelected ) )
                .font(.largeTitle)
                .foregroundColor(.white)
                .frame(
                  maxWidth: .infinity,
                  alignment: .center
                )
              } ) // Button
          .disabled( isResearching || isSpeaking )
          Divider()
        } // VStack
        
        VStack
        {
          Divider()
          Text( "Track" )
             .frame(maxWidth: .infinity, alignment: .leading)
          Divider()
          Button(
            action:
              {
                let artistName = musicVM.trackArtist(
                  trackIndex: localTrackSelected
                )
                let albumName = musicVM.trackAlbum(
                  trackIndex: localTrackSelected
                )
                let trackName = musicVM.trackName(
                  trackIndex: localTrackSelected
                )
                let prompt = "Tell me about the track \"\(trackName)\" from the album \"\(albumName)\" by artist \"\(artistName)\""
                queryClaudeAndSpeak(
                  prompt: prompt
                )
              },
            label:
              {
                Text( musicVM.trackName(
                  trackIndex: localTrackSelected ) )
                .font(.largeTitle)
                .foregroundColor(.white)
                .frame(
                  maxWidth: .infinity,
                  alignment: .center
                )
              } ) // Button
          .disabled( isResearching || isSpeaking )
          Divider()
        } // VStack
        
                // Progress indicators and stop buttons
        if isResearching
        {
          VStack
          {
            Divider()
            Text( "Researching..." )
              .font( .title )
              .foregroundColor( .yellow )
            
            ProgressView()
              .progressViewStyle(
                CircularProgressViewStyle(
                  tint: .yellow
                )
              )
              .scaleEffect( 2.0 )
              .padding()
            
            Button(
              action:
                {
                  stopResearch()
                  if wasMusicPlaying
                  {
                    musicVM.playSelectedTrack()
                    wasMusicPlaying = false
                  } // if
                },
              label:
                {
                  Text( "Stop Research" )
                    .font( .title2 )
                    .foregroundColor( .white )
                    .padding()
                    .background( Color.red )
                    .cornerRadius( 10 )
                } ) // Button
            Divider()
          } // VStack
        } // if
        
        if isSpeaking
        {
          VStack
          {
            Divider()
            Text( "Speaking..." )
              .font( .title )
              .foregroundColor( .green )
            
            ProgressView()
              .progressViewStyle(
                CircularProgressViewStyle(
                  tint: .green
                )
              )
              .scaleEffect( 1.5 )
              .padding()
            
            Button(
              action:
                {
                  stopSpeech()
                },
              label:
                {
                  Text( "Stop Speaking" )
                    .font( .title2 )
                    .foregroundColor( .white )
                    .padding()
                    .background( Color.red )
                    .cornerRadius( 10 )
                } ) // Button
            Divider()
          } // VStack
        } // if
        
        Spacer()
        VStack
        {
          HStack
          {
            Spacer()
            Text( "Remaining:" )
            .font( .largeTitle )
            .foregroundColor(.white)

            ZStack(alignment: .leading) 
            {
              Text("00m 00s").opacity(0.0)
              Text("\(countdownTimeMinutes) \(countdownTimeSeconds)" )
            }
            .font( .largeTitle )
            .monospacedDigit()
          } // HStack

          Divider()
          Divider()

        } // VStack
      } // VStack
      
      Spacer()


      //-------------------------------------------
      // Progress Bar
      
      ProgressView(
        value: elapsedTrackTime,
        total: 1.0 )
      .accentColor(Color.green)
      .background( .black)
      .scaleEffect(x: 1, y: 10, anchor: .bottom)
      
      .onReceive( timer,
                  perform:
      { _ in
        
        localTrackSelected = 
           musicVM.getSelectedTrackIndex() ?? 0
        
        if musicVM.elapsedTimeOfSelectedTrack() <
            musicVM.durationOfSelectedTrack()
        {
          elapsedTrackTime =
          Float( musicVM.elapsedTimeOfSelectedTrack() /
                 musicVM.durationOfSelectedTrack() )

          countdownTime =
            musicVM.durationOfSelectedTrack() -
              musicVM.elapsedTimeOfSelectedTrack()
       } // if
       else 
       {
           elapsedTrackTime = 0.0
           countdownTime = 0.0
       } // else

        MusicStateChanged = !MusicStateChanged

        let tMinutes = Int(countdownTime) / 60
        let tSeconds = Int(countdownTime) % 60

        countdownTimeMinutes = "\(tMinutes)m"
        countdownTimeSeconds = "\(tSeconds)s"
        
      } )  // onReceive
      
      
      
      //-------------------------------------------
      // Previous Track Button
      
      HStack
      {
        Button(
          action:
            {
              musicVM.previousTrackPressed()
              localTrackSelected = musicVM.getSelectedTrackIndex() ?? 0
              MusicStateChanged = !MusicStateChanged
            }, label: {
              Image( "slf_rewind" )
            } ) // Button
        
        Spacer()
        
        
        
        //-------------------------------------------
        // Play/Pause Button
        
        Button(
          action:
            {
              localTrackSelected = musicVM.getSelectedTrackIndex() ?? 0
              
              if musicVM.isPlaying()
              {
                musicVM.pauseSelectedTrack()
              } else {
                musicVM.playSelectedTrack()
              }
              MusicStateChanged = !MusicStateChanged
              
            }, 
          label: 
            {
              ZStack
              {
                Text( MusicStateChanged ? "" : "" )
                Image( musicVM.isPlaying() ? "slf_pause" : "slf_play" )
              }
            } ) // Button
        
        Spacer()
        
        
        
        //-------------------------------------------
        // Forward Track Button
        
        Button(
          action:
            {
              musicVM.nextTrackPressed()
              localTrackSelected =
              musicVM.getSelectedTrackIndex() ?? 0
              MusicStateChanged = !MusicStateChanged
            }, label: {
              Image( "slf_fastforward" )
              
            } ) // Button
      }
      .font(.system(size:64))
      
    } // VStack
    
    
    //-------------------------------------------
    // When the View appears
    
    .onAppear
    {
      elapsedTrackTime = 0
      countdownTime = 0
      startTimer()
      MusicStateChanged = !MusicStateChanged
    }
    
    //-------------------------------------------
    // When the View disappears
    
    .onDisappear()
    {
      stopTimer()
      cleanupSpeechAndResearch()
    }
    
    //-------------------------------------------
    // Toolbar with Settings icon
    
    .toolbar
    {
      ToolbarItem(placement: .navigationBarTrailing)
      {
        NavigationLink(destination: SettingsView())
        {
          Image(systemName: "gear")
            .font(.title2)
            .foregroundColor(.white)
        }
      } // ToolbarItem
    } // toolbar
    
    //-------------------------------------------
    // Alert for missing API key
    
    .alert("API Key Required", isPresented: $showingAPIKeyAlert)
    {
      Button("OK", role: .cancel) { }
    } message: {
      Text("Please configure your Claude API key in Settings to use AI features.")
    }
    
  } // var body
  
} // TrackDetailsView



//--------------------------------------------

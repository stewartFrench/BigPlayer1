//
//  TrackDetailsView.swift
//  BigPlayer1
//
//  Created by Stewart French on 3/5/23.
//

import SwiftUI

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
          Text( musicVM.trackArtist(
            trackIndex: localTrackSelected ) )
          .font(.largeTitle)
          .foregroundColor(.white)
          Divider()
        } // VStack
        
        VStack
        {
          Divider()
          Text( "Album" )
             .frame(maxWidth: .infinity, alignment: .leading)
          Divider()
          Text( musicVM.trackAlbum(
            trackIndex: localTrackSelected ) )
          .font(.largeTitle)
          .foregroundColor(.white)
          Divider()
        } // VStack
        
        VStack
        {
          Divider()
          Text( "Track" )
             .frame(maxWidth: .infinity, alignment: .leading)
          Divider()
          Text( musicVM.trackName(
            trackIndex: localTrackSelected ) )
          .font(.largeTitle)
          .foregroundColor(.white)
          Divider()
        } // VStack
        
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
       } 
       else 
       {
           elapsedTrackTime = 0.0
           countdownTime = 0.0
        }

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
    }
    
  } // var body
  
} // TrackDetailsView



//--------------------------------------------

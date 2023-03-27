//
//  ResumeView.swift
//  BigPlayer1
//
//  Created by Stewart French on 3/16/23.
//

import SwiftUI

struct ResumeView: View
{
  @EnvironmentObject var musicVM : MusicViewModel

  @State var localTrackSelected : Int? = nil
  @State var MusicStateChanged : Bool = false

  @State var elapsedTrackTime : Float = 0

  @State var timer = Timer.publish(
    every: 0.5,
    on: .main,
    in: .common ).autoconnect()

  @State var scrollToCurrentTrack : Bool = false

  @State var notAuthorized : Bool = false


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


  //---------------------------------------------
  var body: some View
  {
    VStack(spacing: 0)
    {
      //-------------------------------------------
      // Tracks Listing

      ScrollView
      {
        Button(
          action:
            {
              musicVM.shuffleTracks()
              musicVM.setSelectedTrack( trackIndex: 0 )
              musicVM.prepareTracksToPlay()
              musicVM.playSelectedTrack()
              musicVM.saveTrackInfoToAppStorage()

            }, 
          label:
            {
              VStack
              {
                Text( "Shuffle")
                  .font(.system(size: 36.0))
                  .frame(
                    maxWidth: .infinity,
                    minHeight: 75,
                    maxHeight: .infinity,
                    alignment: .leading )
                  .lineLimit( 3 )
                  .foregroundColor( .yellow )
                Divider()
              }
            })

        ScrollViewReader
        { proxy in
          ForEach( musicVM.MMTracks.indices, id: \.self )
          { feTrack in
            Button(
              action:
                {
                  localTrackSelected = feTrack
                  musicVM.setSelectedTrack(
                    trackIndex: feTrack)
                  musicVM.playSelectedTrack()
                  musicVM.saveTrackInfoToAppStorage()
                  proxy.scrollTo( feTrack )

                }, 
              label:
                {

                  // This can't be the proper way to do this!!
                  // I created a State var that indicates music went
                  // from playing to paused and viceVersa so that these
                  // images and fields would get updated.  Works, but...
                  // yuk!
                  VStack
                  {
                    ZStack
                    {
                      Text( MusicStateChanged ? "" : "" )



                      HStack
                      {
                        Text( musicVM.trackName(
                          trackIndex:feTrack ) )
                        .padding( .leading )
                        .font(.system(size: 36.0))
                        .frame(
                          maxWidth: .infinity,
                          minHeight: 75,
                          maxHeight: .infinity,
                          alignment: .leading )
                        .multilineTextAlignment(.leading)
                        .lineLimit( 3 )

                        Spacer()
                        NavigationLink(
                          destination: TrackDetailsView(
                            localTrackSelected: feTrack ),
                          label:
                            {
                              Image(systemName: "info.circle")
                            } )
                        .padding( .trailing )
                        .opacity(
                          ( localTrackSelected != nil &&
                            localTrackSelected == feTrack ) ? 1 : 0 )

                      } // HStack
                      .foregroundColor(
                        ( localTrackSelected != nil &&
                          localTrackSelected == feTrack ) ?
                        Color(uiColor: .green) : .white )
                      .background(
                        ( localTrackSelected != nil &&
                          localTrackSelected == feTrack ) ?
                        Color(uiColor: .darkGray) : .black )
                    } // ZStack
                    Divider()
                  } // VStack
                } ) // Button
            .id( feTrack )

          } // ForEach

          .onChange(
            of: localTrackSelected,
            perform:
              { value in
                withAnimation(.spring() )
                {
                  musicVM.setSelectedTrack( trackIndex: value! )
                  proxy.scrollTo(value, anchor: .center)
                }
              } ) // onChange

          .onChange(
            of: scrollToCurrentTrack,
            perform:
              { _ in
                withAnimation(.spring() )
                {
                  proxy.scrollTo(localTrackSelected, anchor: .center)
                }
              } ) // onChange

        }  // ScrollViewReader
      } // ScrollView

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

        localTrackSelected = musicVM.getSelectedTrackIndex()

        if musicVM.elapsedTimeOfSelectedTrack() <
            musicVM.durationOfSelectedTrack()
        {
          elapsedTrackTime =
          Float( musicVM.elapsedTimeOfSelectedTrack() /
                 musicVM.durationOfSelectedTrack() )
        } else 
        {
          elapsedTrackTime = 0.0
        }
        MusicStateChanged = !MusicStateChanged

      } )  // onReceive



      //-------------------------------------------
      // Previous Track Button

      HStack
      {
        Button(
          action:
            {
              musicVM.previousTrackPressed()
              localTrackSelected = musicVM.getSelectedTrackIndex()
              musicVM.saveTrackInfoToAppStorage()
              MusicStateChanged = !MusicStateChanged
            }, 
          label:
            {
              Image( "slf_rewind" )
            }) // Button

        Spacer()



        //-------------------------------------------
        // Play/Pause Button

        Button(
          action:
            {
              localTrackSelected = musicVM.getSelectedTrackIndex()

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
            }) // Button

        Spacer()



        //-------------------------------------------
        // Forward Track Button

        Button(
          action:
            {
              musicVM.nextTrackPressed()
              localTrackSelected =
              musicVM.getSelectedTrackIndex()
              musicVM.saveTrackInfoToAppStorage()
              MusicStateChanged = !MusicStateChanged
            }, 
          label: 
            {
              Image( "slf_fastforward" )

            }) // Button
      }
      .font(.system(size:64))

    } // VStack

        //-------------------------------------------
        // Navigation Bar


    .navigationBarTitle(
      musicVM.ASCollectionName,
      displayMode: .inline )
    .navigationBarItems(
      trailing:
        Button(
          action:
            {
              scrollToCurrentTrack.toggle()
            },
          label:
            {
              Image( systemName: "filemenu.and.selection" )
            } )
    )

    //-------------------------------------------
    // When the View appears
    
    .onAppear
    {
      notAuthorized = !musicVM.authorizedToAccessMusic

      localTrackSelected = musicVM.getSelectedTrackIndex()
      elapsedTrackTime = 0
      startTimer()
      MusicStateChanged = !MusicStateChanged
    } // .onAppear

    .alert( isPresented: $notAuthorized )
    {
      Alert( 
        title: Text( "Not Allowed to Access the Music Library." ),
        message: Text( "Go to Settings > One Big Player\nto Allow Access to Apple Music" ) )
    } // .alert

    //-------------------------------------------
    // When the View disappears

    .onDisappear()
    {
      stopTimer()
    }
  } // var body

} // ResumeView

//--------------------------------------------

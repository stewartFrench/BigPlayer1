//
//  TracksView.swift
//  BigPlayer1
//
//  Created by Stewart French on 3/8/23.
//

import SwiftUI

struct TracksView: View
{
  @EnvironmentObject var musicVM : MusicViewModel

  @State var localTrackSelected : Int? = nil
  @State var MusicStateChanged : Bool = false

  @State var elapsedTrackTime : Float = 0
  @State var countdownTime : Double = 0

  @State var timer = Timer.publish(
    every: 0.5,
    on: .main,
    in: .common ).autoconnect()

  @State var scrollToCurrentTrack : Bool = false

  @State var countdownTimeMinutes : String = ""
  @State var countdownTimeSeconds : String = ""


  //---------------------------------------
  func stopTimer() {
    timer.upstream.connect().cancel()
  }

  func startTimer() {
    timer = Timer.publish(
      every: 0.5,
      on: .main,
      in: .common ).autoconnect()
  }


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
              musicVM.prepareTracksToPlay()
              musicVM.setSelectedTrack( trackIndex: 0 )
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
                  musicVM.saveTrackInfoToAppStorage()
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

      ZStack( alignment: .bottom )
      {
        ProgressView(
          value: elapsedTrackTime,
          total: 1.0 )
        .accentColor(Color.green)
        .background( .black)
        .scaleEffect(x: 1, y: 10, anchor: .bottom)

        Text( countdownTimeMinutes + countdownTimeSeconds )
        .font(.body)
        .monospacedDigit( )

      }  // ZStack

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
         countdownTime =
            musicVM.durationOfSelectedTrack() -
              musicVM.elapsedTimeOfSelectedTrack()
         MusicStateChanged = !MusicStateChanged

         let tMinutes = Int(countdownTime) / 60
         let tSeconds = Int(countdownTime) % 60

         countdownTimeMinutes = "\(tMinutes)m"
         countdownTimeSeconds = "\(tSeconds)s"

      })  // onReceive



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
              } else 
              {
                musicVM.playSelectedTrack()
                musicVM.saveTrackInfoToAppStorage()
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
      musicVM.getCollectionName(),
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
      localTrackSelected = musicVM.getSelectedTrackIndex()
      musicVM.saveTrackInfoToAppStorage()
      elapsedTrackTime = 0
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

} // TracksView

//--------------------------------------------

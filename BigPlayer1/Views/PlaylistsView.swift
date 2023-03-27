//
//  PlaylistsView.swift
//  BigPlayer1
//
//  Created by Stewart French on 2/2/23.
//

import SwiftUI
import MediaPlayer

//--------------------------------------------
struct PlaylistsView: View 
{
  @EnvironmentObject var musicVM : MusicViewModel
  
  @State private var tSelectedPlaylist: Int? = nil
  
  @State private var scrollToCurrentPlaylist : Bool = false
  
  @State private var thumbedPlaylist : Int = 0
  
  @State var notAuthorized : Bool = false
  

  //-------------------
  var body: some View
  {
    ZStack
    {
      // Background
      
      Color.black
        .edgesIgnoringSafeArea( .all )
      
      // content
      
        HStack
        {
          ScrollView( showsIndicators: true )
          {
            ScrollViewReader
            { proxy in
              
              ForEach( musicVM.MMPlaylists.indices, id: \.self )
              { feIndex in
                
                NavigationLink(
                  destination: TracksView(),
                  label:
                    {
                      VStack
                      {
                        Text(musicVM.getPlaylistName(index: feIndex))
                          .font(.system(size: 36.0))
                          .frame(
                            maxWidth: .infinity,
                            minHeight: 50,
                            maxHeight: .infinity,
                            alignment: .leading )
                          .multilineTextAlignment(.leading)
                          .lineLimit( 3 )
                          .foregroundColor(
                            tSelectedPlaylist==feIndex ?
                            Color(uiColor: .green) : .white )
                          .background(
                            tSelectedPlaylist==feIndex ?
                            Color(uiColor: .darkGray) : .black )
                        Divider()
                      } // VStack
                    } ) // NavigationLink
                .id( feIndex )
                .simultaneousGesture(
                  TapGesture().onEnded
                  {
                    musicVM.setSelectedPlaylist(
                      index: feIndex )

                    musicVM.retrieveTracksFromPlaylist(
                      playlistIndex: feIndex )

                    musicVM.prepareTracksToPlay()

                  } ) // simultaneousGesture

              } // Foreach
              
              .onChange(
                of: scrollToCurrentPlaylist,
                perform:
                  { _ in
                    withAnimation(.spring() )
                    {
                      proxy.scrollTo(tSelectedPlaylist, anchor: .center)
                    }
                    
                  } ) // onChange

              .onChange(
                of: thumbedPlaylist,
                perform:
                  { _ in
                    withAnimation(.spring() )
                    {
                      proxy.scrollTo( thumbedPlaylist, anchor: .center )
                    }
                    
                  } ) // onChange
                  
            } // ScrollViewReader
          } // ScrollView

          Divider()

          Spacer()
          Spacer()

          verticalAZsliderPlaylists( scrollTo: $thumbedPlaylist )
        } // HStack
    } // ZStack


        //-------------------------------------------
        // Navigation Bar


    .navigationBarTitle( "Playlists", displayMode: .inline )
    .font(.largeTitle)
    .foregroundColor(.white)

    .navigationBarItems(
      trailing:
        HStack
      {

        NavigationLink(
          destination: TracksView(),
          label:
            {
              Image( systemName: "waveform" )
            } )
        .disabled( musicVM.selectedTrackIndex == nil )
        .simultaneousGesture(
          TapGesture().onEnded
          {
            musicVM.restoreTracksState()
          } )
          .disabled( musicVM.selectedTrackIndex == nil )

        Button(
          action:
            {
              scrollToCurrentPlaylist.toggle()
            },
          label:
            {
              Image( systemName: "filemenu.and.selection" )
            } ) // Button

      } ) // navigationBarItems
    
    .onAppear
    {
      notAuthorized = !musicVM.authorizedToAccessMusic

      if musicVM.selectedPlaylistIndex != nil
      {
        tSelectedPlaylist = musicVM.selectedPlaylistIndex
      }
    } // .onAppear

    .alert( isPresented: $notAuthorized )
    {
      Alert( 
        title: Text( "Not Allowed to Access the Music Library." ),
        message: Text( "Go to Settings > One Big Player\nto Allow Access to Apple Music" ) )
    } // .alert

  } // var body
  
} // PlaylistsView



//--------------------------------------------
struct verticalAZsliderPlaylists: View
{
  
  @EnvironmentObject var musicVM : MusicViewModel
  
  @Binding var scrollTo : Int
  let startingValue = UInt8(65)
  
  var body: some View
  {
    VStack
    {
      VStack
      {
        Text( "A" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[0] }
        .font(.system(size: 20))
        Text( "B" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[1] }
        .font(.system(size: 20))
        Text( "C" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[2] }
        .font(.system(size: 20))
        Text( "D" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[3] }
        .font(.system(size: 20))
        Text( "E" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[4] }
        .font(.system(size: 20))
        Text( "F" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[5] }
        .font(.system(size: 20))
        Text( "G" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[6] }
        .font(.system(size: 20))
        Text( "H" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[7] }
        .font(.system(size: 20))
        Text( "I" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[8] }
        .font(.system(size: 20))
      }
      VStack
      {
        Text( "J" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[9] }
        .font(.system(size: 20))
        Text( "K" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[10] }
        .font(.system(size: 20))
        Text( "L" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[11] }
        .font(.system(size: 20))
        Text( "M" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[12] }
        .font(.system(size: 20))
        Text( "N" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[13] }
        .font(.system(size: 20))
        Text( "O" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[14] }
        .font(.system(size: 20))
        Text( "P" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[15] }
        .font(.system(size: 20))
        Text( "Q" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[16] }
        .font(.system(size: 20))
        Text( "R" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[17] }
        .font(.system(size: 20))
        Text( "S" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[18] }
        .font(.system(size: 20))
      }
      VStack
      {
        Text( "T" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[19] }
        .font(.system(size: 20))
        Text( "U" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[20] }
        .font(.system(size: 20))
        Text( "V" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[21] }
        .font(.system(size: 20))
        Text( "W" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[22] }
        .font(.system(size: 20))
        Text( "X" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[23] }
        .font(.system(size: 20))
        Text( "Y" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[24] }
        .font(.system(size: 20))
        Text( "Z" ).onTapGesture {
          scrollTo = musicVM.MMPlaylistsAlphaMap[25] }
        .font(.system(size: 20))
      }
    }
    .foregroundColor( .white )
    .background( .black )
    
  } // body
  
} // verticalAZslider



//--------------------------------------------

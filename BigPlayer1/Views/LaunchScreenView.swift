//
//  LaunchScreenView.swift
//  BigPlayer1
//
//  Created by Stewart French on 1/25/23.
//

import SwiftUI

// --------------------------------------------
struct LaunchScreenView: View
{
  
  @EnvironmentObject var musicVM : MusicViewModel
  
  var body: some View
  {
    NavigationStack
    {
      ZStack 
      {
        // background
        
        Color.gray
          .edgesIgnoringSafeArea(.all)
        
        // content
        
        VStack
        {
          Spacer()
          
          // --------------
          HStack
          {
            
            // -----
            NavigationLink(destination: NewestAlbumsView())
            {
              MyRectangleView(buttonLabel: "Newest \nAlbums")
            }

            .simultaneousGesture(
              TapGesture().onEnded
              {
                musicVM.clearSelections()
              } ) // simultaneousGesture

            
            // -----
            NavigationLink(destination: PlaylistsView())
            {
              MyRectangleView(buttonLabel: "Playlists")
            }
            .simultaneousGesture(
              TapGesture().onEnded
              {
                musicVM.clearSelections()
              } ) // simultaneousGesture

          } // HStack
          .padding(.horizontal, 5)

            
          // --------------
          HStack 
          {
            
            // -----
            NavigationLink(destination: ArtistsView())
            {
              MyRectangleView(buttonLabel: "Artists")
            }
            .simultaneousGesture(
              TapGesture().onEnded
              {
                musicVM.clearSelections()
              } ) // simultaneousGesture


            // -----
            NavigationLink(destination: AlbumsView()) 
            {
              MyRectangleView(buttonLabel: "Albums")
            }
            .simultaneousGesture(
              TapGesture().onEnded
              {
                musicVM.clearSelections()
              } ) // simultaneousGesture

          } // HStack
          .padding(.horizontal, 5)
          
          
          // --------------
          HStack 
          {
            
            // -----
            NavigationLink(destination: TracksView() )
            {
              MyRectangleView(
                buttonLabel: "Now \nPlaying",
                disabled: !musicVM.tracksAreQueued )
            }
            .disabled( !musicVM.tracksAreQueued )
            .simultaneousGesture(
              TapGesture().onEnded
              {
                musicVM.restoreTracksState()
              } )
              .disabled( !musicVM.tracksAreQueued )


            // -----
            NavigationLink(destination: ResumeView()) 
            {
              MyRectangleView(
                  buttonLabel: "Resume",
                  disabled: !musicVM.ASusable )
            }
            .disabled( !musicVM.ASusable )

            .simultaneousGesture(
              TapGesture().onEnded
              {
                musicVM.restoreTracksFromAppStorage()
                musicVM.prepareTracksToPlay( fromAppStorage: true )
                musicVM.playSelectedTrack()
              } ) // simultaneousGesture
              .disabled( !musicVM.ASusable )

            .padding(.horizontal, 5)
          }

        } // VStack
        .padding(.horizontal, 5)
        .padding(.vertical, 5)
        .navigationBarHidden(true)
      } // ZStack
    } // NavigationStack
  } // var body
} // LaunchScreenView



// --------------------------------------------
struct MyRectangleView: View 
{
  let buttonLabel: String
  
  var disabled : Bool = false
  
  var body: some View 
  {
    Rectangle()
      .fill(Color.black)
      .overlay(
        Text(buttonLabel)
          .font(.largeTitle)
          .foregroundColor( disabled ? .gray : .white )
        
      )
  }
} // MyRectangleView

// --------------------------------------------


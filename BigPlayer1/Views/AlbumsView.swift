//
//  AlbumsView.swift
//  BigPlayer1
//
//  Created by Stewart French on 2/2/23.
//

import SwiftUI
  
//--------------------------------------------
struct AlbumsView: View
{
  @EnvironmentObject var musicVM : MusicViewModel
  
  @State private var tSelectedAlbum: Int? = nil
  
  @State private var scrollToCurrentAlbum : Bool = false
  
  @State private var thumbedAlbum : Int = 0
  
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
        ScrollView
        {
          LazyVStack
          {
            ScrollViewReader
            { proxy in

              ForEach( musicVM.MMAlbums.indices, id: \.self )
              { feIndex in

                NavigationLink(
                  destination: TracksView(),

                  label:
                    {
                      VStack
                      {
                        Text(musicVM.getAlbumName(index: feIndex))
                          .font(.system(size: 36.0))
                          .frame(
                            maxWidth: .infinity,
                            minHeight: 50,
                            maxHeight: .infinity,
                            alignment: .leading )
                          .multilineTextAlignment(.leading)
                          .lineLimit( 3 )
                          .foregroundColor(
                            tSelectedAlbum==feIndex ?
                              Color(uiColor: .green) : .white )
                          .background(
                            tSelectedAlbum==feIndex ?
                              Color(uiColor: .darkGray) : .black )
                        Divider()

                      } // VStack
                    } ) // NavigationLink

                .id( feIndex )
                .simultaneousGesture(
                  TapGesture().onEnded
                  {
                    musicVM.setSelectedAlbum(
                      albumIndex: feIndex )

                    musicVM.retrieveTracksFromAlbum(
                      albumIndex: feIndex )

                    musicVM.prepareTracksToPlay()
                  } ) // simultaneousGesture

              } // ForEach

              .onChange(
                of: scrollToCurrentAlbum,
                perform:
                  { _ in
                    withAnimation(.spring() )
                    {
                      proxy.scrollTo(tSelectedAlbum, anchor: .center)
                    }
                  } ) // onChange
                  
              .onChange(
                of: thumbedAlbum,
                perform:
                  { _ in
                    withAnimation(.spring() )
                    {
                      proxy.scrollTo( thumbedAlbum, anchor: .center )
                    }
                  } ) // onChange
                  
            } // ScrollViewReader
          } // LazyVStack
        } // ScrollView

        Divider()

        Spacer()
        Spacer()

        verticalAZsliderAlbums( scrollTo: $thumbedAlbum )
      } // HStack
    } // ZStack
    


        //-------------------------------------------
        // Navigation Bar

    .navigationBarTitle( "Albums",
                         displayMode: .inline )
    
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
          .disabled( musicVM.selectedTrackIndex == nil  )

        Button(
          action:
            {
              scrollToCurrentAlbum.toggle()
            },
          label:
            {
              Image( systemName: "filemenu.and.selection" )
            } )
      } ) // .navigationBarItems
    

        //-------------------------------------------
        // When the View appears

.onAppear
    {
      notAuthorized = !musicVM.authorizedToAccessMusic

      if musicVM.selectedAlbumIndex != nil
      {
        tSelectedAlbum = musicVM.selectedAlbumIndex
      }
      
      musicVM.selectedArtistIndex = nil
      musicVM.retrieveAlbums(
        artistNameIndex: nil )
    } // .onAppear

    .alert( isPresented: $notAuthorized )
    {
      Alert( 
        title: Text( "Not Allowed to Access the Music Library." ),
        message: Text( "Go to Settings > One Big Player\nto Allow Access to Apple Music" ) )
    } // .alert

  } // var body
} // AlbumsView



//--------------------------------------------
struct verticalAZsliderAlbums: View {
  
  @EnvironmentObject var musicVM : MusicViewModel
  
  @Binding var scrollTo : Int
  
  var body: some View
  {
    VStack
    {
      VStack
      {
        Text( "A" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[0] }
        .font(.system(size: 20))
        Text( "B" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[1] }
        .font(.system(size: 20))
        Text( "C" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[2] }
        .font(.system(size: 20))
        Text( "D" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[3] }
        .font(.system(size: 20))
        Text( "E" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[4] }
        .font(.system(size: 20))
        Text( "F" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[5] }
        .font(.system(size: 20))
        Text( "G" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[6] }
        .font(.system(size: 20))
        Text( "H" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[7] }
        .font(.system(size: 20))
        Text( "I" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[8] }
        .font(.system(size: 20))
      }
      VStack
      {
        Text( "J" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[9] }
        .font(.system(size: 20))
        Text( "K" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[10] }
        .font(.system(size: 20))
        Text( "L" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[11] }
        .font(.system(size: 20))
        Text( "M" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[12] }
        .font(.system(size: 20))
        Text( "N" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[13] }
        .font(.system(size: 20))
        Text( "O" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[14] }
        .font(.system(size: 20))
        Text( "P" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[15] }
        .font(.system(size: 20))
        Text( "Q" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[16] }
        .font(.system(size: 20))
        Text( "R" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[17] }
        .font(.system(size: 20))
        Text( "S" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[18] }
        .font(.system(size: 20))
      }
      VStack
      {
        Text( "T" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[19] }
        .font(.system(size: 20))
        Text( "U" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[20] }
        .font(.system(size: 20))
        Text( "V" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[21] }
        .font(.system(size: 20))
        Text( "W" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[22] }
        .font(.system(size: 20))
        Text( "X" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[23] }
        .font(.system(size: 20))
        Text( "Y" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[24] }
        .font(.system(size: 20))
        Text( "Z" ).onTapGesture {
          scrollTo = musicVM.MMAlbumsAlphaMap[25] }
        .font(.system(size: 20))
      }
    }
    .foregroundColor( .white )
    .background( .black )
  } // body
  
} // verticalAZslider



//--------------------------------------------

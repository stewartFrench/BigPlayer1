//
//  ArtistsView.swift
//  BigPlayer1
//
//  Created by Stewart French on 1/25/23.
//

import SwiftUI

//--------------------------------------------
struct ArtistsView: View
{
  @EnvironmentObject var musicVM : MusicViewModel
  
  @State private var tSelectedArtist: Int? = nil
  
  @State private var scrollToCurrentArtist : Bool = false
  
  @State private var thumbedArtist : Int = 0
  
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
            
            ForEach( musicVM.MMArtists.indices, id: \.self )
            { feIndex in
              
              NavigationLink(
                
                destination:
                  AlbumsFromArtistView(
                    tappedArtistIndex: feIndex,
                    tSelectedArtist: $tSelectedArtist),
                
                label:
                  {
                    VStack
                    {
                      Text(musicVM.getArtistName(index: feIndex))
                        .font(.system(size: 36.0))
                        .frame(
                          maxWidth: .infinity,
                          minHeight: 50,
                          maxHeight: .infinity,
                          alignment: .leading )
                        .multilineTextAlignment(.leading)
                        .lineLimit( 3 )
                        .foregroundColor(
                          tSelectedArtist==feIndex ?
                            Color(uiColor: .green) : .white )
                        .background(
                          tSelectedArtist==feIndex ?
                            Color(uiColor: .darkGray) : .black )
                      Divider()
                    } // VStack
                  } ) // NavigationLink
              .id( feIndex )
              .simultaneousGesture(
                TapGesture().onEnded
                {
                  musicVM.setSelectedArtist( index: feIndex )
                } )
            } // ForEach
            
            .onChange(
              of: scrollToCurrentArtist,
              perform:
                { _ in
                  withAnimation(.spring() )
                  {
                    proxy.scrollTo(tSelectedArtist, anchor: .center)
                  }
                } ) // onChange
                
            .onChange(
              of: thumbedArtist,
              perform:
                { _ in
                  withAnimation(.spring() )
                  {
                    proxy.scrollTo( thumbedArtist, anchor: .center )
                  }
                } ) // onChange

          } // ScrollViewReader
        } // ScrollView

        Divider()

        Spacer()

        verticalAZsliderArtists( scrollTo: $thumbedArtist )
          .frame( minWidth: 0, maxWidth: 20,
                 minHeight: 0, maxHeight: .infinity )

      } // HStack
    } // ZStack
    

        //-------------------------------------------
        // Navigation Bar

    .navigationBarTitle( "Artists",
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
              scrollToCurrentArtist.toggle()
            },
          label:
            {
              Image( systemName: "filemenu.and.selection" )
            } ) // Button

      } ) // navigationBarItems
    
    
        //-------------------------------------------
        // When the View appears
    
    .onAppear
    {

      notAuthorized = !musicVM.authorizedToAccessMusic

      if musicVM.selectedArtistIndex != nil
      {
        tSelectedArtist = musicVM.selectedArtistIndex
      }
    } // .onAppear

    .alert( isPresented: $notAuthorized )
    {
      Alert( 
        title: Text( "Not Allowed to Access the Music Library." ),
        message: Text( "Go to Settings > One Big Player\nto Allow Access to Apple Music" ) )
    } // .alert

  } // var body
  
}  // ArtistsView



//--------------------------------------------
struct verticalAZsliderArtists: View
{
  
  @EnvironmentObject var musicVM : MusicViewModel
  
  @Binding var scrollTo : Int
  
  var body: some View
  {
    GeometryReader
    { geometry in
      VStack
      {
        VStack
        {
          Spacer()
          Text( "A" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[0] }
          .font(.system(size: 12))
          Spacer()
          Text( "B" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[1] }
          .font(.system(size: 12))
          Spacer()
          Text( "C" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[2] }
          .font(.system(size: 12))
          Spacer()
          Text( "D" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[3] }
          .font(.system(size: 12))
          Spacer()
          Text( "E" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[4] }
          .font(.system(size: 12))
          Spacer()
          Text( "F" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[5] }
          .font(.system(size: 12))
          Spacer()
          Text( "G" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[6] }
          .font(.system(size: 12))
          Spacer()
          Text( "H" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[7] }
          .font(.system(size: 12))
          Spacer()
          Text( "I" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[8] }
          .font(.system(size: 12))
        }
        VStack
        {
          Spacer()
          Text( "J" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[9] }
          .font(.system(size: 12))
          Spacer()
          Text( "K" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[10] }
          .font(.system(size: 12))
          Spacer()
          Text( "L" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[11] }
          .font(.system(size: 12))
          Spacer()
          Text( "M" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[12] }
          .font(.system(size: 12))
          Spacer()
          Text( "N" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[13] }
          .font(.system(size: 12))
          Spacer()
          Text( "O" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[14] }
          .font(.system(size: 12))
          Spacer()
          Text( "P" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[15] }
          .font(.system(size: 12))
          Spacer()
          Text( "Q" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[16] }
          .font(.system(size: 12))
          Spacer()
          Text( "R" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[17] }
          .font(.system(size: 12))
          Spacer()
          Text( "S" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[18] }
          .font(.system(size: 12))
        }
        VStack
        {
          Spacer()
          Text( "T" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[19] }
          .font(.system(size: 12))
          Spacer()
          Text( "U" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[20] }
          .font(.system(size: 12))
          Spacer()
          Text( "V" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[21] }
          .font(.system(size: 12))
          Spacer()
          Text( "W" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[22] }
          .font(.system(size: 12))
          Spacer()
          Text( "X" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[23] }
          .font(.system(size: 12))
          Spacer()
          Text( "Y" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[24] }
          .font(.system(size: 12))
          Spacer()
          Text( "Z" ).onTapGesture {
            scrollTo = musicVM.MMArtistsAlphaMap[25] }
          .font(.system(size: 12))
          Spacer()
        }
      }
      .foregroundColor( .white )
      .background( .black )
      .gesture(DragGesture(minimumDistance: 0)
        .onChanged({ value in
          let yPercentage = min(max(0,
                  Float(value.location.y / geometry.size.height * 100)), 100)
//          print( "yPercentage = \(yPercentage)")
          let tScrollTo = musicVM.MMArtistsAlphaMap[
                       Int( ( yPercentage / 100 ) * 25 ) ]
//          print( "tScrollTo = \(tScrollTo)")
          scrollTo = tScrollTo
        }))  // .gesture

    } // GeometryReader
  } // body
  
} // verticalAZsliderArtists



//--------------------------------------------

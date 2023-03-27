//
//  BigPlayer1App.swift
//  BigPlayer1
//
//  Created by Stewart French on 1/25/23.
//

import SwiftUI

@main
struct BigPlayer1App: App {

  var musicVM : MusicViewModel = MusicViewModel()

  var body: some Scene {
    WindowGroup {
      LaunchScreenView()
              .preferredColorScheme( .dark )

//      ArtistsView()
//      TrackPlayerView()
        .environmentObject(musicVM)
    }
  }
}

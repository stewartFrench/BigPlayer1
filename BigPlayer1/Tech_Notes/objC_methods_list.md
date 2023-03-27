# Methods from Geezerplay/MusicManager.h

.md is Mark Down formatting.  See -

[GitHub Page](https://developer.apple.com/documentation/xcode/formatting-your-documentation-content)


DONE - (void) retrieveArtists;
DONE - (void) retrieveAlbums;

DONE - (void) retrieveAlbums: (NSString *) artistName;
     - (void) retrieveRecentAlbums: (NSString *) artistName;

DONE - (void) retrieveAlbumsFromSelectedArtist;
DONE - (void) retrievePlaylists;
     
     - (void) resetSelected;
     
DONE - (NSUInteger) countOfArtists;
DONE - (NSUInteger) countOfAlbums;
DONE - (NSUInteger) countOfPlaylists;
     
DONE - (NSString *) getArtistName: (NSUInteger) index;
DONE - (NSString *) getAlbumName: (NSUInteger) index;
DONE - (NSString *) getPlaylistName: (NSUInteger) index;
     
DONE - (void)    retrieveTracksFromAlbum: (NSUInteger) albumIndex;
DONE - (void) retrieveTracksFromPlaylist: (NSUInteger) PlaylistIndex;
     
     - (void) shuffleTracks;
     
     - (void) prepareTracksToPlay;
     
     - (NSUInteger) countOfTracks;
     
DONE - (NSString *) trackArtist: (NSUInteger) index;
DONE - (NSString *) trackTitle: (NSUInteger) index;
DONE - (NSString *) trackDuration: (NSUInteger) index;
     
     - (NSTimeInterval) timeLeftInPlaylist: (NSUInteger) trackNumber;
     
     - (void) setSelectedTrack: (NSNumber *) index;
     
     - (void) clearSelectedTrack;
     - (void) playSelectedTrack;
     - (void) pauseSelectedTrack;
     - (void) rewind;
     - (void) skipToPreviousTrack;
     - (void) skipToNextTrack;
     
     - (NSTimeInterval) durationOfSelectedTrack;
     - (NSTimeInterval) elapsedTimeOfSelectedTrack;
     
     - (NSString *) selectedTrackArtist;
     - (NSString *) selectedTrackTitle;
     - (NSString *) selectedTrackAlbum;
     - (NSString *) selectedTrackReleaseDate;
     
     - (NSString *) selectedTrackInfo;
     
     - (MusicManagerState) selectedTrackState;
     
     - (BOOL) selectedTrackIsAtBeginningOfPlaylist;
     - (BOOL) selectedTrackIsAtEndOfPlaylist;


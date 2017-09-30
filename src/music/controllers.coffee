app = angular.module "kodiRemote.music.controllers", []

# ----- artists -----

app.controller "ArtistsController", [ "$scope", "$rootScope", "NavbarFactory", "Artists", 
($scope, $rootScope, NavbarFactory, Artists) ->  
  $scope.artists = []
  $scope.artistGroups = []

  # sortable directive
  # - set $scope.sortParams before load
  # - call $scope.beforeSortLoad  before load
  $scope.showAlbums = true
  $scope.showGenre = true
  $scope.showRating = true
  $scope.showRecentlyAdded = true
  $scope.showSortDirection = true
  $scope.beforeSortLoad = ->
    $scope.artists = []
    $scope.pagination.page = 1

  # autoScrollPaginate directive
  # - sets $scope.pagination hash
  # - uses $scope.paginationAfterLoad to calculate $scope.pagination.more
  # - uses $scope.loading

  $scope.load = ->
    $rootScope.$broadcast "topbar.loading", true
    $scope.loading = true
    $scope.sortParams.by = "label" if $scope.sortParams
    Artists.all($scope.pagination.page, $scope.sortParams).then (data) ->    
      $rootScope.$broadcast "topbar.loading", false
      $scope.loading = false
      for artist in data.data
        $scope.artists.push artist
      $scope.artistGroups = kodiRemote.array.inGroupsOf $scope.artists, 2      
      $scope.Navbar = new NavbarFactory
      $scope.Navbar.addTitle "Artists (#{data.total})"
      $scope.paginationAfterLoad Artists.perPage, data.total
      return
]

# ----- albums ------

app.controller "AlbumsController", [ "$scope", "$rootScope", "NavbarFactory", "Albums", 
($scope, $rootScope, NavbarFactory, Albums) ->  
  $scope.albums = []
  $scope.albumGroups = []

  # sortable directive
  # - set $scope.sortParams before load
  # - call $scope.beforeSortLoad  before load
  $scope.showArtists = true
  $scope.showGenre = true
  $scope.showRating = true
  $scope.showRecentlyAdded = true
  $scope.showSortDirection = true
  $scope.beforeSortLoad = ->
    $scope.albums = []
    $scope.pagination.page = 1

  # autoScrollPaginate directive
  # - sets $scope.pagination hash
  # - uses $scope.paginationAfterLoad to calculate $scope.pagination.more
  # - uses $scope.loading

  $scope.load = ->
    $rootScope.$broadcast "topbar.loading", true
    $scope.loading = true
    $scope.sortParams.by = "label" if $scope.sortParams
    Albums.all($scope.pagination.page, $scope.sortParams).then (data) ->          
      $rootScope.$broadcast "topbar.loading", false
      $scope.loading = false
      for album in data.data
        $scope.albums.push album
      $scope.albumGroups = kodiRemote.array.inGroupsOf $scope.albums, 2      
      $scope.Navbar = new NavbarFactory
      $scope.Navbar.addTitle "Albums (#{data.total})"
      $scope.paginationAfterLoad Albums.perPage, data.total
      return
]

app.controller "AlbumController", [ "$scope", "$rootScope", "$routeParams", "Albums", "Songs", "NavbarFactory",
($scope, $rootScope, $routeParams, Albums, Songs, NavbarFactory) ->
  albumId = parseInt $routeParams.id

  $scope.album = null

  $rootScope.$broadcast "topbar.loading", true
  Albums.get(albumId).then (albumData) ->
    $rootScope.$broadcast "topbar.loading", false
    $scope.album = albumData.data
    $scope.album.songs = []
    Songs.all($scope.album.title).then (songsData) ->
      $scope.album.songs = songsData.data
    $scope.Navbar = new NavbarFactory
    $scope.Navbar.addLink "/music/albums", "Albums"
    $scope.Navbar.addLink "/music/artists/#{$scope.album.artistid}", $scope.album.artist.join(", ")
    $scope.Navbar.addTitle $scope.album.title
    $scope.Navbar.addTitle "Tracks"
]

# ----- genres -----

app.controller "MusicGenresController", [ "$scope", "$rootScope", "NavbarFactory", "Genres", ($scope, $rootScope, NavbarFactory, Genres) ->    
  $scope.showAlbums = true
  $scope.showArtists = true
  $scope.showGenre = true
  $scope.showRating = true
  $scope.showRecentlyAdded = true
  
  $scope.genreType = "music"
  $scope.genres = []
  $scope.genreGroups = []

  $rootScope.$broadcast "topbar.loading", true
  Genres.all("music").then (data) ->    
    $rootScope.$broadcast "topbar.loading", false
    $scope.genres = data.data
    $scope.genreGroups = kodiRemote.array.inGroupsOf $scope.genres, 2
    $scope.Navbar = new NavbarFactory
    $scope.Navbar.addLink "/music/artists", "Artists"
    $scope.Navbar.addTitle "Genres (#{data.total})"  
]

# ----- rating -----

app.controller "MusicRatingController", [ "$scope", "$rootScope", "NavbarFactory", "Albums", ($scope, $rootScope, NavbarFactory, Albums) ->  
  $scope.albums = []  
  $scope.albumGroups = []

  # sortable directive
  # - set $scope.sortParams before load
  # - call $scope.beforeSortLoad before load
  $scope.showAlbums = true
  $scope.showArtists = true
  $scope.showGenre = true  
  $scope.showRecentlyAdded = true
  $scope.showSortDirection = true
  $scope.beforeSortLoad = ->
    $scope.albums = []
    $scope.pagination.page = 1

  # autoScrollPaginate directive
  # - sets $scope.pagination hash
  # - uses $scope.paginationAfterLoad to calculate $scope.pagination.more

  $scope.load = ->
    $rootScope.$broadcast "topbar.loading", true

    $scope.sortParams =
      by: "rating"
      direction: "ascending"
    $scope.sortParams.direction = $scope.sort.direction.methods[$scope.sort.direction.current] if $scope.sort

    Albums.all($scope.pagination.page, $scope.sortParams).then (data) ->
      $rootScope.$broadcast "topbar.loading", false
      for tvShow in data.data
        $scope.albums.push tvShow

      $scope.albumGroups = kodiRemote.array.inGroupsOf $scope.albums, 2      

      $scope.Navbar = new NavbarFactory
      $scope.Navbar.addLink "/music/albums", "Albums (#{data.total})"      
      $scope.Navbar.addTitle "Rating"
      $scope.paginationAfterLoad Music.perPage, data.total
      return
]
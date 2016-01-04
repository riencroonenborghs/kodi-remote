# http://kodi.wiki/view/JSON-RPC_API/v6

kodiRemote = window.kodiRemote ||= {}

app = angular.module "kodiRemote", [
  "ngAria", 
  "ngAnimate", 
  "ngMaterial", 
  "ngMdIcons",
  "ngRoute",
  "ngWebSocket",
  "kodiRemote.controllers",
  "kodiRemote.services",
  "kodiRemote.directives",
  "kodiRemote.factories",
  "kodiRemote.tvshows.controllers",
  "kodiRemote.tvshows.services",
  "kodiRemote.movies.controllers",
  "kodiRemote.movies.services",
  "kodiRemote.settings.controllers",
  "kodiRemote.remote.controllers",
  "kodiRemote.remote.services",
  "kodiRemote.playlist.controllers",
  "kodiRemote.playlist.services",
  "kodiRemote.genres.controllers",
  "kodiRemote.genres.services",
  "kodiRemote.music.controllers",
  "kodiRemote.music.services" 
]

app.config ($mdThemingProvider) ->
  $mdThemingProvider.theme("default")
    .primaryPalette("blue")
    .accentPalette("green")


kodiRemote.settings =
  server: null
  port: null
  requestType: null

kodiRemote.imageObject = (image) ->
  url: "http://#{kodiRemote.settings.server}:#{kodiRemote.settings.port}/image/#{encodeURIComponent image}"
  original: image
  isSet: image != undefined && image != null && image != ""

kodiRemote.array =
  inGroupsOf: (_list, number) ->
    list = _list.slice(0)
    newList = []
    while list.length > 0
      newList.push list.splice(0, number)
    return newList

kodiRemote.video =
  resumePercentage: (video) -> 
    video.resume.percentage = if video.resume.position == 0 then 0 else ((video.resume.position/video.resume.total)*100)

app.config ($routeProvider, $locationProvider) ->
  $routeProvider
    .when "/settings",
      templateUrl: "app/views/settings/index.html"
      controller: "SettingsController"

    .when "/tvshows",
      templateUrl: "app/views/tvshows/index.html"
      controller: "TvShowsController"
    .when "/tvshows/genres",
      templateUrl: "app/views/genres/index.html"
      controller: "TvShowGenresController"
    .when "/tvshows/rating",
      templateUrl: "app/views/tvshows/rating.html"
      controller: "TvShowsRatingController"
    .when "/tvshows/:id/seasons",
      templateUrl: "app/views/tvshows/seasons/index.html"
      controller: "SeasonsController"
    .when "/tvshows/:tvshowid/seasons/:id/episodes",
      templateUrl: "app/views/tvshows/seasons/episodes/index.html"
      controller: "EpisodesController"
    .when "/episodes/recently-added",
      templateUrl: "app/views/tvshows/seasons/episodes/recently-added.html"
      controller: "RecentlyAddedEpisodesController"
    .when "/episodes/:id",
      templateUrl: "app/views/tvshows/seasons/episodes/show.html"
      controller: "EpisodeController"

    .when "/movies",
      templateUrl: "app/views/movies/index.html"
      controller: "MoviesController"
    .when "/movies/genres",
      templateUrl: "app/views/genres/index.html"
      controller: "MovieGenresController"
    .when "/movies/rating",
      templateUrl: "app/views/movies/rating.html"
      controller: "MoviesRatingController"
    .when "/movies/recently-added",
      templateUrl: "app/views/movies/recently-added.html"
      controller: "RecentlyAddedMoviesController"
    .when "/movies/years",
      templateUrl: "app/views/movies/years/index.html"
      controller: "MovieYearsController"
    .when "/movies/years/:year",
      templateUrl: "app/views/movies/years/show.html"
      controller: "MovieYearController"
    .when "/movies/:id",
      templateUrl: "app/views/movies/show.html"
      controller: "MovieController"

    .when "/remote",
      templateUrl: "app/views/remote/index.html"
      controller: "RemoteController"

    .when "/music/artists",
      templateUrl: "app/views/music/artists.html"
      controller: "ArtistsController"
    .when "/music/albums",
      templateUrl: "app/views/music/albums/index.html"
      controller: "AlbumsController"
    .when "/music/albums/:id",
      templateUrl: "app/views/music/albums/show.html"
      controller: "AlbumController"
    .when "/music/genres",
      templateUrl: "app/views/genres/index.html"
      controller: "MusicGenresController"
    .when "/music/rating",
      templateUrl: "app/views/music/rating.html"
      controller: "MusicRatingController"
    # .when "/music/albums/:id",
    #   templateUrl: "app/views/music/albums/index.html"
    #   controller: "AlbumController"

    .when "/genres/tvshows/:genre",
      templateUrl: "app/views/genres/show-tvshows.html"
      controller: "TvShowGenreController"
    .when "/genres/movies/:genre",
      templateUrl: "app/views/genres/show-movies.html"
      controller: "MovieGenreController"

    .otherwise "/tvshows",
      templateUrl: "app/views/tvshows/index.html"
      controller: "TvShowsController"

  $locationProvider.html5Mode true

app.filter "secondsToDateTime", [ ->
 (seconds) -> return new Date(1970, 0, 1).setSeconds(seconds);
]

app.filter "zeroPrepend", [->
  (input, length) ->
    inputString = new String(input)
    zeroes = "0".repeat (length - inputString.length)
    "#{zeroes}#{input}"
]


kodiRemote.Loader = class
  constructor: (@scope, @service) -> return
  handleData: (data) -> return
  afterCallback: (data) -> return
  _baseMethod: (method, params...) ->
    @scope.loading = true
    @service[method](params...).then (data) => 
      @scope.loading = false
      @handleData data
      @afterCallback data
  index: (params...) -> @_baseMethod "index", params...
  show: (params...) -> @_baseMethod "show", params...
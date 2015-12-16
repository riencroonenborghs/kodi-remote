# http://kodi.wiki/view/JSON-RPC_API/v6

kodiRemote = window.kodiRemote ||= {}

app = angular.module "kodiRemote", [
  "ngAria", 
  "ngAnimate", 
  "ngMaterial", 
  "ngMdIcons",
  "ngRoute",
  "kodiRemote.controllers",
  "kodiRemote.services",
  "kodiRemote.directives",
  "kodiRemote.tvshows.controllers",
  "kodiRemote.tvshows.services",
  "kodiRemote.movies.controllers",
  "kodiRemote.movies.services",
  "kodiRemote.settings.controllers",
  "kodiRemote.remote.controllers",
  "kodiRemote.remote.services"
]

app.config ($mdThemingProvider) ->
  $mdThemingProvider.theme("default")
    .primaryPalette("blue")
    .accentPalette("green")


kodiRemote.settings =
  server: null # "192.168.0.169"
  port: null # 80
  # else
  #   kodiRemote.settings.server  = "192.168.0.169"
  #   kodiRemote.settings.port    = 8080  

app.config ($routeProvider, $locationProvider) ->
  $routeProvider
    .when "/settings",
      templateUrl: "app/views/settings/index.html"
      controller: "SettingsController"
    .when "/tvshows",
      templateUrl: "app/views/tvshows/index.html"
      controller: "TvShowsController"
    .when "/tvshows/:id/seasons",
      templateUrl: "app/views/tvshows/seasons/index.html"
      controller: "TvShowSeasonsController"
    .when "/tvshows/:tvshowid/seasons/:id/episodes",
      templateUrl: "app/views/tvshows/seasons/episodes/index.html"
      controller: "TvShowSeasonEpisodesController"
    .when "/movies",
      templateUrl: "app/views/movies/index.html"
      controller: "MoviesController"
    .when "/movies/:id/details",
      templateUrl: "app/views/movies/details/index.html"
      controller: "MovieDetailsController"
    .when "/remote",
      templateUrl: "app/views/remote/index.html"
      controller: "RemoteController"    
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
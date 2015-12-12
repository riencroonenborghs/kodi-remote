app = angular.module "kodiRemote", [
  "ngAria", 
  "ngAnimate", 
  "ngMaterial", 
  "ngMdIcons",
  "ngRoute",
  "infinite-scroll",
  "kodiRemote.controllers",
  "kodiRemote.services",
  "kodiRemote.directives",
  "kodiRemote.tvshows.controllers",
  "kodiRemote.tvshows.services",
  "kodiRemote.movies.controllers",
  "kodiRemote.movies.services"
]

app.config ($mdThemingProvider) ->
  $mdThemingProvider.theme("default")
    .primaryPalette("blue")
    .accentPalette("blue")

app.constant "SERVER", "192.168.0.111"
app.constant "PORT", 8080

app.config ($routeProvider, $locationProvider) ->
  $routeProvider
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
    # .otherwise "/movies",
    #   templateUrl: "app/views/movies/index.html"
    #   controller: "MoviesController"
    .otherwise "/tvshows",
      templateUrl: "app/views/tvshows/index.html"
      controller: "TvShowsController"

  $locationProvider.html5Mode true

app.filter "secondsToDateTime", [ ->
 (seconds) -> return new Date(1970, 0, 1).setSeconds(seconds);
]
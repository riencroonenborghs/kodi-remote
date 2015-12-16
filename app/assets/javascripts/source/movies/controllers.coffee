app = angular.module "kodiRemote.movies.controllers", []

app.controller "MoviesController", [ "$scope", "$controller", "Topbar", "Movies", "Remote",
($scope, $controller, Topbar, Movies, Remote) ->
  Topbar.setTitle "Movies"

  $scope.listService = Movies
  $scope.pushItemsOntoList = (data) ->
    for movie in data.movies
      $scope.list.push movie
    Topbar.setTitle "Movies (#{data.limits.total})"
  $controller "SortedPaginatedController", {$scope: $scope}

  $scope.setItemsOnList = (data) -> $scope.list = data.movies
  $scope.emptyList = -> $scope.list = []
  $controller "SearchController", {$scope: $scope}

  $scope.play = (movie) ->
    Remote.playMovie(movie.movieid)

  $scope.visitDetails = (movieId) -> 
    $scope.visit("/movies/#{movieId}/details")
]

app.controller "MovieDetailsController", [ "$scope", "$routeParams", "MoviesLoader", "Topbar", 
($scope, $routeParams, MoviesLoader, Topbar) ->
  $scope.movieId = parseInt $routeParams.id

  detailsLoader = new MoviesLoader.DetailsLoader $scope
  detailsLoader.afterCallback = (data) -> 
    Topbar.setLink "/movies", $scope.movieDetails.label
    for castMember in $scope.movieDetails.cast
      if castMember.thumbnail
        castMember.avatar = decodeURIComponent castMember.thumbnail.replace("image://", "")
        castMember.avatar = castMember.avatar.slice(0, -1)
    
  detailsLoader.show $scope.movieId
]
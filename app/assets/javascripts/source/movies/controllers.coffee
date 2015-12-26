app = angular.module "kodiRemote.movies.controllers", []

app.controller "MoviesController", [ "$scope", "$rootScope", "NavbarFactory", "Movies",
($scope, $rootScope, NavbarFactory, Movies) ->  
  $scope.movies = []
  $scope.movieGroups = []

  # sortable directive
  # - set $scope.sortParams before load
  # - call $scope.beforeSortLoad  before load
  $scope.showSortDirection = true

  $scope.beforeSortLoad = ->
    $scope.movies = []
    $scope.pagination.page = 1

  # autoScrollPaginate directive
  # - sets $scope.pagination hash
  # - uses $scope.paginationAfterLoad to calculate $scope.pagination.more
  # - uses $scope.loading

  $rootScope.$broadcast "topbar.loading", true
  $scope.load = ->
    $scope.loading = true
    Movies.all($scope.pagination.page, $scope.sortParams).then (data) ->
      $rootScope.$broadcast "topbar.loading", false
      $scope.loading = false
      for movie in data.data
        $scope.movies.push movie

      $scope.movieGroups = kodiRemote.array.inGroupsOf $scope.movies, 2
      $scope.Navbar = new NavbarFactory
      $scope.Navbar.addTitle "Movies (#{data.total})"
      $scope.paginationAfterLoad Movies.perPage, data.total
      return
]

app.controller "RecentlyAddedMoviesController", [ "$scope", "$rootScope", "NavbarFactory", "Movies",
($scope, $rootScope, NavbarFactory, Movies) ->  
  $scope.movies = []
  $scope.movieGroups = []

  $rootScope.$broadcast "topbar.loading", true
  Movies.recentlyAdded().then (data) ->
    $rootScope.$broadcast "topbar.loading", false
    $scope.movies = data.data
    $scope.movieGroups = kodiRemote.array.inGroupsOf $scope.movies, 2
    $scope.Navbar = new NavbarFactory
    $scope.Navbar.addLink "/movies", "Movies"
    $scope.Navbar.addTitle "Recently Added (#{data.total})"
    return
]


app.controller "MovieGenresController", [ "$scope", "$rootScope", "NavbarFactory", "Genres", ($scope, $rootScope,NavbarFactory, Genres) ->  
  $scope.type = "movies"
  $scope.genres = []
  $scope.genreGroups = []

  $rootScope.$broadcast "topbar.loading", true
  Genres.all("movie").then (data) ->    
    $rootScope.$broadcast "topbar.loading", false
    $scope.genres = data.data
    $scope.genreGroups = kodiRemote.array.inGroupsOf $scope.genres, 2
    $scope.Navbar = new NavbarFactory
    $scope.Navbar.addLink "/movies", "Movies"
    $scope.Navbar.addTitle "Genres (#{data.total})"  
]

app.controller "MovieController", [ "$scope", "$rootScope", "$routeParams", "Movies", "NavbarFactory", 
($scope, $rootScope, $routeParams, Movies, NavbarFactory) ->
  movieId = parseInt $routeParams.id

  $scope.movie = null

  $rootScope.$broadcast "topbar.loading", true
  Movies.get(movieId).then (movieData) ->
    $rootScope.$broadcast "topbar.loading", false
    $scope.movie = movieData.data
    $scope.Navbar = new NavbarFactory
    $scope.Navbar.addLink "/movies", "Movies"
    $scope.Navbar.addTitle $scope.movie.title
]
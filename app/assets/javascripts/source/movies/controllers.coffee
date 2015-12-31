app = angular.module "kodiRemote.movies.controllers", []

app.controller "MoviesController", [ "$scope", "$rootScope", "NavbarFactory", "Movies",
($scope, $rootScope, NavbarFactory, Movies) ->  
  $scope.movies = []
  $scope.movieGroups = []

  # sortable directive
  # - set $scope.sortParams before load
  # - call $scope.beforeSortLoad  before load
  $scope.showGenre = true
  $scope.showRating = true
  $scope.showYear = true
  $scope.showRecentlyAdded = true
  $scope.showSortDirection = true

  $scope.beforeSortLoad = ->
    $scope.movies = []
    $scope.pagination.page = 1

  # autoScrollPaginate directive
  # - sets $scope.pagination hash
  # - uses $scope.paginationAfterLoad to calculate $scope.pagination.more
  # - uses $scope.loading

  $scope.load = ->
    $rootScope.$broadcast "topbar.loading", true
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

  $scope.showGenre = true
  $scope.showRating = true
  $scope.showYear = true

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
  $scope.showRating = true
  $scope.showYear = true
  $scope.showRecentlyAdded = true

  $scope.genreType = "movies"
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

app.controller "MovieController", [ "$scope", "$rootScope", "$routeParams", "Movies", "NavbarFactory", "Files",
($scope, $rootScope, $routeParams, Movies, NavbarFactory, Files) ->
  movieId = parseInt $routeParams.id

  $scope.movie = null

  $rootScope.$broadcast "topbar.loading", true
  Movies.get(movieId).then (movieData) ->
    $rootScope.$broadcast "topbar.loading", false
    $scope.movie = movieData.data
    $scope.Navbar = new NavbarFactory
    $scope.Navbar.addLink "/movies", "Movies"
    $scope.Navbar.addTitle $scope.movie.title

    Files.prepareDownload($scope.movie.file).then (fileData) ->      
      $scope.filePath = "#{fileData.data.protocol}://#{kodiRemote.settings.server}:#{kodiRemote.settings.port}/#{fileData.data.details.path}"
]

app.controller "MovieYearsController", [ "$scope", "$rootScope", "Movies", "NavbarFactory", ($scope, $rootScope, Movies, NavbarFactory) ->

  $scope.showGenre = true
  $scope.showRating = true
  $scope.showRecentlyAdded = true
  
  $scope.years = []

  $rootScope.$broadcast "topbar.loading", true
  Movies.years().then (data) ->
    $rootScope.$broadcast "topbar.loading", false
    $scope.Navbar = new NavbarFactory
    $scope.Navbar.addLink "/movies", "Movies"
    $scope.Navbar.addTitle "years"
    years = for movie in data.data
      movie.year
    $scope.years = $.unique(years).sort().reverse()
    $scope.yearGroups = kodiRemote.array.inGroupsOf $scope.years, 5
]

app.controller "MovieYearController", [ "$scope", "$rootScope", "$routeParams", "Movies", "NavbarFactory", ($scope, $rootScope, $routeParams, Movies, NavbarFactory) ->
  year = parseInt $routeParams.year

  $scope.movies = []
  $scope.movieGroups = []

  # sortable directive
  # - set $scope.sortParams before load
  # - call $scope.beforeSortLoad  before load
  $scope.showGenre = true
  $scope.showRating = true
  $scope.showRecentlyAdded = true
  $scope.showSortDirection = true

  $scope.beforeSortLoad = ->
    $scope.movies = []
    $scope.pagination.page = 1

  # autoScrollPaginate directive
  # - sets $scope.pagination hash
  # - uses $scope.paginationAfterLoad to calculate $scope.pagination.more
  # - uses $scope.loading

  $scope.load = ->
    $rootScope.$broadcast "topbar.loading", true
    $scope.loading = true
    Movies.year(year, $scope.pagination.page, $scope.sortParams).then (data) ->
      $rootScope.$broadcast "topbar.loading", false
      $scope.loading = false
      for movie in data.data
        $scope.movies.push movie
      $scope.movieGroups = kodiRemote.array.inGroupsOf $scope.movies, 2
      $scope.paginationAfterLoad Movies.perPage, data.total
      $scope.Navbar = new NavbarFactory
      $scope.Navbar.addLink "/movies", "Movies"
      $scope.Navbar.addLink "/movies/years", "By Year"
      $scope.Navbar.addTitle "#{year} (#{data.total})"
]

app.controller "MoviesRatingController", [ "$scope", "$rootScope", "NavbarFactory", "Movies",
($scope, $rootScope, NavbarFactory, Movies) ->  
  $scope.movies = []
  $scope.movieGroups = []
  
  # sortable directive
  # - set $scope.sortParams before load
  # - call $scope.beforeSortLoad  before load
  $scope.showRating = true
  $scope.showYear = true
  $scope.showRecentlyAdded = true
  $scope.showSortDirection = true
  $scope.beforeSortLoad = ->
    $scope.movies = []
    $scope.pagination.page = 1

  # autoScrollPaginate directive
  # - sets $scope.pagination hash
  # - uses $scope.paginationAfterLoad to calculate $scope.pagination.more
  # - uses $scope.loading

  $scope.load = ->
    $rootScope.$broadcast "topbar.loading", true

    $scope.sortParams =
      by: "rating"
      direction: "ascending"
    $scope.sortParams.direction = $scope.sort.direction.methods[$scope.sort.direction.current] if $scope.sort

    $scope.loading = true
    Movies.all($scope.pagination.page, $scope.sortParams).then (data) ->
      $rootScope.$broadcast "topbar.loading", false
      $scope.loading = false
      for movie in data.data
        $scope.movies.push movie

      $scope.movieGroups = kodiRemote.array.inGroupsOf $scope.movies, 2
      $scope.Navbar = new NavbarFactory
      $scope.Navbar.addLink "/movies", "Movies (#{data.total})"
      $scope.Navbar.addTitle "Rating"
      $scope.paginationAfterLoad Movies.perPage, data.total
      return
]
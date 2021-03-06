app = angular.module "kodiRemote.directives", []

app.directive "loadingScreen", [ ->
  restrict: "E"
  scope:
    loading: "="
  templateUrl: "app/views/loading.html"
]

app.directive "navbar", [->
  restrict: "E"
  scope:
    model: "="
  templateUrl: "app/views/ui/navbar.html"
  controller: [ "$scope", "$location", ($scope, $location) ->
    $scope.go = (url) -> $location.path url
  ]
]

app.directive "autoScrollPaginate", [ "$compile", ($compile) ->
  restrict: "A"
  link: (scope, element, attrs) ->
    button = $("<md-button>").attr("ng-click", "loadNextPage()").html("Next Page")
    $compile(button)(scope)
    element.append(button)

    elementVisible = (elem) ->
      $elem = $(elem)
      $window = $(window)
      docViewTop = $window.scrollTop()
      docViewBottom = docViewTop + $window.height()
      elemTop = $elem.offset().top
      elemBottom = elemTop + $elem.height()
      return ((elemBottom <= docViewBottom) && (elemTop >= docViewTop))

    scrollHandler = ->
      unless scope.pagination.more
        button.hide()
      if elementVisible(button) && !scope.loading && scope.pagination.more
        scope.loadNextPage()

    $(document).off "scroll", scrollHandler
    $(document).on "scroll", scrollHandler
    scope.$watch "pagination.more", ->
      button.show() if scope.pagination.more
      button.hide() unless scope.pagination.more
    return

  controller: ["$scope", ($scope) ->
    $scope.pagination =
      page: 1
      more: true
    $scope.loadNextPage = ->
      $scope.pagination.page += 1
      $scope.load()
    $scope.paginationAfterLoad = (perPage, total) ->
      $scope.pagination.more  = ($scope.pagination.page * perPage) < total
      
    $scope.load()
  ]
]

app.directive "sortable", [->
  restrict: "A"
  controller: [ "$scope", ($scope) ->
    $scope.sort = 
      direction:
        icons: ["sort_ascending", "sort_descending"]
        methods: ["ascending", "descending"]
        labels: ["Ascending", "Descending"]
        current: 0

    $scope.sortByArtists        = -> $scope.visitArtists()
    $scope.sortByAlbums         = -> $scope.visitAlbums()
    $scope.sortByGenre          = (type) -> $scope.visitGenres(type)
    $scope.sortByRecentlyAdded  = (type) -> $scope.visitRecentlyAdded(type)
    $scope.sortByYear           = -> $scope.visitYears()
    $scope.sortByRating         = (type) -> $scope.visitRating(type)

    $scope.toggleSortDirection = ->
      $scope.sort.direction.current += 1
      $scope.sort.direction.current = 0 if $scope.sort.direction.current == $scope.sort.direction.methods.length
      $scope.sortParams =
        by: "title"
        direction: $scope.sort.direction.methods[$scope.sort.direction.current]
      $scope.beforeSortLoad()
      $scope.load()
  ]
]

app.directive "videoButtons", [->
  restrict: "E"
  scope:
    video: "="
    visible: "="
  templateUrl: "app/views/ui/video-buttons.html"
  controller: [ "$scope", "$rootScope", "Player", "Playlist", "Episodes", "Movies", ($scope, $rootScope, Player, Playlist, Episodes, Movies) ->

    $scope.play = -> 
      if $scope.video.type == "movie"
        Player.playMovie $scope.video.movieid
      if $scope.video.type == "episode"
        Player.playEpisode $scope.video.episodeid

    $scope.addedToPlaylist = false
    $scope.addToPlaylist = (event) ->
      if $scope.video.type == "episode"
        Playlist.addEpisode $scope.video.episodeid
        $scope.addedToPlaylist = true
      if $scope.video.type == "movie"
        Playlist.addMovie $scope.video.movieid
        $scope.addedToPlaylist = true

    $scope.markAsWatched = -> 
      if $scope.video.type == "episode"
        Episodes.markAsWatched($scope.video)        
      if $scope.video.type == "movie"
        Movies.markAsWatched($scope.video)        
      $scope.video.playcount = 1
  ]
]
app.directive "videoButtonsEvents", [->
  restrict: "A"
  controller: ["$scope", ($scope) ->
    $scope.visible = false
    $scope.showPlayButton = (event) -> $scope.visible = true
    $scope.hidePlayButton = (event) -> 
      element = $(event.toElement)
      if element.parents(".hoverable-video-avatar").length == 0
        $scope.visible = false
  ]
]

app.directive "castMembers", [->
  restrict: "E"
  scope:
    video: "="
  templateUrl: "app/views/ui/cast-members.html"
  controller: [ "$scope", ($scope) ->
    $scope.$watch "video", ->
      $scope.video.castGroups = kodiRemote.array.inGroupsOf $scope.video.cast, 2
  ]
]

# ---------- avatars ----------

app.directive "avatarImage", [ ->
  restrict: "E"
  replace: true
  scope:
    avatar: "="
  templateUrl: "app/views/ui/avatar-image.html"  
]

app.directive "circleAvatar", [->
  restrict: "E"
  replace: true
  scope:
    label: "="
  templateUrl: "app/views/ui/circle-avatar.html" 
  controller: [ "$scope", ($scope) ->
    parts = $scope.label.split(" ")
    $scope.initials = parts[0][0]
    if parts.length == 1
      $scope.initials = parts[0][0] + parts[0][1]
    else
      $scope.initials = parts[0][0] + parts[1][0]
  ]
]

app.directive "emptyAvatar", [->
  restrict: "E"
  replace: true
  template: "<div class='empty-avatar video-avatar'></div>"
]
app.directive "emptyCast", [->
  restrict: "E"
  replace: true
  template: "<div class='empty-cast'></div>"
]

# ---------- video details ----------

app.directive "rating", [->
  restrict: "E"
  scope:
    rating: "="
    size: "@"
  template: "<div class='rating {{classSize}}'><ng-md-icon icon='star' size='{{iconSize}}' style='fill: rgba(33,150,243,1);'></ng-md-icon> {{rating | number: 1}}</div>"
  controller: [ "$scope", ($scope) ->
    $scope.iconSize = if $scope.size == "big" then 32 else 16
    $scope.classSize = if $scope.size == "big" then "big" else "regular"
  ]
]

app.directive "runtime", [->
  restrict: "E"
  scope:
    seconds: "="
  templateUrl: "app/views/ui/runtime.html"
  controller: [ "$scope", ($scope) ->
    $scope.hours = $scope.seconds / 3600
    $scope.runtime = $scope.runtime % 3600
    $scope.minutes = $scope.seconds / 60    
  ]
]

app.directive "watchedIt", [->
  restrict: "E"
  scope:
    model: "="
  templateUrl: "app/views/ui/watched-it.html"
  controller: [ "$scope", ($scope) ->
    $scope.$watch "model.playcount", (c,o) ->
      $scope.title      = if $scope.model.playcount == 1 then "Watched it" else "Haven't watched it"
      $scope.iconColor  = if $scope.model.playcount == 1 then "rgba(33,150,243,1)" else "rgba(33,150,243,0.2)"
  ]
]
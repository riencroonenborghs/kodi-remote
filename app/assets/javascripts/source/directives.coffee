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
    scope.$watch "morePages", ->
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
      by: 
        labels: ["Name", "Recent"]
        methods: ["label", "dateadded"]
        current: 0
      direction:
        icons: ["sort_ascending", "sort_descending"]
        methods: ["ascending", "descending"]
        current: 0

    setSortParams = ->
      $scope.sortParams =
        by: $scope.sort.by.methods[$scope.sort.by.current]
        direction: $scope.sort.direction.methods[$scope.sort.direction.current]

    $scope.toggleSortDirection = ->
      $scope.sort.direction.current += 1
      $scope.sort.direction.current = 0 if $scope.sort.direction.current == $scope.sort.direction.methods.length
      setSortParams()
      $scope.beforeSortLoad()
      $scope.load()

    $scope.toggleSortBy = -> 
      $scope.sort.by.current += 1
      $scope.sort.by.current = 0 if $scope.sort.by.current == $scope.sort.by.methods.length
      setSortParams()
      $scope.beforeSortLoad()
      $scope.load()
  ]
]



# ---------- avatars ----------

app.directive "avatarImage", [ ->
  restrict: "E"
  replace: true
  scope:
    avatar: "="
  templateUrl: "app/views/ui/avatar-image.html"
  controller: [ "$scope", ($scope) ->
    if $scope.avatar
      $scope.avatar = decodeURIComponent $scope.avatar.replace("image://", "")
      if $scope.avatar.endsWith("/")
        $scope.avatar = $scope.avatar.slice(0, -1)
  ]
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

# ---------- video details ----------

app.directive "showRating", [->
  restrict: "E"
  replace: true
  scope:
    rating: "="
  templateUrl: "app/views/ui/show-rating.html"
  controller: [ "$scope", ($scope) ->
    $scope.stars = ["star_outline","star_outline","star_outline","star_outline","star_outline"]
    $scope.stars[0] = "star_half" if $scope.rating >= 1
    $scope.stars[0] = "star" if $scope.rating >= 2
    $scope.stars[1] = "star_half" if $scope.rating >= 3
    $scope.stars[1] = "star" if $scope.rating >= 4
    $scope.stars[2] = "star_half" if $scope.rating >= 5
    $scope.stars[2] = "star" if $scope.rating >= 6
    $scope.stars[3] = "star_half" if $scope.rating >= 7
    $scope.stars[3] = "star" if $scope.rating >= 8
    $scope.stars[4] = "star_half" if $scope.rating >= 9
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
    $scope.title      = if $scope.model.playcount == 1 then "Watched it" else "Haven't watched it"
    $scope.iconColor  = if $scope.model.playcount == 1 then "#6FA67B" else "grey"
  ]
]
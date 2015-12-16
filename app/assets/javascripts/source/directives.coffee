app = angular.module "kodiRemote.directives", []

app.directive "loadingScreen", [ ->
  restrict: "E"
  scope:
    loading: "="
  templateUrl: "app/views/loading.html"
]

app.directive "autoScroll", [ "$compile", ($compile) ->
  restrict: "A"
  link: (scope, element, attrs) ->
    button = $("<md-button>").attr("ng-click", "nextPage()").html("Next Page")
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
      unless scope.morePages
        button.hide()
      if elementVisible(button) && !scope.loading && scope.morePages
        scope.nextPage()

    $(document).off "scroll", scrollHandler
    $(document).on "scroll", scrollHandler
    scope.$watch "morePages", ->
      button.show() if scope.morePages 
      button.hide() unless scope.morePages 

  controller: ["$scope", ($scope) ->
    
  ]
]

# ---------- avatars ----------

app.directive "avatarImage", [ ->
  restrict: "E"
  replace: true
  scope:
    avatar: "="
  template: "<img src='{{avatar}}' class='md-avatar' />"
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
  template: "<div class='circle-avatar md-avatar'><span>{{initials}}</span></div>"
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
  template: "<span ng-repeat='star in stars track by $index'><ng-md-icon icon='{{star}}' size='8' style='fill: grey;'></ng-md-icon></span>"
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
  template: "{{hours | number}}:{{minutes | number}}"
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
  template: "<ng-md-icon icon='check_circle' size='12' style='fill: #6FA67B;' ng-if='model.playcount == 1' title='Watched it'></ng-md-icon>"
]
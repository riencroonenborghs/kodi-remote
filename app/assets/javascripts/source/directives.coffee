app = angular.module "kodiRemote.directives", []

app.directive "loadingScreen", [ ->
  restrict: "E"
  scope:
    loading: "="
  templateUrl: "app/views/loading.html"
]

app.directive "artPoster", [ ->
  restrict: "E"
  replace: true
  scope:
    art: "="
  template: "<img src='{{poster}}' class='art-poster' />"
  controller: [ "$scope", ($scope) ->
    $scope.poster = ""
    if $scope.art.poster
      $scope.poster = decodeURIComponent $scope.art.poster.replace("image://", "")
      $scope.poster = $scope.poster.slice(0, -1)    

  ]
]

app.directive "tvshowThumbnail", [ ->
  restrict: "E"
  replace: true
  scope:
    thumbnail: "="
  template: "<img src='{{thumb}}' class='art-thumb' />"
  controller: [ "$scope", ($scope) ->
    $scope.thumb = decodeURIComponent $scope.thumbnail.replace("image://", "")
    $scope.thumb = $scope.thumb.slice(0, -1)
  ]
]

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

app.directive "circleAvatar", [->
  restrict: "E"
  scope:
    label: "="
  template: "<div class='circle-avatar'>{{initials}}</div>"
  controller: [ "$scope", ($scope) ->
    parts = $scope.label.split(" ")
    $scope.initials = parts[0][0]
    if parts.length == 1
      $scope.initials = parts[0][0] + parts[0][1]
    else
      $scope.initials = parts[0][0] + parts[1][0]
  ]
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

app.directive "watchedIt", [->
  restrict: "E"
  scope:
    model: "="
  template: "<ng-md-icon icon='check_circle' size='12' style='fill: #6FA67B;' ng-if='model.playcount == 1' title='Watched it'></ng-md-icon>"
]
// Generated by CoffeeScript 1.9.3
(function() {
  var app;

  app = angular.module("kodiRemote.directives", []);

  app.directive("loadingScreen", [
    function() {
      return {
        restrict: "E",
        scope: {
          loading: "="
        },
        templateUrl: "app/views/loading.html"
      };
    }
  ]);

  app.directive("navbar", [
    function() {
      return {
        restrict: "E",
        scope: {
          model: "="
        },
        templateUrl: "app/views/ui/navbar.html",
        controller: [
          "$scope", "$location", function($scope, $location) {
            return $scope.go = function(url) {
              return $location.path(url);
            };
          }
        ]
      };
    }
  ]);

  app.directive("autoScrollPaginate", [
    "$compile", function($compile) {
      return {
        restrict: "A",
        link: function(scope, element, attrs) {
          var button, elementVisible, scrollHandler;
          button = $("<md-button>").attr("ng-click", "loadNextPage()").html("Next Page");
          $compile(button)(scope);
          element.append(button);
          elementVisible = function(elem) {
            var $elem, $window, docViewBottom, docViewTop, elemBottom, elemTop;
            $elem = $(elem);
            $window = $(window);
            docViewTop = $window.scrollTop();
            docViewBottom = docViewTop + $window.height();
            elemTop = $elem.offset().top;
            elemBottom = elemTop + $elem.height();
            return (elemBottom <= docViewBottom) && (elemTop >= docViewTop);
          };
          scrollHandler = function() {
            if (!scope.pagination.more) {
              button.hide();
            }
            if (elementVisible(button) && !scope.loading && scope.pagination.more) {
              return scope.loadNextPage();
            }
          };
          $(document).off("scroll", scrollHandler);
          $(document).on("scroll", scrollHandler);
          scope.$watch("morePages", function() {
            if (scope.pagination.more) {
              button.show();
            }
            if (!scope.pagination.more) {
              return button.hide();
            }
          });
        },
        controller: [
          "$scope", function($scope) {
            $scope.pagination = {
              page: 1,
              more: true
            };
            $scope.loadNextPage = function() {
              $scope.pagination.page += 1;
              return $scope.load();
            };
            $scope.paginationAfterLoad = function(perPage, total) {
              return $scope.pagination.more = ($scope.pagination.page * perPage) < total;
            };
            return $scope.load();
          }
        ]
      };
    }
  ]);

  app.directive("sortable", [
    function() {
      return {
        restrict: "A",
        controller: [
          "$scope", function($scope) {
            var setSortParams;
            $scope.sort = {
              by: {
                labels: ["Name", "Recent"],
                methods: ["label", "dateadded"],
                current: 0
              },
              direction: {
                icons: ["sort_ascending", "sort_descending"],
                methods: ["ascending", "descending"],
                current: 0
              }
            };
            setSortParams = function() {
              return $scope.sortParams = {
                by: $scope.sort.by.methods[$scope.sort.by.current],
                direction: $scope.sort.direction.methods[$scope.sort.direction.current]
              };
            };
            $scope.toggleSortDirection = function() {
              $scope.sort.direction.current += 1;
              if ($scope.sort.direction.current === $scope.sort.direction.methods.length) {
                $scope.sort.direction.current = 0;
              }
              setSortParams();
              $scope.beforeSortLoad();
              return $scope.load();
            };
            return $scope.toggleSortBy = function() {
              $scope.sort.by.current += 1;
              if ($scope.sort.by.current === $scope.sort.by.methods.length) {
                $scope.sort.by.current = 0;
              }
              setSortParams();
              $scope.beforeSortLoad();
              return $scope.load();
            };
          }
        ]
      };
    }
  ]);

  app.directive("videoButtons", [
    function() {
      return {
        restrict: "E",
        scope: {
          video: "=",
          visible: "="
        },
        templateUrl: "app/views/ui/video-buttons.html",
        controller: [
          "$scope", "$rootScope", "Player", "Playlist", function($scope, $rootScope, Player, Playlist) {
            var showMessage;
            showMessage = function(message) {
              return $rootScope.$broadcast("show.message", message);
            };
            $scope.addedToPlaylist = false;
            $scope.play = function() {
              if ($scope.video.type === "movie") {
                Player.playMovie($scope.video.movieid);
              }
              if ($scope.video.type === "episode") {
                return Player.playEpisode($scope.video.episodeid);
              }
            };
            return $scope.addToPlaylist = function(event) {
              if ($scope.video.type === "episode") {
                Playlist.addEpisode($scope.video.episodeid);
                $scope.addedToPlaylist = true;
              }
              if ($scope.video.type === "movie") {
                Playlist.addMovie($scope.video.movieid);
                return $scope.addedToPlaylist = true;
              }
            };
          }
        ]
      };
    }
  ]);

  app.directive("videoButtonsEvents", [
    function() {
      return {
        restrict: "A",
        controller: [
          "$scope", function($scope) {
            $scope.visible = false;
            $scope.showPlayButton = function(event) {
              return $scope.visible = true;
            };
            return $scope.hidePlayButton = function(event) {
              var element;
              element = $(event.toElement);
              if (element.parents(".hoverable-video-avatar").length === 0) {
                return $scope.visible = false;
              }
            };
          }
        ]
      };
    }
  ]);

  app.directive("castMembers", [
    function() {
      return {
        restrict: "E",
        scope: {
          video: "="
        },
        templateUrl: "app/views/ui/cast-members.html",
        controller: [
          "$scope", function($scope) {
            return $scope.$watch("video", function() {
              return $scope.video.castGroups = kodiRemote.array.inGroupsOf($scope.video.cast, 2);
            });
          }
        ]
      };
    }
  ]);

  app.directive("avatarImage", [
    function() {
      return {
        restrict: "E",
        replace: true,
        scope: {
          avatar: "="
        },
        templateUrl: "app/views/ui/avatar-image.html"
      };
    }
  ]);

  app.directive("circleAvatar", [
    function() {
      return {
        restrict: "E",
        replace: true,
        scope: {
          label: "="
        },
        templateUrl: "app/views/ui/circle-avatar.html",
        controller: [
          "$scope", function($scope) {
            var parts;
            parts = $scope.label.split(" ");
            $scope.initials = parts[0][0];
            if (parts.length === 1) {
              return $scope.initials = parts[0][0] + parts[0][1];
            } else {
              return $scope.initials = parts[0][0] + parts[1][0];
            }
          }
        ]
      };
    }
  ]);

  app.directive("emptyAvatar", [
    function() {
      return {
        restrict: "E",
        replace: true,
        template: "<div class='empty-avatar video-avatar'>&nbsp;</div>"
      };
    }
  ]);

  app.directive("emptyCast", [
    function() {
      return {
        restrict: "E",
        replace: true,
        template: "<div class='empty-cast'>&nbsp;</div>"
      };
    }
  ]);

  app.directive("rating", [
    function() {
      return {
        restrict: "E",
        scope: {
          rating: "=",
          size: "@"
        },
        template: "<div class='rating {{classSize}}'><ng-md-icon icon='star' size='{{iconSize}}' style='fill: rgba(33,150,243,1);'></ng-md-icon> {{rating | number: 1}}</div>",
        controller: [
          "$scope", function($scope) {
            $scope.iconSize = $scope.size === "big" ? 32 : 16;
            return $scope.classSize = $scope.size === "big" ? "big" : "regular";
          }
        ]
      };
    }
  ]);

  app.directive("runtime", [
    function() {
      return {
        restrict: "E",
        scope: {
          seconds: "="
        },
        templateUrl: "app/views/ui/runtime.html",
        controller: [
          "$scope", function($scope) {
            $scope.hours = $scope.seconds / 3600;
            $scope.runtime = $scope.runtime % 3600;
            return $scope.minutes = $scope.seconds / 60;
          }
        ]
      };
    }
  ]);

  app.directive("watchedIt", [
    function() {
      return {
        restrict: "E",
        scope: {
          model: "="
        },
        templateUrl: "app/views/ui/watched-it.html",
        controller: [
          "$scope", function($scope) {
            $scope.title = $scope.model.playcount === 1 ? "Watched it" : "Haven't watched it";
            return $scope.iconColor = $scope.model.playcount === 1 ? "rgba(33,150,243,1)" : "rgba(33,150,243,0.2)";
          }
        ]
      };
    }
  ]);

}).call(this);

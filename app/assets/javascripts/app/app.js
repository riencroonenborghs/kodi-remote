var app, kodiRemote,
  slice = [].slice;

kodiRemote = window.kodiRemote || (window.kodiRemote = {});

app = angular.module("kodiRemote", ["ngAria", "ngAnimate", "ngMaterial", "ngMdIcons", "ngRoute", "ngWebSocket", "kodiRemote.controllers", "kodiRemote.services", "kodiRemote.directives", "kodiRemote.factories", "kodiRemote.tvshows.controllers", "kodiRemote.tvshows.services", "kodiRemote.movies.controllers", "kodiRemote.movies.services", "kodiRemote.settings.controllers", "kodiRemote.remote.controllers", "kodiRemote.remote.services", "kodiRemote.playlist.controllers", "kodiRemote.playlist.services", "kodiRemote.genres.controllers", "kodiRemote.genres.services", "kodiRemote.music.controllers", "kodiRemote.music.services", "kodiRemote.liked.controllers", "kodiRemote.liked.services", "kodiRemote.tv.controllers", "kodiRemote.tv.services"]);

app.config(function($mdThemingProvider) {
  return $mdThemingProvider.theme("default").primaryPalette("blue").accentPalette("green");
});

kodiRemote.settings = {
  server: null,
  port: null,
  requestType: null,
  liked: {
    tvShows: [],
    movies: []
  }
};

kodiRemote.imageObject = function(image) {
  return {
    url: "http://" + kodiRemote.settings.server + ":" + kodiRemote.settings.port + "/image/" + (encodeURIComponent(image)),
    original: image,
    isSet: image !== void 0 && image !== null && image !== ""
  };
};

kodiRemote.array = {
  inGroupsOf: function(_list, number) {
    var list, newList;
    list = _list.slice(0);
    newList = [];
    while (list.length > 0) {
      newList.push(list.splice(0, number));
    }
    return newList;
  }
};

kodiRemote.video = {
  resumePercentage: function(video) {
    return video.resume.percentage = video.resume.position === 0 ? 0 : (video.resume.position / video.resume.total) * 100;
  }
};

app.config(function($routeProvider, $locationProvider) {
  $routeProvider.when("/settings", {
    templateUrl: "app/views/settings/index.html",
    controller: "SettingsController"
  }).when("/tvshows", {
    templateUrl: "app/views/tvshows/index.html",
    controller: "TvShowsController"
  }).when("/tvshows/genres", {
    templateUrl: "app/views/genres/index.html",
    controller: "TvShowGenresController"
  }).when("/tvshows/rating", {
    templateUrl: "app/views/tvshows/rating.html",
    controller: "TvShowsRatingController"
  }).when("/tvshows/:id/seasons", {
    templateUrl: "app/views/tvshows/seasons/index.html",
    controller: "SeasonsController"
  }).when("/tvshows/:tvshowid/seasons/:id/episodes", {
    templateUrl: "app/views/tvshows/seasons/episodes/index.html",
    controller: "EpisodesController"
  }).when("/episodes/recently-added", {
    templateUrl: "app/views/tvshows/seasons/episodes/recently-added.html",
    controller: "RecentlyAddedEpisodesController"
  }).when("/episodes/:id", {
    templateUrl: "app/views/tvshows/seasons/episodes/show.html",
    controller: "EpisodeController"
  }).when("/movies", {
    templateUrl: "app/views/movies/index.html",
    controller: "MoviesController"
  }).when("/movies/genres", {
    templateUrl: "app/views/genres/index.html",
    controller: "MovieGenresController"
  }).when("/movies/rating", {
    templateUrl: "app/views/movies/rating.html",
    controller: "MoviesRatingController"
  }).when("/movies/recently-added", {
    templateUrl: "app/views/movies/recently-added.html",
    controller: "RecentlyAddedMoviesController"
  }).when("/movies/years", {
    templateUrl: "app/views/movies/years/index.html",
    controller: "MovieYearsController"
  }).when("/movies/years/:year", {
    templateUrl: "app/views/movies/years/show.html",
    controller: "MovieYearController"
  }).when("/movies/:id", {
    templateUrl: "app/views/movies/show.html",
    controller: "MovieController"
  }).when("/remote", {
    templateUrl: "app/views/remote/index.html",
    controller: "RemoteController"
  }).when("/genres/tvshows/:genre", {
    templateUrl: "app/views/genres/show-tvshows.html",
    controller: "TvShowGenreController"
  }).when("/genres/movies/:genre", {
    templateUrl: "app/views/genres/show-movies.html",
    controller: "MovieGenreController"
  }).when("/tv", {
    templateUrl: "app/views/tv/index.html",
    controller: "TVController"
  }).otherwise("/tvshows", {
    templateUrl: "app/views/tvshows/index.html",
    controller: "TvShowsController"
  });
  return $locationProvider.html5Mode(true);
});

app.filter("secondsToDateTime", [
  function() {
    return function(seconds) {
      return new Date(1970, 0, 1).setSeconds(seconds);
    };
  }
]);

app.filter("zeroPrepend", [
  function() {
    return function(input, length) {
      var inputString, zeroes;
      inputString = new String(input);
      zeroes = "0".repeat(length - inputString.length);
      return "" + zeroes + input;
    };
  }
]);

kodiRemote.Loader = (function() {
  function _Class(scope, service) {
    this.scope = scope;
    this.service = service;
    return;
  }

  _Class.prototype.handleData = function(data) {};

  _Class.prototype.afterCallback = function(data) {};

  _Class.prototype._baseMethod = function() {
    var method, params, ref;
    method = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    this.scope.loading = true;
    return (ref = this.service)[method].apply(ref, params).then((function(_this) {
      return function(data) {
        _this.scope.loading = false;
        _this.handleData(data);
        return _this.afterCallback(data);
      };
    })(this));
  };

  _Class.prototype.index = function() {
    var params;
    params = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return this._baseMethod.apply(this, ["index"].concat(slice.call(params)));
  };

  _Class.prototype.show = function() {
    var params;
    params = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return this._baseMethod.apply(this, ["show"].concat(slice.call(params)));
  };

  return _Class;

})();

var app,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

app = angular.module("kodiRemote.services", []);

app.service("Request", [
  "$http", "$q", "$websocket", function($http, $q, $websocket) {
    var service;
    service = {
      fetch: function(method, handler, params) {
        var deferred, errorHandler, httpSuccessHandler, payload, successHandler, websocketObject, websocketSuccessHandler;
        deferred = $q.defer();
        errorHandler = function(response) {
          console.error("wsRequest ERROR - " + (new Date()));
          console.error(response);
          return console.error("wsRequest ERROR ---------------");
        };
        successHandler = function(parsedResponse) {
          var data, total;
          if (parsedResponse.result) {
            data = handler(parsedResponse.result);
            if (parsedResponse.result === "OK") {
              deferred.resolve({
                data: data,
                total: 0
              });
            } else {
              total = parsedResponse.result.limits ? parsedResponse.result.limits.total : null;
              deferred.resolve({
                data: data,
                total: total
              });
            }
          }
        };
        payload = {
          jsonrpc: "2.0",
          method: method,
          id: 1,
          params: params
        };
        if (kodiRemote.settings.requestType === "http") {
          httpSuccessHandler = function(response) {
            return successHandler(response.data);
          };
          $http.post("http://" + kodiRemote.settings.server + ":" + kodiRemote.settings.port + "/jsonrpc", payload).then(httpSuccessHandler, errorHandler);
        } else {
          websocketSuccessHandler = function(response) {
            return successHandler(JSON.parse(response.data));
          };
          websocketObject = $websocket("ws://" + kodiRemote.settings.server + ":" + kodiRemote.settings.port + "/jsonrpc");
          websocketObject.onError(errorHandler);
          websocketObject.onMessage(websocketSuccessHandler);
          websocketObject.send(payload);
        }
        return deferred.promise;
      }
    };
    return service;
  }
]);

app.service("SearchService", [
  "TvShows", "Movies", function(TvShows, Movies) {
    var service;
    service = {
      tvShows: [],
      tvShowGroups: [],
      movies: [],
      movieGroups: [],
      searching: false,
      reset: function() {
        this.tvShows = [];
        this.movies = [];
        return this.searching = false;
      },
      search: function(query) {
        var searchingMovies, searchingTvShows;
        if (!(query.length > 2)) {
          return;
        }
        searchingTvShows = true;
        searchingMovies = true;
        this.searching = searchingTvShows && searchingMovies;
        this.tvShows = [];
        this.movies = [];
        TvShows.where.title(query).then((function(_this) {
          return function(tvShowsData) {
            var i, len, ref, ref1, tvShow;
            ref = tvShowsData.data;
            for (i = 0, len = ref.length; i < len; i++) {
              tvShow = ref[i];
              tvShow.liked = false;
              if (ref1 = tvShow.tvshowid, indexOf.call(kodiRemote.settings.liked.tvShows, ref1) >= 0) {
                tvShow.liked = true;
              }
              _this.tvShows.push(tvShow);
            }
            _this.tvShowGroups = kodiRemote.array.inGroupsOf(_this.tvShows, 2);
            searchingTvShows = false;
            return _this.searching = searchingTvShows && searchingMovies;
          };
        })(this));
        Movies.where.title(query).then((function(_this) {
          return function(moviesData) {
            _this.movies = moviesData.data;
            _this.movieGroups = kodiRemote.array.inGroupsOf(_this.movies, 2);
            searchingMovies = true;
            return _this.searching = searchingTvShows && searchingMovies;
          };
        })(this));
      }
    };
    return service;
  }
]);

app.service("Files", [
  "Request", function(Request) {
    var prepareDownloadResultHandler, service;
    prepareDownloadResultHandler = function(result) {
      return result;
    };
    return service = {
      prepareDownload: function(file) {
        var params;
        params = [file];
        return Request.fetch("Files.PrepareDownload", prepareDownloadResultHandler, params);
      }
    };
  }
]);

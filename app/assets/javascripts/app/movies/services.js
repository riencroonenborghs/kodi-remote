var app;

app = angular.module("kodiRemote.movies.services", []);

app.service("Movies", [
  "Request", function(Request) {
    var allResultHandler, emptyResultHandler, getResultHandler, properties, service, yearsResultHandler;
    properties = ["title", "genre", "year", "rating", "director", "tagline", "plot", "plotoutline", "playcount", "writer", "studio", "mpaa", "cast", "imdbnumber", "runtime", "thumbnail", "resume", "file"];
    allResultHandler = function(result) {
      var i, len, movie, ref;
      ref = result.movies || [];
      for (i = 0, len = ref.length; i < len; i++) {
        movie = ref[i];
        movie.type = "movie";
        movie.thumbnail = kodiRemote.imageObject(movie.thumbnail);
        kodiRemote.video.resumePercentage(movie);
      }
      return result.movies || [];
    };
    getResultHandler = function(result) {
      var castMember, i, len, ref;
      result.moviedetails.type = "movie";
      result.moviedetails.thumbnail = kodiRemote.imageObject(result.moviedetails.thumbnail);
      kodiRemote.video.resumePercentage(result.moviedetails);
      ref = result.moviedetails.cast;
      for (i = 0, len = ref.length; i < len; i++) {
        castMember = ref[i];
        castMember.thumbnail = kodiRemote.imageObject(castMember.thumbnail);
      }
      return result.moviedetails;
    };
    yearsResultHandler = function(result) {
      return result.movies || [];
    };
    emptyResultHandler = function(result) {
      return result;
    };
    service = {
      perPage: 10,
      where: {
        title: function(query) {
          var params;
          params = {
            properties: properties,
            filter: {
              field: "title",
              operator: "contains",
              value: query
            }
          };
          return Request.fetch("VideoLibrary.GetMovies", allResultHandler, params);
        }
      },
      all: function(pageParams, sortParams) {
        var params;
        if (pageParams == null) {
          pageParams = 1;
        }
        if (sortParams == null) {
          sortParams = {
            by: "label",
            direction: "ascending"
          };
        }
        params = {
          properties: properties,
          sort: {
            method: sortParams.by,
            order: sortParams.direction
          },
          limits: {
            start: (pageParams - 1) * this.perPage,
            end: pageParams * this.perPage
          }
        };
        return Request.fetch("VideoLibrary.GetMovies", allResultHandler, params);
      },
      recentlyAdded: function() {
        var params;
        params = {
          properties: properties
        };
        return Request.fetch("VideoLibrary.GetRecentlyAddedMovies", allResultHandler, params);
      },
      get: function(movieId) {
        var params;
        params = {
          movieid: movieId,
          properties: properties
        };
        return Request.fetch("VideoLibrary.GetMovieDetails", getResultHandler, params);
      },
      years: function() {
        var params;
        params = {
          properties: ["year"]
        };
        return Request.fetch("VideoLibrary.GetMovies", yearsResultHandler, params);
      },
      year: function(year, pageParams, sortParams) {
        var params;
        if (pageParams == null) {
          pageParams = 1;
        }
        if (sortParams == null) {
          sortParams = {
            by: "label",
            direction: "ascending"
          };
        }
        params = {
          properties: properties,
          sort: {
            method: sortParams.by,
            order: sortParams.direction
          },
          filter: {
            field: "year",
            operator: "is",
            value: "" + year
          },
          limits: {
            start: (pageParams - 1) * this.perPage,
            end: pageParams * this.perPage
          }
        };
        return Request.fetch("VideoLibrary.GetMovies", allResultHandler, params);
      },
      markAsWatched: function(movie) {
        var params;
        params = [movie.movieid, movie.title, 1];
        return Request.fetch("VideoLibrary.SetMovieDetails", emptyResultHandler, params);
      }
    };
    return service;
  }
]);

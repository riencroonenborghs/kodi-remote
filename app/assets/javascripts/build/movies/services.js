// Generated by CoffeeScript 1.9.3
(function() {
  var app;

  app = angular.module("kodiRemote.movies.services", []);

  app.service("Movies", [
    "Request", function(Request) {
      var allResultHandler, getResultHandler, properties, service;
      properties = ["title", "genre", "year", "rating", "director", "tagline", "plot", "plotoutline", "playcount", "writer", "studio", "mpaa", "cast", "imdbnumber", "runtime", "thumbnail", "resume"];
      allResultHandler = function(result) {
        var i, len, movie, ref;
        ref = result.movies || [];
        for (i = 0, len = ref.length; i < len; i++) {
          movie = ref[i];
          movie.type = "movie";
          movie.thumbnail = kodiRemote.parseImage(movie.thumbnail);
        }
        return result.movies || [];
      };
      getResultHandler = function(result) {
        var castMember, i, len, ref;
        result.moviedetails.type = "movie";
        result.moviedetails.thumbnail = kodiRemote.parseImage(result.moviedetails.thumbnail);
        ref = result.moviedetails.cast;
        for (i = 0, len = ref.length; i < len; i++) {
          castMember = ref[i];
          castMember.thumbnail = kodiRemote.parseImage(castMember.thumbnail);
        }
        return result.moviedetails;
      };
      service = {
        perPage: 5,
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
        get: function(movieId) {
          var params;
          params = {
            movieid: movieId,
            properties: properties
          };
          return Request.fetch("VideoLibrary.GetMovieDetails", getResultHandler, params);
        }
      };
      return service;
    }
  ]);

}).call(this);

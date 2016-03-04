var app;

app = angular.module("kodiRemote.genres.services", []);

app.service("Genres", [
  "Request", function(Request) {
    var allResultHandler, getMoviesResultHandler, getResultHandler, getTvShowsResultHandler, movieProperties, service, tvShowProperties;
    tvShowProperties = ["title", "genre", "year", "rating", "plot", "studio", "mpaa", "cast", "playcount", "episode", "imdbnumber", "premiered", "thumbnail", "season", "watchedepisodes"];
    movieProperties = ["title", "genre", "year", "rating", "director", "tagline", "plot", "plotoutline", "playcount", "writer", "studio", "mpaa", "cast", "imdbnumber", "runtime", "thumbnail", "resume"];
    allResultHandler = function(result) {
      return result.genres || [];
    };
    getResultHandler = function(type, result) {
      var castMember, i, j, len, len1, ref, ref1, show;
      ref = result[type] || [];
      for (i = 0, len = ref.length; i < len; i++) {
        show = ref[i];
        show.type = "tvShow";
        show.thumbnail = kodiRemote.imageObject(show.thumbnail);
        ref1 = show.cast;
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          castMember = ref1[j];
          castMember.thumbnail = kodiRemote.imageObject(castMember.thumbnail);
        }
        show.seasons = function() {
          return Seasons.all(this.tvshowid);
        };
      }
      return result[type] || [];
    };
    getTvShowsResultHandler = function(result) {
      return getResultHandler("tvshows", result);
    };
    getMoviesResultHandler = function(result) {
      return getResultHandler("movies", result);
    };
    service = {
      all: function(type) {
        var params;
        params = {
          properties: ["title"],
          sort: {
            method: "title",
            order: "ascending"
          }
        };
        if (type !== "music") {
          params.type = type;
          return Request.fetch("VideoLibrary.GetGenres", allResultHandler, params);
        } else {
          return Request.fetch("AudioLibrary.GetGenres", allResultHandler, params);
        }
      },
      get: function(type, genre, sortDirection) {
        var params;
        params = {
          sort: {
            method: "title",
            order: sortDirection
          },
          filter: {
            field: "genre",
            operator: "is",
            value: genre
          }
        };
        switch (type) {
          case "tvshows":
            params.properties = tvShowProperties;
            return Request.fetch("VideoLibrary.GetTVShows", getTvShowsResultHandler, params);
          case "movies":
            params.properties = movieProperties;
            return Request.fetch("VideoLibrary.GetMovies", getMoviesResultHandler, params);
        }
      }
    };
    return service;
  }
]);

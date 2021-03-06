var app;

app = angular.module("kodiRemote.tvshows.services", []);

app.service("TvShows", [
  "Request", "Seasons", function(Request, Seasons) {
    var allResultHandler, getResultHandler, properties, service;
    properties = ["title", "genre", "year", "rating", "plot", "studio", "mpaa", "cast", "playcount", "episode", "imdbnumber", "premiered", "thumbnail", "season", "watchedepisodes"];
    allResultHandler = function(result) {
      var castMember, i, j, len, len1, ref, ref1, show;
      ref = result.tvshows || [];
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
      return result.tvshows || [];
    };
    getResultHandler = function(result) {
      var castMember, i, len, ref;
      result.tvshowdetails.type = "tvShow";
      result.tvshowdetails.thumbnail = kodiRemote.imageObject(result.tvshowdetails.thumbnail);
      ref = result.tvshowdetails.cast;
      for (i = 0, len = ref.length; i < len; i++) {
        castMember = ref[i];
        castMember.thumbnail = kodiRemote.imageObject(castMember.thumbnail);
      }
      result.tvshowdetails.seasons = function() {
        return Seasons.all(this.tvshowid);
      };
      return result.tvshowdetails;
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
          return Request.fetch("VideoLibrary.GetTVShows", allResultHandler, params);
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
        return Request.fetch("VideoLibrary.GetTVShows", allResultHandler, params);
      },
      get: function(tvShowId) {
        var params;
        params = {
          tvshowid: tvShowId,
          properties: properties
        };
        return Request.fetch("VideoLibrary.GetTVShowDetails", getResultHandler, params);
      }
    };
    return service;
  }
]);

app.service("Seasons", [
  "Request", "Episodes", function(Request, Episodes) {
    var properties, resultHandler, service;
    properties = ["season", "playcount", "episode", "thumbnail", "tvshowid", "watchedepisodes"];
    resultHandler = function(result) {
      var i, len, ref, season;
      ref = result.seasons || [];
      for (i = 0, len = ref.length; i < len; i++) {
        season = ref[i];
        season.type = "season";
        season.thumbnail = kodiRemote.imageObject(season.thumbnail);
        season.episodes = function() {
          return Episodes.all(this.tvshowid, this.season);
        };
      }
      return result.seasons || [];
    };
    service = {
      all: function(tvShowId) {
        var params;
        params = {
          tvshowid: tvShowId,
          properties: properties
        };
        return Request.fetch("VideoLibrary.GetSeasons", resultHandler, params);
      }
    };
    return service;
  }
]);

app.service("Episodes", [
  "Request", function(Request) {
    var emptyResultHandler, getResultHandler, properties, resultHandler, service;
    properties = ["title", "plot", "rating", "writer", "firstaired", "playcount", "runtime", "director", "season", "episode", "cast", "thumbnail", "resume", "showtitle", "tvshowid", "file"];
    resultHandler = function(result) {
      var episode, i, len, ref;
      ref = result.episodes || [];
      for (i = 0, len = ref.length; i < len; i++) {
        episode = ref[i];
        episode.type = "episode";
        episode.thumbnail = kodiRemote.imageObject(episode.thumbnail);
        kodiRemote.video.resumePercentage(episode);
      }
      return result.episodes || [];
    };
    getResultHandler = function(result) {
      var castMember, i, len, ref;
      result.episodedetails.type = "episode";
      result.episodedetails.thumbnail = kodiRemote.imageObject(result.episodedetails.thumbnail);
      kodiRemote.video.resumePercentage(result.episodedetails);
      ref = result.episodedetails.cast;
      for (i = 0, len = ref.length; i < len; i++) {
        castMember = ref[i];
        castMember.thumbnail = kodiRemote.imageObject(castMember.thumbnail);
      }
      return result.episodedetails;
    };
    emptyResultHandler = function(result) {
      return result;
    };
    service = {
      all: function(tvShowId, season) {
        var params;
        params = {
          tvshowid: tvShowId,
          season: season,
          properties: properties
        };
        return Request.fetch("VideoLibrary.GetEpisodes", resultHandler, params);
      },
      recentlyAdded: function() {
        var params;
        params = {
          properties: properties
        };
        return Request.fetch("VideoLibrary.GetRecentlyAddedEpisodes", resultHandler, params);
      },
      get: function(episodeId) {
        var params;
        params = {
          episodeid: episodeId,
          properties: properties
        };
        return Request.fetch("VideoLibrary.GetEpisodeDetails", getResultHandler, params);
      },
      markAsWatched: function(episode) {
        var params;
        params = [episode.episodeid, episode.title, 1];
        return Request.fetch("VideoLibrary.SetEpisodeDetails", emptyResultHandler, params);
      }
    };
    return service;
  }
]);

// Generated by CoffeeScript 1.9.3
(function() {
  var app;

  app = angular.module("kodiRemote.music.services", []);

  app.service("Albums", [
    "Request", "Songs", function(Request, Songs) {
      var allResultHandler, getResultHandler, properties, service;
      properties = ["title", "description", "artist", "genre", "mood", "style", "albumlabel", "rating", "year", "thumbnail", "playcount", "genreid", "artistid", "fanart"];
      allResultHandler = function(result) {
        var i, len, ref, show;
        ref = result.albums || [];
        for (i = 0, len = ref.length; i < len; i++) {
          show = ref[i];
          show.type = "album";
          show.songs = function() {
            return Songs.all(this.albumid);
          };
        }
        return result.albums || [];
      };
      getResultHandler = function(result) {
        result.albumdetails.type = "album";
        result.albumdetails.songs = function() {
          return Songs.all(this.albumid);
        };
        return result.albumdetails;
      };
      service = {
        perPage: 5,
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
          return Request.fetch("AudioLibrary.GetAlbums", allResultHandler, params);
        },
        get: function(albumId) {
          var params;
          params = {
            albumid: albumId,
            properties: properties
          };
          return Request.fetch("AudioLibrary.GetAlbumDetails", getResultHandler, params);
        }
      };
      return service;
    }
  ]);

  app.service("Songs", [
    "Request", function(Request) {
      var properties, resultHandler, service;
      properties = ["title", "description", "artist", "genre", "mood", "style", "albumlabel", "rating", "year", "thumbnail", "playcount", "genreid", "artistid", "fanart"];
      resultHandler = function(result) {
        var i, len, ref, season;
        ref = result.songs || [];
        for (i = 0, len = ref.length; i < len; i++) {
          season = ref[i];
          season.type = "song";
        }
        return result.songs || [];
      };
      service = {
        all: function(albumId) {
          var params;
          params = {
            albumid: albumId,
            properties: properties
          };
          return Request.fetch("AudioLibrary.GetSongs", resultHandler, params);
        }
      };
      return service;
    }
  ]);

}).call(this);

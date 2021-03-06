var app;

app = angular.module("kodiRemote.music.services", []);

app.service("Artists", [
  "Request", function(Request) {
    var allResultHandler, properties, service;
    properties = ["description", "genre", "thumbnail"];
    allResultHandler = function(result) {
      var artist, i, len, ref;
      ref = result.artists || [];
      for (i = 0, len = ref.length; i < len; i++) {
        artist = ref[i];
        artist.type = "artist";
        artist.thumbnail = kodiRemote.imageObject(artist.thumbnail);
      }
      return result.artists || [];
    };
    service = {
      perPage: 10,
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
        return Request.fetch("AudioLibrary.GetArtists", allResultHandler, params);
      }
    };
    return service;
  }
]);

app.service("Albums", [
  "Request", function(Request) {
    var allResultHandler, getResultHandler, properties, service;
    properties = ["title", "description", "artist", "genre", "mood", "style", "albumlabel", "rating", "year", "thumbnail", "playcount", "genreid", "artistid", "fanart"];
    allResultHandler = function(result) {
      var album, i, len, ref;
      ref = result.albums || [];
      for (i = 0, len = ref.length; i < len; i++) {
        album = ref[i];
        album.type = "album";
        album.thumbnail = kodiRemote.imageObject(album.thumbnail);
      }
      return result.albums || [];
    };
    getResultHandler = function(result) {
      result.albumdetails.type = "album";
      result.albumdetails.thumbnail = kodiRemote.imageObject(result.albumdetails.thumbnail);
      return result.albumdetails;
    };
    service = {
      perPage: 10,
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
    properties = ["title", "artist", "genre", "year", "rating", "album", "track", "duration", "playcount", "thumbnail", "file"];
    resultHandler = function(result) {
      var i, len, ref, song;
      ref = result.songs || [];
      for (i = 0, len = ref.length; i < len; i++) {
        song = ref[i];
        song.type = "song";
        song.thumbnail = kodiRemote.imageObject(song.thumbnail);
      }
      return result.songs || [];
    };
    service = {
      all: function(albumTitle) {
        var params;
        params = {
          properties: properties,
          filter: {
            field: "album",
            operator: "is",
            value: albumTitle
          }
        };
        return Request.fetch("AudioLibrary.GetSongs", resultHandler, params);
      }
    };
    return service;
  }
]);

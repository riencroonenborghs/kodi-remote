var app,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

app = angular.module("kodiRemote.liked.services", []);

app.service("Liked", [
  function() {
    var service;
    service = {
      addTvShow: function(tvShow) {
        var ref;
        if (ref = tvShow.tvshowid, indexOf.call(kodiRemote.settings.liked.tvShows, ref) >= 0) {
          return;
        }
        kodiRemote.settings.liked.tvShows.push(tvShow.tvshowid);
        tvShow.liked = true;
        this._save();
      },
      removeTvShow: function(tvShow) {
        var ref;
        if (ref = tvShow.tvshowid, indexOf.call(kodiRemote.settings.liked.tvShows, ref) < 0) {
          return;
        }
        kodiRemote.settings.liked.tvShows.splice(kodiRemote.settings.liked.tvShows.indexOf(tvShow.tvshowid), 1);
        tvShow.liked = false;
        this._save();
      },
      toggleTvShow: function(tvShow) {
        var ref;
        if (ref = tvShow.tvshowid, indexOf.call(kodiRemote.settings.liked.tvShows, ref) >= 0) {
          return this.removeTvShow(tvShow);
        } else {
          return this.addTvShow(tvShow);
        }
      },
      _save: function() {
        var data, hash;
        chrome.storage.local.clear();
        hash = {
          server: kodiRemote.settings.server,
          port: kodiRemote.settings.port,
          requestType: kodiRemote.settings.requestType,
          liked: {
            tvShows: kodiRemote.settings.liked.tvShows,
            movies: kodiRemote.settings.liked.movies
          }
        };
        data = JSON.stringify(hash);
        return chrome.storage.local.set({
          kodiRemote: data
        });
      }
    };
    return service;
  }
]);

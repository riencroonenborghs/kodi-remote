var app;

app = angular.module("kodiRemote.music.controllers", []);

app.controller("ArtistsController", [
  "$scope", "$rootScope", "NavbarFactory", "Artists", function($scope, $rootScope, NavbarFactory, Artists) {
    $scope.artists = [];
    $scope.artistGroups = [];
    $scope.showAlbums = true;
    $scope.showGenre = true;
    $scope.showRating = true;
    $scope.showRecentlyAdded = true;
    $scope.showSortDirection = true;
    $scope.beforeSortLoad = function() {
      $scope.artists = [];
      return $scope.pagination.page = 1;
    };
    return $scope.load = function() {
      $rootScope.$broadcast("topbar.loading", true);
      $scope.loading = true;
      if ($scope.sortParams) {
        $scope.sortParams.by = "label";
      }
      return Artists.all($scope.pagination.page, $scope.sortParams).then(function(data) {
        var artist, i, len, ref;
        $rootScope.$broadcast("topbar.loading", false);
        $scope.loading = false;
        ref = data.data;
        for (i = 0, len = ref.length; i < len; i++) {
          artist = ref[i];
          $scope.artists.push(artist);
        }
        $scope.artistGroups = kodiRemote.array.inGroupsOf($scope.artists, 2);
        $scope.Navbar = new NavbarFactory;
        $scope.Navbar.addTitle("Artists (" + data.total + ")");
        $scope.paginationAfterLoad(Artists.perPage, data.total);
      });
    };
  }
]);

app.controller("AlbumsController", [
  "$scope", "$rootScope", "NavbarFactory", "Albums", function($scope, $rootScope, NavbarFactory, Albums) {
    $scope.albums = [];
    $scope.albumGroups = [];
    $scope.showArtists = true;
    $scope.showGenre = true;
    $scope.showRating = true;
    $scope.showRecentlyAdded = true;
    $scope.showSortDirection = true;
    $scope.beforeSortLoad = function() {
      $scope.albums = [];
      return $scope.pagination.page = 1;
    };
    return $scope.load = function() {
      $rootScope.$broadcast("topbar.loading", true);
      $scope.loading = true;
      if ($scope.sortParams) {
        $scope.sortParams.by = "label";
      }
      return Albums.all($scope.pagination.page, $scope.sortParams).then(function(data) {
        var album, i, len, ref;
        $rootScope.$broadcast("topbar.loading", false);
        $scope.loading = false;
        ref = data.data;
        for (i = 0, len = ref.length; i < len; i++) {
          album = ref[i];
          $scope.albums.push(album);
        }
        $scope.albumGroups = kodiRemote.array.inGroupsOf($scope.albums, 2);
        $scope.Navbar = new NavbarFactory;
        $scope.Navbar.addTitle("Albums (" + data.total + ")");
        $scope.paginationAfterLoad(Albums.perPage, data.total);
      });
    };
  }
]);

app.controller("AlbumController", [
  "$scope", "$rootScope", "$routeParams", "Albums", "Songs", "NavbarFactory", function($scope, $rootScope, $routeParams, Albums, Songs, NavbarFactory) {
    var albumId;
    albumId = parseInt($routeParams.id);
    $scope.album = null;
    $rootScope.$broadcast("topbar.loading", true);
    return Albums.get(albumId).then(function(albumData) {
      $rootScope.$broadcast("topbar.loading", false);
      $scope.album = albumData.data;
      $scope.album.songs = [];
      Songs.all($scope.album.title).then(function(songsData) {
        return $scope.album.songs = songsData.data;
      });
      $scope.Navbar = new NavbarFactory;
      $scope.Navbar.addLink("/music/albums", "Albums");
      $scope.Navbar.addLink("/music/artists/" + $scope.album.artistid, $scope.album.artist.join(", "));
      $scope.Navbar.addTitle($scope.album.title);
      return $scope.Navbar.addTitle("Tracks");
    });
  }
]);

app.controller("MusicGenresController", [
  "$scope", "$rootScope", "NavbarFactory", "Genres", function($scope, $rootScope, NavbarFactory, Genres) {
    $scope.showAlbums = true;
    $scope.showArtists = true;
    $scope.showGenre = true;
    $scope.showRating = true;
    $scope.showRecentlyAdded = true;
    $scope.genreType = "music";
    $scope.genres = [];
    $scope.genreGroups = [];
    $rootScope.$broadcast("topbar.loading", true);
    return Genres.all("music").then(function(data) {
      $rootScope.$broadcast("topbar.loading", false);
      $scope.genres = data.data;
      $scope.genreGroups = kodiRemote.array.inGroupsOf($scope.genres, 2);
      $scope.Navbar = new NavbarFactory;
      $scope.Navbar.addLink("/music/artists", "Artists");
      return $scope.Navbar.addTitle("Genres (" + data.total + ")");
    });
  }
]);

app.controller("MusicRatingController", [
  "$scope", "$rootScope", "NavbarFactory", "Albums", function($scope, $rootScope, NavbarFactory, Albums) {
    $scope.albums = [];
    $scope.albumGroups = [];
    $scope.showAlbums = true;
    $scope.showArtists = true;
    $scope.showGenre = true;
    $scope.showRecentlyAdded = true;
    $scope.showSortDirection = true;
    $scope.beforeSortLoad = function() {
      $scope.albums = [];
      return $scope.pagination.page = 1;
    };
    return $scope.load = function() {
      $rootScope.$broadcast("topbar.loading", true);
      $scope.sortParams = {
        by: "rating",
        direction: "ascending"
      };
      if ($scope.sort) {
        $scope.sortParams.direction = $scope.sort.direction.methods[$scope.sort.direction.current];
      }
      return Albums.all($scope.pagination.page, $scope.sortParams).then(function(data) {
        var i, len, ref, tvShow;
        $rootScope.$broadcast("topbar.loading", false);
        ref = data.data;
        for (i = 0, len = ref.length; i < len; i++) {
          tvShow = ref[i];
          $scope.albums.push(tvShow);
        }
        $scope.albumGroups = kodiRemote.array.inGroupsOf($scope.albums, 2);
        $scope.Navbar = new NavbarFactory;
        $scope.Navbar.addLink("/music/albums", "Albums (" + data.total + ")");
        $scope.Navbar.addTitle("Rating");
        $scope.paginationAfterLoad(Music.perPage, data.total);
      });
    };
  }
]);

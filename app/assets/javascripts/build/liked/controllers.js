var app;

app = angular.module("kodiRemote.liked.controllers", []);

app.controller("LikedController", [
  "$scope", "NavbarFactory", function($scope, NavbarFactory) {
    $scope.Navbar = new NavbarFactory;
    return $scope.Navbar.addTitle("Liked");
  }
]);

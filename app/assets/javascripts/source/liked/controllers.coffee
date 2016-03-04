app = angular.module "kodiRemote.liked.controllers", []

app.controller "LikedController", [ "$scope", "NavbarFactory",
($scope, NavbarFactory) ->  

  $scope.Navbar = new NavbarFactory
  $scope.Navbar.addTitle "Liked"
]
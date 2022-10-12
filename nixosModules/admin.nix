{ config, pkgs, ... }:

{
  users.users.admin = {
    name = "admin";
    initialPassword = "1234";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkMLqezObEnh3bNFj8QeyVFoJlRaDgO308rvfR8XE2oLFGrY8gUr6QwWt2P5sROrOskF9XuriUPPs5/jSom2uOdbwxBs1zTkdVUPIog5e81GaGNmS2BMKntD5d9GYI6YESBBBxTFEh6hFkd7GpautRfCPiwcIM1daxHEQsKNCp3fGWqonsIAfLkPgVfNQ0piXN4AR4PFpDSuAPDFlxG8q9K/P/w6OtGq/FcxDbl0e2t54ZDVj/fTqDOiKNDb5GVF1tu/IW/KzPcjLl2GFAcRYrIJaptzZOIuHWLK86jEPI+DpkmpbOWOugKXr9wG/eibdndh8w3vvPH+HUrs4OaPmkVhPkZH+899j1sFBAVE7uL+GFOt0N6GNMFKePcJQMQdkq5bGYV8HeXN6U+UQWr4+/2opmoXduIN8nS68l5GeDzyuCQ0Osa6TN47vQ8I2nd6x3E4c+fWXg908SUcaPpTRii6EU0egrjOFRFl0vwe26owCNSJjzMyto0OsexSEILyE= hhefesto@olimpo" ];
  };
  security.sudo.wheelNeedsPassword = false;
  nix.trustedUsers = [ "@wheel" ]; # https://github.com/serokell/deploy-rs/issues/25
}

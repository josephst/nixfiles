final: prev:
# this adds custom pkgs in the same namespace as all other packages
# (ie nixpkgs.recyclarr)
import ../pkgs { pkgs = final; }

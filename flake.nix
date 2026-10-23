{
  description = "mc-rtc-superbuild release and development shells for a controller";

  inputs = {
    mc-rtc-nix.url = "github:mc-rtc/nixpkgs";
    flake-parts.follows = "mc-rtc-nix/flake-parts";
    systems.follows = "mc-rtc-nix/systems";

    ccache-trigger.follows = "mc-rtc-nix/ccache-trigger";

    # You can override dependencies from a commit/pull request by:
    # Adding it as input
    # your-repository.url = "github:username/repository/pull/ID/head";
    # your-repository.flake = true; # use false if the repository does not have a flake
  };

  outputs =
    inputs:
    /**
      This will:
      - Build the controller from the local sources in this repository
      - Generate two mc-rtc-superbuild development shells:
        - mc-rtc-superbuild-mc-openarm : a release shell allowing to run the controller
        - mc-rtc-superbuild-mc-openarm-devel : a development shell allowing to build the controller and run it
        Instructions are displayed upon entering the shells.

       You can control the behaviour or define your own shells with:
       mc-rtc-nix = {};
       mc-rtc-superbuild = {};

       Note that the mc-rtc-superbuild attribute set will be merged with the default controller configuration
    */
    inputs.mc-rtc-nix.lib.mkMcRtcModule inputs (
      { lib, ... }:
      {
        mc-rtc-nix.overlays.ccache = inputs.ccache-trigger.value;
        mc-rtc-superbuild =
          { pkgs, ... }:
          {
            enable = true;
            # project.pname = "";
            configurations = {
              mc-openarm = {
                extends = [ "minimal" ];
                mainRobot = "OpenArmV2";
                runtime.apps = [ pkgs.mc-rtc-magnum ];
                devel.robots = [ pkgs.mc-openarm ];
              };
            };
          };

        flakoboros = {
          overrideAttrs.mc-openarm = {
            src = lib.cleanSource ./.;
          };
        };
      }
    );
}

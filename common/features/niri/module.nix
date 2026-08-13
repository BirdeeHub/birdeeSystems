{...}: {
  flake.wrappers.niri = {wlib, ...}: {
    imports = [ wlib.wrapperModules.niri ];
    settings.window-rules = [
      {
        matches = [
          { app-id = _: { content = ''r#"^org\.wezfurlong\.wezterm$"#''; }; }
        ];
        draw-border-with-background = false;
      }
    ];
  };
}

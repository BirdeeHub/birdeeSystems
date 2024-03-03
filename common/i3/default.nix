isHomeModule: let
  modulePath = if isHomeModule then ./home else ./system;
in modulePath

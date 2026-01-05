{
  description = "acomagu dotfiles for Fish";

  outputs = { self, ... }: {
    homeManagerModules.default = { ... }: {
      home.file.".config/fish/config.fish".source = self + "/config.fish";
    };
  };
}

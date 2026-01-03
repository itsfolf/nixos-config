# folf's nix config

```
nixos-config
┣━━ assets                      # images and assets
┣━━ hosts                       # host specific configuration
┃   ┣━━ meow                    # main desktop, rename pending
┣━━ modules                     # shared modules
┃   ┗━━ common/darwin/nixos     # platform specific modules
┃       ┗━━ profiles            
┃           ┣━━ server          # for servers
┃           ┗━━ workstation     # for personal workstations
┗━━ secrets                     # age encrypted secrets
```

Largely inspired by https://github.com/maeve-oake/nixos-config, with glue code from https://github.com/numtide/blueprint.

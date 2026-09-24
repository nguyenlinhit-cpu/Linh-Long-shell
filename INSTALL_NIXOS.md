# ❄️ Hướng Dẫn Cài Đặt Linh-Long Shell Trên NixOS (Hyprland & Niri)

Tài liệu này hướng dẫn cách khai báo và tích hợp **Linh-Long Desktop Shell** vào hệ thống **NixOS** thông qua **Nix Flakes** và **Home Manager**, hỗ trợ hoàn hảo cho cả **Hyprland** và **Niri**.

---

## ⚡ 1. Chạy Nhanh Không Cần Cài Đặt (Quick Run)

Bạn có thể chạy thử trực tiếp shell mà không cần sửa `configuration.nix`:

```bash
# Chạy trực tiếp từ GitHub repository
nix run github:nguyenlinhit-cpu/Linh-Long-shell

# Hoặc kích hoạt môi trường devShell có sẵn quickshell, pipewire, upower:
nix develop github:nguyenlinhit-cpu/Linh-Long-shell
```

---

## 📦 2. Cài Đặt Hệ Thống Qua Nix Flakes

### Bước 2.1: Thêm Input vào `flake.nix` của bạn

Mở file `flake.nix` quản lý hệ thống NixOS hoặc Home Manager của bạn:

```nix
{
  description = "NixOS Configuration Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Thêm Linh-Long Desktop Shell Flake Input
    linh-long-shell = {
      url = "github:nguyenlinhit-cpu/Linh-Long-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, linh-long-shell, ... }@inputs: {
    # Cấu hình NixOS host của bạn
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # hoặc "aarch64-linux"
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
      ];
    };
  };
}
```

### Bước 2.2: Khai báo Package trong `configuration.nix`

Trong file `configuration.nix` (hoặc module cấu hình của bạn):

```nix
{ pkgs, inputs, ... }:

{
  # 1. Thêm gói Linh-Long Shell vào system packages
  environment.systemPackages = [
    inputs.linh-long-shell.packages.${pkgs.system}.default
    
    # Các tiện ích hỗ trợ chụp màn hình & clipboard
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard
  ];

  # 2. Bật dịch vụ PipeWire & UPower
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  services.upower.enable = true;

  # 3. Hỗ trợ xác thực PAM cho Lock Screen
  security.pam.services.hyprlock = {};

  # 4. Phông chữ khuyến nghị (Nerd Fonts & Inter)
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    inter
    noto-fonts
    noto-fonts-emoji
  ];
}
```

> [!NOTE]
> **Nếu bạn dùng Home Manager**: Bạn có thể thêm vào `home.packages`:
> ```nix
> home.packages = [
>   inputs.linh-long-shell.packages.${pkgs.system}.default
> ];
> ```

---

## 🪟 3. Cấu Hình Tích Hợp Trên Hyprland (NixOS)

### 3.1. Autostart & Layer Rules (`hyprland.conf`)

Nếu quản lý file bằng tay (`~/.config/hypr/hyprland.conf`) hoặc qua Home Manager (`wayland.windowManager.hyprland.extraConfig`):

```ini
# ══════════════════════════════════════════════════════════════
# LINH-LONG SHELL AUTOSTART
# ══════════════════════════════════════════════════════════════
exec-once = linh-long-shell start

# ══════════════════════════════════════════════════════════════
# LAYER RULES (BLUR & TRANSPARENCY)
# ══════════════════════════════════════════════════════════════
layerrule = blur, linh-long-.*
layerrule = ignorezero, linh-long-.*
layerrule = blurpopups, linh-long-.*
layerrule = noanim, linh-long-corner-.*
layerrule = noanim, linh-long-hotcorner-.*
```

### 3.2. Phím Tắt Điều Khiển

```ini
# ══════════════════════════════════════════════════════════════
# LINH-LONG SHELL KEYBINDINGS
# ══════════════════════════════════════════════════════════════
$mainMod = SUPER

bind = $mainMod, SPACE, exec, linh-long-shell launcher
bind = $mainMod, D, exec, linh-long-shell launcher
bind = $mainMod, C, exec, linh-long-shell control-center
bind = $mainMod, V, exec, linh-long-shell clipboard
bind = ALT, TAB, exec, linh-long-shell switcher
bind = $mainMod, TAB, exec, linh-long-shell overview
bind = $mainMod, M, exec, linh-long-shell media
bind = $mainMod, W, exec, linh-long-shell wallpaper
bind = $mainMod, comma, exec, linh-long-shell settings
bind = $mainMod, slash, exec, linh-long-shell cheatsheet
bind = $mainMod, A, exec, linh-long-shell ai
bind = $mainMod, L, exec, linh-long-shell lock
bind = $mainMod, ESCAPE, exec, linh-long-shell session
bind = , Print, exec, linh-long-shell screenshot
bind = $mainMod SHIFT, S, exec, linh-long-shell screenshot

# Phím chức năng phần cứng (Volume & Media)
bindle = , XF86AudioRaiseVolume, exec, linh-long-shell vol-up
bindle = , XF86AudioLowerVolume, exec, linh-long-shell vol-down
bindl  = , XF86AudioMute, exec, linh-long-shell vol-mute
bindl  = , XF86AudioPlay, exec, linh-long-shell media-play
bindl  = , XF86AudioNext, exec, linh-long-shell media-next
bindl  = , XF86AudioPrev, exec, linh-long-shell media-prev
```

---

## 🌊 4. Cấu Hình Tích Hợp Trên Niri (NixOS)

Niri là modern scrollable-tiling Wayland compositor được hỗ trợ hoàn hảo trên NixOS.

### 4.1. Bật Niri trên NixOS
Trong `configuration.nix`:
```nix
programs.niri.enable = true;
```

### 4.2. Cấu hình Autostart & Phím tắt (`~/.config/niri/config.kdl`)
Thêm vào file cấu hình `config.kdl` của Niri:

```kdl
// ══════════════════════════════════════════════════════════════
// AUTOSTART
// ══════════════════════════════════════════════════════════════
spawn-at-startup "linh-long-shell" "start"

// ══════════════════════════════════════════════════════════════
// BINDS
// ══════════════════════════════════════════════════════════════
binds {
    Mod+Space { spawn "linh-long-shell" "launcher"; }
    Mod+D { spawn "linh-long-shell" "launcher"; }
    Mod+C { spawn "linh-long-shell" "control-center"; }
    Mod+V { spawn "linh-long-shell" "clipboard"; }
    Alt+Tab { spawn "linh-long-shell" "switcher"; }
    Mod+Tab { spawn "linh-long-shell" "overview"; }
    Mod+M { spawn "linh-long-shell" "media"; }
    Mod+W { spawn "linh-long-shell" "wallpaper"; }
    Mod+Comma { spawn "linh-long-shell" "settings"; }
    Mod+Slash { spawn "linh-long-shell" "cheatsheet"; }
    Mod+A { spawn "linh-long-shell" "ai"; }
    Mod+L { spawn "linh-long-shell" "lock"; }
    Mod+Escape { spawn "linh-long-shell" "session"; }
    Print { spawn "linh-long-shell" "screenshot"; }
    Mod+Shift+S { spawn "linh-long-shell" "screenshot"; }

    XF86AudioRaiseVolume allow-when-locked=true { spawn "linh-long-shell" "vol-up"; }
    XF86AudioLowerVolume allow-when-locked=true { spawn "linh-long-shell" "vol-down"; }
    XF86AudioMute allow-when-locked=true { spawn "linh-long-shell" "vol-mute"; }
    XF86AudioPlay allow-when-locked=true { spawn "linh-long-shell" "media-play"; }
    XF86AudioNext allow-when-locked=true { spawn "linh-long-shell" "media-next"; }
    XF86AudioPrev allow-when-locked=true { spawn "linh-long-shell" "media-prev"; }
}
```

---

## ⚙️ 5. Quản Lý File Cấu Hình Shell Declarative (Home Manager)

Nếu bạn muốn quản lý file cấu hình `config.toml` một cách declarative qua Home Manager, hãy thêm vào cấu hình home-manager:

```nix
{ inputs, pkgs, ... }:

{
  xdg.configFile."linh-long-shell/config.toml".text = ''
    [shell]
    compositor = "auto"
    ui_scale = 1.0
    corner_radius = 1.0

    [theme]
    mode = "dark"
    source = "wallpaper"
    blur_enabled = true
    blur_strength = 24
    background_opacity = 0.78

    [bar]
    enabled = true
    style = "floating"
    edge = "top"
    height = 44

    [dock]
    enabled = true
    autohide = true
    edge = "bottom"
    height = 56
  '';
}
```

Hoặc chỉ cần chạy lệnh khởi tạo cấu hình cục bộ:
```bash
linh-long-shell init-config
```

Sau khi cấu hình, áp dụng thay đổi hệ thống NixOS bằng lệnh:
```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

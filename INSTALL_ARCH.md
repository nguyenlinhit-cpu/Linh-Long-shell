# 📦 Hướng Dẫn Cài Đặt Linh-Long Shell Trên Arch Linux (Hyprland & Niri)

Tài liệu này hướng dẫn chi tiết cách cài đặt, cấu hình và tích hợp **Linh-Long Desktop Shell** trên hệ điều hành **Arch Linux** khi sử dụng bộ quản lý cửa sổ Wayland: **Hyprland** hoặc **Niri**.

---

## 📋 1. Yêu Cầu Tiền Đề & Cài Đặt Dependencies

Linh-Long Shell sử dụng engine đồ họa **Quickshell** (QtQuick 6 SceneGraph C++ protocol bindings). Hãy cài đặt Quickshell và các tiện ích cần thiết qua AUR (`yay` hoặc `paru`).

### Bước 1.1: Cài đặt qua AUR Helper (`yay` / `paru`)

```bash
# Cập nhật hệ thống
sudo pacman -Syu

# Cài đặt Quickshell và các dependencies hệ thống
yay -S --needed \
    quickshell-git \
    qt6-declarative \
    qt6-svg \
    pipewire \
    wireplumber \
    upower \
    grim \
    slurp \
    wl-clipboard \
    pam \
    ttf-jetbrains-mono-nerd \
    inter-font \
    noto-fonts \
    noto-fonts-emoji
```

> [!TIP]
> **AI Copilot (Tùy chọn)**: Nếu muốn sử dụng tính năng AI Copilot Sidebar (`Super + A`) chạy LLM offline cục bộ, cài đặt thêm Ollama:
> ```bash
> yay -S ollama
> sudo systemctl enable --now ollama
> ollama run llama3
> ```

---

## 📥 2. Tải & Cài Đặt Linh-Long Shell

### Cách 1: Clone vào thư mục `~/.config/quickshell` (Khuyên Dùng)

Quickshell tự động nạp cấu hình mặc định tại `~/.config/quickshell/shell.qml`:

```bash
# Backup cấu hình quickshell cũ nếu có
[ -d "$HOME/.config/quickshell" ] && mv "$HOME/.config/quickshell" "$HOME/.config/quickshell.bak"

# Clone Linh-Long Shell
git clone https://github.com/nguyenlinhit-cpu/Linh-Long-shell.git "$HOME/.config/quickshell"

# Thêm binary runner linh-long-shell vào PATH (~/.local/bin)
mkdir -p "$HOME/.local/bin"
ln -sf "$HOME/.config/quickshell/bin/linh-long-shell" "$HOME/.local/bin/linh-long-shell"
```

Đảm bảo `~/.local/bin` đã có trong biến môi trường `$PATH` của bạn (thường đã có sẵn trong `~/.bashrc` hoặc `~/.zshrc`):
```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Cách 2: Clone vào thư mục riêng biệt

```bash
git clone https://github.com/nguyenlinhit-cpu/Linh-Long-shell.git ~/Linh-Long-shell
mkdir -p "$HOME/.local/bin"
ln -sf ~/Linh-Long-shell/bin/linh-long-shell "$HOME/.local/bin/linh-long-shell"
```

### Khởi tạo file cấu hình:
```bash
linh-long-shell init-config
```
File cấu hình người dùng sẽ được tạo tại `~/.config/linh-long-shell/config.toml`. Bạn có thể tùy biến màu sắc, blur, hotkey, kích thước bar/dock tại đây.

---

## 🪟 3. Cấu Hình Tích Hợp Trên Hyprland

Mở file cấu hình Hyprland của bạn (`~/.config/hypr/hyprland.conf`):

### 3.1. Tự Động Khởi Chạy (Autostart)
Thêm vào đầu hoặc phần autostart của `hyprland.conf`:

```ini
# ══════════════════════════════════════════════════════════════
# LINH-LONG SHELL AUTOSTART
# ══════════════════════════════════════════════════════════════
exec-once = linh-long-shell start
```

### 3.2. Hiệu Ứng Mờ & Bo Tròn (Layer Rules)
Linh-Long Shell sử dụng Wayland Layer Shell. Để có hiệu ứng Frosted Glassmorphism blur mượt mà, thêm các rule sau vào `hyprland.conf`:

```ini
# ══════════════════════════════════════════════════════════════
# LINH-LONG SHELL LAYER RULES (BLUR & ANIMATIONS)
# ══════════════════════════════════════════════════════════════
layerrule = blur, linh-long-.*
layerrule = ignorezero, linh-long-.*
layerrule = blurpopups, linh-long-.*

# Tắt animation cho các viền bo góc màn hình và góc nhạy cảm chuột
layerrule = noanim, linh-long-corner-.*
layerrule = noanim, linh-long-hotcorner-.*
```

### 3.3. Phím Tắt Điều Khiển (Keybindings)
Thêm cụm phím tắt tích hợp IPC vào `hyprland.conf`:

```ini
# ══════════════════════════════════════════════════════════════
# LINH-LONG SHELL SHORTCUTS
# ══════════════════════════════════════════════════════════════
$mainMod = SUPER

# Menu & Launcher
bind = $mainMod, SPACE, exec, linh-long-shell launcher
bind = $mainMod, D, exec, linh-long-shell launcher

# Control Center & Clipboard
bind = $mainMod, C, exec, linh-long-shell control-center
bind = $mainMod, V, exec, linh-long-shell clipboard

# Switcher & Overview
bind = ALT, TAB, exec, linh-long-shell switcher
bind = $mainMod, TAB, exec, linh-long-shell overview

# Media & Wallpapers
bind = $mainMod, M, exec, linh-long-shell media
bind = $mainMod, W, exec, linh-long-shell wallpaper

# Settings, Cheatsheet & AI Copilot
bind = $mainMod, comma, exec, linh-long-shell settings
bind = $mainMod, slash, exec, linh-long-shell cheatsheet
bind = $mainMod, A, exec, linh-long-shell ai

# Lock Screen & Session Menu
bind = $mainMod, L, exec, linh-long-shell lock
bind = $mainMod, ESCAPE, exec, linh-long-shell session

# Screenshot Region
bind = , Print, exec, linh-long-shell screenshot
bind = $mainMod SHIFT, S, exec, linh-long-shell screenshot

# ══════════════════════════════════════════════════════════════
# HARDWARE VOLUME & MEDIA KEYS
# ══════════════════════════════════════════════════════════════
bindle = , XF86AudioRaiseVolume, exec, linh-long-shell vol-up
bindle = , XF86AudioLowerVolume, exec, linh-long-shell vol-down
bindl  = , XF86AudioMute, exec, linh-long-shell vol-mute
bindl  = , XF86AudioPlay, exec, linh-long-shell media-play
bindl  = , XF86AudioNext, exec, linh-long-shell media-next
bindl  = , XF86AudioPrev, exec, linh-long-shell media-prev
```

---

## 🌊 4. Cấu Hình Tích Hợp Trên Niri

Niri là Scrollable-Tiling Wayland Compositor hiện đại. Cấu hình của Niri nằm tại `~/.config/niri/config.kdl`.

### 4.1. Tự Động Khởi Chạy (Autostart)
Thêm khối lệnh `spawn-at-startup` vào `~/.config/niri/config.kdl`:

```kdl
// Khởi chạy Linh-Long Shell cùng Niri
spawn-at-startup "linh-long-shell" "start"
```

### 4.2. Cấu Hình Phím Tắt (Keybindings)
Thêm các bindings sau vào khối `binds { ... }` trong `config.kdl`:

```kdl
binds {
    // ══════════════════════════════════════════════════════════
    // LINH-LONG SHELL CONTROLS
    // ══════════════════════════════════════════════════════════
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

    // ══════════════════════════════════════════════════════════
    // MEDIA & AUDIO HARDWARE KEYS
    // ══════════════════════════════════════════════════════════
    XF86AudioRaiseVolume allow-when-locked=true { spawn "linh-long-shell" "vol-up"; }
    XF86AudioLowerVolume allow-when-locked=true { spawn "linh-long-shell" "vol-down"; }
    XF86AudioMute allow-when-locked=true { spawn "linh-long-shell" "vol-mute"; }
    XF86AudioPlay allow-when-locked=true { spawn "linh-long-shell" "media-play"; }
    XF86AudioNext allow-when-locked=true { spawn "linh-long-shell" "media-next"; }
    XF86AudioPrev allow-when-locked=true { spawn "linh-long-shell" "media-prev"; }
}
```

---

## 🛠️ 5. Kiểm Tra & Khắc Phục Lỗi (Troubleshooting)

### Kiểm tra trạng thái shell:
```bash
linh-long-shell status
```

### Chạy chế độ test (Dry-run):
```bash
linh-long-shell test
```

### Khởi động lại shell:
```bash
linh-long-shell restart
```

### Lỗi không tìm thấy icon hoặc phông chữ:
Nếu các icon Nerd Fonts bị hiển thị thành ô vuông, hãy cập nhật font cache:
```bash
fc-cache -fv
```

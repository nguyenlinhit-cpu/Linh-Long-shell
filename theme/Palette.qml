pragma Singleton
import QtQuick

QtObject {
    id: root

    // Active theme mode
    property bool dark: true
    property bool oledMode: false
    property string activePreset: "wallpaper" // "wallpaper" | "catppuccin" | "tokyo-night" | "nord" | "dracula"

    // Material 3 Core Tonal Roles (Using colOn... to avoid QML signal handler reserved name 'on[A-Z]')
    property color primary: "#D0BCFF"
    property color colOnPrimary: "#381E72"
    property color primaryContainer: "#4F378B"
    property color colOnPrimaryContainer: "#EADDFF"

    property color secondary: "#CCC2DC"
    property color colOnSecondary: "#332D41"
    property color secondaryContainer: "#4A4458"
    property color colOnSecondaryContainer: "#E8DEF8"

    property color tertiary: "#EFB8C8"
    property color colOnTertiary: "#492532"
    property color tertiaryContainer: "#633B48"
    property color colOnTertiaryContainer: "#FFD8E4"

    property color error: "#F2B8B5"
    property color colOnError: "#601410"
    property color errorContainer: "#8C1D18"
    property color colOnErrorContainer: "#F9DEDC"

    property color background: oledMode ? "#000000" : "#141218"
    property color colOnBackground: "#E6E0E9"
    property color surface: oledMode ? "#000000" : "#141218"
    property color colOnSurface: "#E6E0E9"
    property color surfaceVariant: "#49454F"
    property color colOnSurfaceVariant: "#CAC4D0"
    property color outline: "#938F99"
    property color outlineVariant: "#49454F"

    // 5-Elevation Layer Surface Architecture (From Dots-Hyprland & M3)
    property color layer0: background
    property color layer1: oledMode ? "#0d0d0f" : "#1D192B"
    property color layer2: oledMode ? "#16151a" : "#2B243C"
    property color layer3: oledMode ? "#201e25" : "#38304E"
    property color layer4: oledMode ? "#2a2732" : "#443B5E"

    // Interactive States: Hover & Active
    property color layer1Hover: Qt.lighter(layer1, 1.15)
    property color layer2Hover: Qt.lighter(layer2, 1.12)
    property color layer3Hover: Qt.lighter(layer3, 1.10)

    // Glassmorphic Tint & Border Roles
    property color glassBorder: Qt.rgba(outline.r, outline.g, outline.b, 0.22)
    property color glassHighlight: Qt.rgba(1.0, 1.0, 1.0, 0.08)
    property color glassShadow: Qt.rgba(0.0, 0.0, 0.0, 0.45)

    // Functional State Colors
    property color colSuccess: "#A8DAB5"
    property color colOnSuccess: "#10381C"
    property color colWarning: "#FFD180"
    property color colOnWarning: "#4A2800"
    property color colInfo: "#A5D6A7"

    // Preset Switching
    function applyPreset(name, isDark) {
        root.activePreset = name;
        root.dark = isDark;

        if (name === "catppuccin") {
            primary = "#CBA6F7";
            colOnPrimary = "#1E1E2E";
            primaryContainer = "#313244";
            colOnPrimaryContainer = "#CBA6F7";
            secondary = "#89B4FA";
            colOnSecondary = "#1E1E2E";
            tertiary = "#F5C2E7";
            background = "#1E1E2E";
            colOnBackground = "#CDD6F4";
            surface = "#1E1E2E";
            colOnSurface = "#CDD6F4";
            surfaceVariant = "#313244";
            colOnSurfaceVariant = "#A6ADC8";
            outline = "#6C7086";
            layer0 = "#181825";
            layer1 = "#1E1E2E";
            layer2 = "#313244";
            layer3 = "#45475A";
            layer4 = "#585B70";
        } else if (name === "tokyo-night") {
            primary = "#7AA2F7";
            colOnPrimary = "#1A1B26";
            primaryContainer = "#24283B";
            colOnPrimaryContainer = "#7AA2F7";
            secondary = "#BB9AF7";
            colOnSecondary = "#1A1B26";
            tertiary = "#7DCFFF";
            background = "#1A1B26";
            colOnBackground = "#C0CAF5";
            surface = "#1A1B26";
            colOnSurface = "#C0CAF5";
            surfaceVariant = "#24283B";
            colOnSurfaceVariant = "#A9B1D6";
            outline = "#565F89";
            layer0 = "#16161E";
            layer1 = "#1F2335";
            layer2 = "#292E42";
            layer3 = "#3B4261";
            layer4 = "#414868";
        } else if (name === "nord") {
            primary = "#88C0D0";
            colOnPrimary = "#2E3440";
            primaryContainer = "#3B4252";
            colOnPrimaryContainer = "#88C0D0";
            secondary = "#81A1C1";
            colOnSecondary = "#2E3440";
            tertiary = "#B48EAD";
            background = "#2E3440";
            colOnBackground = "#ECEFF4";
            surface = "#2E3440";
            colOnSurface = "#ECEFF4";
            surfaceVariant = "#3B4252";
            colOnSurfaceVariant = "#D8DEE9";
            outline = "#4C566A";
            layer0 = "#242933";
            layer1 = "#2E3440";
            layer2 = "#3B4252";
            layer3 = "#434C5E";
            layer4 = "#4C566A";
        }
    }

    // Direct Dynamic Color Injection
    function applyDynamicColors(colors) {
        if (!colors) return;
        if (colors.primary) primary = colors.primary;
        if (colors.colOnPrimary) colOnPrimary = colors.colOnPrimary;
        if (colors.primaryContainer) primaryContainer = colors.primaryContainer;
        if (colors.colOnPrimaryContainer) colOnPrimaryContainer = colors.colOnPrimaryContainer;
        if (colors.secondary) secondary = colors.secondary;
        if (colors.surface) surface = colors.surface;
        if (colors.colOnSurface) colOnSurface = colors.colOnSurface;
        if (colors.surfaceVariant) surfaceVariant = colors.surfaceVariant;
        if (colors.background) background = colors.background;
        if (colors.layer1) layer1 = colors.layer1;
        if (colors.layer2) layer2 = colors.layer2;
        if (colors.layer3) layer3 = colors.layer3;
    }
}

pragma Singleton
import QtQuick

QtObject {
    id: root

    // Embedded Material 3 Palette Object (Guaranteed instant synchronous initialization)
    property QtObject palette: QtObject {
        id: pal

        property bool dark: true
        property bool oledMode: false
        property string activePreset: "wallpaper"

        // Material 3 Core Tonal Roles
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
        property color inverseSurface: "#E6E0E9"
        property color colOnInverseSurface: "#313033"

        // 5-Elevation Layer Surface Architecture
        property color layer0: background
        property color layer1: oledMode ? "#0d0d0f" : "#1D192B"
        property color layer2: oledMode ? "#16151a" : "#2B243C"
        property color layer3: oledMode ? "#201e25" : "#38304E"
        property color layer4: oledMode ? "#2a2732" : "#443B5E"

        // Interactive States
        property color layer1Hover: Qt.lighter(layer1, 1.15)
        property color layer2Hover: Qt.lighter(layer2, 1.12)
        property color layer3Hover: Qt.lighter(layer3, 1.10)

        // Glassmorphic Roles
        property color glassBorder: Qt.rgba(outline.r, outline.g, outline.b, 0.22)
        property color glassHighlight: Qt.rgba(1.0, 1.0, 1.0, 0.08)
        property color glassShadow: Qt.rgba(0.0, 0.0, 0.0, 0.45)

        // Functional State Colors
        property color colSuccess: "#A8DAB5"
        property color colOnSuccess: "#10381C"
        property color colWarning: "#FFD180"
        property color colOnWarning: "#4A2800"
        property color colInfo: "#A5D6A7"

        function applyPreset(name, isDark) {
            pal.activePreset = name;
            pal.dark = isDark;
            if (name === "catppuccin") {
                pal.primary = "#CBA6F7";
                pal.colOnPrimary = "#1E1E2E";
                pal.primaryContainer = "#313244";
                pal.colOnPrimaryContainer = "#CBA6F7";
                pal.secondary = "#89B4FA";
                pal.colOnSecondary = "#1E1E2E";
                pal.tertiary = "#F5C2E7";
                pal.background = "#1E1E2E";
                pal.colOnBackground = "#CDD6F4";
                pal.surface = "#1E1E2E";
                pal.colOnSurface = "#CDD6F4";
                pal.surfaceVariant = "#313244";
                pal.colOnSurfaceVariant = "#A6ADC8";
                pal.outline = "#6C7086";
                pal.layer0 = "#181825";
                pal.layer1 = "#1E1E2E";
                pal.layer2 = "#313244";
                pal.layer3 = "#45475A";
                pal.layer4 = "#585B70";
            } else if (name === "tokyo-night") {
                pal.primary = "#7AA2F7";
                pal.colOnPrimary = "#1A1B26";
                pal.primaryContainer = "#24283B";
                pal.colOnPrimaryContainer = "#7AA2F7";
                pal.secondary = "#BB9AF7";
                pal.colOnSecondary = "#1A1B26";
                pal.tertiary = "#7DCFFF";
                pal.background = "#1A1B26";
                pal.colOnBackground = "#C0CAF5";
                pal.surface = "#1A1B26";
                pal.colOnSurface = "#C0CAF5";
                pal.surfaceVariant = "#24283B";
                pal.colOnSurfaceVariant = "#A9B1D6";
                pal.outline = "#565F89";
                pal.layer0 = "#16161E";
                pal.layer1 = "#1F2335";
                pal.layer2 = "#292E42";
                pal.layer3 = "#3B4261";
                pal.layer4 = "#414868";
            } else if (name === "nord") {
                pal.primary = "#88C0D0";
                pal.colOnPrimary = "#2E3440";
                pal.primaryContainer = "#3B4252";
                pal.colOnPrimaryContainer = "#88C0D0";
                pal.secondary = "#81A1C1";
                pal.colOnSecondary = "#2E3440";
                pal.tertiary = "#B48EAD";
                pal.background = "#2E3440";
                pal.colOnBackground = "#ECEFF4";
                pal.surface = "#2E3440";
                pal.colOnSurface = "#ECEFF4";
                pal.surfaceVariant = "#3B4252";
                pal.colOnSurfaceVariant = "#D8DEE9";
                pal.outline = "#4C566A";
                pal.layer0 = "#242933";
                pal.layer1 = "#2E3440";
                pal.layer2 = "#3B4252";
                pal.layer3 = "#434C5E";
                pal.layer4 = "#4C566A";
            }
        }
    }

    // Global Radius Tokens (Scalable via corner_radius)
    property real radiusScale: 1.0
    readonly property real radiusSmall: 8 * radiusScale
    readonly property real radiusMedium: 14 * radiusScale
    readonly property real radiusLarge: 20 * radiusScale
    readonly property real radiusPill: 9999

    // Elevation & Glassmorphism Properties
    property bool blurEnabled: true
    property real blurStrength: 24.0
    property real surfaceAlpha: 0.85
    property real cardAlpha: 0.92

    // Typography Tokens
    property string fontFamily: "Inter, Roboto, sans-serif"
    property string fontMono: "JetBrainsMono Nerd Font, monospace"

    readonly property int fontSizeCaption: 11
    readonly property int fontSizeBodySmall: 12
    readonly property int fontSizeBody: 14
    readonly property int fontSizeTitle: 16
    readonly property int fontSizeHeadline: 22
    readonly property int fontSizeDisplay: 32

    // Color Helpers for Quick Access
    readonly property color colBackground: ColorResolver.transparentize(palette.background, surfaceAlpha)
    readonly property color colSurface: ColorResolver.transparentize(palette.surface, surfaceAlpha)
    readonly property color colLayer1: ColorResolver.transparentize(palette.layer1, cardAlpha)
    readonly property color colLayer2: ColorResolver.transparentize(palette.layer2, cardAlpha)
    readonly property color colLayer3: ColorResolver.transparentize(palette.layer3, cardAlpha)
    readonly property color colPrimary: palette.primary
    readonly property color colOnPrimary: palette.colOnPrimary
    readonly property color colPrimaryContainer: palette.primaryContainer
    readonly property color colOnPrimaryContainer: palette.colOnPrimaryContainer
    readonly property color colOnSurface: palette.colOnSurface
    readonly property color colOnSurfaceVariant: palette.colOnSurfaceVariant
    readonly property color colOutline: palette.outline
    readonly property color colBorder: palette.glassBorder
}

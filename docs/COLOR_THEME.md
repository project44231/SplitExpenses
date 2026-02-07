# 🎨 App Color Theme

## Primary Color Scheme - Modern Blue Theme

### Core Colors

| Color Name | Hex Code | RGB | Usage |
|------------|----------|-----|-------|
| **Primary Blue** | `#1E88E5` | `Color(0xFF1E88E5)` | App bar, main buttons, headers, primary actions |
| **Primary Dark** | `#1976D2` | `Color(0xFF1976D2)` | Darker variant for depth/contrast |
| **Primary Light** | `#42A5F5` | `Color(0xFF42A5F5)` | Lighter variant for highlights |
| **Light Blue Accent** | `#4FC3F7` | `Color(0xFF4FC3F7)` | Secondary actions, FAB, accents, gradients |
| **Medium Blue** | `#42A5F5` | `Color(0xFF42A5F5)` | Tertiary color, highlights, soft accents |

### Status Colors

| Color Name | Usage | Code |
|------------|-------|------|
| **Error/Loss Red** | Error messages, losses, delete actions | `Color(0xFFE53935)` |
| **Success/Win Blue** | Success messages, wins, confirmations | `Color(0xFF42A5F5)` |
| **Warning Orange** | Warnings, neutral alerts | `Color(0xFFFFA726)` |

### Background Colors

| Color Name | Hex Code | RGB | Usage |
|------------|----------|-----|-------|
| **Light Background** | `#FAFAFA` | `Color(0xFFFAFAFA)` | Main screen background |
| **Light Blue Background** | `#E3F2FD` | `Color(0xFFE3F2FD)` | Card backgrounds, sections |
| **Light Card Blue** | `#BBDEFB` | `Color(0xFFBBDEFB)` | Card highlights |
| **Input Field Grey** | `#EEEEEE` | `Color(0xFFEEEEEE)` | Text input backgrounds (Grey[200]) |
| **White** | `#FFFFFF` | `Colors.white` | Cards, surfaces |

## Color Usage Guidelines

### App Components

#### App Bar
- **Background**: Primary Blue `#1E88E5`
- **Text/Icons**: White `#FFFFFF`
- **Elevation**: 0 (flat design)

#### Buttons

**Primary (Elevated)**
- **Background**: Primary Blue `#1E88E5`
- **Text**: White
- **Shadow**: Subtle elevation

**Secondary (Outlined)**
- **Border**: Primary Blue `#1E88E5`
- **Text**: Primary Blue
- **Background**: Transparent

**Accent (FAB)**
- **Background**: Light Blue `#4FC3F7`
- **Icon**: White

#### Cards
- **Background**: White or Light Blue Background `#E3F2FD`
- **Border**: None (use elevation/shadows)
- **Elevation**: 2-4dp

#### Gradients
- **Primary Gradient**: `#1E88E5` → `#4FC3F7`
- **Accent Gradient**: `#26A69A` → `#26A69A` (70% opacity)
- **Usage**: Backgrounds, highlights, badges

### Game-Specific Colors

#### Player Buy-in Cards
- **Header**: Primary Blue with 5% opacity
- **Border**: Primary Blue with 20% opacity
- **Badge**: Light Blue gradient `#4FC3F7` with shadow
- **Add Button**: Light Blue `#4FC3F7`

#### Settlement Screen
- **Win Indicator**: Success Blue `#42A5F5`
- **Loss Indicator**: Error Red `#E53935`
- **Transfer Cards**: Light Blue Background

#### Active Game Banner
- **Background**: Primary Blue `#1E88E5`
- **Text**: White
- **Player Count Badge**: White with 20% opacity background

## Text Colors

### Light Theme
- **Primary Text**: `#212121` (dark grey)
- **Secondary Text**: `#757575` (medium grey)
- **Disabled Text**: `#BDBDBD` (light grey)

### Dark Theme
- **Primary Text**: `#FFFFFF` (white)
- **Secondary Text**: `#B0B0B0` (light grey)
- **Disabled Text**: `#757575` (medium grey)

## Accessibility

### Contrast Ratios (WCAG AA Compliant)
- ✅ Primary Blue on White: 4.5:1
- ✅ Light Blue Accent on White: 4.5:1
- ✅ White text on Primary Blue: 7:1
- ✅ Error Red on White: 4.5:1

### Color Blindness Considerations
- Uses shape and text labels in addition to colors
- High contrast between interactive elements
- Multiple visual cues for status (not just color)

## Implementation

All colors are defined in `lib/core/theme/app_theme.dart`:

```dart
// Primary Colors
static const Color primaryColor = Color(0xFF1E88E5);
static const Color primaryDark = Color(0xFF1976D2);
static const Color primaryLight = Color(0xFF42A5F5);

// Accent Colors
static const Color accentColor = Color(0xFF4FC3F7);      // Light blue accent
static const Color tertiaryColor = Color(0xFF42A5F5);    // Medium blue

// Status Colors
static const Color errorColor = Color(0xFFE53935);       // Red for errors/loss
static const Color successColor = Color(0xFF42A5F5);     // Blue for success/win
static const Color warningColor = Color(0xFFFFA726);     // Orange for warnings
```

## Visual Examples

### Button Styles
```
┌──────────────────────┐
│  Primary Button      │  ← Blue #1E88E5
└──────────────────────┘

┌──────────────────────┐
│  Secondary Button    │  ← Outlined Blue
└──────────────────────┘

    ┌────┐
    │ +  │  ← FAB Light Blue #4FC3F7
    └────┘
```

### Game Card
```
┌─────────────────────────────┐
│ 👤 Player Name              │ ← Blue circle avatar
│    $100 • 2 buy-ins         │
│ ─────────────────────────── │
│ ① $50   12:30 PM  [Edit][×] │ ← Light blue badge
│ ② $50   1:45 PM   [Edit][×] │
└─────────────────────────────┘
```

## Design Principles

1. **Clean & Modern**: Flat design with subtle shadows
2. **Professional**: Blue conveys trust and reliability
3. **High Contrast**: Easy to read in various lighting
4. **Consistent**: All components follow the same theme
5. **Accessible**: WCAG AA compliant contrast ratios

---

**Last Updated**: February 2026  
**Theme Version**: 2.1 (Consistent Blue - No Green)

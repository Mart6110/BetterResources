# BetterResources

A World of Warcraft addon providing a clean, customizable resource frame for tracking power, runes, and secondary resources. Built with **clean, maintainable architecture**.

## Features

- **Custom Resource Frame** - Clean, minimal power bar display separate from default UI
- **Class-Specific Resources** - Special support for Death Knight runes with smart sorting
- **Fully Customizable** - Adjust size, position, scale, and opacity via settings panel
- **Dual Input Controls** - Use sliders OR input boxes for precise adjustments
- **Real-Time Updates** - All changes apply instantly without reloading
- **Movable & Lockable** - Drag to reposition or lock in place
- **Position Persistence** - Frame position saved between sessions
- **GUI Settings Panel** - Easy-to-use interface with `/br` command
- **100% Cosmetic** - No combat logic, safe for restrictive environments

## Installation

Copy the `BetterResources` folder to:
- **Retail**: `World of Warcraft\_retail_\Interface\AddOns\`
- **Classic**: `World of Warcraft\_classic_\Interface\AddOns\`

Then restart WoW or `/reload`

## Commands

- `/br` or `/betterresources` - Open settings panel
- `/br toggle` - Enable/disable the addon
- `/br scale [0.5-2.0]` - Set global frame scale
- `/br lock` - Lock/unlock frame position
- `/br reset` - Reset frame to default position

## Settings Panel

Access the settings panel with `/br` to customize:

### General Settings
- **Lock Frame Position** - Prevent accidental movement
- **Global Scale** - Adjust overall size (0.5x - 2.0x)

### Size Controls
- **Width** - Set frame width (100-400 pixels) via slider or input
- **Height** - Set power bar height (20-100 pixels) via slider or input

### Position Controls
- **X Position** - Horizontal position (-1000 to 1000) via slider or input
- **Y Position** - Vertical position (-1000 to 1000) via slider or input

### Other Settings
- **Individual Scale** - Fine-tune this frame's scale independently
- **Opacity** - Adjust frame transparency (10%-100%)
- **Show/Hide Frame** - Toggle frame visibility
- **Reset Position** - Return to default centered position

---

## Architecture (SOLID + KISS)

Built following **SOLID principles** and **KISS** (Keep It Simple, Stupid) for easy maintenance and extension.

### Directory Structure
```
BetterResources/
├── Core.lua                       # Initialization & coordination only
├── Config.lua                     # Slash commands & configuration
├── utils/                         # Utility modules (no dependencies)
│   ├── Colors.lua                 # Single Responsibility: Color management
│   └── Formatter.lua              # Single Responsibility: Text formatting
├── ui/                            # UI components
│   ├── FrameFactory.lua           # Creates consistent UI elements
│   └── SettingsPanel.lua          # Settings GUI with dual slider/input controls
└── modules/                       # Frame implementations
    ├── ResourceFrame.lua          # Player power/resource display coordinator
    └── secondary/                 # Secondary resource components (class-specific)
        ├── RuneDisplay.lua        # Death Knight runes
        ├── ComboPointDisplay.lua  # Combo points (Rogue, Druid, Feral)
        ├── EssenceDisplay.lua     # Evoker essence
        ├── SoulShardDisplay.lua   # Warlock soul shards
        └── ArcaneChargesDisplay.lua # Mage arcane charges
```

### SOLID Principles Applied

1. **Single Responsibility (SRP)**: Each file has ONE clear purpose
   - `Colors.lua` → Only handles power type colors
   - `Formatter.lua` → Only formats power values
   - `ResourceFrame.lua` → Coordinates main resource display
   - `RuneDisplay.lua` → Only handles Death Knight runes
   - `ComboPointDisplay.lua` → Only handles combo points (Rogue, Druid, Monk, Paladin)
   - `EssenceDisplay.lua` → Only handles Evoker essence
   - `SoulShardDisplay.lua` → Only handles Warlock soul shards
   - `ArcaneChargesDisplay.lua` → Only handles Mage arcane charges
   - `SettingsPanel.lua` → Settings UI only

2. **Open/Closed (OCP)**: Open for extension, closed for modification
   - Add new secondary resource types by creating new components
   - ResourceFrame automatically uses appropriate component
   - No modification to existing code needed

3. **Liskov Substitution (LSP)**: Consistent interfaces
   - All secondary resource components share common methods (Update, UpdateWidth, Show, Hide, GetHeight)
   - Components are interchangeable and predictable

4. **Interface Segregation (ISP)**: Modules depend only on what they need
   - Each component is self-contained
   - No bloated dependencies between resource types

5. **Dependency Inversion (DIP)**: Depend on abstractions
   - ResourceFrame depends on component interfaces, not implementations
   - Easy to add new secondary resource components (essence, insanity, fury, etc.)

### Why This Matters

**Clean architecture** ensures maintainability and extensibility

✅ **Easy to understand**: Each file does ONE thing  
✅ **Easy to modify**: Change one thing in one place  
✅ **Easy to extend**: Add features without breaking existing code  
✅ **Easy to test**: Isolated modules  

---

## Class-Specific Features

### Death Knight - Runes
- **Smart Sorting**: Ready runes shown first (left side)
- **Visual Cooldowns**: Runes fill from left to right as they recharge
- **Color Coding**: Bright cyan/blue when ready, dim during cooldown
- **6 Runes**: All runes displayed in centered row below power bar

### Rogue & Druid - Combo Points
- **Up to 5-8 Points**: Dynamic display based on talents
- **Yellow Color**: Classic combo point yellow
- **Individual Displays**: Each point shown separately

### Monk - Chi
- **Up to 6 Chi**: Brewmaster/Windwalker chi tracking
- **Green Color**: Distinctive jade green for chi
- **Individual Orbs**: Each chi orb shown separately

### Paladin - Holy Power
- **Up to 5 Points**: Holy power tracking
- **Golden Color**: Holy yellow-gold coloring
- **Individual Displays**: Each point shown separately

### Warlock - Soul Shards
- **Up to 5 Shards**: Soul shard tracking for all specs
- **Purple Color**: Distinctive dark purple for soul shards
- **Slightly Larger**: More prominent display with purple borders

### Mage - Arcane Charges
- **Up to 4 Charges**: Arcane mage charges
- **Bright Blue Color**: Arcane blue coloring
- **Individual Charges**: Each charge shown separately

### Evoker - Essence
- **Up to 6 Essence**: Evoker resource tracking
- **Teal Color**: Distinctive cyan/teal coloring
- **Individual Displays**: Each essence point shown separately

### All Classes
- **Primary Power**: Mana, energy, rage, focus, fury, pain, maelstrom, insanity, etc.
- **Class Colors**: Power bars automatically colored by power type
- **Dynamic Updates**: Real-time tracking of all resource changes
- **Smart Layout**: Components automatically appear/hide based on class and spec

---

## Customization Features

### Dual Input System
Every numeric setting can be adjusted two ways:
- **Sliders**: Quick, visual adjustments with live preview
- **Input Boxes**: Precise numeric entry for exact values
- **Synchronized**: Both methods update each other in real-time

### Positioning
- **Manual Dragging**: Click and drag when unlocked
- **Slider Controls**: Fine-tune X/Y position with -1000 to +1000 range
- **Input Boxes**: Enter exact coordinates
- **Lock Feature**: Prevent accidental movement during gameplay
- **Persistent**: Position saved automatically between sessions

### Size & Scale
- **Width Control**: 100-400 pixels
- **Height Control**: 20-100 pixels for power bar
- **Global Scale**: 0.5x - 2.0x for all frames
- **Individual Scale**: Per-frame scaling independent of global
- **Opacity**: 10%-100% transparency

### Visual Feedback
- All changes apply **instantly** - no reload required
- Settings panel shows current values
- Input validation prevents invalid values

---

## Technical Details

### Performance
- Efficient event handling with targeted updates
- Minimal CPU usage during combat
- No unnecessary frame updates
- Smart rune cooldown tracking for Death Knights

### Saved Variables
Settings are stored in `BetterResourcesDB` including:
- Frame positions (X, Y coordinates)
- Size settings (width, height)
- Scale and opacity values
- Lock state and visibility toggles

### Event System
Monitors these events for resource updates:
- `UNIT_POWER_UPDATE` - Power changes
- `UNIT_MAXPOWER` - Max power changes
- `UNIT_DISPLAYPOWER` - Power type changes
- `UNIT_POWER_FREQUENT` - High-frequency updates
- `RUNE_POWER_UPDATE` - Death Knight rune updates

---

## Version

**1.0.0** - Initial release with clean architecture
- Custom resource frame with power/secondary power tracking
- Death Knight rune display with smart sorting
- Full GUI settings panel with dual slider/input controls
- Position, size, scale, and opacity customization
- Frame locking and position persistence

## Compliance

✅ **100% Cosmetic Only** - No combat functionality, safe for restrictive addon environments  
✅ **No Protected Actions** - Does not interfere with combat mechanics  
✅ **UI Display Only** - Pure visual enhancement addon  

## Compatibility

- WoW 11.0.2 (The War Within)
- Update Interface version in `.toc` for other expansions
- Tested with all classes, special features for Death Knight runes

## Support & Feedback

For bugs or feature requests, please include:
- Your class and spec
- WoW version
- Steps to reproduce any issues
- Screenshots if applicable

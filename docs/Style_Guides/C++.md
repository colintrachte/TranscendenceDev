# C++ Style Guidelines

## Formatting

### Use Whitesmith Indentation

[Wikipedia: Whitesmith Style](https://en.wikipedia.org/wiki/Indentation_style#Whitesmiths_style)

```cpp
int function (int x)
   {
   while (x < 0)
      {
      if (something 
            && something_else
            && yet_another_condition)
         {
         do_something();
         }
      }
   }
```

### Use Tabs

Use tabs to indent. Set the indent at 4 spaces.

### Use Whitespace to Separate Blocks

```cpp
   {
   ...

   //   This section does some stuff

   do_something();
   do_something_else();

   //   This is another block of code that is logically
   //   related.

   if (something)
      {
      ok_do_it();
      this_too();
      }

   //   We're done

   return 0;
   }
```

### Function Declaration and Calls

#### Inline documentation

Inline documentation of functions should be before the declaration so that it
is detected as a standard docstring and displayed in mouse-over tooltips etc.

```cpp
// UpdateExtended
//
// This is called when the player re-enters a system after having been
// away. We update the system to reflect the amount of time that has passed.
//
void CUniverse::UpdateExtended (void)
	{
	}
```

NOTE - most of the codebase uses an older style with the comment description
after the declaration. These are not detected as docstrings so should be updated
to follow the new style. See: https://ministry.kronosaur.com/record.hexm?id=104374

#### Distinguish Between Declarations and Calls

Add a space between the function name and the opening parenthesis when
declaring or defining a function. Do not add space when calling the function:

```cpp
int function (int a)
//          ^
//     Space here.
   {
   return 0;
   }

function(10);

//      ^
//   No space here
```

#### Omit void if no parameters

```cpp
int function ()
//            ^
//          Empty
   {
   return 0;
   }
```

## Layering

```
+---------------+-------------------------------------+
| Transcendence | CTranscendenceController            |
|               | CTranscendenceModel                 |
|               | CTranscendenceWnd                   |
|               | CGameSession, CIntroSession, etc.   |
|               | TransCore                           |
|               | TransData, etc.                     |
+---------------+-------------------------------------+
| Mammoth       | TSUI                                |
|               |    CHumanInterface                  |
|               |    CVisualPalette                   |
|               |    IHISession                       |
|               |                                     |
|               | TSE                                 |
|               |    CUniverse                        |
|               |    CDesignCollection                |
|               |    CTopology                        |
|               |    CSystem                          |
|               |    CSpaceObject hierarchy           |
+---------------+-------------------------------------+
| Alchemy       | CodeChain                           |
|               |    CCodeChain                       |
|               |    ICCItemPtr                       |
|               |                                     |
|               | DirectXUtil                         |
|               |    CG32bitPixel                     |
|               |    CG32bitImage, CG8bitImage, etc.  |
|               |    CGDraw                           |
|               |                                     |
|               | Kernel                              |
|               |    CString                          |
|               |    TArray                           |
|               |    TSortMap                         |
|               |    IReadStream                      |
|               |    IWriteStream                     |
|               |    CObject                          |
|               |                                     |
|               | 3rd Party Libraries                 |
+---------------+-------------------------------------+
```

Lower layers must never depend on higher layers. A pull request that introduces
an upward dependency (e.g., Alchemy referencing a TSE type) will be rejected.

### Alchemy

The foundation layer. Contains no game logic. Sub-libraries:

- **Kernel** — Core utilities: `CString`, `TArray`, `TSortMap`, streams, and `CObject`
  (the base for serializable objects). Has no dependencies on any other Alchemy library.
- **CodeChain** — The TLisp scripting engine. Depends on Kernel.
- **Graphics** — Software-rendered image primitives. Depends on Kernel.
- **DirectXUtil** — DirectX rendering and hardware blitting. Depends on Graphics, Kernel.
- **XMLUtil** — XML parsing. Depends on Kernel.
- **zlibstat** — zlib compression (vendored, no internal dependencies).

### TSE

Transcendence Space Engine — the core game simulation. Owns the universe, all
space objects, the design system, and game rules. Depends on all Alchemy libraries.
Key types: `CUniverse`, `CSystem`, `CSpaceObject`, `CShip`, `CStation`,
`CDesignCollection`.

### TSUI

Game UI framework built on top of TSE. Provides the session abstraction
(`IHISession`), the visual palette, and the human interface layer
(`CHumanInterface`). Dock screens and the HUD are implemented here.

### Transcendence

The main application layer. Owns the game loop, player controller, intro and
in-game sessions, and the top-level model/controller split
(`CTranscendenceModel`, `CTranscendenceController`).

### TransCore

Game data written in XML and TLisp. Contains all ship classes, item types,
missions, star systems, and sovereign definitions for the base game. Loaded at
runtime — changes here do not require a C++ rebuild.

### TransData and Utilities

Command-line tools (TransData, TransBench, TransCompiler, TransExec) for
diagnostics, benchmarking, packaging, and batch operations on game data.

## Major Components

### The Universe

`CUniverse` (Mammoth/TSE) is the top-level singleton for a running game. It owns
the design collection, the topology, all loaded star systems, and global game state.
Entry point for almost all cross-system queries.

### The Design Collection

`CDesignCollection` holds every design type (`CDesignType` subclass) loaded from
XML — ship classes, item types, sovereigns, effects, etc. Types are addressed by
UNID (Unique Numeric Identifier), a 32-bit value assigned in XML.

### The Topology

`CTopology` is the node graph of all star systems. Nodes are connected by
stargates. The topology is generated from XML `<SystemMap>` definitions and
governs stargate travel between systems.

### Star Systems

`CSystem` represents a single playable star system. It contains the list of all
active `CSpaceObject` instances, handles physics updates, manages encounter
spawning, and owns the system's background environment.

### Space Objects

`CSpaceObject` is the abstract base class for everything that exists in a star
system: ships, stations, missiles, effects, markers. It provides position,
velocity, bounding box, paint, and update interfaces. Subclasses must implement
`Update`, `Paint`, and type-identification methods.

### Station Objects

`CStation` represents fixed or semi-fixed objects: space stations, outposts,
asteroids, wrecks, and stargates. Stations own docking services, item inventory,
and encounter tables. They are the primary source of missions and trade.

### Ship Objects

`CShip` represents all mobile crewed vessels — both the player ship and NPCs.
Ships carry devices, armor, a cargo hold, and an AI controller (`CAIBehaviorCtx`).
The player ship is the special case where the AI is replaced by player input.

### Missile/Damage Objects

Projectiles, beams, and area-effect damage objects are managed by
`CWeaponFireDesc` and instantiated as `CSpaceObject` subclasses during combat.
Damage calculation flows through `DamageDesc` and the armor/shield class system.

### Effects

Visual effects (explosions, particle trails, overlays) are rendered through the
painter system (`IEffectPainter`). Effects are attached to space objects or
emitted as standalone objects. The reanimator drives time-based animation.

### Items

`CItem` is a typed, counted, enhanced stack of a single item type (`CItemType`).
`CItemList` is the container used by ships and stations. Item enhancements are
stored as a bitmask and modifier list on the `CItem` instance.

## Data Structures

### Strings (Kernel::CString)

`CString` is a reference-counted, immutable string. Prefer it over `std::string`
in all engine code. String literals should be written as `CONSTLIT("text")` to
avoid heap allocation.

### Arrays (Kernel::TArray)

`TArray<T>` is the standard dynamic array, analogous to `std::vector<T>`. Use it
instead of raw arrays or `std::vector` in engine code.

### Maps (Kernel::TMap, Kernel::TSortMap)

`TSortMap<K, V>` is a sorted key-value map backed by a `TArray`. Prefer it over
`std::map` for engine code. `TMap` is a hash map variant for unordered lookup.

### Streams

`IReadStream` and `IWriteStream` are the abstract interfaces for serialization.
`CFileReadStream`/`CFileWriteStream` and `CMemoryReadStream`/`CMemoryWriteStream`
provide concrete implementations. All serializable objects implement
`ReadFromStream` and `WriteToStream`.

### TLisp Items (CodeChain::ICCItem)

`ICCItem` is the base type for all TLisp values. Always held via `ICCItemPtr`
(RAII smart pointer). Create values through `CCodeChain` factory methods; never
construct `ICCItem` subclasses directly.

## Graphics

### Images and Pixels

`CG32bitImage` is the primary off-screen buffer type (32 bpp ARGB). `CG32bitPixel`
represents a single pixel. `CG8bitImage` is used for alpha masks. All drawing
targets one of these image types; there is no direct-to-screen rendering in
engine code.

### Drawing Algorithms

`CGDraw` provides the static drawing primitives used across the engine: lines,
circles, filled polygons, image blitting, and compositing. Hardware-accelerated
paths are in `DirectXUtil`; software fallbacks are in `Graphics`.

## User Interface

### TSUI

The UI framework wraps DirectX presentation and provides the session lifecycle.
`CHumanInterface` drives the main loop, dispatches input, and calls the active
`IHISession` to paint and handle events.

### AGScreen

`AGScreen` (deprecated name; prefer `IHISession`) is the base class for a full-
screen UI state — intro, in-game, dock, and so on. Sessions are pushed/popped on
a stack managed by `CHumanInterface`.

### Reanimator

The animation system drives time-based effects via `CReanimator`. Performance
sequences (sequences of frames or tweens) are loaded from XML and played back
against a canvas of animated elements.

### Dock Screens

Dock screens are the XML-driven UI panels displayed when the player docks with a
station. `CDockScreen` interprets `<DockScreen>` XML at runtime; actions and
panels are scripted in TLisp.

### HUD

The HUD renders the in-flight overlay: shields, armor, targeting, and system
state. Individual HUD elements are `IHUDPainter` subclasses registered with the
game session.

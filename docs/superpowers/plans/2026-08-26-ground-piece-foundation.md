# Ground Piece Foundation Implementation Plan

> Note de reprise — 2026-08-27 : les restrictions de rotation et d'échelle de
> cette première tranche sont obsolètes. Le contrat en vigueur est
> `docs/architecture/AUTHORED_TRANSFORM_CONTRACT.md` : le Transform auteur
> complet est souverain.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the editor-first Ground Piece foundation with Permanent, Carvable, and Breakable modes, preserve the legacy map flow, and integrate one real Côte toxique ledge.

**Architecture:** `GroundPieceDefinition` owns published art and geometry settings; `GroundPiece2D` owns per-map mode and placement. Carvable pieces stamp their mask and illustration into the existing mission-wide `DestructibleTerrain2D`, while Permanent and Breakable pieces retain local presentation and collision.

**Tech Stack:** Godot 4.7.1, typed GDScript, `@tool` scenes and Resources, `Image`/`BitMap`, headless SceneTree tests, Python/Pillow asset pipeline, built-in ImageGen.

**Spec:** `docs/superpowers/specs/2026-08-26-ground-piece-architecture-design.md`

## Global Constraints

- Do not launch the graphical Godot editor; the project owner already has it open.
- `pipeline/` remains hidden behind `pipeline/.gdignore`; runtime files never reference it.
- ImageGen outputs remain candidates until technical and human visual validation.
- Preserve the four current `GroundModule2D` instances and legacy `DestructibleZones` during this tranche.
- Preserve the current player weapon transforms and Muzzle position.
- The instance in the master map is the sole authority for Ground Mode and placement.
- Alpha-derived and authored collision outlines are mutually exclusive authorities.
- The workspace is not currently a Git repository. Do not initialize Git without explicit authorization; record each checkpoint in `docs/WORKLOG.md` instead of committing.

---

## File map

### New runtime files

- `terrain/ground_pieces/ground_piece_definition.gd` — immutable piece definition and alpha-to-polygons conversion.
- `terrain/ground_pieces/ground_breakable_profile.gd` — editable maximum health and destroyed-visual policy.
- `terrain/ground_pieces/components/ground_breakable_component.gd` — runtime health and break signals.
- `terrain/ground_pieces/ground_piece_2d.gd` — scene synchronization, exclusive mode activation, stamp sampling.
- `terrain/ground_pieces/ground_piece_2d.tscn` — canonical editor-visible composition.
- `terrain/ground_pieces/ground_kit_catalog.gd` — Resource catalog and unique-ID validation.
- `terrain/kits/toxic_coast/definitions/natural_ledge_medium.tres` — first production definition.
- `terrain/kits/toxic_coast/pieces/natural_ledge_medium.tscn` — first drag-and-drop scene.
- `terrain/kits/toxic_coast/toxic_coast_ground_kit.tres` — kit catalog.

### New asset-pipeline files

- `pipeline/assets/sources/terrain_kits/toxic_coast/natural/natural-ledge-medium-source-v001.png` — immutable generated source.
- `pipeline/assets/exports/terrain_kits/toxic_coast/natural/natural-ledge-medium-768x384-v001.png` — normalized candidate.
- `pipeline/assets/tools/process_ground_piece_candidates.py` — deterministic normalization and QA.
- `pipeline/assets/tools/validate_ground_piece_candidates.py` — technical gate.
- `pipeline/assets/recipes/toxic_coast_ground_kit_v001.md` — prompt and transformation recipe.
- `pipeline/assets/profiles/toxic_coast_ground_piece_profile_v001.json` — canvas, pivot, alpha and naming contract.
- `pipeline/assets/manifests/toxic_coast_ground_kit_v001.json` — lifecycle and hashes.
- `pipeline/assets/provenance/toxic_coast_ground_kit_v001.json` — generation provenance.
- `pipeline/assets/working/terrain_kits/toxic_coast/natural-ledge-medium-v001-qa.json` — generated report.
- `art/terrain/pieces/toxic_coast/natural/natural-ledge-medium-v001.png` — approved runtime bitmap.

### New tests

- `tests/ground_piece_definition_test.gd` — definition validation and deterministic geometry.
- `tests/ground_piece_modes_test.gd` — exclusive scene modes and Breakable lifecycle.
- `tests/ground_piece_destructible_stamp_test.gd` — adjacent stamps, carving and no double collision.
- `tests/ground_kit_catalog_test.gd` — catalog identity and drag-scene contract.

### Modified files

- `terrain/destructible_terrain_2d.gd` — collect Carvable pieces and compose authored-color stamps while retaining legacy zones.
- `maps/missions/toxic_coast/toxic_coast.tscn` — add `Gameplay/GroundPieces` and the first ledge.
- `maps/system/mission_map_root_2d.gd` — require the new authoring branch without removing legacy branches.
- `tests/map_contract_test.gd` — verify the new branch and first scene.
- `tests/asset_pipeline_contract_test.gd` — verify reference/source/runtime separation.
- `docs/maps/MAP_AUTHORING_CONTRACT.md` — document drag-and-drop authoring.
- `docs/assets/GUIDE_TERRAIN_ET_GROUND_PIECES.md` — change target entries to implemented entries.
- `docs/PROJECT_STATE.md` and `docs/WORKLOG.md` — resumable state and checkpoints.
- `art/ASSET_MANIFEST.md` — publish the approved bitmap and provenance link.

---

### Task 1: Ground Piece data Resources

**Files:**
- Create: `terrain/ground_pieces/ground_piece_definition.gd`
- Create: `terrain/ground_pieces/ground_breakable_profile.gd`
- Test: `tests/ground_piece_definition_test.gd`

**Interfaces:**
- Produces: `GroundPieceDefinition.validation_errors() -> PackedStringArray`
- Produces: `GroundPieceDefinition.geometry_polygons() -> Array[PackedVector2Array]`
- Produces: `GroundPieceDefinition.texture_image() -> Image`
- Produces: `GroundPieceDefinition.mask_image() -> Image`
- Produces: `GroundBreakableProfile.is_valid() -> bool`

- [x] **Step 1: Write the failing Resource test**

Create a 16 × 16 `ImageTexture` with an opaque rectangle from `(2, 4)` through
`(13, 15)`, assign pivot `(8, 12)`, and assert that `geometry_polygons()` returns
at least one polygon whose local bounds cross the origin. Also assert that an
empty ID, missing texture, authored outline with fewer than three points, and
missing Breakable profile each produce the exact expected validation warning.

```gdscript
extends SceneTree

var failures: Array[String] = []

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
        push_error(message)

func _initialize() -> void:
    call_deferred(&"_run")

func _run() -> void:
    var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
    image.fill(Color.TRANSPARENT)
    image.fill_rect(Rect2i(2, 4, 12, 12), Color.WHITE)
    var definition := GroundPieceDefinition.new()
    definition.piece_id = &"test_ledge"
    definition.display_name = "Test ledge"
    definition.texture = ImageTexture.create_from_image(image)
    definition.pivot_px = Vector2(8, 12)
    var polygons := definition.geometry_polygons()
    _check(definition.validation_errors().is_empty(), "La définition alpha doit être valide.")
    _check(not polygons.is_empty(), "L'alpha doit produire au moins un polygone.")
    var bounds := Rect2(polygons[0][0], Vector2.ZERO)
    for point in polygons[0]:
        bounds = bounds.expand(point)
    _check(bounds.position.x < 0.0 and bounds.end.x > 0.0, "Le pivot doit décaler le contour en espace local.")
    definition.collision_source = GroundPieceDefinition.CollisionSource.AUTHORED_OUTLINE
    definition.authored_outline = PackedVector2Array([Vector2.ZERO, Vector2.RIGHT])
    _check(definition.validation_errors().has("Authored Outline exige au moins trois points."), "Le contour auteur incomplet doit être signalé.")
    definition.piece_id = &""
    _check(definition.validation_errors().has("Piece ID ne peut pas être vide."), "L'identifiant vide doit être signalé.")
    definition.piece_id = &"test_ledge"
    definition.texture = null
    _check(definition.validation_errors().has("Texture est obligatoire."), "La texture absente doit être signalée.")
    definition.texture = ImageTexture.create_from_image(image)
    definition.collision_source = GroundPieceDefinition.CollisionSource.ALPHA
    definition.recommended_mode = GroundPieceDefinition.RecommendedMode.BREAKABLE
    definition.breakable_profile = null
    _check(definition.validation_errors().has("Breakable Profile est obligatoire pour le mode conseillé Breakable."), "Le profil cassable absent doit être signalé.")
    print("GROUND_PIECE_DEFINITION_TEST: PASS" if failures.is_empty() else "GROUND_PIECE_DEFINITION_TEST: FAIL")
    quit(0 if failures.is_empty() else 1)
```

- [x] **Step 2: Run the test and confirm the missing classes fail**

Run:

```bash
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/ground_piece_definition_test.gd
```

Expected: non-zero exit because `GroundPieceDefinition` is not declared.

- [x] **Step 3: Implement `GroundBreakableProfile`**

Use this exact public surface:

```gdscript
@tool
class_name GroundBreakableProfile
extends Resource

@export_range(1.0, 10000.0, 1.0) var maximum_health := 100.0
@export var remove_collision_when_broken := true
@export var remove_after_break := false

func is_valid() -> bool:
    return maximum_health > 0.0
```

- [x] **Step 4: Implement `GroundPieceDefinition`**

Define `Category`, `CollisionSource`, and `RecommendedMode` enums. Group exports
as Identity, Presentation, Geometry, and Recommended Behavior. Use these exact
properties:

```gdscript
@export var piece_id: StringName
@export var display_name := "Ground piece"
@export var category := Category.NATURAL
@export var tags := PackedStringArray()
@export var texture: Texture2D
@export var pivot_px := Vector2.ZERO
@export var default_z_index := 0
@export var default_flip_h := false
@export var destroyed_texture: Texture2D
@export var collision_source := CollisionSource.ALPHA
@export_range(0.01, 0.99, 0.01) var alpha_threshold := 0.5
@export_range(0.0, 16.0, 0.25) var simplification := 2.0
@export var authored_outline := PackedVector2Array()
@export var material_mask: Texture2D
@export var recommended_mode := RecommendedMode.CARVABLE
@export var breakable_profile: GroundBreakableProfile
@export var supports_rotation := false
@export var supports_uniform_scale := true
```

`geometry_polygons()` must use `BitMap.create_from_image_alpha()` and
`opaque_to_polygons()`, then subtract `pivot_px` from every generated point.
`texture_image()` returns `texture.get_image()`. `mask_image()` returns
`material_mask.get_image()` when present, otherwise `texture.get_image()`.
Validation rejects a material mask whose dimensions differ from the texture.
Authored geometry returns exactly one copied polygon.

- [x] **Step 5: Run the Resource test**

Run the Task 1 command. Expected: `GROUND_PIECE_DEFINITION_TEST: PASS`.

- [x] **Step 6: Record the checkpoint**

Append a dated “Ground Piece Resources” entry to `docs/WORKLOG.md`, including
the test command and result. Do not initialize Git.

---

### Task 2: Breakable component and canonical scene

**Files:**
- Create: `terrain/ground_pieces/components/ground_breakable_component.gd`
- Create: `terrain/ground_pieces/ground_piece_2d.gd`
- Create: `terrain/ground_pieces/ground_piece_2d.tscn`
- Test: `tests/ground_piece_modes_test.gd`

**Interfaces:**
- Consumes: `GroundPieceDefinition.geometry_polygons()`
- Produces: `GroundPiece2D.GroundMode`
- Produces: `GroundPiece2D.is_permanent_collision_active() -> bool`
- Produces: `GroundPiece2D.is_carvable_stamp_active() -> bool`
- Produces: `GroundPiece2D.is_breakable_active() -> bool`
- Produces: `GroundPiece2D.validation_errors() -> PackedStringArray`
- Produces: `GroundBreakableComponent.apply_damage(amount: float) -> bool`

- [x] **Step 1: Write the failing mode test**

Instantiate the canonical scene with an in-memory alpha definition. Set each
mode in turn and assert exclusive activation. In Breakable mode, apply exactly
the profile maximum health and assert one `piece_broken` emission, destroyed
state, and disabled collision.

```gdscript
piece.ground_mode = GroundPiece2D.GroundMode.PERMANENT
piece.sync_from_authority()
_check(piece.is_permanent_collision_active(), "Permanent doit activer sa collision.")
_check(not piece.is_carvable_stamp_active(), "Permanent ne doit pas produire de stamp.")
piece.ground_mode = GroundPiece2D.GroundMode.CARVABLE
piece.sync_from_authority()
_check(not piece.is_permanent_collision_active(), "Carvable interdit la double collision locale.")
_check(piece.is_carvable_stamp_active(), "Carvable doit exposer son stamp.")
piece.ground_mode = GroundPiece2D.GroundMode.BREAKABLE
piece.sync_from_authority()
_check(piece.is_breakable_active(), "Breakable doit activer son composant de vie.")
```

- [x] **Step 2: Run the test and confirm the scene is missing**

Run the new headless test. Expected: failure loading
`res://terrain/ground_pieces/ground_piece_2d.tscn`.

- [x] **Step 3: Implement `GroundBreakableComponent`**

Use signals `health_changed(current, maximum)`, `damaged(amount)`, and
`piece_broken`. `configure(profile)` resets health. `apply_damage()` rejects
non-positive damage and repeated damage after break, then emits exactly once
when health reaches zero.

```gdscript
class_name GroundBreakableComponent
extends Node

signal health_changed(current: float, maximum: float)
signal damaged(amount: float)
signal piece_broken

var profile: GroundBreakableProfile
var current_health := 0.0
var broken := false

func configure(value: GroundBreakableProfile) -> void:
    profile = value
    broken = false
    current_health = profile.maximum_health if profile != null else 0.0
```

- [x] **Step 4: Create the canonical scene tree**

Create exactly:

```text
GroundPiece2D (Node2D)
├── Presentation (Sprite2D, unique name)
├── PermanentBody (StaticBody2D, unique name)
│   └── Collision (CollisionPolygon2D, unique name)
├── DestructibleStamp (Node2D, unique name)
├── BreakableComponent (Node, unique name)
└── EditorPreview (Node2D, unique name)
```

The first tranche accepts one connected collision polygon. If alpha conversion
returns several polygons, use the polygon with the greatest absolute area and
emit a configuration warning stating that the source must be consolidated or
use `AuthoredOutline`.

- [x] **Step 5: Implement `GroundPiece2D` synchronization**

Export `definition`, `ground_mode`, `flip_h`, and `render_priority`. Public
`sync_from_authority()` sets Sprite texture, position to `-pivot_px`, z-index,
collision polygon, component process modes, and visibility. Connect
`BreakableComponent.piece_broken` once and expose `apply_damage(amount)` on the
root so projectiles can command the piece directly.

Validation must reject non-uniform scale in Carvable mode, rotation when
`supports_rotation == false`, missing Breakable profile, and multiple alpha
polygons. Use `is_equal_approx(scale.x, scale.y)` for uniform-scale validation.

- [x] **Step 6: Run the mode test**

Expected: `GROUND_PIECE_MODES_TEST: PASS`.

- [x] **Step 7: Record the checkpoint**

Append scene tree, Inspector authorities, and test result to `docs/WORKLOG.md`.

---

### Task 3: Carvable stamps in the global terrain

**Files:**
- Modify: `terrain/destructible_terrain_2d.gd`
- Test: `tests/ground_piece_destructible_stamp_test.gd`

**Interfaces:**
- Consumes: `GroundPiece2D` instances under `ground_pieces_path`
- Produces: `DestructibleTerrain2D.collect_carvable_pieces() -> Array[GroundPiece2D]`
- Produces: `DestructibleTerrain2D.authored_color_image: Image`
- Preserves: `generate_from_authored_zones()`, `carve_circle()`, and legacy `authored_zones_path`

- [x] **Step 1: Write a failing adjacent-stamps test**

Build a 1280 × 720 terrain profile in memory and two 64 × 64 pieces whose alpha
rectangles touch at x=640. Place both under a `GroundPieces` Node2D, generate the
terrain, then assert solidity on both sides and carve a circle centered on the
seam.

```gdscript
_check(terrain.collect_carvable_pieces().size() == 2, "Deux stamps doivent être collectés.")
_check(terrain.is_solid_at(Vector2(636, 560)), "Le stamp gauche doit être solide.")
_check(terrain.is_solid_at(Vector2(644, 560)), "Le stamp droit doit être solide.")
terrain.carve_circle(Vector2(640, 560), 12.0)
_check(not terrain.is_solid_at(Vector2(636, 560)), "Le cratère doit traverser le stamp gauche.")
_check(not terrain.is_solid_at(Vector2(644, 560)), "Le cratère doit traverser le stamp droit.")
_check(not left.is_permanent_collision_active() and not right.is_permanent_collision_active(), "Les stamps ne doivent pas conserver de collisions locales.")
```

- [x] **Step 2: Run the stamp test and verify failure**

Expected: failure because `ground_pieces_path` and collection do not exist.

- [x] **Step 3: Add Ground Pieces as a second authoring source**

Add:

```gdscript
@export_node_path("Node2D") var ground_pieces_path := NodePath("../Gameplay/GroundPieces")
var authored_color_image: Image

func ground_pieces_root() -> Node2D:
    return get_node_or_null(ground_pieces_path) as Node2D

func collect_carvable_pieces() -> Array[GroundPiece2D]:
    var result: Array[GroundPiece2D] = []
    var root_node := ground_pieces_root()
    if root_node == null:
        return result
    for child in root_node.find_children("*", "GroundPiece2D", true, false):
        var piece := child as GroundPiece2D
        if piece != null and piece.ground_mode == GroundPiece2D.GroundMode.CARVABLE:
            result.append(piece)
    result.sort_custom(func(a: GroundPiece2D, b: GroundPiece2D) -> bool:
        return a.render_priority < b.render_priority
    )
    return result
```

Preserve legacy zone rasterization. Missing `GroundPieces` is allowed while the
legacy branch exists; missing both authoring sources is a configuration warning.

- [x] **Step 4: Implement deterministic texture/mask stamping**

Initialize `authored_color_image` as transparent with `profile.world_size`.
For each source pixel whose `mask_image()` alpha exceeds the definition threshold:

1. subtract `pivot_px`;
2. mirror x when `flip_h` is true;
3. apply the piece global transform;
4. convert to terrain-local integer coordinates;
5. set `mask_image` white;
6. alpha-composite the corresponding `texture_image()` pixel into
   `authored_color_image`.

When `_rebuild_display_image()` visits a solid pixel, prefer the authored color
when its alpha is non-zero; otherwise retain `_terrain_sample()`. Carving clears
`mask_image` and therefore hides the composed color without modifying the source.

- [x] **Step 5: Run stamp and legacy terrain tests**

Run:

```bash
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/ground_piece_destructible_stamp_test.gd
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --script res://tests/destructible_terrain_test.gd
```

Expected: both tests pass; the legacy map still builds its bitmap once.

- [x] **Step 6: Record the checkpoint**

Document dual-source migration and test results in `docs/WORKLOG.md`.

---

### Task 4: First real Côte toxique piece through the isolated asset pipeline

**Files:**
- Create all pipeline and art files listed in the File map for `natural_ledge_medium_v001`
- Modify: `art/ASSET_MANIFEST.md`
- Test: `pipeline/assets/tools/validate_ground_piece_candidates.py`
- Test: `tests/asset_pipeline_contract_test.gd`

**Interfaces:**
- Produces: transparent 768 × 384 runtime bitmap
- Produces: documented pivot `[384, 64]`
- Produces: candidate QA with alpha bounds, edge alpha, hashes, and publication status

- [x] **Step 1: Write the failing pipeline validator**

The validator must assert exact RGBA mode, exact 768 × 384 dimensions, alpha
extrema 0 and 255, non-empty alpha bounds, zero alpha on all four canvas edges,
and pivot `[384, 64]` contained inside the canvas. It must compare SHA-256 values
against the generated QA report.

- [x] **Step 2: Run the validator and confirm the export is missing**

Run:

```bash
python3 pipeline/assets/tools/validate_ground_piece_candidates.py
```

Expected: non-zero exit naming the missing normalized candidate.

- [x] **Step 3: Generate one isolated source with ImageGen**

Use `imagegen` with `art/concepts/da-03-environment-destruction.png` as style
reference and this recorded prompt:

```text
One isolated medium natural terrain ledge for a side-scrolling run-and-gun game,
strict side view, broad nearly horizontal walkable top, irregular toxic dark-earth
underside hanging downward, embedded oily pipes and a few acid-green roots, thick
black expressive outlines, olive military grime, tiny magenta accents, matching
the supplied Côte toxique environment reference. One object only, no characters,
no weapons, no explosion, no labels, no ground plane, no cast shadow, no detached
debris or floating islands, native true transparent background. Keep every opaque
pixel away from the canvas edges.
```

Save the untouched result under the exact source path. Record the generation
tool and reference in provenance before processing.

- [x] **Step 4: Implement deterministic normalization**

`process_ground_piece_candidates.py` must remove alpha values at or below
16/255, crop the remaining alpha bounds, fit the source within a 704 × 304 safe
area, place the walkable top around y=64 on a 768 × 384 transparent canvas, and
write pivot `[384, 64]` to QA. It must not publish into `art/`.

- [x] **Step 5: Run processing and technical validation**

Run the processor, validator, `identify`, and the asset pipeline contract test.
Expected: all technical checks pass and the export remains `candidate`.

- [x] **Step 6: Perform the human visual gate**

Present the candidate at original resolution. Verify a readable walkable top,
clean alpha, no baked checkerboard, coherent scale and no clipped detail. Do not
continue to publication until the project owner explicitly approves it.

- [x] **Step 7: Publish the approved bitmap**

Copy the exact validated export to
`art/terrain/pieces/toxic_coast/natural/natural-ledge-medium-v001.png`. Change
manifest statuses to `validated` then `integrated`, add the runtime hash to
`art/ASSET_MANIFEST.md`, and rerun `asset_pipeline_contract_test.gd`.

- [x] **Step 8: Record the checkpoint**

Document prompt, approval, hashes and validation results in `docs/WORKLOG.md`.

---

### Task 5: Drag-and-drop kit scene and catalog

**Files:**
- Create: `terrain/ground_pieces/ground_kit_catalog.gd`
- Create: `terrain/kits/toxic_coast/definitions/natural_ledge_medium.tres`
- Create: `terrain/kits/toxic_coast/pieces/natural_ledge_medium.tscn`
- Create: `terrain/kits/toxic_coast/toxic_coast_ground_kit.tres`
- Test: `tests/ground_kit_catalog_test.gd`

**Interfaces:**
- Consumes: published bitmap and canonical `GroundPiece2D`
- Produces: `GroundKitCatalog.validation_errors() -> PackedStringArray`
- Produces: `GroundKitCatalog.scene_for(piece_id: StringName) -> PackedScene`

- [x] **Step 1: Write the failing catalog test**

Load the catalog, assert zero validation errors, retrieve
`natural_ledge_medium`, instantiate it as `GroundPiece2D`, and verify that its
definition ID, texture path, recommended Carvable mode and Inspector mode agree.
Create an in-memory catalog with the same PackedScene twice and assert the exact
duplicate-ID error.

- [x] **Step 2: Run the catalog test and confirm missing files**

Expected: failure loading `toxic_coast_ground_kit.tres`.

- [x] **Step 3: Implement `GroundKitCatalog`**

Export `kit_id`, `display_name`, and `pieces: Array[PackedScene]`. Validation
instantiates each scene temporarily, requires a valid `GroundPiece2D`, and
rejects duplicate `definition.piece_id`. `scene_for()` returns null for unknown
IDs without logging an error.

- [x] **Step 4: Create definition and drag scene**

The definition must reference only the published `art/` PNG, use pivot
`Vector2(384, 64)`, alpha collision, threshold `0.5`, simplification `2.0`, and
recommended Carvable mode. The piece scene inherits or instantiates the
canonical scene and assigns this Resource without copying texture or geometry.

- [x] **Step 5: Create and test the catalog**

Add exactly the first piece scene to the Côte toxique catalog. Run the catalog,
definition, and mode tests. Expected: all pass.

- [x] **Step 6: Record the checkpoint**

Add the FileSystem drag path and Inspector workflow to `docs/WORKLOG.md`.

---

### Task 6: Pilot integration in Côte toxique

**Files:**
- Modify: `maps/missions/toxic_coast/toxic_coast.tscn`
- Modify: `maps/system/mission_map_root_2d.gd`
- Modify: `tests/map_contract_test.gd`
- Modify: `docs/maps/MAP_AUTHORING_CONTRACT.md`

**Interfaces:**
- Consumes: `natural_ledge_medium.tscn`
- Produces: mandatory `Gameplay/GroundPieces` authoring branch
- Preserves: legacy `Gameplay/DestructibleZones` and `Gameplay/IndestructibleGeometry`

- [x] **Step 1: Extend the failing map contract**

Assert that `Gameplay/GroundPieces` exists, contains `LandingNaturalLedge`, and
that the instance is Carvable with definition ID `natural_ledge_medium`. Assert
that all four legacy `GroundModule2D` instances remain present.

- [x] **Step 2: Run the map contract and confirm failure**

Expected: failure because `Gameplay/GroundPieces` does not exist.

- [x] **Step 3: Add the authoring branch and pilot instance**

Add `Gameplay/GroundPieces` after `Segments`. Place `LandingNaturalLedge` within
the existing CentralSoil footprint, with its origin on the current walking
surface. Keep the legacy zone beneath it during this tranche so player collision
and spawn safety cannot regress. Assign Carvable mode on the instance.

- [x] **Step 4: Extend root validation**

Add `GroundPieces` to the required Gameplay branches. For each descendant
`GroundPiece2D`, append its `validation_errors()` prefixed with its scene path.
Do not remove validation of `DestructibleZones` or `IndestructibleGeometry`.

- [x] **Step 5: Document the author workflow**

Add the exact workflow to `MAP_AUTHORING_CONTRACT.md`: drag from
`terrain/kits/<kit>/pieces/`, place under `Gameplay/GroundPieces`, choose mode,
regenerate destructible preview, resolve all configuration warnings.

- [x] **Step 6: Run map and terrain tests**

Run `map_contract_test.gd`, `destructible_terrain_test.gd`,
`ground_piece_destructible_stamp_test.gd`, and
`permanent_ground_module_test.gd`. Expected: all pass.

- [x] **Step 7: Record the checkpoint**

Record exact node path, position, mode, retained legacy nodes and tests in
`docs/WORKLOG.md`.

---

### Task 7: Full verification and resumable handoff

**Files:**
- Modify: `docs/assets/GUIDE_TERRAIN_ET_GROUND_PIECES.md`
- Modify: `docs/PROJECT_STATE.md`
- Modify: `docs/WORKLOG.md`

**Interfaces:**
- Consumes: all prior deliverables
- Produces: a verified, documented tranche that can be resumed without chat history

- [x] **Step 1: Update the guide from target to current**

Mark every created path as implemented, retain a separate list for future kit
pieces, and add the first drag-and-drop example path.

- [x] **Step 2: Run every focused test**

Run the four new tests plus `asset_pipeline_contract_test.gd`,
`map_contract_test.gd`, `destructible_terrain_test.gd`,
`permanent_ground_module_test.gd`, and `foundation_smoke_test.gd`.

- [x] **Step 3: Run project startup validation**

```bash
env XDG_DATA_HOME=/tmp/jeuweb-test-data XDG_CONFIG_HOME=/tmp/jeuweb-test-config XDG_CACHE_HOME=/tmp/jeuweb-test-cache /home/evan/.local/bin/godot --headless --path . --quit-after 240
```

Expected: exit 0 without parser errors, invalid Resources or missing imports.

- [x] **Step 4: Verify no forbidden pipeline references**

```bash
rg -n 'res://pipeline/' --glob '*.gd' --glob '*.tscn' --glob '*.tres' . --glob '!pipeline/**'
```

Expected: only the deliberate string construction inside the contract test; no
runtime direct reference.

- [x] **Step 5: Write final state**

Update `PROJECT_STATE.md` with the new authorities, working editor workflow,
legacy compatibility and next recommended kit pieces. Append all commands and
their real outputs to `WORKLOG.md`; never claim visual approval or a passing
test without the corresponding evidence.

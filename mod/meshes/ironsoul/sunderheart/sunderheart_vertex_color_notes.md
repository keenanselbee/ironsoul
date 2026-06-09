# Sunderheart Vertex Color Notes

This note records the reliable binary edit path for the outer Sunderheart particle effect in `sunderheart_1.nif`.

## Target

File:

```text
mod/meshes/ironsoul/sunderheart/sunderheart_1.nif
```

Outer particle effect subtree:

```text
60 BSOrderedNode SigilStone:60
61 NiNode :61
62 NiBillboardNode Wisps
65 BSTriShape Wisps:0
80 BSTriShape Wisps:1
95 BSTriShape Wisps:2
104 BSTriShape Wisps:3
119 NiBillboardNode glowBlue
120 BSTriShape glowBlue:0
123 BSTriShape glowBlue:1
```

Only the six `BSTriShape` blocks above should be edited for the outer particle vertex colors.

## Correct Vertex Color Layout

These shapes use 32-byte packed vertex records.

For each vertex:

```text
vertex + 20: packed normal/tangent-related data. Do not edit as color.
vertex + 28: Vertex Colors RGBA, as shown by NifSkope.
```

The `vertex + 20` lane can look color-like in a hex dump, but it is not the NifSkope `Vertex Colors` field. If it was edited by mistake, restore those 4 bytes per vertex from a clean matching copy before changing the real color lane.

## Desired Color

Use neutral grey centered around:

```text
#bdbdbd
```

Small per-vertex variation is okay and helps avoid a flat particle look. The current intended range is:

```text
#b5b5b5 through #c5c5c5
```

Preserve the existing alpha byte. Some vertices intentionally have alpha values such as `00`, `8e`, `bf`, `cb`, or `ff`.

## Binary Edit Procedure

1. Parse the NIF header and block table.
2. Confirm the file has the expected block layout and that blocks `65`, `80`, `95`, `104`, `120`, and `123` are `BSTriShape`.
3. For each target `BSTriShape`, locate the embedded vertex stream:
   - `Num Triangles` is a `uint16`.
   - `Num Vertices` is the following `uint16`.
   - `Data Size` is the following `uint32`.
   - `Triangle Bytes = Num Triangles * 3 * 2`.
   - `Vertex Bytes = Data Size - Triangle Bytes`.
   - `Stride = Vertex Bytes / Num Vertices`.
   - Accept only `Stride == 32`.
   - `Vertex Start = block start + field offset + 8`.
4. For each vertex, edit only these bytes:

```text
Vertex Start + vertex_index * 32 + 28: R
Vertex Start + vertex_index * 32 + 29: G
Vertex Start + vertex_index * 32 + 30: B
Vertex Start + vertex_index * 32 + 31: A, preserve this byte
```

5. Verify:
   - RGB is neutral grey on every target vertex.
   - RGB values are within `0xb5..0xc5`.
   - R, G, and B match for every target vertex.
   - Alpha matches the pre-edit file.
   - The `vertex + 20` lane matches the pre-edit file if a repair source is available.

## Known-Good Verification State

After the corrected edit, the six target blocks had this result:

```text
65  vertices 363  grey range b5-c5
80  vertices 363  grey range b5-c5
95  vertices 99   grey range b5-c5
104 vertices 264  grey range b5-c5
120 vertices 9    grey range b6-c5
123 vertices 29   grey range b5-c5
```

Total edited vertices:

```text
1127
```

Verification result:

```text
0 non-neutral vertex colors
0 out-of-range vertex colors
0 alpha mismatches
0 restored-lane mismatches
```

## Minimal Node Edit Pattern

Use this as the shape of the edit, not as a blind copy-paste without checking paths and block layout:

```js
const ids = [65, 80, 95, 104, 120, 123];
const baseGrey = 0xbd;

for (const id of ids) {
  const meta = findBSTriShapeVertexStream(id);

  for (let v = 0; v < meta.vertices; v++) {
    const vertex = meta.vertexStart + v * 32;
    const hash = (id * 1103515245 + v * 12345 + ((v + id) << 7)) >>> 0;
    const grey = Math.max(0, Math.min(255, baseGrey + ((hash % 17) - 8)));

    data[vertex + 28] = grey;
    data[vertex + 29] = grey;
    data[vertex + 30] = grey;
    // data[vertex + 31] is alpha. Preserve it.
  }
}
```

## NifSkope Check

Reload the mesh in NifSkope and inspect one of the target shapes, for example:

```text
65 BSTriShape Wisps:0
Vertex Data
Vertex Data
Vertex Colors
```

Expected values should look like:

```text
#b6b6b6ff
#c2c2c2ff
#bdbdbd00
```

They should not look purple, such as:

```text
#715b90ff
```

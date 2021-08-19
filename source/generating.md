# Regenerating bindings

In order to update `raylib-d` to work with a newer version of `raylib`, the headers must be regenerated with [dstep].

Three modules should be regenerated: `raylib`, `raymath` and `rlgl`.

```
dstep raylib.h raymath.h rlgl.h -o ~/git/contrib/raylib-d/source --space-after-function-name=false --skip Vector2 \
    --skip Vector3 --skip Vector4 --skip Quaternion --skip Matrix --skip Rectangle --skip RL_MALLOC --skip RL_CALLOC \
    --skip RL_REALLOC --skip RL_FREE
```

Note: we're skipping a couple symbols because we define them manually in `raylib_types`. We also skip memory functions
because they only have effect when compiling Raylib in C.

After you regenerate them, they won't be ready to use yet. We need to add module declarations and imports at the top
of each module:

```d
module raylib;

public
{
    import rlgl;
    import easings;
    import raymath;
    import raymathext;
    import raylib_types;
}
```

```d
module raymath;

import raylib;
```

```d
module rlgl;

import raylib;
```

Additionally, each of those modules will have an automatically generated `extern (C):` line. We need to find it and
edit it to `extern (C) @nogc nothrow:`.

dstep will also make a mistake in `raylib.d` and incorrectly define a couple `alias`es as `enums`. Those must be fixed.
Look for a block of code similar to this:

```d
// Temporal hacks to avoid breaking old codebases using
// deprecated raylib implementation or definitions
enum FormatText = TextFormat;
enum LoadText = LoadFileText;
enum GetExtension = GetFileExtension;
enum GetImageData = LoadImageColors;
enum FILTER_POINT = TextureFilter.TEXTURE_FILTER_POINT;
enum FILTER_BILINEAR = TextureFilter.TEXTURE_FILTER_BILINEAR;
enum MAP_DIFFUSE = MATERIAL_MAP_DIFFUSE;
enum PIXELFORMAT_UNCOMPRESSED_R8G8B8A8 = PixelFormat.PIXELFORMAT_PIXELFORMAT_UNCOMPRESSED_R8G8B8A8;
```

and replace each `enum` with `alias`.

This should be enough. Run `dub test` and see if it compiles.

[dstep]: https://github.com/jacob-carlborg/dstep

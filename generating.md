# Regenerating bindings

In order to update `raylib-d` to work with a newer version of `raylib`, the headers must be regenerated with [dstep].

Four modules should be regenerated: `raylib`, `raymath`, `rlgl`, and `rcamera`.

`rcamera.h` is an odd one, because it depends on raylib types, but does not include `raylib.h` directly. So dstep has trouble with it. In order to properly generate the binding, you must add the following to the file, inside the header. I prefer to do it in an `#else` clause after the `#ifdef RCAMERA_STANDALONE`:

```c
#include "raylib.h"
```

Run the following command from the `raylib/src` directory. Note: path/to/raylib-d should be the path to the raylib-d repository that you have on your system.

```
dstep raylib.h raymath.h rlgl.h rcamera.h -o path/to/raylib-d/source/raylib --space-after-function-name=false \
    --skip Vector2 --skip Vector3 --skip Vector4 --skip Quaternion --skip Matrix --skip Rectangle \
    --skip RL_MALLOC --skip RL_CALLOC --skip RL_REALLOC --skip RL_FREE
```

Note: we're skipping a couple symbols because we define them manually in `raylib_types`. We also skip memory functions
because they only have effect when compiling Raylib in C.

Finally, the `raylib.h` file will export as `raylib.d`, but it should be moved to `raylib/package.d`.

After you regenerate them, they won't be ready to use yet. We need to add module declarations and imports at the top
of each module:

```d
module raylib;

public
{
    import raylib.rlgl;
    import raylib.reasings;
    import raylib.raymath;
    import raylib.raymathext;
    import raylib.raylib_types;
    import raylib.binding;
}
```

```d
module raylib.raymath;

import raylib;
```

```d
module raylib.rlgl;

import raylib;
```

Additionally, each of those modules will have an automatically generated `extern (C):` line. We need to find it and
edit it to `extern (C) @nogc nothrow:`.

This should be enough. Run `dub test` and see if it compiles.

## Generating raygui

Using [ctod], I have completely ported raygui.h to D. This was not as swift a process as creating the C header bindings for raylib, and is fairly untested. However, the old raygui modules was completely out of date, so this should be a much needed update.

The changes are fairly involved, and mostly involve fixing the compiler errors that occur when trying to build the example program.

Unlike the old raygui.d, this does not need a binding library -- it's included in the raylib-d build directly.

[dstep]: https://github.com/jacob-carlborg/dstep
[ctod]: https://github.com/dkorpel/ctod

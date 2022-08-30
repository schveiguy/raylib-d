![](raylib_logo.png)

# raylib-d [![DUB](https://img.shields.io/dub/v/raylib-d?style=for-the-badge)](https://code.dlang.org/packages/raylib-d)
(static) D bindings for [raylib](https://www.raylib.com/), a simple and easy-to-use library to learn videogames programming.

# Installation

## Adding the dependency

raylib-d is used via the [dub](https://code.dlang.org) build system.

Use `dub add` to add raylib-d to the dependency list of an existing project:

```sh
> dub add raylib-d
Adding dependency raylib-d ~>4.2.0
>
```

Or you can add the dependency through the interactive prompts when creating your project with `dub init`

## Get a copy of Raylib
You can get the library by compiling it from the [source](https://github.com/raysan5/raylib), or download the [official precompiled binaries](https://github.com/raysan5/raylib/releases).

*WARNING*: Make sure you get the correct copy of the raylib library based on the version of raylib-d! Getting the incorrect version will cause SILENT compatibility errors, including memory corruption. It is extremely important to match these together.

If you depend on raylib-d vX.Y.Z, then your raylib binary should be vX.Y.0. Note that so far, raylib has never had point releases, but raylib-d may have them. Note that raylib-d version 3.1.0 is matched against raylib version 3.7.0, but should probably never have been tagged that way. There is an equivalent 3.7.0 tag now.

For example, if you depend on raylib-d version `v3.0.x`, then you should download raylib version `3.0.0`. If you depend on raylib-d version `3.7.x`, then you should download raylib version `3.7.0`.

### Runtime validation of binding

Starting with version 4.2.0, raylib-d includes a new module `raylib.binding`,
which at the moment contains one function: `validateRaylibBinding`. @raysan5
was kind enough to include a runtime-accessible version string for version
4.2.0 of the library, so now we can validate the raylib binding mechanically
without relying on proper environmental setup. So if you compile against one
version, but link against another, you can call this function and it will exit
the program with an error code if the binding is incorrect. This is better than
creating memory corruption errors!

If you link against an earlier verison of raylib, it should fail to link if
this symbol doesn't exist.

### Linux/Mac:

You must make raylib visible to the linker. `cd` into the extracted raylib folder (e.g. `raylib-4.2.0_macos`).

Now we must make raylib visible to the compiler and linker system wide. Simply run the following.
```
sudo mv lib/* /usr/local/lib/
```

Linux users must also update the linker with this command:
```
sudo ldconfig
```

### Windows:
On Windows you must drag and drop all the required library files into the root directory of your project. These are `raylib.dll`, `raylib.lib`, and `raylibdll.lib`.

## In order to link against raylib, add it to your dub.json.


Starting with `4.0.0`, raylib on windows includes 2 windows linker files, `raylib.lib` for static linking (not recommended) and `raylibdll.lib` for dynamic linking. Even though the dll is called `raylib.dll`, use the `raylibdll` for the linker file to link dynamically.

You can link against all oses correctly by using os-specific `libs` keys.

Using version 4.2.0 as an example:

```json
"dependencies": { "raylib-d": "~>4.2.0" },
"libs-posix": [ "raylib" ],
"libs-windows": [ "raylibdll" ],
```

# Example
```D
import raylib;

void main()
{
    // call this before using raylib
    validateRaylibBinding();
    InitWindow(800, 600, "Hello, Raylib-D!");
    while (!WindowShouldClose())
    {
        BeginDrawing();
        ClearBackground(Colors.RAYWHITE);
        DrawText("Hello, World!", 400, 300, 28, Colors.BLACK);
        EndDrawing();
    }
    CloseWindow();
}
```

# Docs/Cheatsheet

At the moment, we do not properly ddoc the binding. This may change in the near future. However, all documentation is valid from the raylib [online cheatsheet](https://www.raylib.com/cheatsheet/cheatsheet.html), or you can view the binding source files directly.

# License
raylib-d is licensed under an unmodified zlib/libpng license. View [LICENSE](LICENSE).

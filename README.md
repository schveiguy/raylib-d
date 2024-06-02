![](raylib_logo.png)

# raylib-d [![DUB](https://img.shields.io/dub/v/raylib-d?style=for-the-badge)](https://code.dlang.org/packages/raylib-d)
(static) D bindings for [raylib](https://www.raylib.com/), a simple and easy-to-use library to learn videogames programming.

# Differences from Raylib
All functions, types, and enum values are the same as in upstream Raylib. The only difference is that the `zoom` property of the `Camera2D` struct is initially set to `1.0f` instead of `0.0f`.

# Installation

## Adding the dependency

raylib-d is used via the [dub](https://code.dlang.org) build system.

Use `dub add` to add raylib-d to the dependency list of an existing project:

```sh
> dub add raylib-d
Adding dependency raylib-d ~>4.2.3
>
```

Or you can add the dependency through the interactive prompts when creating your project with `dub init`

## Get a copy of Raylib
You will need a copy of the raylib binary C library to link against, in order to run a raylib-d program. There are 3 ways to get this. Please read ALL the instructions before picking which mechanism you want to use.

1. (beta) Use the raylib-d:install utility to copy the appropriate pre-built library.
2. Download the precompiled binary from the official github account for raylib.
3. Compile the library from source

### *NEW* Method 1: install appropriate raylib library with helper tool

In version 4.2.1 of raylib-d, a new subproject `raylib-d:install` is included, along with pre-built binary libraries of raylib. This greatly simplifies the process of obtaining pre-built libraries. Note that this is a *work in progress* and not every binary distribution is included.

To run this, run this command from your project directory, and it will copy all the appropriate library files to your project directory:

```sh
> dub upgrade
> dub run raylib-d:install
```
The following OS/arch combinations are included:

* Windows - x86_64
* Linux -x86_64 *Note: 4.2.4 and above!*
* MacOS - x86_64
* MacOS - arm64

If you do not have one of these systems, or want to use static linking, please use a different method.

If other platforms are desired, please let me know in the issues. As of now, I am only supporting libraries that I built myself or that are included in the official distribution.

### Method 2: Download official binaries

Download the [official precompiled binaries](https://github.com/raysan5/raylib/releases) from raylib's github page. Find the appropriate download archive for your version of raylib and your OS/arch. Copy or move the files out of the `lib` subdirectory into your project directory.

Notes for Windows users:
* The raylib dll linker file will be named `raylibdll.lib`. It is recommended to copy this file, but *rename it to `raylib.lib`*. The `raylib.lib` file included in the zipfile is for static linking, which is not recommended.
* Version 4.2.0 of raylib had a [build issue](https://github.com/raysan5/raylib/issues/2671) where it did not export a needed symbol for raylib-d 4.2.x, and therefore the downloaded version *will not link* with raylib-d. If you are using raylib 4.2.0, use Method 1.

### Method 3: Compile raylib from source

You can get the library from the [source](https://github.com/raysan5/raylib), and build it according to those instructions. Make sure to checkout the version tagged, and *not* the master branch. `raylib` is under continuous development, and the binding does not take into account any possible changes to API that may have occurred. You may get linker errors (or worse, memory corruption) if you use the master version, or wrong tagged version of raylib! Due to the way C functions are linked, there is no protection against this.

The Windows notes from Method 2 apply here as well.

## Optional: relocate libraries (Linux/MacOS)

On Posix systems (non-windows), you have the option of moving the library files to the appropriate directory instead of your project directory. On most systems, this would be `/usr/local/lib`.

To do this, use the `sudo` command:

```sh
> sudo mv libraylib* /usr/local/lib
```

On Linux, you should also reload the library cache:

```sh
> sudo ldconfig
```

This aids in running your executable, as the library can be found easily by the dynamic loader.

See the linking instructions for ways to avoid this step. This step is never necessary for Windows, and there is no "global" location to use.

## Linking instructions in dub.json

You must include the linker flags to link against the raylib library in your dub.json file. This is done using the `"libs"` directive.

The following directives should work for all systems, for the case where the library is in the project directory.

```json
"dependencies": { "raylib-d": "~>4.2.0" },
"libs": [ "raylib" ],
"lflags-posix" : ["-L."],
"lflags-osx" : ["-rpath", "@executable_path/"],
"lflags-linux" : ["-rpath=$$ORIGIN"],
```

The OS-specific `lflags` lines are unnecessary if your library is copied to `/usr/local/lib`

The `-rpath` flag allows the system to load the library from the local directory without using environment variables.

## Using the correct library

*WARNING*: Make sure you get the correct copy of the raylib library based on the version of raylib-d! Getting the incorrect version will cause SILENT compatibility errors, including memory corruption. It is extremely important to match these together.

If you depend on raylib-d vX.Y.Z, then your raylib binary should be vX.Y.0. Note that so far, raylib has never had point releases, but raylib-d may have them. Note that raylib-d version 3.1.0 is matched against raylib version 3.7.0, but should probably never have been tagged that way. There is an equivalent 3.7.0 tag now.

For example, if you depend on raylib-d version `v3.0.x`, then you should download raylib version `3.0.0`. If you depend on raylib-d version `3.7.x`, then you should download raylib version `3.7.0`.

Starting with version 4.2.0, raylib-d includes a new module `raylib.binding`,
which at the moment contains one function: `validateRaylibBinding`. @raysan5
was kind enough to include a runtime-accessible version string for version
4.2.0 of the library, so now we can validate the raylib binding mechanically
without relying on proper environmental setup. So if you compile against one
version, but link against another, you can call this function and it will exit
the program with an error code if the binding is incorrect. This is better than
creating memory corruption errors!

As noted earlier, this did not properly get exported for the pre-built Windows dll for 4.2.0. Therefore, you *must* use installation method 1 above to link with raylib-d 4.2.x.

## Running your program

In order to run your program, you will need to ensure the raylib dynamic library is available for loading. This is different based on the OS:

* On Windows, you simply need the `raylib.dll` file to be located in the same directory as your executable, or in the PATH.
* On MacOS, if you used the `-rpath` option as specified above, you can run the executable as long as the appropriate `dylib` is located in the same directory as your executable. Alternatively, it can be located in `/usr/local/lib`. If you do not use the `-rpath` option, you can export the environment variable `DYLD_LIBRARY_PATH` to point at the path where your library resides and it will be loaded.
* On Linux, the same instructions as MacOS apply, except that if you want to use the environment variable it is `LD_LIBRARY_PATH`.

# Example Program
```D
import raylib;

void main()
{
    // call this before using raylib
    validateRaylibBinding();
    InitWindow(800, 600, "Hello, Raylib-D!");
    SetTargetFPS(60);
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

# Port of raylib examples

@D-a-n-i-l-o has been kind enough to port a large amount of the raylib examples from the C library to D (maybe all of them at this point!)

Please see his [repository](https://github.com/D-a-n-i-l-o/raylib-d_examples) for more information.

# BetterC support (Experimental)

[BetterC](https://dlang.org/spec/betterc.html) support has been added for the raylib-d binding. This should work just as well as the original binding, but be usable with the `betterC` compilation option. No specific configuration is necessary.

# Docs/Cheatsheet

At the moment, we do not properly ddoc the binding. This may change in the near future. However, all documentation is valid from the raylib [online cheatsheet](https://www.raylib.com/cheatsheet/cheatsheet.html), or you can view the binding source files directly.

# License
raylib-d is licensed under an unmodified zlib/libpng license. View [LICENSE](LICENSE).

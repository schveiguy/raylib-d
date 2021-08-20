![](raylib_logo.png)

# raylib-d [![DUB](https://img.shields.io/dub/v/raylib-d?style=for-the-badge)](https://code.dlang.org/packages/raylib-d)
(static) D bindings for [raylib](https://www.raylib.com/), a simple and easy-to-use library to learn videogames programming.

*Note: this is a resurrected copy of the original raylib-d. The original author, onroundit (Petro Romanovych) deleted his github acccount. Therefore, many things in here are broken, and some of the history is lost for good. I will accpet any PRs that fix broken links or replace original data, but the code history itself is intact.*

# Installation
`dub add raylib-d`

## First, get a copy of Raylib
You can get the library by compiling it from the [source](https://github.com/raysan5/raylib), download the [official precompiled binaries](https://github.com/raysan5/raylib/releases). The local copies of binaries are no longer available, as that history was lost.

Note: version 3.7.0 of raylib (the latest as of this writing) is supported by raylib-d version 3.1.x. Version 3.0.0 of raylib is supported in version 3.0.x of raylib-d. _These releases are binary incompatible but may link with each other_. If you use the wrong raylib binary with raylib-d, bad things (including memory corruption) may happen due to struct layout differences! Any suggestions on how to identify these problems during compilation are most welcome!

## In order to link against raylib, add it to your dub.json.
```json
"libs": [ "raylib" ]
```
(*Note: this is missing, but may be available from wayback machine*)

For more information look into the [wiki](https://github.com/onroundit/raylib-d/wiki/Installation).

# Example
```D
import raylib;

void main()
{
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

*Note: this is missing, but may be available from wayback machine*

# [Docs / cheatsheet](https://github.com/onroundit/raylib-d/wiki/Docs-(cheatsheet))

# License
raylib-d is licensed under an unmodified zlib/libpng license. View [LICENSE](LICENSE).

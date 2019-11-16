![](raylib_logo.png)
# raylib-d ![DUB](https://img.shields.io/dub/v/raylib-d?style=for-the-badge)
(static) D bindings for [raylib](https://www.raylib.com/), a simple and easy-to-use library to learn videogames programming.
# Installation
`dub add raylib-d`
## First, get a copy of Raylib
you can get the library by compiling it from the [source](https://github.com/raysan5/raylib), download the [official precompiled binaries](https://github.com/raysan5/raylib/releases) or [download them from our repository](https://github.com/onroundit/raylib-d/releases) (originally taken from official releases, sorted in folders for each system).
## In order to link against raylib, add it to your dub.json.
```json
"libs": [ "raylib" ]
```
# Sample
```D
import raylib;

void main()
{
	InitWindow(800, 600, "Hello, Raylib-D!");
	while (!WindowShouldClose())
	{
		BeginDrawing();
		ClearBackground(RAYWHITE);
		DrawText(BLACK);
		EndDrawing();
	}
	CloseWindow();
}
```
# [Docs / cheatsheet](https://github.com/onroundit/raylib-d/wiki/Docs-(cheatsheet))
# License
raylib-d is licensed under an unmodified zlib/libpng license. View [LICENSE](LICENSE).

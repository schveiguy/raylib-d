import std.stdio;

import raylib;

void main()
{
	writeln("Starting a raylib example.");

  SetTargetFPS(60);
  InitWindow(800, 640, "Hello, World!");
  scope(exit) CloseWindow(); // see https://dlang.org/spec/statement.html#scope-guard-statement

  while (!WindowShouldClose())
  {
    BeginDrawing();
    scope(exit) EndDrawing();

    ClearBackground(RAYWHITE);
    DrawText("Hello, World!", 330, 300, 28, BLACK);
  }

	writeln("Ending a raylib example.");
}

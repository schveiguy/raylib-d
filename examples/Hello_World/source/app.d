import std.stdio;
import raylib;

void main()
{
  writeln("Starting a raylib example.");
  validateRaylibBinding();

  InitWindow(800, 640, "Hello, World!");
  SetTargetFPS(60);
  scope (exit)
    CloseWindow(); // see https://dlang.org/spec/statement.html#scope-guard-statement

  while (!WindowShouldClose())
  {
    BeginDrawing();
    scope (exit)
      EndDrawing();

    ClearBackground(Colors.RAYWHITE);
    DrawText("Hello, World!", 330, 300, 28, Colors.BLACK);
  }

  writeln("Ending a raylib example.");
}

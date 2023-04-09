/*******************************************************************************************
*
*   raylib [shapes] example - Colors palette
*
*   Example originally created with raylib 1.0, last time updated with raylib 2.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2014-2023 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;
import std.string : toStringz;

const int MAX_COLORS_COUNT = 21;          // Number of colors available

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - colors palette");

    Color[MAX_COLORS_COUNT] colors = [
        Colors.DARKGRAY, Colors.MAROON,     Colors.ORANGE,    Colors.DARKGREEN,
        Colors.DARKBLUE, Colors.DARKPURPLE, Colors.DARKBROWN, Colors.GRAY,
        Colors.RED,      Colors.GOLD,       Colors.LIME,      Colors.BLUE,
        Colors.VIOLET,   Colors.BROWN,      Colors.LIGHTGRAY, Colors.PINK,
        Colors.YELLOW,   Colors.GREEN,      Colors.SKYBLUE,   Colors.PURPLE,
        Colors.BEIGE
    ];

    string[MAX_COLORS_COUNT] colorNames = [
        "DARKGRAY",  "MAROON",     "ORANGE",    "DARKGREEN",
        "DARKBLUE",  "DARKPURPLE", "DARKBROWN", "GRAY",
        "RED",       "GOLD",       "LIME",      "BLUE",
        "VIOLET",    "BROWN",      "LIGHTGRAY", "PINK",
        "YELLOW",    "GREEN",      "SKYBLUE",   "PURPLE",
        "BEIGE"
    ];

    Rectangle[MAX_COLORS_COUNT] colorsRecs;     // Rectangles array

    // Fills colorsRecs data (for every rectangle)
    for (int i = 0; i < MAX_COLORS_COUNT; i++)
    {
        colorsRecs[i].x = 20.0f + 100.0f *(i%7) + 10.0f *(i%7);
        colorsRecs[i].y = 80.0f + 100.0f *(i/7) + 10.0f *(i/7);
        colorsRecs[i].width = 100.0f;
        colorsRecs[i].height = 100.0f;
    }

    int[MAX_COLORS_COUNT] colorState;           // Color state: 0-DEFAULT, 1-MOUSE_HOVER

    Vector2 mousePoint = { 0.0f, 0.0f };

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        mousePoint = GetMousePosition();

        for (int i = 0; i < MAX_COLORS_COUNT; i++)
        {
            if (CheckCollisionPointRec(mousePoint, colorsRecs[i])) colorState[i] = 1;
            else colorState[i] = 0;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            DrawText("raylib colors palette", 28, 42, 20, Colors.BLACK);
            DrawText("press SPACE to see all colors", GetScreenWidth() - 180, GetScreenHeight() - 40, 10, Colors.GRAY);

            for (int i = 0; i < MAX_COLORS_COUNT; i++)    // Draw all rectangles
            {
                DrawRectangleRec(colorsRecs[i], Fade(colors[i], colorState[i]? 0.6f : 1.0f));

                if (IsKeyDown(KeyboardKey.KEY_SPACE) || colorState[i])
                {
                    DrawRectangle(
                        cast(int)colorsRecs[i].x,
                        cast(int)(colorsRecs[i].y + colorsRecs[i].height - 26),
                        cast(int)colorsRecs[i].width, 20,
                        Colors.BLACK
                    );
                    DrawRectangleLinesEx(colorsRecs[i], 6, Fade(Colors.BLACK, 0.3f));
                    DrawText(
                        colorNames[i].toStringz,
                        cast(int)(colorsRecs[i].x + colorsRecs[i].width - MeasureText(colorNames[i].toStringz, 10) - 12),
                        cast(int)(colorsRecs[i].y + colorsRecs[i].height - 20),
                        10,
                        colors[i]
                    );
                }
            }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();                // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

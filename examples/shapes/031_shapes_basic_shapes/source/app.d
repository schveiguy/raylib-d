/*******************************************************************************************
*
*   raylib [shapes] example - Draw basic shapes 2d (rectangle, circle, line...)
*
*   Example originally created with raylib 1.0, last time updated with raylib 4.2
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2014-2023 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - basic shapes drawing");

    float rotation = 0.0f;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        rotation += 0.2f;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            DrawText("some basic shapes available on raylib", 20, 20, 20, Colors.DARKGRAY);

            // Circle shapes and lines
            DrawCircle(screenWidth/5, 120, 35, Colors.DARKBLUE);
            DrawCircleGradient(screenWidth/5, 220, 60, Colors.GREEN, Colors.SKYBLUE);
            DrawCircleLines(screenWidth/5, 340, 80, Colors.DARKBLUE);

            // Rectangle shapes and lines
            DrawRectangle(screenWidth/4*2 - 60, 100, 120, 60, Colors.RED);
            DrawRectangleGradientH(screenWidth/4*2 - 90, 170, 180, 130, Colors.MAROON, Colors.GOLD);
            DrawRectangleLines(screenWidth/4*2 - 40, 320, 80, 60, Colors.ORANGE);  // NOTE: Uses QUADS internally, not lines

            // Triangle shapes and lines
            DrawTriangle(Vector2( screenWidth/4.0f *3.0f, 80.0f ),
                         Vector2( screenWidth/4.0f *3.0f - 60.0f, 150.0f ),
                         Vector2( screenWidth/4.0f *3.0f + 60.0f, 150.0f ), Colors.VIOLET);

            DrawTriangleLines(Vector2( screenWidth/4.0f*3.0f, 160.0f ),
                              Vector2( screenWidth/4.0f*3.0f - 20.0f, 230.0f ),
                              Vector2( screenWidth/4.0f*3.0f + 20.0f, 230.0f ), Colors.DARKBLUE);

            // Polygon shapes and lines
            DrawPoly(Vector2( screenWidth/4.0f*3, 330 ), 6, 80, rotation, Colors.BROWN);
            DrawPolyLines(Vector2( screenWidth/4.0f*3, 330 ), 6, 90, rotation, Colors.BROWN);
            DrawPolyLinesEx(Vector2( screenWidth/4.0f*3, 330 ), 6, 85, rotation, 6, Colors.BEIGE);

            // NOTE: We draw all LINES based shapes together to optimize internal drawing,
            // this way, all LINES are rendered in a single draw pass
            DrawLine(18, 42, screenWidth - 18, 42, Colors.BLACK);
        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

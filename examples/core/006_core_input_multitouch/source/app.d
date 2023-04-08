/*******************************************************************************************
*
*   raylib [core] example - Input multitouch
*
*   Example originally created with raylib 2.1, last time updated with raylib 2.5
*
*   Example contributed by Berni (@Berni8k) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2023 Berni (@Berni8k) and Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;

const int MAX_TOUCH_POINTS = 10;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - input multitouch");

    Vector2[MAX_TOUCH_POINTS] touchPositions = { 0 };

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //---------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Get the touch point count ( how many fingers are touching the screen )
        int tCount = GetTouchPointCount();
        // Clamp touch points available ( set the maximum touch points allowed )
        if(tCount > MAX_TOUCH_POINTS) tCount = MAX_TOUCH_POINTS;
        // Get touch points positions
        for (int i = 0; i < tCount; ++i) touchPositions[i] = GetTouchPosition(i);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            for (int i = 0; i < tCount; ++i)
            {
                // Make sure point is not (0, 0) as this means there is no touch for it
                if ((touchPositions[i].x > 0) && (touchPositions[i].y > 0))
                {
                    // Draw circle and touch index number
                    DrawCircleV(touchPositions[i], 34, Colors.ORANGE);
                    DrawText(TextFormat("%d", i), cast(int)touchPositions[i].x - 10, cast(int)touchPositions[i].y - 70, 40, Colors.BLACK);
                }
            }

            DrawText("touch the screen at multiple locations to get multiple balls", 10, 10, 20, Colors.DARKGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

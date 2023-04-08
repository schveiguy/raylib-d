/*******************************************************************************************
*
*   raylib [core] example - window flags
*
*   Example originally created with raylib 3.5, last time updated with raylib 3.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2020-2023 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //---------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    // Possible window flags
    /*
    FLAG_VSYNC_HINT
    FLAG_FULLSCREEN_MODE    -> not working properly -> wrong scaling!
    FLAG_WINDOW_RESIZABLE
    FLAG_WINDOW_UNDECORATED
    FLAG_WINDOW_TRANSPARENT
    FLAG_WINDOW_HIDDEN
    FLAG_WINDOW_MINIMIZED   -> Not supported on window creation
    FLAG_WINDOW_MAXIMIZED   -> Not supported on window creation
    FLAG_WINDOW_UNFOCUSED
    FLAG_WINDOW_TOPMOST
    FLAG_WINDOW_HIGHDPI     -> errors after minimize-resize, fb size is recalculated
    FLAG_WINDOW_ALWAYS_RUN
    FLAG_MSAA_4X_HINT
    */

    // Set configuration flags for window creation
    SetConfigFlags(
        ConfigFlags.FLAG_VSYNC_HINT |
        ConfigFlags.FLAG_MSAA_4X_HINT |
        ConfigFlags.FLAG_WINDOW_HIGHDPI
    );

    InitWindow(screenWidth, screenHeight, "raylib [core] example - window flags");

    Vector2 ballPosition = { GetScreenWidth() / 2.0f, GetScreenHeight() / 2.0f };
    Vector2 ballSpeed = { 5.0f, 4.0f };
    float ballRadius = 20;

    int framesCounter = 0;

    //SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //----------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //-----------------------------------------------------
        if (IsKeyPressed(KeyboardKey.KEY_F)) ToggleFullscreen();  // modifies window size when scaling!

        if (IsKeyPressed(KeyboardKey.KEY_R))
        {
            if (IsWindowState(ConfigFlags.FLAG_WINDOW_RESIZABLE)) ClearWindowState(ConfigFlags.FLAG_WINDOW_RESIZABLE);
            else SetWindowState(ConfigFlags.FLAG_WINDOW_RESIZABLE);
        }

        if (IsKeyPressed(KeyboardKey.KEY_D))
        {
            if (IsWindowState(ConfigFlags.FLAG_WINDOW_UNDECORATED)) ClearWindowState(ConfigFlags.FLAG_WINDOW_UNDECORATED);
            else SetWindowState(ConfigFlags.FLAG_WINDOW_UNDECORATED);
        }

        if (IsKeyPressed(KeyboardKey.KEY_H))
        {
            if (!IsWindowState(ConfigFlags.FLAG_WINDOW_HIDDEN)) SetWindowState(ConfigFlags.FLAG_WINDOW_HIDDEN);

            framesCounter = 0;
        }

        if (IsWindowState(ConfigFlags.FLAG_WINDOW_HIDDEN))
        {
            framesCounter++;
            if (framesCounter >= 240) ClearWindowState(ConfigFlags.FLAG_WINDOW_HIDDEN); // Show window after 3 seconds
        }

        if (IsKeyPressed(KeyboardKey.KEY_N))
        {
            if (!IsWindowState(ConfigFlags.FLAG_WINDOW_MINIMIZED)) MinimizeWindow();

            framesCounter = 0;
        }

        if (IsWindowState(ConfigFlags.FLAG_WINDOW_MINIMIZED))
        {
            framesCounter++;
            if (framesCounter >= 240) RestoreWindow(); // Restore window after 3 seconds
        }

        if (IsKeyPressed(KeyboardKey.KEY_M))
        {
            // NOTE: Requires FLAG_WINDOW_RESIZABLE enabled!
            if (IsWindowState(ConfigFlags.FLAG_WINDOW_MAXIMIZED)) RestoreWindow();
            else MaximizeWindow();
        }

        if (IsKeyPressed(KeyboardKey.KEY_U))
        {
            if (IsWindowState(ConfigFlags.FLAG_WINDOW_UNFOCUSED)) ClearWindowState(ConfigFlags.FLAG_WINDOW_UNFOCUSED);
            else SetWindowState(ConfigFlags.FLAG_WINDOW_UNFOCUSED);
        }

        if (IsKeyPressed(KeyboardKey.KEY_T))
        {
            if (IsWindowState(ConfigFlags.FLAG_WINDOW_TOPMOST)) ClearWindowState(ConfigFlags.FLAG_WINDOW_TOPMOST);
            else SetWindowState(ConfigFlags.FLAG_WINDOW_TOPMOST);
        }

        if (IsKeyPressed(KeyboardKey.KEY_A))
        {
            if (IsWindowState(ConfigFlags.FLAG_WINDOW_ALWAYS_RUN)) ClearWindowState(ConfigFlags.FLAG_WINDOW_ALWAYS_RUN);
            else SetWindowState(ConfigFlags.FLAG_WINDOW_ALWAYS_RUN);
        }

        if (IsKeyPressed(KeyboardKey.KEY_V))
        {
            if (IsWindowState(ConfigFlags.FLAG_VSYNC_HINT)) ClearWindowState(ConfigFlags.FLAG_VSYNC_HINT);
            else SetWindowState(ConfigFlags.FLAG_VSYNC_HINT);
        }

        // Bouncing ball logic
        ballPosition.x += ballSpeed.x;
        ballPosition.y += ballSpeed.y;
        if ((ballPosition.x >= (GetScreenWidth() - ballRadius)) || (ballPosition.x <= ballRadius)) ballSpeed.x *= -1.0f;
        if ((ballPosition.y >= (GetScreenHeight() - ballRadius)) || (ballPosition.y <= ballRadius)) ballSpeed.y *= -1.0f;
        //-----------------------------------------------------

        // Draw
        //-----------------------------------------------------
        BeginDrawing();

        if (IsWindowState(ConfigFlags.FLAG_WINDOW_TRANSPARENT)) ClearBackground(Colors.BLANK);
        else ClearBackground(Colors.RAYWHITE);

        DrawCircleV(ballPosition, ballRadius, Colors.MAROON);
        DrawRectangleLinesEx(Rectangle(0, 0, cast(float)GetScreenWidth(), cast(float)GetScreenHeight() ), 4, Colors.RAYWHITE);

        DrawCircleV(GetMousePosition(), 10, Colors.DARKBLUE);

        DrawFPS(10, 10);

        DrawText(TextFormat("Screen Size: [%i, %i]", GetScreenWidth(), GetScreenHeight()), 10, 40, 10, Colors.GREEN);

        // Draw window state info
        DrawText("Following flags can be set after window creation:", 10, 60, 10, Colors.GRAY);
        if (IsWindowState(ConfigFlags.FLAG_FULLSCREEN_MODE)) DrawText("[F] FLAG_FULLSCREEN_MODE: on", 10, 80, 10, Colors.LIME);
        else DrawText("[F] FLAG_FULLSCREEN_MODE: off", 10, 80, 10, Colors.MAROON);
        if (IsWindowState(ConfigFlags.FLAG_WINDOW_RESIZABLE)) DrawText("[R] FLAG_WINDOW_RESIZABLE: on", 10, 100, 10, Colors.LIME);
        else DrawText("[R] FLAG_WINDOW_RESIZABLE: off", 10, 100, 10, Colors.MAROON);
        if (IsWindowState(ConfigFlags.FLAG_WINDOW_UNDECORATED)) DrawText("[D] FLAG_WINDOW_UNDECORATED: on", 10, 120, 10, Colors.LIME);
        else DrawText("[D] FLAG_WINDOW_UNDECORATED: off", 10, 120, 10, Colors.MAROON);
        if (IsWindowState(ConfigFlags.FLAG_WINDOW_HIDDEN)) DrawText("[H] FLAG_WINDOW_HIDDEN: on", 10, 140, 10, Colors.LIME);
        else DrawText("[H] FLAG_WINDOW_HIDDEN: off", 10, 140, 10, Colors.MAROON);
        if (IsWindowState(ConfigFlags.FLAG_WINDOW_MINIMIZED)) DrawText("[N] FLAG_WINDOW_MINIMIZED: on", 10, 160, 10, Colors.LIME);
        else DrawText("[N] FLAG_WINDOW_MINIMIZED: off", 10, 160, 10, Colors.MAROON);
        if (IsWindowState(ConfigFlags.FLAG_WINDOW_MAXIMIZED)) DrawText("[M] FLAG_WINDOW_MAXIMIZED: on", 10, 180, 10, Colors.LIME);
        else DrawText("[M] FLAG_WINDOW_MAXIMIZED: off", 10, 180, 10, Colors.MAROON);
        if (IsWindowState(ConfigFlags.FLAG_WINDOW_UNFOCUSED)) DrawText("[G] FLAG_WINDOW_UNFOCUSED: on", 10, 200, 10, Colors.LIME);
        else DrawText("[U] FLAG_WINDOW_UNFOCUSED: off", 10, 200, 10, Colors.MAROON);
        if (IsWindowState(ConfigFlags.FLAG_WINDOW_TOPMOST)) DrawText("[T] FLAG_WINDOW_TOPMOST: on", 10, 220, 10, Colors.LIME);
        else DrawText("[T] FLAG_WINDOW_TOPMOST: off", 10, 220, 10, Colors.MAROON);
        if (IsWindowState(ConfigFlags.FLAG_WINDOW_ALWAYS_RUN)) DrawText("[A] FLAG_WINDOW_ALWAYS_RUN: on", 10, 240, 10, Colors.LIME);
        else DrawText("[A] FLAG_WINDOW_ALWAYS_RUN: off", 10, 240, 10, Colors.MAROON);
        if (IsWindowState(ConfigFlags.FLAG_VSYNC_HINT)) DrawText("[V] FLAG_VSYNC_HINT: on", 10, 260, 10, Colors.LIME);
        else DrawText("[V] FLAG_VSYNC_HINT: off", 10, 260, 10, Colors.MAROON);

        DrawText("Following flags can only be set before window creation:", 10, 300, 10, Colors.GRAY);
        if (IsWindowState(ConfigFlags.FLAG_WINDOW_HIGHDPI)) DrawText("FLAG_WINDOW_HIGHDPI: on", 10, 320, 10, Colors.LIME);
        else DrawText("FLAG_WINDOW_HIGHDPI: off", 10, 320, 10, Colors.MAROON);
        if (IsWindowState(ConfigFlags.FLAG_WINDOW_TRANSPARENT)) DrawText("FLAG_WINDOW_TRANSPARENT: on", 10, 340, 10, Colors.LIME);
        else DrawText("FLAG_WINDOW_TRANSPARENT: off", 10, 340, 10, Colors.MAROON);
        if (IsWindowState(ConfigFlags.FLAG_MSAA_4X_HINT)) DrawText("FLAG_MSAA_4X_HINT: on", 10, 360, 10, Colors.LIME);
        else DrawText("FLAG_MSAA_4X_HINT: off", 10, 360, 10, Colors.MAROON);

        EndDrawing();
        //-----------------------------------------------------
    }

    // De-Initialization
    //---------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //----------------------------------------------------------
}

/*******************************************************************************************
*
*   raylib [core] example - Scissor test
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.0
*
*   Example contributed by Chris Dill (@MysteriousSpace) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2023 Chris Dill (@MysteriousSpace)
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

    InitWindow(screenWidth, screenHeight, "raylib [core] example - scissor test");

    Rectangle scissorArea = { 0, 0, 300, 300 };
    bool scissorMode = true;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(KeyboardKey.KEY_S)) scissorMode = !scissorMode;

        // Centre the scissor area around the mouse position
        scissorArea.x = GetMouseX() - scissorArea.width/2;
        scissorArea.y = GetMouseY() - scissorArea.height/2;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            if (scissorMode) {
                BeginScissorMode(
                    cast(int)scissorArea.x,
                    cast(int)scissorArea.y,
                    cast(int)scissorArea.width,
                    cast(int)scissorArea.height
                );
            }

            // Draw full screen rectangle and some text
            // NOTE: Only part defined by scissor area will be rendered
            DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), Colors.RED);
            DrawText("Move the mouse around to reveal this text!", 190, 200, 20, Colors.LIGHTGRAY);

            if (scissorMode) {
                EndScissorMode();
            }

            DrawRectangleLinesEx(scissorArea, 1, Colors.BLACK);
            DrawText("Press S to toggle scissor test", 10, 10, 20, Colors.BLACK);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

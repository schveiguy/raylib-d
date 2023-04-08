/*******************************************************************************************
*
*   raylib [core] example - World to screen
*
*   Example originally created with raylib 1.3, last time updated with raylib 1.4
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2015-2023 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;
import std.string : toStringz;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - core world screen");

    // Define the camera to look into our 3d world
    Camera camera;
    camera.position = Vector3( 10.0f, 10.0f, 10.0f );        // Camera position
    camera.target = Vector3( 0.0f, 0.0f, 0.0f );             // Camera looking at point
    camera.up = Vector3( 0.0f, 1.0f, 0.0f );                 // Camera up vector (rotation towards target)
    camera.fovy = 45.0f;                                     // Camera field-of-view Y
    camera.projection = CameraProjection.CAMERA_PERSPECTIVE; // Camera projection type

    Vector3 cubePosition = { 0.0f, 0.0f, 0.0f };
    Vector2 cubeScreenPosition = { 0.0f, 0.0f };

    DisableCursor();                    // Limit cursor to relative movement inside the window

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(&camera, CameraMode.CAMERA_THIRD_PERSON);

        // Calculate cube screen space position (with a little offset to be in top)
        cubeScreenPosition = GetWorldToScreen(Vector3(cubePosition.x, cubePosition.y + 2.5f, cubePosition.z), camera);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            BeginMode3D(camera);

                DrawCube(cubePosition, 2.0f, 2.0f, 2.0f, Colors.RED);
                DrawCubeWires(cubePosition, 2.0f, 2.0f, 2.0f, Colors.MAROON);

                DrawGrid(10, 1.0f);

            EndMode3D();

            DrawText("Enemy: 100 / 100".toStringz, cast(int)cubeScreenPosition.x - MeasureText("Enemy: 100/100".toStringz, 20)/2, cast(int)cubeScreenPosition.y, 20, Colors.BLACK);

            DrawText(TextFormat("Cube position in screen space coordinates: [%i, %i]".toStringz, cast(int)cubeScreenPosition.x, cast(int)cubeScreenPosition.y), 10, 10, 20, Colors.LIME);
            DrawText("Text 2d should be always on top of the cube".toStringz, 10, 40, 20, Colors.GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

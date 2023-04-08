/*******************************************************************************************
*
*   raylib [core] example - smooth pixel-perfect camera
*
*   Example originally created with raylib 3.7, last time updated with raylib 4.0
*
*   Example contributed by Giancamillo Alessandroni (@NotManyIdeasDev) and
*   reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2021-2023 Giancamillo Alessandroni (@NotManyIdeasDev) and Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;
import std.math;       // Required for: sinf(), cosf()
//import core.stdc.math;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    const int virtualScreenWidth = 160;
    const int virtualScreenHeight = 90;

    const float virtualRatio = cast(float)screenWidth/cast(float)virtualScreenWidth;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - smooth pixel-perfect camera");

    Camera2D worldSpaceCamera = { Vector2(0), Vector2(0) };  // Game world camera
    worldSpaceCamera.rotation = 0.0f;
    worldSpaceCamera.zoom = 1.0f;

    Camera2D screenSpaceCamera = { Vector2(0), Vector2(0) }; // Smoothing camera
    screenSpaceCamera.rotation = 0.0f;
    screenSpaceCamera.zoom = 1.0f;

    RenderTexture2D target = LoadRenderTexture(virtualScreenWidth, virtualScreenHeight); // This is where we'll draw all our objects.

    Rectangle rec01 = { 70.0f, 35.0f, 20.0f, 20.0f };
    Rectangle rec02 = { 90.0f, 55.0f, 30.0f, 10.0f };
    Rectangle rec03 = { 80.0f, 65.0f, 15.0f, 25.0f };

    // The target's height is flipped (in the source Rectangle), due to OpenGL reasons
    Rectangle sourceRec = { 0.0f, 0.0f, cast(float)target.texture.width, -cast(float)target.texture.height };
    Rectangle destRec = { -virtualRatio, -virtualRatio, screenWidth + (virtualRatio*2), screenHeight + (virtualRatio*2) };

    Vector2 origin = { 0.0f, 0.0f };

    float rotation = 0.0f;

    float cameraX = 0.0f;
    float cameraY = 0.0f;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        rotation += 60.0f*GetFrameTime();   // Rotate the rectangles, 60 degrees per second

        // Make the camera move to demonstrate the effect
        cameraX = (sin(GetTime())*50.0f) - 10.0f;
        cameraY = cos(GetTime())*30.0f;

        // Set the camera's target to the values computed above
        screenSpaceCamera.target = Vector2( cameraX, cameraY );

        // Round worldSpace coordinates, keep decimals into screenSpace coordinates
        worldSpaceCamera.target.x = cast(int)screenSpaceCamera.target.x;
        screenSpaceCamera.target.x -= worldSpaceCamera.target.x;
        screenSpaceCamera.target.x *= virtualRatio;

        worldSpaceCamera.target.y = cast(int)screenSpaceCamera.target.y;
        screenSpaceCamera.target.y -= worldSpaceCamera.target.y;
        screenSpaceCamera.target.y *= virtualRatio;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginTextureMode(target);
            ClearBackground(Colors.RAYWHITE);

            BeginMode2D(worldSpaceCamera);
                DrawRectanglePro(rec01, origin, rotation, Colors.BLACK);
                DrawRectanglePro(rec02, origin, -rotation, Colors.RED);
                DrawRectanglePro(rec03, origin, rotation + 45.0f, Colors.BLUE);
            EndMode2D();
        EndTextureMode();

        BeginDrawing();
            ClearBackground(Colors.RED);

            BeginMode2D(screenSpaceCamera);
                DrawTexturePro(target.texture, sourceRec, destRec, origin, 0.0f, Colors.WHITE);
            EndMode2D();

            DrawText(TextFormat("Screen resolution: %ix%i", screenWidth, screenHeight), 10, 10, 20, Colors.DARKBLUE);
            DrawText(TextFormat("World resolution: %ix%i", virtualScreenWidth, virtualScreenHeight), 10, 40, 20, Colors.DARKGREEN);
            DrawFPS(GetScreenWidth() - 95, 10);
        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadRenderTexture(target);    // Unload render texture

    CloseWindow();                  // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

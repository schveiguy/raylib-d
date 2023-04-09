/*******************************************************************************************
*
*   raylib [shapes] example - draw ring (with gui options)
*
*   Example originally created with raylib 2.5, last time updated with raylib 2.5
*
*   Example contributed by Vlad Adrian (@demizdor) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2018-2023 Vlad Adrian (@demizdor) and Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;
import raygui;                 // Required for GUI controls

import core.stdc.math : ceilf;
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

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - draw ring");

    Vector2 center = {(GetScreenWidth() - 300)/2.0f, GetScreenHeight()/2.0f };

    float innerRadius = 80.0f;
    float outerRadius = 190.0f;

    float startAngle = 0.0f;
    float endAngle = 360.0f;
    int segments = 0;

    bool drawRing = true;
    bool drawRingLines = false;
    bool drawCircleLines = false;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // NOTE: All variables update happens inside GUI control functions
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            DrawLine(500, 0, 500, GetScreenHeight(), Fade(Colors.LIGHTGRAY, 0.6f));
            DrawRectangle(500, 0, GetScreenWidth() - 500, GetScreenHeight(), Fade(Colors.LIGHTGRAY, 0.3f));

            if (drawRing) DrawRing(center, innerRadius, outerRadius, startAngle, endAngle, segments, Fade(Colors.MAROON, 0.3f));
            if (drawRingLines) DrawRingLines(center, innerRadius, outerRadius, startAngle, endAngle, segments, Fade(Colors.BLACK, 0.4f));
            if (drawCircleLines) DrawCircleSectorLines(center, outerRadius, startAngle, endAngle, segments, Fade(Colors.BLACK, 0.4f));

            // Draw GUI controls
            //------------------------------------------------------------------------------
            startAngle = GuiSliderBar(Rectangle( 600, 40, 120, 20 ), "StartAngle", null, startAngle, -450, 450);
            endAngle = GuiSliderBar(Rectangle( 600, 70, 120, 20 ), "EndAngle", null, endAngle, -450, 450);

            innerRadius = GuiSliderBar(Rectangle( 600, 140, 120, 20 ), "InnerRadius", null, innerRadius, 0, 100);
            outerRadius = GuiSliderBar(Rectangle( 600, 170, 120, 20 ), "OuterRadius", null, outerRadius, 0, 200);

            segments = cast(int)GuiSliderBar(Rectangle( 600, 240, 120, 20 ), "Segments", null, cast(float)segments, 0, 100);

            drawRing = GuiCheckBox(Rectangle( 600, 320, 20, 20 ), "Draw Ring", drawRing);
            drawRingLines = GuiCheckBox(Rectangle( 600, 350, 20, 20 ), "Draw RingLines", drawRingLines);
            drawCircleLines = GuiCheckBox(Rectangle( 600, 380, 20, 20 ), "Draw CircleLines", drawCircleLines);
            //------------------------------------------------------------------------------

            int minSegments = cast(int)ceilf((endAngle - startAngle)/90);
            DrawText(
                TextFormat("MODE: %s", (segments >= minSegments) ? "MANUAL".toStringz : "AUTO".toStringz),
                600,
                270,
                10,
                (segments >= minSegments)
                    ? Colors.MAROON
                    : Colors.DARKGRAY
            );

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

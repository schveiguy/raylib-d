/*******************************************************************************************
*
*   raylib [core] example - Custom logging
*
*   Example originally created with raylib 2.5, last time updated with raylib 2.5
*
*   Example contributed by Pablo Marcos Oltra (@pamarcos) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2018-2023 Pablo Marcos Oltra (@pamarcos) and Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;

import core.stdc.stdarg : va_list;
import core.stdc.stdio : printf, vprintf;

// Custom logging function
extern (C) void CustomLog(int msgType, const char *text, va_list args) @nogc nothrow
{
    switch (msgType)
    {
        case TraceLogLevel.LOG_INFO:    printf(">>> raylib-d [INFO] : "); break;
        case TraceLogLevel.LOG_ERROR:   printf(">>> raylib-d [ERROR]: "); break;
        case TraceLogLevel.LOG_WARNING: printf(">>> raylib-d [WARN] : "); break;
        case TraceLogLevel.LOG_DEBUG:   printf(">>> raylib-d [DEBUG]: "); break;
        default: break;
    }

    vprintf(text, args);
    printf("\n");
}

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    // Set custom logger
    SetTraceLogCallback(&CustomLog);

    InitWindow(screenWidth, screenHeight, "raylib [core] example - custom logging");

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

        ClearBackground(Colors.RAYWHITE);

        DrawText("Check out the console output to see the custom logger in action!", 60, 200, 20, Colors.LIGHTGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

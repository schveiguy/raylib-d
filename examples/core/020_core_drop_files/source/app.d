/*******************************************************************************************
*
*   raylib [core] example - Windows drop files
*
*   NOTE: This example only works on platforms that support drag & drop (Windows, Linux, OSX, Html5?)
*
*   Example originally created with raylib 1.3, last time updated with raylib 4.2
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2015-2023 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;
import std.container : DList;
import std.range : walkLength;
import std.string : toStringz, fromStringz;
import std.conv;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - drop files");

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    DList!string filePaths;

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsFileDropped())
        {
            filePaths.clear;
            FilePathList droppedFiles = LoadDroppedFiles();

            for (int i = 0; i < droppedFiles.count; i++)
            {
                string file_name = droppedFiles.paths[i].to!string;
                filePaths.insertBack(file_name);
            }

            UnloadDroppedFiles(droppedFiles);    // Unload filepaths from memory
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            if (filePaths[].walkLength == 0) DrawText("Drop your files to this window!", 100, 40, 20, Colors.DARKGRAY);
            else
            {
                DrawText("Dropped files:", 100, 40, 20, Colors.DARKGRAY);

                uint i = 0;
                foreach (path; filePaths)
                {
                    if (i%2 == 0) DrawRectangle(0, 85 + 40*i, screenWidth, 40, Fade(Colors.LIGHTGRAY, 0.5f));
                    else DrawRectangle(0, 85 + 40*i, screenWidth, 40, Fade(Colors.LIGHTGRAY, 0.3f));

                    DrawText(path.toStringz, 120, 100 + 40*i, 10, Colors.GRAY);
                    i++;
                }

                DrawText("Drop new files...", 100, cast(int)(110 + 40*filePaths[].walkLength), 20, Colors.DARKGRAY);
            }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

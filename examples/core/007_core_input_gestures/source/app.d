/*******************************************************************************************
*
*   raylib [core] example - Input Gestures Detection
*
*   Example originally created with raylib 1.4, last time updated with raylib 4.2
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2016-2023 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;
import std.container : DList;
import std.range : walkLength;
import std.string : toStringz;

const int MAX_GESTURE_STRINGS = 20;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - input gestures");

    Vector2 touchPosition = { 0, 0 };
    Rectangle touchArea = { 220, 10, screenWidth - 230.0f, screenHeight - 20.0f };

    DList!string gestureStrings;

    int currentGesture = Gesture.GESTURE_NONE;
    int lastGesture = Gesture.GESTURE_NONE;

    //SetGesturesEnabled(0b0000000000001001);   // Enable only some gestures to be detected

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        lastGesture = currentGesture;
        currentGesture = GetGestureDetected();
        touchPosition = GetTouchPosition(0);

        if (CheckCollisionPointRec(touchPosition, touchArea) && (currentGesture != Gesture.GESTURE_NONE))
        {
            if (currentGesture != lastGesture)
            {
                // Store gesture string
                switch (currentGesture)
                {
                    case Gesture.GESTURE_TAP: gestureStrings.insertBack("GESTURE TAP"); break;
                    case Gesture.GESTURE_DOUBLETAP: gestureStrings.insertBack("GESTURE DOUBLETAP"); break;
                    case Gesture.GESTURE_HOLD: gestureStrings.insertBack("GESTURE HOLD"); break;
                    case Gesture.GESTURE_DRAG: gestureStrings.insertBack("GESTURE DRAG"); break;
                    case Gesture.GESTURE_SWIPE_RIGHT: gestureStrings.insertBack("GESTURE SWIPE RIGHT"); break;
                    case Gesture.GESTURE_SWIPE_LEFT: gestureStrings.insertBack("GESTURE SWIPE LEFT"); break;
                    case Gesture.GESTURE_SWIPE_UP: gestureStrings.insertBack("GESTURE SWIPE UP"); break;
                    case Gesture.GESTURE_SWIPE_DOWN: gestureStrings.insertBack("GESTURE SWIPE DOWN"); break;
                    case Gesture.GESTURE_PINCH_IN: gestureStrings.insertBack("GESTURE PINCH IN"); break;
                    case Gesture.GESTURE_PINCH_OUT: gestureStrings.insertBack("GESTURE PINCH OUT"); break;
                    default: break;
                }

                // Limit gestures strings length
                if (gestureStrings[].walkLength >= MAX_GESTURE_STRINGS)
                {
                    gestureStrings.removeFront();
                }
            }
        }

        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            DrawRectangleRec(touchArea, Colors.GRAY);
            DrawRectangle(225, 15, screenWidth - 240, screenHeight - 30, Colors.RAYWHITE);

            DrawText("GESTURES TEST AREA", screenWidth - 270, screenHeight - 40, 20, Fade(Colors.GRAY, 0.5f));

            int i = 0;
            foreach (string s; gestureStrings)
            {
                if (i%2 == 0) {
                    DrawRectangle(10, 30 + 20*i, 200, 20, Fade(Colors.LIGHTGRAY, 0.5f));
                }
                else {
                    DrawRectangle(10, 30 + 20*i, 200, 20, Fade(Colors.LIGHTGRAY, 0.3f));
                }

                if (i < gestureStrings[].walkLength - 1)
                {
                    DrawText(s.toStringz, 35, 36 + 20*i, 10, Colors.DARKGRAY);
                }
                else
                {
                    DrawText(s.toStringz, 35, 36 + 20*i, 10, Colors.MAROON);
                }
                i++;
            }

            DrawRectangleLines(10, 29, 200, screenHeight - 50, Colors.GRAY);
            DrawText("DETECTED GESTURES", 50, 15, 10, Colors.GRAY);

            if (currentGesture != Gesture.GESTURE_NONE) DrawCircleV(touchPosition, 30, Colors.MAROON);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

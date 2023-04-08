/*******************************************************************************************
*
*   raylib [core] example - Gamepad input
*
*   NOTE: This example requires a Gamepad connected to the system
*         raylib is configured to work with the following gamepads:
*                - Xbox 360 Controller (Xbox 360, Xbox One)
*                - PLAYSTATION(R)3 Controller
*         Check raylib.h for buttons configuration
*
*   Example originally created with raylib 1.1, last time updated with raylib 4.2
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2013-2023 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;

// NOTE: Gamepad name ID depends on drivers and OS
const char* XBOX360_LEGACY_NAME_ID = "Xbox Controller";
version(Raspberry)
{
    const char* XBOX360_NAME_ID = "Microsoft X-Box 360 pad";
    const char* PS3_NAME_ID     = "PLAYSTATION(R)3 Controller";
}
else
{
    const char* XBOX360_NAME_ID = "Xbox 360 Controller";
    const char* PS3_NAME_ID     = "PLAYSTATION(R)3 Controller";
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

    SetConfigFlags(ConfigFlags.FLAG_MSAA_4X_HINT);  // Set MSAA 4X hint before windows creation

    InitWindow(screenWidth, screenHeight, "raylib [core] example - gamepad input");

    Texture2D texPs3Pad = LoadTexture("resources/ps3.png");
    Texture2D texXboxPad = LoadTexture("resources/xbox.png");

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // ...
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            if (IsGamepadAvailable(0))
            {
                DrawText(TextFormat("GP1: %s", GetGamepadName(0)), 10, 10, 10, Colors.BLACK);

                if (TextIsEqual(GetGamepadName(0), XBOX360_NAME_ID) || TextIsEqual(GetGamepadName(0), XBOX360_LEGACY_NAME_ID))
                {
                    DrawTexture(texXboxPad, 0, 0, Colors.DARKGRAY);

                    // Draw buttons: xbox home
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_MIDDLE)) DrawCircle(394, 89, 19, Colors.RED);

                    // Draw buttons: basic
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_MIDDLE_RIGHT)) DrawCircle(436, 150, 9, Colors.RED);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_MIDDLE_LEFT)) DrawCircle(352, 150, 9, Colors.RED);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_LEFT)) DrawCircle(501, 151, 15, Colors.BLUE);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) DrawCircle(536, 187, 15, Colors.LIME);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT)) DrawCircle(572, 151, 15, Colors.MAROON);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_UP)) DrawCircle(536, 115, 15, Colors.GOLD);

                    // Draw buttons: d-pad
                    DrawRectangle(317, 202, 19, 71, Colors.BLACK);
                    DrawRectangle(293, 228, 69, 19, Colors.BLACK);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP)) DrawRectangle(317, 202, 19, 26, Colors.RED);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN)) DrawRectangle(317, 202 + 45, 19, 26, Colors.RED);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT)) DrawRectangle(292, 228, 25, 19, Colors.RED);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT)) DrawRectangle(292 + 44, 228, 26, 19, Colors.RED);

                    // Draw buttons: left-right back
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_LEFT_TRIGGER_1)) DrawCircle(259, 61, 20, Colors.RED);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_TRIGGER_1)) DrawCircle(536, 61, 20, Colors.RED);

                    // Draw axis: left joystick
                    DrawCircle(259, 152, 39, Colors.BLACK);
                    DrawCircle(259, 152, 34, Colors.LIGHTGRAY);
                    DrawCircle(259 + cast(int)(GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_X)*20),
                               152 + cast(int)(GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_Y)*20), 25, Colors.BLACK);

                    // Draw axis: right joystick
                    DrawCircle(461, 237, 38, Colors.BLACK);
                    DrawCircle(461, 237, 33, Colors.LIGHTGRAY);
                    DrawCircle(461 + cast(int)(GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_X)*20),
                               237 + cast(int)(GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_Y)*20), 25, Colors.BLACK);

                    // Draw axis: left-right triggers
                    DrawRectangle(170, 30, 15, 70, Colors.GRAY);
                    DrawRectangle(604, 30, 15, 70, Colors.GRAY);
                    DrawRectangle(170, 30, 15, cast(int)(((1 + GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_TRIGGER))/2)*70), Colors.RED);
                    DrawRectangle(604, 30, 15, cast(int)(((1 + GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_TRIGGER))/2)*70), Colors.RED);

                    //DrawText(TextFormat("Xbox axis LT: %02.02f", GetGamepadAxisMovement(0, GamepadButton.GAMEPAD_AXIS_LEFT_TRIGGER)), 10, 40, 10, BLACK);
                    //DrawText(TextFormat("Xbox axis RT: %02.02f", GetGamepadAxisMovement(0, GamepadButton.GAMEPAD_AXIS_RIGHT_TRIGGER)), 10, 60, 10, BLACK);
                }
                else if (TextIsEqual(GetGamepadName(0), PS3_NAME_ID))
                {
                    DrawTexture(texPs3Pad, 0, 0, Colors.DARKGRAY);

                    // Draw buttons: ps
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_MIDDLE)) DrawCircle(396, 222, 13, Colors.RED);

                    // Draw buttons: basic
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_MIDDLE_LEFT)) DrawRectangle(328, 170, 32, 13, Colors.RED);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_MIDDLE_RIGHT)) DrawTriangle(Vector2( 436, 168 ), Vector2( 436, 185 ), Vector2( 464, 177 ), Colors.RED);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_UP)) DrawCircle(557, 144, 13, Colors.LIME);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT)) DrawCircle(586, 173, 13, Colors.RED);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) DrawCircle(557, 203, 13, Colors.VIOLET);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_FACE_LEFT)) DrawCircle(527, 173, 13, Colors.PINK);

                    // Draw buttons: d-pad
                    DrawRectangle(225, 132, 24, 84, Colors.BLACK);
                    DrawRectangle(195, 161, 84, 25, Colors.BLACK);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_UP)) DrawRectangle(225, 132, 24, 29, Colors.RED);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_DOWN)) DrawRectangle(225, 132 + 54, 24, 30, Colors.RED);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_LEFT)) DrawRectangle(195, 161, 30, 25, Colors.RED);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_LEFT_FACE_RIGHT)) DrawRectangle(195 + 54, 161, 30, 25, Colors.RED);

                    // Draw buttons: left-right back buttons
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_LEFT_TRIGGER_1)) DrawCircle(239, 82, 20, Colors.RED);
                    if (IsGamepadButtonDown(0, GamepadButton.GAMEPAD_BUTTON_RIGHT_TRIGGER_1)) DrawCircle(557, 82, 20, Colors.RED);

                    // Draw axis: left joystick
                    DrawCircle(319, 255, 35, Colors.BLACK);
                    DrawCircle(319, 255, 31, Colors.LIGHTGRAY);
                    DrawCircle(319 + cast(int)(GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_X) * 20),
                               255 + cast(int)(GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_Y) * 20), 25, Colors.BLACK);

                    // Draw axis: right joystick
                    DrawCircle(475, 255, 35, Colors.BLACK);
                    DrawCircle(475, 255, 31, Colors.LIGHTGRAY);
                    DrawCircle(475 + cast(int)(GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_X) * 20),
                               255 + cast(int)(GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_Y) * 20), 25, Colors.BLACK);

                    // Draw axis: left-right triggers
                    DrawRectangle(169, 48, 15, 70, Colors.GRAY);
                    DrawRectangle(611, 48, 15, 70, Colors.GRAY);
                    DrawRectangle(169, 48, 15, cast(int)(((1 - GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_LEFT_TRIGGER)) / 2) * 70), Colors.RED);
                    DrawRectangle(611, 48, 15, cast(int)(((1 - GetGamepadAxisMovement(0, GamepadAxis.GAMEPAD_AXIS_RIGHT_TRIGGER)) / 2) * 70), Colors.RED);
                }
                else
                {
                    DrawText("- GENERIC GAMEPAD -", 280, 180, 20, Colors.GRAY);

                    // TODO: Draw generic gamepad
                }

                DrawText(TextFormat("DETECTED AXIS [%i]:", GetGamepadAxisCount(0)), 10, 50, 10, Colors.MAROON);

                for (int i = 0; i < GetGamepadAxisCount(0); i++)
                {
                    DrawText(TextFormat("AXIS %i: %.02f", i, GetGamepadAxisMovement(0, i)), 20, 70 + 20*i, 10, Colors.DARKGRAY);
                }

                if (GetGamepadButtonPressed() != GamepadButton.GAMEPAD_BUTTON_UNKNOWN) DrawText(TextFormat("DETECTED BUTTON: %i", GetGamepadButtonPressed()), 10, 430, 10, Colors.RED);
                else DrawText("DETECTED BUTTON: NONE", 10, 430, 10, Colors.GRAY);
            }
            else
            {
                DrawText("GP1: NOT DETECTED", 10, 10, 10, Colors.GRAY);

                DrawTexture(texXboxPad, 0, 0, Colors.LIGHTGRAY);
            }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texPs3Pad);
    UnloadTexture(texXboxPad);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

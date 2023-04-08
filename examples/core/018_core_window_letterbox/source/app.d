/*******************************************************************************************
*
*   raylib [core] example - window scale letterbox (and virtual mouse)
*
*   Example originally created with raylib 2.5, last time updated with raylib 4.0
*
*   Example contributed by Anata (@anatagawa) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2023 Anata (@anatagawa) and Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;
import std.math : fmin, fmax;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    const int windowWidth = 800;
    const int windowHeight = 450;

    // Enable config flags for resizable window and vertical synchro
    SetConfigFlags(ConfigFlags.FLAG_WINDOW_RESIZABLE | ConfigFlags.FLAG_VSYNC_HINT);
    InitWindow(windowWidth, windowHeight, "raylib [core] example - window scale letterbox");
    SetWindowMinSize(320, 240);

    int gameScreenWidth = 640;
    int gameScreenHeight = 480;

    // Render texture initialization, used to hold the rendering result so we can easily resize it
    RenderTexture2D target = LoadRenderTexture(gameScreenWidth, gameScreenHeight);
    SetTextureFilter(target.texture, TextureFilter.TEXTURE_FILTER_BILINEAR);  // Texture scale filter to use

    Color[10] colors;
    for (int i = 0; i < 10; i++) {
        colors[i] = Color(
            cast(ubyte)GetRandomValue(100, 250),
            cast(ubyte)GetRandomValue(50, 150),
            cast(ubyte)GetRandomValue(10, 100),
            255
        );
    }

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Compute required framebuffer scaling
        float scale = fmin(cast(float)GetScreenWidth()/gameScreenWidth, cast(float)GetScreenHeight()/gameScreenHeight);

        if (IsKeyPressed(KeyboardKey.KEY_SPACE))
        {
            // Recalculate random colors for the bars
            for (int i = 0; i < 10; i++) {
                colors[i] = Color(
                    cast(ubyte)GetRandomValue(100, 250),
                    cast(ubyte)GetRandomValue(50, 150),
                    cast(ubyte)GetRandomValue(10, 100),
                    255
                );
            }
        }

        // Update virtual mouse (clamped mouse value behind game screen)
        Vector2 mouse = GetMousePosition();
        Vector2 virtualMouse = { 0 };
        virtualMouse.x = (mouse.x - (GetScreenWidth() - (gameScreenWidth*scale))*0.5f)/scale;
        virtualMouse.y = (mouse.y - (GetScreenHeight() - (gameScreenHeight*scale))*0.5f)/scale;
        virtualMouse = Vector2Clamp(virtualMouse, Vector2(0, 0), Vector2(cast(float)gameScreenWidth, cast(float)gameScreenHeight ));

        // Apply the same transformation as the virtual mouse to the real mouse (i.e. to work with raygui)
        //SetMouseOffset(-(GetScreenWidth() - (gameScreenWidth*scale))*0.5f, -(GetScreenHeight() - (gameScreenHeight*scale))*0.5f);
        //SetMouseScale(1/scale, 1/scale);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        // Draw everything in the render texture, note this will not be rendered on screen, yet
        BeginTextureMode(target);
            ClearBackground(Colors.RAYWHITE);  // Clear render texture background color

            for (int i = 0; i < 10; i++) DrawRectangle(0, (gameScreenHeight/10)*i, gameScreenWidth, gameScreenHeight/10, colors[i]);

            DrawText("If executed inside a window,\nyou can resize the window,\nand see the screen scaling!", 10, 25, 20, Colors.WHITE);
            DrawText(TextFormat("Default Mouse: [%i , %i]", cast(int)mouse.x, cast(int)mouse.y), 350, 25, 20, Colors.GREEN);
            DrawText(TextFormat("Virtual Mouse: [%i , %i]", cast(int)virtualMouse.x, cast(int)virtualMouse.y), 350, 55, 20, Colors.YELLOW);
        EndTextureMode();

        BeginDrawing();
            ClearBackground(Colors.BLACK);     // Clear screen background

            // Draw render texture to screen, properly scaled
            DrawTexturePro(target.texture, Rectangle( 0.0f, 0.0f, cast(float)target.texture.width, cast(float)-target.texture.height ),
                           Rectangle( (GetScreenWidth() - (cast(float)gameScreenWidth*scale))*0.5f, (GetScreenHeight() - (cast(float)gameScreenHeight*scale))*0.5f,
                           cast(float)gameScreenWidth*scale, cast(float)gameScreenHeight*scale ), Vector2(0, 0), 0.0f, Colors.WHITE);
        EndDrawing();
        //--------------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadRenderTexture(target);        // Unload render texture

    CloseWindow();                      // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

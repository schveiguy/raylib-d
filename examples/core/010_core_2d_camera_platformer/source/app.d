/*******************************************************************************************
*
*   raylib [core] example - 2d camera platformer
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.0
*
*   Example contributed by arvyy (@arvyy) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2023 arvyy (@arvyy)
*
********************************************************************************************/

import raylib;
import std.string : toStringz;
import std.math : fmin, fmax;

const int G = 400;
const float PLAYER_JUMP_SPD = 350.0f;
const float PLAYER_HOR_SPD = 200.0f;

struct Player {
    Vector2 position;
    float speed;
    bool canJump;
}

struct EnvItem {
    Rectangle rect;
    int blocking;
    Color color;
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

    InitWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera");

    Player player;
    player.position = Vector2( 400, 280 );
    player.speed = 0;
    player.canJump = false;
    EnvItem[] envItems = [
        EnvItem( Rectangle( 0, 0, 1000, 400 ), 0, Colors.LIGHTGRAY ),
        EnvItem( Rectangle( 0, 400, 1000, 200 ), 1, Colors.GRAY ),
        EnvItem( Rectangle( 300, 200, 400, 10 ), 1, Colors.GRAY ),
        EnvItem( Rectangle( 250, 300, 100, 10 ), 1, Colors.GRAY ),
        EnvItem( Rectangle( 650, 300, 100, 10 ), 1, Colors.GRAY )
    ];


    //ulong envItemsLength = envItems.length;

    Camera2D camera;
    camera.target = player.position;
    camera.offset = Vector2( screenWidth/2.0f, screenHeight/2.0f );
    camera.rotation = 0.0f;
    camera.zoom = 1.0f;

    // Store pointers to the multiple update camera functions
    alias cameraUpdateFunc = void function(ref Camera2D, ref Player, EnvItem[], float, int, int);

    cameraUpdateFunc[] cameraUpdaters = [
        &UpdateCameraCenter,
        &UpdateCameraCenterInsideMap,
        &UpdateCameraCenterSmoothFollow,
        &UpdateCameraEvenOutOnLanding,
        &UpdateCameraPlayerBoundsPush
    ];

    ulong cameraOption = 0;

    string[] cameraDescriptions = [
        "Follow player center",
        "Follow player center, but clamp to map edges",
        "Follow player center; smoothed",
        "Follow player center horizontally; updateplayer center vertically after landing",
        "Player push camera on getting too close to screen edge"
    ];

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())
    {
        // Update
        //----------------------------------------------------------------------------------
        float deltaTime = GetFrameTime();

        UpdatePlayer(player, envItems, deltaTime);

        camera.zoom += (GetMouseWheelMove()*0.05f);

        if (camera.zoom > 3.0f) camera.zoom = 3.0f;
        else if (camera.zoom < 0.25f) camera.zoom = 0.25f;

        if (IsKeyPressed(KeyboardKey.KEY_R))
        {
            camera.zoom = 1.0f;
            player.position = Vector2( 400, 280 );
        }

        if (IsKeyPressed(KeyboardKey.KEY_C)) cameraOption = (cameraOption + 1)%cameraUpdaters.length;

        // Call update camera function by its pointer
        cameraUpdaters[cameraOption](camera, player, envItems, deltaTime, screenWidth, screenHeight);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.LIGHTGRAY);

            BeginMode2D(camera);

                for (int i = 0; i < envItems.length; i++) DrawRectangleRec(envItems[i].rect, envItems[i].color);

                Rectangle playerRect = { player.position.x - 20, player.position.y - 40, 40, 40 };
                DrawRectangleRec(playerRect, Colors.RED);

            EndMode2D();

            DrawText("Controls:", 20, 20, 10, Colors.BLACK);
            DrawText("- Right/Left to move", 40, 40, 10, Colors.DARKGRAY);
            DrawText("- Space to jump", 40, 60, 10, Colors.DARKGRAY);
            DrawText("- Mouse Wheel to Zoom in-out, R to reset zoom", 40, 80, 10, Colors.DARKGRAY);
            DrawText("- C to change camera mode", 40, 100, 10, Colors.DARKGRAY);
            DrawText("Current camera mode:", 20, 120, 10, Colors.BLACK);
            DrawText(cameraDescriptions[cameraOption].toStringz, 40, 140, 10, Colors.DARKGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

void UpdatePlayer(ref Player player, EnvItem[] envItems, float delta)
{
    if (IsKeyDown(KeyboardKey.KEY_LEFT)) player.position.x -= PLAYER_HOR_SPD*delta;
    if (IsKeyDown(KeyboardKey.KEY_RIGHT)) player.position.x += PLAYER_HOR_SPD*delta;
    if (IsKeyDown(KeyboardKey.KEY_SPACE) && player.canJump)
    {
        player.speed = -PLAYER_JUMP_SPD;
        player.canJump = false;
    }

    int hitObstacle = 0;
    for (int i = 0; i < envItems.length; i++)
    {
        EnvItem *ei = &envItems[i];
        Vector2 *p = &(player.position);
        if (ei.blocking &&
            ei.rect.x <= p.x &&
            ei.rect.x + ei.rect.width >= p.x &&
            ei.rect.y >= p.y &&
            ei.rect.y <= p.y + player.speed*delta)
        {
            hitObstacle = 1;
            player.speed = 0.0f;
            p.y = ei.rect.y;
        }
    }

    if (!hitObstacle)
    {
        player.position.y += player.speed*delta;
        player.speed += G*delta;
        player.canJump = false;
    }
    else player.canJump = true;
}

void UpdateCameraCenter(ref Camera2D camera, ref Player player, EnvItem[] envItems, float delta, int width, int height)
{
    camera.offset = Vector2( width/2.0f, height/2.0f );
    camera.target = player.position;
}

void UpdateCameraCenterInsideMap(ref Camera2D camera, ref Player player, EnvItem[] envItems, float delta, int width, int height)
{
    camera.target = player.position;
    camera.offset = Vector2( width/2.0f, height/2.0f );
    float minX = 1000, minY = 1000, maxX = -1000, maxY = -1000;

    for (int i = 0; i < envItems.length; i++)
    {
        EnvItem *ei = &envItems[i];
        minX = fmin(ei.rect.x, minX);
        maxX = fmax(ei.rect.x + ei.rect.width, maxX);
        minY = fmin(ei.rect.y, minY);
        maxY = fmax(ei.rect.y + ei.rect.height, maxY);
    }

    Vector2 max = GetWorldToScreen2D(Vector2( maxX, maxY ), camera);
    Vector2 min = GetWorldToScreen2D(Vector2( minX, minY ), camera);

    if (max.x < width) camera.offset.x = width - (max.x - width/2);
    if (max.y < height) camera.offset.y = height - (max.y - height/2);
    if (min.x > 0) camera.offset.x = width/2 - min.x;
    if (min.y > 0) camera.offset.y = height/2 - min.y;
}

void UpdateCameraCenterSmoothFollow(ref Camera2D camera, ref Player player, EnvItem[] envItems, float delta, int width, int height)
{
    static float minSpeed = 30;
    static float minEffectLength = 10;
    static float fractionSpeed = 0.8f;

    camera.offset = Vector2( width/2.0f, height/2.0f );
    Vector2 diff = Vector2Subtract(player.position, camera.target);
    float length = Vector2Length(diff);

    if (length > minEffectLength)
    {
        float speed = fmax(fractionSpeed*length, minSpeed);
        camera.target = Vector2Add(camera.target, Vector2Scale(diff, speed*delta/length));
    }
}

void UpdateCameraEvenOutOnLanding(ref Camera2D camera, ref Player player, EnvItem[] envItems, float delta, int width, int height)
{
    static float evenOutSpeed = 700;
    static int eveningOut = false;
    static float evenOutTarget;

    camera.offset = Vector2( width/2.0f, height/2.0f );
    camera.target.x = player.position.x;

    if (eveningOut)
    {
        if (evenOutTarget > camera.target.y)
        {
            camera.target.y += evenOutSpeed*delta;

            if (camera.target.y > evenOutTarget)
            {
                camera.target.y = evenOutTarget;
                eveningOut = 0;
            }
        }
        else
        {
            camera.target.y -= evenOutSpeed*delta;

            if (camera.target.y < evenOutTarget)
            {
                camera.target.y = evenOutTarget;
                eveningOut = 0;
            }
        }
    }
    else
    {
        if (player.canJump && (player.speed == 0) && (player.position.y != camera.target.y))
        {
            eveningOut = 1;
            evenOutTarget = player.position.y;
        }
    }
}

void UpdateCameraPlayerBoundsPush(ref Camera2D camera, ref Player player, EnvItem[] envItems, float delta, int width, int height)
{
    static Vector2 bbox = { 0.2f, 0.2f };

    Vector2 bboxWorldMin = GetScreenToWorld2D(Vector2( (1 - bbox.x)*0.5f*width, (1 - bbox.y)*0.5f*height ), camera);
    Vector2 bboxWorldMax = GetScreenToWorld2D(Vector2( (1 + bbox.x)*0.5f*width, (1 + bbox.y)*0.5f*height ), camera);
    camera.offset = Vector2( (1 - bbox.x)*0.5f * width, (1 - bbox.y)*0.5f*height );

    if (player.position.x < bboxWorldMin.x) camera.target.x = player.position.x;
    if (player.position.y < bboxWorldMin.y) camera.target.y = player.position.y;
    if (player.position.x > bboxWorldMax.x) camera.target.x = bboxWorldMin.x + (player.position.x - bboxWorldMax.x);
    if (player.position.y > bboxWorldMax.y) camera.target.y = bboxWorldMin.y + (player.position.y - bboxWorldMax.y);
}

/*******************************************************************************************
*
*   raylib [core] example - VR Simulator (Oculus Rift CV1 parameters)
*
*   Example originally created with raylib 2.5, last time updated with raylib 4.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2017-2023 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;

//version(DESKTOP) {
version(all) {
    const int GLSL_VERSION = 330;
}
else {   // PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
    const int GLSL_VERSION = 100;
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

    // NOTE: screenWidth/screenHeight should match VR device aspect ratio
    InitWindow(screenWidth, screenHeight, "raylib [core] example - vr simulator");

    // VR device parameters definition
    VrDeviceInfo device;
    with(device) {
        // Oculus Rift CV1 parameters for simulator
        hResolution = 2160;                 // Horizontal resolution in pixels
        vResolution = 1200;                 // Vertical resolution in pixels
        hScreenSize = 0.133793f;            // Horizontal size in meters
        vScreenSize = 0.0669f;              // Vertical size in meters
        vScreenCenter = 0.04678f;           // Screen center in meters
        eyeToScreenDistance = 0.041f;       // Distance between eye and display in meters
        lensSeparationDistance = 0.07f;     // Lens separation distance in meters
        interpupillaryDistance = 0.07f;     // IPD (distance between pupils) in meters

        // NOTE: CV1 uses fresnel-hybrid-asymmetric lenses with specific compute shaders
        // Following parameters are just an approximation to CV1 distortion stereo rendering
        lensDistortionValues[0] = 1.0f;     // Lens distortion constant parameter 0
        lensDistortionValues[1] = 0.22f;    // Lens distortion constant parameter 1
        lensDistortionValues[2] = 0.24f;    // Lens distortion constant parameter 2
        lensDistortionValues[3] = 0.0f;     // Lens distortion constant parameter 3
        chromaAbCorrection[0] = 0.996f;     // Chromatic aberration correction parameter 0
        chromaAbCorrection[1] = -0.004f;    // Chromatic aberration correction parameter 1
        chromaAbCorrection[2] = 1.014f;     // Chromatic aberration correction parameter 2
        chromaAbCorrection[3] = 0.0f;       // Chromatic aberration correction parameter 3
    }

    // Load VR stereo config for VR device parameteres (Oculus Rift CV1 parameters)
    VrStereoConfig config = LoadVrStereoConfig(device);

    // Distortion shader (uses device lens distortion and chroma)
    Shader distortion = LoadShader(null, TextFormat("resources/distortion%i.fs", GLSL_VERSION));

    // Update distortion shader with lens and distortion-scale parameters
    SetShaderValue(distortion, GetShaderLocation(distortion, "leftLensCenter"),
                   &config.leftLensCenter, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
    SetShaderValue(distortion, GetShaderLocation(distortion, "rightLensCenter"),
                   &config.rightLensCenter, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
    SetShaderValue(distortion, GetShaderLocation(distortion, "leftScreenCenter"),
                   &config.leftScreenCenter, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
    SetShaderValue(distortion, GetShaderLocation(distortion, "rightScreenCenter"),
                   &config.rightScreenCenter, ShaderUniformDataType.SHADER_UNIFORM_VEC2);

    SetShaderValue(distortion, GetShaderLocation(distortion, "scale"),
                   &config.scale, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
    SetShaderValue(distortion, GetShaderLocation(distortion, "scaleIn"),
                   &config.scaleIn, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
    SetShaderValue(distortion, GetShaderLocation(distortion, "deviceWarpParam"),
                   &device.lensDistortionValues, ShaderUniformDataType.SHADER_UNIFORM_VEC4);
    SetShaderValue(distortion, GetShaderLocation(distortion, "chromaAbParam"),
                   &device.chromaAbCorrection, ShaderUniformDataType.SHADER_UNIFORM_VEC4);

    // Initialize framebuffer for stereo rendering
    // NOTE: Screen size should match HMD aspect ratio
    RenderTexture2D target = LoadRenderTexture(device.hResolution, device.vResolution);

    // The target's height is flipped (in the source Rectangle), due to OpenGL reasons
    Rectangle sourceRec = { 0.0f, 0.0f, cast(float)target.texture.width, -cast(float)target.texture.height };
    Rectangle destRec = { 0.0f, 0.0f, cast(float)GetScreenWidth(), cast(float)GetScreenHeight() };

    // Define the camera to look into our 3d world
    Camera camera;
    camera.position = Vector3( 5.0f, 2.0f, 5.0f );           // Camera position
    camera.target = Vector3( 0.0f, 2.0f, 0.0f );             // Camera looking at point
    camera.up = Vector3( 0.0f, 1.0f, 0.0f );                 // Camera up vector
    camera.fovy = 60.0f;                                     // Camera field-of-view Y
    camera.projection = CameraProjection.CAMERA_PERSPECTIVE; // Camera projection type

    Vector3 cubePosition = { 0.0f, 0.0f, 0.0f };

    DisableCursor();                    // Limit cursor to relative movement inside the window

    SetTargetFPS(90);                   // Set our game to run at 90 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(&camera, CameraMode.CAMERA_FIRST_PERSON);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginTextureMode(target);
            ClearBackground(Colors.RAYWHITE);
            BeginVrStereoMode(config);
                BeginMode3D(camera);

                    DrawCube(cubePosition, 2.0f, 2.0f, 2.0f, Colors.RED);
                    DrawCubeWires(cubePosition, 2.0f, 2.0f, 2.0f, Colors.MAROON);
                    DrawGrid(40, 1.0f);

                EndMode3D();
            EndVrStereoMode();
        EndTextureMode();

        BeginDrawing();
            ClearBackground(Colors.RAYWHITE);
            BeginShaderMode(distortion);
                DrawTexturePro(target.texture, sourceRec, destRec, Vector2(0.0f, 0.0f), 0.0f, Colors.WHITE);
            EndShaderMode();
            DrawFPS(10, 10);
        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadVrStereoConfig(config);   // Unload stereo config

    UnloadRenderTexture(target);    // Unload stereo render fbo
    UnloadShader(distortion);       // Unload distortion shader

    CloseWindow();                  // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

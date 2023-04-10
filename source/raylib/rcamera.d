/*******************************************************************************************
*
*   rcamera - Basic camera system with support for multiple camera modes
*
*   CONFIGURATION:
*
*   #define CAMERA_IMPLEMENTATION
*       Generates the implementation of the library into the included file.
*       If not defined, the library is in header only mode and can be included in other headers
*       or source files without problems. But only ONE file should hold the implementation.
*
*   #define CAMERA_STANDALONE
*       If defined, the library can be used as standalone as a camera system but some
*       functions must be redefined to manage inputs accordingly.
*
*   CONTRIBUTORS:
*       Ramon Santamaria:   Supervision, review, update and maintenance
*       Christoph Wagner:   Complete redesign, using raymath (2022)
*       Marc Palau:         Initial implementation (2014)
*
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2022-2023 Christoph Wagner (@Crydsch) & Ramon Santamaria (@raysan5)
*
*   This software is provided "as-is", without any express or implied warranty. In no event
*   will the authors be held liable for any damages arising from the use of this software.
*
*   Permission is granted to anyone to use this software for any purpose, including commercial
*   applications, and to alter it and redistribute it freely, subject to the following restrictions:
*
*     1. The origin of this software must not be misrepresented; you must not claim that you
*     wrote the original software. If you use this software in a product, an acknowledgment
*     in the product documentation would be appreciated but is not required.
*
*     2. Altered source versions must be plainly marked as such, and must not be misrepresented
*     as being the original software.
*
*     3. This notice may not be removed or altered from any source distribution.
*
**********************************************************************************************/
module raylib.rcamera;

import raylib;

extern (C) @nogc nothrow:

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------
// Function specifiers definition // Functions defined as 'extern' by default (implicit specifiers)

enum CAMERA_CULL_DISTANCE_NEAR = RL_CULL_DISTANCE_NEAR;
enum CAMERA_CULL_DISTANCE_FAR = RL_CULL_DISTANCE_FAR;

//----------------------------------------------------------------------------------
// Types and Structures Definition
// NOTE: Below types are required for CAMERA_STANDALONE usage
//----------------------------------------------------------------------------------

// Vector2, 2 components

// Vector x component
// Vector y component

// Vector3, 3 components

// Vector x component
// Vector y component
// Vector z component

// Camera type, defines a camera position/orientation in 3d space

// Camera position
// Camera target it looks-at
// Camera up vector (rotation over its axis)
// Camera field-of-view apperture in Y (degrees) in perspective, used as near plane width in orthographic
// Camera projection type: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC

// Camera type fallback, defaults to Camera3D

// Camera projection

// Perspective projection
// Orthographic projection

// Camera system modes

// Camera custom, controlled by user (UpdateCamera() does nothing)
// Camera free mode
// Camera orbital, around target, zoom supported
// Camera first person
// Camera third person

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------
//...

//----------------------------------------------------------------------------------
// Module Functions Declaration
//----------------------------------------------------------------------------------

// Prevents name mangling of functions

Vector3 GetCameraForward(Camera* camera);
Vector3 GetCameraUp(Camera* camera);
Vector3 GetCameraRight(Camera* camera);

// Camera movement
void CameraMoveForward(Camera* camera, float distance, bool moveInWorldPlane);
void CameraMoveUp(Camera* camera, float distance);
void CameraMoveRight(Camera* camera, float distance, bool moveInWorldPlane);
void CameraMoveToTarget(Camera* camera, float delta);

// Camera rotation
void CameraYaw(Camera* camera, float angle, bool rotateAroundTarget);
void CameraPitch(Camera* camera, float angle, bool lockView, bool rotateAroundTarget, bool rotateUp);
void CameraRoll(Camera* camera, float angle);

Matrix GetCameraViewMatrix(Camera* camera);
Matrix GetCameraProjectionMatrix(Camera* camera, float aspect);

// CAMERA_H

/***********************************************************************************
*
*   CAMERA IMPLEMENTATION
*
************************************************************************************/

// Required for vector maths:
// Vector3Add()
// Vector3Subtract()
// Vector3Scale()
// Vector3Normalize()
// Vector3Distance()
// Vector3CrossProduct()
// Vector3RotateByAxisAngle()
// Vector3Angle()
// Vector3Negate()
// MatrixLookAt()
// MatrixPerspective()
// MatrixOrtho()
// MatrixIdentity()

// raylib required functionality:
// GetMouseDelta()
// GetMouseWheelMove()
// IsKeyDown()
// IsKeyPressed()
// GetFrameTime()

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------

// Camera mouse movement sensitivity
// TODO: it should be independant of framerate

// Radians per second

// PLAYER (used by camera)

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
//...

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------
//...

//----------------------------------------------------------------------------------
// Module specific Functions Declaration
//----------------------------------------------------------------------------------
//...

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------
// Returns the cameras forward vector (normalized)

// Returns the cameras up vector (normalized)
// Note: The up vector might not be perpendicular to the forward vector

// Returns the cameras right vector (normalized)

// Moves the camera in its forward direction

// Project vector onto world plane

// Scale by distance

// Move position and target

// Moves the camera in its up direction

// Scale by distance

// Move position and target

// Moves the camera target in its current right direction

// Project vector onto world plane

// Scale by distance

// Move position and target

// Moves the camera position closer/farther to/from the camera target

// Apply delta

// Distance must be greater than 0

// Set new distance by moving the position along the forward vector

// Rotates the camera around its up vector
// Yaw is "looking left and right"
// If rotateAroundTarget is false, the camera rotates around its position
// Note: angle must be provided in radians

// Rotation axis

// View vector

// Rotate view vector around up axis

// Move position relative to target

// rotate around camera.position

// Move target relative to position

// Rotates the camera around its right vector, pitch is "looking up and down"
//  - lockView prevents camera overrotation (aka "somersaults")
//  - rotateAroundTarget defines if rotation is around target or around its position
//  - rotateUp rotates the up direction as well (typically only usefull in CAMERA_FREE)
// NOTE: angle must be provided in radians

// Up direction

// View vector

// In these camera modes we clamp the Pitch angle
// to allow only viewing straight up or down.

// Clamp view up

// avoid numerical errors

// Clamp view down

// downwards angle is negative
// avoid numerical errors

// Rotation axis

// Rotate view vector around right axis

// Move position relative to target

// rotate around camera.position

// Move target relative to position

// Rotate up direction around right axis

// Rotates the camera around its forward vector
// Roll is "turning your head sideways to the left or right"
// Note: angle must be provided in radians

// Rotation axis

// Rotate up direction around forward axis

// Returns the camera view matrix

// Returns the camera projection matrix

// Update camera position for selected mode
// Camera mode: CAMERA_FREE, CAMERA_FIRST_PERSON, CAMERA_THIRD_PERSON, CAMERA_ORBITAL or CUSTOM

// Orbital can just orbit

// Camera rotation

// Camera movement

//if (IsKeyDown(KEY_SPACE)) CameraMoveUp(camera, CAMERA_MOVE_SPEED);
//if (IsKeyDown(KEY_LEFT_CONTROL)) CameraMoveUp(camera, -CAMERA_MOVE_SPEED);

// Zoom target distance

// !CAMERA_STANDALONE

// Update camera movement, movement/rotation values should be provided by user

// Required values
// movement.x - Move forward/backward
// movement.y - Move right/left
// movement.z - Move up/down
// rotation.x - yaw
// rotation.y - pitch
// rotation.z - roll
// zoom - Move towards target

// Camera rotation

// Camera movement

// Zoom target distance

// CAMERA_IMPLEMENTATION

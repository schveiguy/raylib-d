module raymath;

import raylib;

/**********************************************************************************************
*
*   raymath v1.2 - Math functions to work with Vector3, Matrix and Quaternions
*
*   CONFIGURATION:
*
*   #define RAYMATH_IMPLEMENTATION
*       Generates the implementation of the library into the included file.
*       If not defined, the library is in header only mode and can be included in other headers
*       or source files without problems. But only ONE file should hold the implementation.
*
*   #define RAYMATH_HEADER_ONLY
*       Define static inline functions code, so #include header suffices for use.
*       This may use up lots of memory.
*
*   #define RAYMATH_STANDALONE
*       Avoid raylib.h header inclusion in this file.
*       Vector3 and Matrix data types are defined internally in raymath module.
*
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2015-2020 Ramon Santamaria (@raysan5)
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

extern (C):

//#define RAYMATH_STANDALONE      // NOTE: To use raymath as standalone lib, just uncomment this line
//#define RAYMATH_HEADER_ONLY     // NOTE: To compile functions as static inline, uncomment this line

// Required for structs: Vector3, Matrix

// We are building raylib as a Win32 shared library (.dll).

// We are using raylib as a Win32 shared library (.dll)

// Provide external definition

// Functions may be inlined, no external out-of-line definition

// plain inline not supported by tinycc (See issue #435) // Functions may be inlined or external definition used

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------

// Return float vector for Matrix

extern (D) auto MatrixToFloat(T)(auto ref T mat)
{
    return MatrixToFloatV(mat).v;
}

// Return float vector for Vector3

extern (D) auto Vector3ToFloat(T)(auto ref T vec)
{
    return Vector3ToFloatV(vec).v;
}

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------

// Vector2 type

// Vector3 type

// Quaternion type

// Matrix type (OpenGL style 4x4 - right handed, column major)

// NOTE: Helper types to be used instead of array return types for *ToFloat functions
struct float3
{
    float[3] v;
}

struct float16
{
    float[16] v;
}

// Required for: sinf(), cosf(), sqrtf(), tan(), fabs()

//----------------------------------------------------------------------------------
// Module Functions Definition - Utils math
//----------------------------------------------------------------------------------

// Clamp float value
float Clamp (float value, float min, float max);

// Calculate linear interpolation between two floats
float Lerp (float start, float end, float amount);

//----------------------------------------------------------------------------------
// Module Functions Definition - Vector2 math
//----------------------------------------------------------------------------------

// Vector with components value 0.0f
Vector2 Vector2Zero ();

// Vector with components value 1.0f
Vector2 Vector2One ();

// Add two vectors (v1 + v2)
Vector2 Vector2Add (Vector2 v1, Vector2 v2);

// Subtract two vectors (v1 - v2)
Vector2 Vector2Subtract (Vector2 v1, Vector2 v2);

// Calculate vector length
float Vector2Length (Vector2 v);

// Calculate two vectors dot product
float Vector2DotProduct (Vector2 v1, Vector2 v2);

// Calculate distance between two vectors
float Vector2Distance (Vector2 v1, Vector2 v2);

// Calculate angle from two vectors in X-axis
float Vector2Angle (Vector2 v1, Vector2 v2);

// Scale vector (multiply by value)
Vector2 Vector2Scale (Vector2 v, float scale);

// Multiply vector by vector
Vector2 Vector2MultiplyV (Vector2 v1, Vector2 v2);

// Negate vector
Vector2 Vector2Negate (Vector2 v);

// Divide vector by a float value
Vector2 Vector2Divide (Vector2 v, float div);

// Divide vector by vector
Vector2 Vector2DivideV (Vector2 v1, Vector2 v2);

// Normalize provided vector
Vector2 Vector2Normalize (Vector2 v);

// Calculate linear interpolation between two vectors
Vector2 Vector2Lerp (Vector2 v1, Vector2 v2, float amount);

// Rotate Vector by float in Degrees.
Vector2 Vector2Rotate (Vector2 v, float degs);

//----------------------------------------------------------------------------------
// Module Functions Definition - Vector3 math
//----------------------------------------------------------------------------------

// Vector with components value 0.0f
Vector3 Vector3Zero ();

// Vector with components value 1.0f
Vector3 Vector3One ();

// Add two vectors
Vector3 Vector3Add (Vector3 v1, Vector3 v2);

// Subtract two vectors
Vector3 Vector3Subtract (Vector3 v1, Vector3 v2);

// Multiply vector by scalar
Vector3 Vector3Scale (Vector3 v, float scalar);

// Multiply vector by vector
Vector3 Vector3Multiply (Vector3 v1, Vector3 v2);

// Calculate two vectors cross product
Vector3 Vector3CrossProduct (Vector3 v1, Vector3 v2);

// Calculate one vector perpendicular vector
Vector3 Vector3Perpendicular (Vector3 v);

// Calculate vector length
float Vector3Length (const Vector3 v);

// Calculate two vectors dot product
float Vector3DotProduct (Vector3 v1, Vector3 v2);

// Calculate distance between two vectors
float Vector3Distance (Vector3 v1, Vector3 v2);

// Negate provided vector (invert direction)
Vector3 Vector3Negate (Vector3 v);

// Divide vector by a float value
Vector3 Vector3Divide (Vector3 v, float div);

// Divide vector by vector
Vector3 Vector3DivideV (Vector3 v1, Vector3 v2);

// Normalize provided vector
Vector3 Vector3Normalize (Vector3 v);

// Orthonormalize provided vectors
// Makes vectors normalized and orthogonal to each other
// Gram-Schmidt function implementation
void Vector3OrthoNormalize (Vector3* v1, Vector3* v2);

// Transforms a Vector3 by a given Matrix
Vector3 Vector3Transform (Vector3 v, Matrix mat);

// Transform a vector by quaternion rotation
Vector3 Vector3RotateByQuaternion (Vector3 v, Quaternion q);

// Calculate linear interpolation between two vectors
Vector3 Vector3Lerp (Vector3 v1, Vector3 v2, float amount);

// Calculate reflected vector to normal

// I is the original vector
// N is the normal of the incident plane
// R = I - (2*N*( DotProduct[ I,N] ))
Vector3 Vector3Reflect (Vector3 v, Vector3 normal);

// Return min value for each pair of components
Vector3 Vector3Min (Vector3 v1, Vector3 v2);

// Return max value for each pair of components
Vector3 Vector3Max (Vector3 v1, Vector3 v2);

// Compute barycenter coordinates (u, v, w) for point p with respect to triangle (a, b, c)
// NOTE: Assumes P is on the plane of the triangle

//Vector v0 = b - a, v1 = c - a, v2 = p - a;
Vector3 Vector3Barycenter (Vector3 p, Vector3 a, Vector3 b, Vector3 c);

// Returns Vector3 as float array
float3 Vector3ToFloatV (Vector3 v);

//----------------------------------------------------------------------------------
// Module Functions Definition - Matrix math
//----------------------------------------------------------------------------------

// Compute matrix determinant

// Cache the matrix values (speed optimization)
float MatrixDeterminant (Matrix mat);

// Returns the trace of the matrix (sum of the values along the diagonal)
float MatrixTrace (Matrix mat);

// Transposes provided matrix
Matrix MatrixTranspose (Matrix mat);

// Invert provided matrix

// Cache the matrix values (speed optimization)

// Calculate the invert determinant (inlined to avoid double-caching)
Matrix MatrixInvert (Matrix mat);

// Normalize provided matrix
Matrix MatrixNormalize (Matrix mat);

// Returns identity matrix
Matrix MatrixIdentity ();

// Add two matrices
Matrix MatrixAdd (Matrix left, Matrix right);

// Subtract two matrices (left - right)
Matrix MatrixSubtract (Matrix left, Matrix right);

// Returns translation matrix
Matrix MatrixTranslate (float x, float y, float z);

// Create rotation matrix from axis and angle
// NOTE: Angle should be provided in radians
Matrix MatrixRotate (Vector3 axis, float angle);

// Returns xyz-rotation matrix (angles in radians)
Matrix MatrixRotateXYZ (Vector3 ang);

// Returns x-rotation matrix (angle in radians)
Matrix MatrixRotateX (float angle);

// Returns y-rotation matrix (angle in radians)
Matrix MatrixRotateY (float angle);

// Returns z-rotation matrix (angle in radians)
Matrix MatrixRotateZ (float angle);

// Returns scaling matrix
Matrix MatrixScale (float x, float y, float z);

// Returns two matrix multiplication
// NOTE: When multiplying matrices... the order matters!
Matrix MatrixMultiply (Matrix left, Matrix right);

// Returns perspective projection matrix
Matrix MatrixFrustum (
    double left,
    double right,
    double bottom,
    double top,
    double near,
    double far);

// Returns perspective projection matrix
// NOTE: Angle should be provided in radians
Matrix MatrixPerspective (double fovy, double aspect, double near, double far);

// Returns orthographic projection matrix
Matrix MatrixOrtho (
    double left,
    double right,
    double bottom,
    double top,
    double near,
    double far);

// Returns camera look-at matrix (view matrix)
Matrix MatrixLookAt (Vector3 eye, Vector3 target, Vector3 up);

// Returns float array of matrix data
float16 MatrixToFloatV (Matrix mat);

//----------------------------------------------------------------------------------
// Module Functions Definition - Quaternion math
//----------------------------------------------------------------------------------

// Returns identity quaternion
Quaternion QuaternionIdentity ();

// Computes the length of a quaternion
float QuaternionLength (Quaternion q);

// Normalize provided quaternion
Quaternion QuaternionNormalize (Quaternion q);

// Invert provided quaternion
Quaternion QuaternionInvert (Quaternion q);

// Calculate two quaternion multiplication
Quaternion QuaternionMultiply (Quaternion q1, Quaternion q2);

// Calculate linear interpolation between two quaternions
Quaternion QuaternionLerp (Quaternion q1, Quaternion q2, float amount);

// Calculate slerp-optimized interpolation between two quaternions
Quaternion QuaternionNlerp (Quaternion q1, Quaternion q2, float amount);

// Calculates spherical linear interpolation between two quaternions
Quaternion QuaternionSlerp (Quaternion q1, Quaternion q2, float amount);

// Calculate quaternion based on the rotation from one vector to another

// NOTE: Added QuaternioIdentity()

// Normalize to essentially nlerp the original and identity to 0.5

// Above lines are equivalent to:
//Quaternion result = QuaternionNlerp(q, QuaternionIdentity(), 0.5f);
Quaternion QuaternionFromVector3ToVector3 (Vector3 from, Vector3 to);

// Returns a quaternion for a given rotation matrix
Quaternion QuaternionFromMatrix (Matrix mat);

// Returns a matrix for a given quaternion
Matrix QuaternionToMatrix (Quaternion q);

// Returns rotation quaternion for an angle and axis
// NOTE: angle must be provided in radians
Quaternion QuaternionFromAxisAngle (Vector3 axis, float angle);

// Returns the rotation angle and axis for a given quaternion

// This occurs when the angle is zero.
// Not a problem: just set an arbitrary normalized axis.
void QuaternionToAxisAngle (Quaternion q, Vector3* outAxis, float* outAngle);

// Returns he quaternion equivalent to Euler angles
Quaternion QuaternionFromEuler (float roll, float pitch, float yaw);

// Return the Euler angles equivalent to quaternion (roll, pitch, yaw)
// NOTE: Angles are returned in a Vector3 struct in degrees

// roll (x-axis rotation)

// pitch (y-axis rotation)

// yaw (z-axis rotation)
Vector3 QuaternionToEuler (Quaternion q);

// Transform a quaternion given a transformation matrix
Quaternion QuaternionTransform (Quaternion q, Matrix mat);

// RAYMATH_H

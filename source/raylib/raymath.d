/**********************************************************************************************
*
*   raymath v2.0 - Math functions to work with Vector2, Vector3, Matrix and Quaternions
*
*   CONVENTIONS:
*     - Matrix structure is defined as row-major (memory layout) but parameters naming AND all
*       math operations performed by the library consider the structure as it was column-major
*       It is like transposed versions of the matrices are used for all the maths
*       It benefits some functions making them cache-friendly and also avoids matrix
*       transpositions sometimes required by OpenGL
*       Example: In memory order, row0 is [m0 m4 m8 m12] but in semantic math row0 is [m0 m1 m2 m3]
*     - Functions are always self-contained, no function use another raymath function inside,
*       required code is directly re-implemented inside
*     - Functions input parameters are always received by value (2 unavoidable exceptions)
*     - Functions use always a "result" variable for return (except C++ operators)
*     - Functions are always defined inline
*     - Angles are always in radians (DEG2RAD/RAD2DEG macros provided for convenience)
*     - No compound literals used to make sure the library is compatible with C++
*
*   CONFIGURATION:
*       #define RAYMATH_IMPLEMENTATION
*           Generates the implementation of the library into the included file
*           If not defined, the library is in header only mode and can be included in other headers
*           or source files without problems. But only ONE file should hold the implementation
*
*       #define RAYMATH_STATIC_INLINE
*           Define static inline functions code, so #include header suffices for use
*           This may use up lots of memory
*
*       #define RAYMATH_DISABLE_CPP_OPERATORS
*           Disables C++ operator overloads for raymath types.
*
*       #define RAYMATH_USE_SIMD_INTRINSICS   1
*           Try to enable SIMD intrinsics for MatrixMultiply()
*           Note that users enabling it must be aware of the target platform where application will
*           run to support the selected SIMD intrinsic, for now, only SSE is supported
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2015-2026 Ramon Santamaria (@raysan5)
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
module raylib.raymath;

import raylib;

extern (C) @nogc nothrow:

// Function specifiers definition

// Building raylib as a Win32 shared library (.dll)

// Building raylib as a Unix shared library (.so/.dylib)

// Using raylib as a Win32 shared library (.dll)

// Provide external definition

// Functions may be inlined, no external out-of-line definition

// plain inline not supported by tinycc (See issue #435) // Functions may be inlined or external definition used

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------

enum PI = 3.14159265358979323846f;

enum EPSILON = 0.000001f;

enum DEG2RAD = PI / 180.0f;

enum RAD2DEG = 180.0f / PI;

// Get float vector for Matrix

extern (D) auto MatrixToFloat(T)(auto ref T mat)
{
    return MatrixToFloatV(mat).v;
}

// Get float vector for Vector3

extern (D) auto Vector3ToFloat(T)(auto ref T vec)
{
    return Vector3ToFloatV(vec).v;
}

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------

// Vector2 type

// Vector3 type

// Vector4 type

// Quaternion type

// Matrix type (OpenGL style 4x4 - right handed, column major)

// Matrix first row (4 components)
// Matrix second row (4 components)
// Matrix third row (4 components)
// Matrix fourth row (4 components)

// NOTE: Helper types to be used instead of array return types for *ToFloat functions

struct float3
{
    float[3] v;
}

struct float16
{
    float[16] v;
}

// Required for: sinf(), cosf(), tan(), atan2f(), sqrtf(), floor(), fminf(), fmaxf(), fabsf()

// SIMD is used on the most costly raymath function MatrixMultiply()
// NOTE: Only SSE intrinsics support implemented
// TODO: Consider support for other SIMD intrinsics:
//  - SSEx, AVX, AVX2, FMA, NEON, RVV
/*
#if defined(__SSE4_2__)
    #include <nmmintrin.h>
    #define RAYMATH_SSE42_ENABLED
#elif defined(__SSE4_1__)
    #include <smmintrin.h>
    #define RAYMATH_SSE41_ENABLED
#elif defined(__SSSE3__)
    #include <tmmintrin.h>
    #define RAYMATH_SSSE3_ENABLED
#elif defined(__SSE3__)
    #include <pmmintrin.h>
    #define RAYMATH_SSE3_ENABLED
#elif defined(__SSE2__) || (defined(_M_AMD64) || defined(_M_X64)) // SSE2 x64
    #include <emmintrin.h>
    #define RAYMATH_SSE2_ENABLED
#endif
*/

//----------------------------------------------------------------------------------
// Module Functions Definition - Utils math
//----------------------------------------------------------------------------------

// Clamp float value
float Clamp(float value, float min, float max);

// Calculate linear interpolation between two floats
float Lerp(float start, float end, float amount);

// Normalize input value within input range
float Normalize(float value, float start, float end);

// Remap input value within input range to output range
float Remap(
    float value,
    float inputStart,
    float inputEnd,
    float outputStart,
    float outputEnd);

// Wrap input value from min to max
float Wrap(float value, float min, float max);

// Check whether two given floats are almost equal
int FloatEquals(float x, float y);

//----------------------------------------------------------------------------------
// Module Functions Definition - Vector2 math
//----------------------------------------------------------------------------------

// Vector with components value 0.0f
Vector2 Vector2Zero();

// Vector with components value 1.0f
Vector2 Vector2One();

// Add two vectors (v1 + v2)
Vector2 Vector2Add(Vector2 v1, Vector2 v2);

// Add vector and float value
Vector2 Vector2AddValue(Vector2 v, float add);

// Subtract two vectors (v1 - v2)
Vector2 Vector2Subtract(Vector2 v1, Vector2 v2);

// Subtract vector by float value
Vector2 Vector2SubtractValue(Vector2 v, float sub);

// Calculate vector length
float Vector2Length(Vector2 v);

// Calculate vector square length
float Vector2LengthSqr(Vector2 v);

// Calculate two vectors dot product
float Vector2DotProduct(Vector2 v1, Vector2 v2);

// Calculate two vectors cross product
float Vector2CrossProduct(Vector2 v1, Vector2 v2);

// Calculate distance between two vectors
float Vector2Distance(Vector2 v1, Vector2 v2);

// Calculate square distance between two vectors
float Vector2DistanceSqr(Vector2 v1, Vector2 v2);

// Calculate the signed angle from v1 to v2, relative to the origin (0, 0)
// NOTE: Coordinate system convention: positive X right, positive Y down
// positive angles appear clockwise, and negative angles appear counterclockwise
float Vector2Angle(Vector2 v1, Vector2 v2);

// Calculate angle defined by a two vectors line
// NOTE: Parameters need to be normalized
// Current implementation should be aligned with glm::angle

// TODO(10/9/2023): Currently angles move clockwise, determine if this is wanted behavior
float Vector2LineAngle(Vector2 start, Vector2 end);

// Scale vector (multiply by value)
Vector2 Vector2Scale(Vector2 v, float scale);

// Multiply vector by vector
Vector2 Vector2Multiply(Vector2 v1, Vector2 v2);

// Negate vector
Vector2 Vector2Negate(Vector2 v);

// Divide vector by vector
Vector2 Vector2Divide(Vector2 v1, Vector2 v2);

// Normalize provided vector
Vector2 Vector2Normalize(Vector2 v);

// Transforms a Vector2 by a given Matrix
Vector2 Vector2Transform(Vector2 v, Matrix mat);

// Calculate linear interpolation between two vectors
Vector2 Vector2Lerp(Vector2 v1, Vector2 v2, float amount);

// Calculate reflected vector to normal

// Dot product
Vector2 Vector2Reflect(Vector2 v, Vector2 normal);

// Get min value for each pair of components
Vector2 Vector2Min(Vector2 v1, Vector2 v2);

// Get max value for each pair of components
Vector2 Vector2Max(Vector2 v1, Vector2 v2);

// Rotate vector by angle
Vector2 Vector2Rotate(Vector2 v, float angle);

// Move Vector towards target
Vector2 Vector2MoveTowards(Vector2 v, Vector2 target, float maxDistance);

// Invert the given vector
Vector2 Vector2Invert(Vector2 v);

// Clamp the components of the vector between
// min and max values specified by the given vectors
Vector2 Vector2Clamp(Vector2 v, Vector2 min, Vector2 max);

// Clamp the magnitude of the vector between two min and max values

// By default, 1 as the neutral element
Vector2 Vector2ClampValue(Vector2 v, float min, float max);

// Check whether two given vectors are almost equal
int Vector2Equals(Vector2 p, Vector2 q);

// Compute the direction of a refracted ray
// v: normalized direction of the incoming ray
// n: normalized normal vector of the interface of two optical media
// r: ratio of the refractive index of the medium from where the ray comes
// to the refractive index of the medium on the other side of the surface
Vector2 Vector2Refract(Vector2 v, Vector2 n, float r);

//----------------------------------------------------------------------------------
// Module Functions Definition - Vector3 math
//----------------------------------------------------------------------------------

// Vector with components value 0.0f
Vector3 Vector3Zero();

// Vector with components value 1.0f
Vector3 Vector3One();

// Add two vectors
Vector3 Vector3Add(Vector3 v1, Vector3 v2);

// Add vector and float value
Vector3 Vector3AddValue(Vector3 v, float add);

// Subtract two vectors
Vector3 Vector3Subtract(Vector3 v1, Vector3 v2);

// Subtract vector by float value
Vector3 Vector3SubtractValue(Vector3 v, float sub);

// Multiply vector by scalar
Vector3 Vector3Scale(Vector3 v, float scalar);

// Multiply vector by vector
Vector3 Vector3Multiply(Vector3 v1, Vector3 v2);

// Calculate two vectors cross product
Vector3 Vector3CrossProduct(Vector3 v1, Vector3 v2);

// Calculate one vector perpendicular vector

// Cross product between vectors
Vector3 Vector3Perpendicular(Vector3 v);

// Calculate vector length
float Vector3Length(const Vector3 v);

// Calculate vector square length
float Vector3LengthSqr(const Vector3 v);

// Calculate two vectors dot product
float Vector3DotProduct(Vector3 v1, Vector3 v2);

// Calculate distance between two vectors
float Vector3Distance(Vector3 v1, Vector3 v2);

// Calculate square distance between two vectors
float Vector3DistanceSqr(Vector3 v1, Vector3 v2);

// Calculate angle between two vectors
float Vector3Angle(Vector3 v1, Vector3 v2);

// Negate provided vector (invert direction)
Vector3 Vector3Negate(Vector3 v);

// Divide vector by vector
Vector3 Vector3Divide(Vector3 v1, Vector3 v2);

// Normalize provided vector
Vector3 Vector3Normalize(Vector3 v);

//Calculate the projection of the vector v1 on to v2
Vector3 Vector3Project(Vector3 v1, Vector3 v2);

//Calculate the rejection of the vector v1 on to v2
Vector3 Vector3Reject(Vector3 v1, Vector3 v2);

// Orthonormalize provided vectors
// Makes vectors normalized and orthogonal to each other
// Gram-Schmidt function implementation

// Vector3Normalize(*v1);

// Vector3CrossProduct(*v1, *v2)

// Vector3Normalize(vn1);

// Vector3CrossProduct(vn1, *v1)
void Vector3OrthoNormalize(Vector3* v1, Vector3* v2);

// Transforms a Vector3 by a given Matrix
Vector3 Vector3Transform(Vector3 v, Matrix mat);

// Transform a vector by quaternion rotation
Vector3 Vector3RotateByQuaternion(Vector3 v, Quaternion q);

// Rotates a vector around an axis

// Using Euler-Rodrigues Formula
// Ref.: https://en.wikipedia.org/w/index.php?title=Euler%E2%80%93Rodrigues_formula

// Vector3Normalize(axis);

// Vector3CrossProduct(w, v)

// Vector3CrossProduct(w, wv)

// Vector3Scale(wv, 2*a)

// Vector3Scale(wwv, 2)
Vector3 Vector3RotateByAxisAngle(Vector3 v, Vector3 axis, float angle);

// Move Vector towards target
Vector3 Vector3MoveTowards(Vector3 v, Vector3 target, float maxDistance);

// Calculate linear interpolation between two vectors
Vector3 Vector3Lerp(Vector3 v1, Vector3 v2, float amount);

// Calculate cubic hermite interpolation between two vectors and their tangents
// as described in the GLTF 2.0 specification: https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#interpolation-cubic
Vector3 Vector3CubicHermite(
    Vector3 v1,
    Vector3 tangent1,
    Vector3 v2,
    Vector3 tangent2,
    float amount);

// Calculate reflected vector to normal

// I is the original vector
// N is the normal of the incident plane
// R = I - (2*N*(DotProduct[I, N]))
Vector3 Vector3Reflect(Vector3 v, Vector3 normal);

// Get min value for each pair of components
Vector3 Vector3Min(Vector3 v1, Vector3 v2);

// Get max value for each pair of components
Vector3 Vector3Max(Vector3 v1, Vector3 v2);

// Compute barycenter coordinates (u, v, w) for point p with respect to triangle (a, b, c)
// NOTE: Assumes P is on the plane of the triangle

// Vector3Subtract(b, a)
// Vector3Subtract(c, a)
// Vector3Subtract(p, a)
// Vector3DotProduct(v0, v0)
// Vector3DotProduct(v0, v1)
// Vector3DotProduct(v1, v1)
// Vector3DotProduct(v2, v0)
// Vector3DotProduct(v2, v1)
Vector3 Vector3Barycenter(Vector3 p, Vector3 a, Vector3 b, Vector3 c);

// Projects a Vector3 from screen space into object space
// NOTE: Self-contained function, no other raymath functions are called

// Calculate unprojected matrix (multiply view matrix by projection matrix) and invert it
// MatrixMultiply(view, projection);

// Calculate inverted matrix -> MatrixInvert(matViewProj);
// Cache the matrix values (speed optimization)

// Calculate the invert determinant (inlined to avoid double-caching)

// Create quaternion from source point

// Multiply quat point by unprojected matrix
// QuaternionTransform(quat, matViewProjInv)

// Normalized world points in vectors
Vector3 Vector3Unproject(Vector3 source, Matrix projection, Matrix view);

// Get Vector3 as float array
float3 Vector3ToFloatV(Vector3 v);

// Invert the given vector
Vector3 Vector3Invert(Vector3 v);

// Clamp the components of the vector between
// min and max values specified by the given vectors
Vector3 Vector3Clamp(Vector3 v, Vector3 min, Vector3 max);

// Clamp the magnitude of the vector between two values

// By default, 1 as the neutral element
Vector3 Vector3ClampValue(Vector3 v, float min, float max);

// Check whether two given vectors are almost equal
int Vector3Equals(Vector3 p, Vector3 q);

// Compute the direction of a refracted ray
// v: normalized direction of the incoming ray
// n: normalized normal vector of the interface of two optical media
// r: ratio of the refractive index of the medium from where the ray comes
// to the refractive index of the medium on the other side of the surface
Vector3 Vector3Refract(Vector3 v, Vector3 n, float r);

//----------------------------------------------------------------------------------
// Module Functions Definition - Vector4 math
//----------------------------------------------------------------------------------
// Get  vector zero
Vector4 Vector4Zero();

// Get vector one
Vector4 Vector4One();

// Add two vectors
Vector4 Vector4Add(Vector4 v1, Vector4 v2);

// Add value to vector components
Vector4 Vector4AddValue(Vector4 v, float add);

// Substract vectors
Vector4 Vector4Subtract(Vector4 v1, Vector4 v2);

// Substract value from vector components
Vector4 Vector4SubtractValue(Vector4 v, float add);

// Vector length
float Vector4Length(Vector4 v);

// Vector square length
float Vector4LengthSqr(Vector4 v);

// Vectors dot product
float Vector4DotProduct(Vector4 v1, Vector4 v2);

// Calculate distance between two vectors
float Vector4Distance(Vector4 v1, Vector4 v2);

// Calculate square distance between two vectors
float Vector4DistanceSqr(Vector4 v1, Vector4 v2);

// Scale vector components by value (multiply)
Vector4 Vector4Scale(Vector4 v, float scale);

// Multiply vector by vector
Vector4 Vector4Multiply(Vector4 v1, Vector4 v2);

// Negate vector
Vector4 Vector4Negate(Vector4 v);

// Divide vector by vector
Vector4 Vector4Divide(Vector4 v1, Vector4 v2);

// Normalize provided vector
Vector4 Vector4Normalize(Vector4 v);

// Get min value for each pair of components
Vector4 Vector4Min(Vector4 v1, Vector4 v2);

// Get max value for each pair of components
Vector4 Vector4Max(Vector4 v1, Vector4 v2);

// Calculate linear interpolation between two vectors
Vector4 Vector4Lerp(Vector4 v1, Vector4 v2, float amount);

// Move Vector towards target
Vector4 Vector4MoveTowards(Vector4 v, Vector4 target, float maxDistance);

// Invert the given vector
Vector4 Vector4Invert(Vector4 v);

// Check whether two given vectors are almost equal
int Vector4Equals(Vector4 p, Vector4 q);

//----------------------------------------------------------------------------------
// Module Functions Definition - Matrix math
//----------------------------------------------------------------------------------

// Compute matrix determinant

/*
    // Cache the matrix values (speed optimization)
    float a00 = mat.m0, a01 = mat.m1, a02 = mat.m2, a03 = mat.m3;
    float a10 = mat.m4, a11 = mat.m5, a12 = mat.m6, a13 = mat.m7;
    float a20 = mat.m8, a21 = mat.m9, a22 = mat.m10, a23 = mat.m11;
    float a30 = mat.m12, a31 = mat.m13, a32 = mat.m14, a33 = mat.m15;

    // NOTE: It takes 72 multiplication to calculate 4x4 matrix determinant
    result = a30*a21*a12*a03 - a20*a31*a12*a03 - a30*a11*a22*a03 + a10*a31*a22*a03 +
             a20*a11*a32*a03 - a10*a21*a32*a03 - a30*a21*a02*a13 + a20*a31*a02*a13 +
             a30*a01*a22*a13 - a00*a31*a22*a13 - a20*a01*a32*a13 + a00*a21*a32*a13 +
             a30*a11*a02*a23 - a10*a31*a02*a23 - a30*a01*a12*a23 + a00*a31*a12*a23 +
             a10*a01*a32*a23 - a00*a11*a32*a23 - a20*a11*a02*a33 + a10*a21*a02*a33 +
             a20*a01*a12*a33 - a00*a21*a12*a33 - a10*a01*a22*a33 + a00*a11*a22*a33;
*/
// Using Laplace expansion (https://en.wikipedia.org/wiki/Laplace_expansion),
// previous operation can be simplified to 40 multiplications, decreasing matrix
// size from 4x4 to 2x2 using minors

// Cache the matrix values (speed optimization)
float MatrixDeterminant(Matrix mat);

// Get the trace of the matrix (sum of the values along the diagonal)
float MatrixTrace(Matrix mat);

// Transposes provided matrix
Matrix MatrixTranspose(Matrix mat);

// Invert provided matrix

// Cache the matrix values (speed optimization)

// Calculate the invert determinant (inlined to avoid double-caching)
Matrix MatrixInvert(Matrix mat);

// Get identity matrix
Matrix MatrixIdentity();

// Add two matrices
Matrix MatrixAdd(Matrix left, Matrix right);

// Subtract two matrices (left - right)
Matrix MatrixSubtract(Matrix left, Matrix right);

// Get two matrix multiplication
// NOTE: When multiplying matrices... the order matters!

// Load left side and right side

// Transpose so c0..c3 become *rows* of the right matrix in semantic order

// Row 0 of result: [m0, m1, m2, m3]

// Row 1 of result: [m4, m5, m6, m7]

// Row 2 of result: [m8, m9, m10, m11]

// Row 3 of result: [m12, m13, m14, m15]
Matrix MatrixMultiply(Matrix left, Matrix right);

// Multiply matrix components by value
Matrix MatrixMultiplyValue(Matrix left, float value);

// Get translation matrix
Matrix MatrixTranslate(float x, float y, float z);

// Create rotation matrix from axis and angle
// NOTE: Angle should be provided in radians
Matrix MatrixRotate(Vector3 axis, float angle);

// Get x-rotation matrix
// NOTE: Angle must be provided in radians

// MatrixIdentity()
Matrix MatrixRotateX(float angle);

// Get y-rotation matrix
// NOTE: Angle must be provided in radians

// MatrixIdentity()
Matrix MatrixRotateY(float angle);

// Get z-rotation matrix
// NOTE: Angle must be provided in radians

// MatrixIdentity()
Matrix MatrixRotateZ(float angle);

// Get xyz-rotation matrix
// NOTE: Angle must be provided in radians

// MatrixIdentity()
Matrix MatrixRotateXYZ(Vector3 angle);

// Get zyx-rotation matrix
// NOTE: Angle must be provided in radians
Matrix MatrixRotateZYX(Vector3 angle);

// Get scaling matrix
Matrix MatrixScale(float x, float y, float z);

// Get perspective projection matrix
Matrix MatrixFrustum(
    double left,
    double right,
    double bottom,
    double top,
    double nearPlane,
    double farPlane);

// Get perspective projection matrix
// NOTE: Fovy angle must be provided in radians

// MatrixFrustum(-right, right, -top, top, near, far);
Matrix MatrixPerspective(
    double fovY,
    double aspect,
    double nearPlane,
    double farPlane);

// Get orthographic projection matrix
Matrix MatrixOrtho(
    double left,
    double right,
    double bottom,
    double top,
    double nearPlane,
    double farPlane);

// Get camera look-at matrix (view matrix)

// Vector3Subtract(eye, target)

// Vector3Normalize(vz)

// Vector3CrossProduct(up, vz)

// Vector3Normalize(x)

// Vector3CrossProduct(vz, vx)

// Vector3DotProduct(vx, eye)
// Vector3DotProduct(vy, eye)
// Vector3DotProduct(vz, eye)
Matrix MatrixLookAt(Vector3 eye, Vector3 target, Vector3 up);

// Get float array of matrix data
float16 MatrixToFloatV(Matrix mat);

//----------------------------------------------------------------------------------
// Module Functions Definition - Quaternion math
//----------------------------------------------------------------------------------

// Add two quaternions
Quaternion QuaternionAdd(Quaternion q1, Quaternion q2);

// Add quaternion and float value
Quaternion QuaternionAddValue(Quaternion q, float add);

// Subtract two quaternions
Quaternion QuaternionSubtract(Quaternion q1, Quaternion q2);

// Subtract quaternion and float value
Quaternion QuaternionSubtractValue(Quaternion q, float sub);

// Get identity quaternion
Quaternion QuaternionIdentity();

// Computes the length of a quaternion
float QuaternionLength(Quaternion q);

// Normalize provided quaternion
Quaternion QuaternionNormalize(Quaternion q);

// Invert provided quaternion
Quaternion QuaternionInvert(Quaternion q);

// Calculate two quaternion multiplication
Quaternion QuaternionMultiply(Quaternion q1, Quaternion q2);

// Scale quaternion by float value
Quaternion QuaternionScale(Quaternion q, float mul);

// Divide two quaternions
Quaternion QuaternionDivide(Quaternion q1, Quaternion q2);

// Calculate linear interpolation between two quaternions
Quaternion QuaternionLerp(Quaternion q1, Quaternion q2, float amount);

// Calculate slerp-optimized interpolation between two quaternions

// QuaternionLerp(q1, q2, amount)

// QuaternionNormalize(q);
Quaternion QuaternionNlerp(Quaternion q1, Quaternion q2, float amount);

// Calculates spherical linear interpolation between two quaternions
Quaternion QuaternionSlerp(Quaternion q1, Quaternion q2, float amount);

// Calculate quaternion cubic spline interpolation using Cubic Hermite Spline algorithm
// as described in the GLTF 2.0 specification: https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#interpolation-cubic
Quaternion QuaternionCubicHermiteSpline(
    Quaternion q1,
    Quaternion outTangent1,
    Quaternion q2,
    Quaternion inTangent2,
    float t);

// Calculate quaternion based on the rotation from one vector to another

// Vector3DotProduct(from, to)
// Vector3CrossProduct(from, to)

// QuaternionNormalize(q);
// NOTE: Normalize to essentially nlerp the original and identity to 0.5
Quaternion QuaternionFromVector3ToVector3(Vector3 from, Vector3 to);

// Get a quaternion for a given rotation matrix
Quaternion QuaternionFromMatrix(Matrix mat);

// Get a matrix for a given quaternion

// MatrixIdentity()
Matrix QuaternionToMatrix(Quaternion q);

// Get rotation quaternion for an angle and axis
// NOTE: Angle must be provided in radians

// Vector3Normalize(axis)

// QuaternionNormalize(q);
Quaternion QuaternionFromAxisAngle(Vector3 axis, float angle);

// Get the rotation angle and axis for a given quaternion

// QuaternionNormalize(q);

// This occurs when the angle is zero
// Not a problem, set an arbitrary normalized axis
void QuaternionToAxisAngle(Quaternion q, Vector3* outAxis, float* outAngle);

// Get the quaternion equivalent to Euler angles
// NOTE: Rotation order is ZYX
Quaternion QuaternionFromEuler(float pitch, float yaw, float roll);

// Get the Euler angles equivalent to quaternion (roll, pitch, yaw)
// NOTE: Angles are returned in a Vector3 struct in radians

// Roll (x-axis rotation)

// Pitch (y-axis rotation)

// Yaw (z-axis rotation)
Vector3 QuaternionToEuler(Quaternion q);

// Transform a quaternion given a transformation matrix
Quaternion QuaternionTransform(Quaternion q, Matrix mat);

// Check whether two given quaternions are almost equal
int QuaternionEquals(Quaternion p, Quaternion q);

// Compose a transformation matrix from rotational, translational and scaling components
// TODO: This function is not following raymath conventions defined in header: NOT self-contained

// Initialize vectors

// Scale vectors

// Rotate vectors

// Set result matrix output
Matrix MatrixCompose(Vector3 translation, Quaternion rotation, Vector3 scale);

// Decompose a transformation matrix into its rotational, translational and scaling components and remove shear
// TODO: This function is not following raymath conventions defined in header: NOT self-contained

// Extract Translation

// Matrix Columns - Rotation will be extracted into here

// Shear Parameters XY, XZ, and YZ (extract and ignored)

// Normalized Scale Parameters

// Max-Normalizing helps numerical stability

// X Scale

// Compute XY shear and make col2 orthogonal

// Y Scale

// Correct XY shear

// Compute XZ and YZ shears and make col3 orthogonal

// Z Scale

// Correct XZ shear
// Correct YZ shear

// matColumns are now orthonormal in O(3). Now ensure its in SO(3) by enforcing det = 1

// Set Scale

// Extract Rotation
void MatrixDecompose(
    Matrix mat,
    Vector3* translation,
    Quaternion* rotation,
    Vector3* scale);

// Optional C++ math operators
//-------------------------------------------------------------------------------

// Vector2 operators

// Vector3 operators

// Vector4 operators

// Quaternion operators

// Matrix operators

//-------------------------------------------------------------------------------
// C++ operators

// RAYMATH_H

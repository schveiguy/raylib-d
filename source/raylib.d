module raylib;

public
{
    import rlgl;
    import raymath;
    import raymathext;
}
/**********************************************************************************************
*
*   raylib - A simple and easy-to-use library to enjoy videogames programming (www.raylib.com)
*
*   FEATURES:
*       - NO external dependencies, all required libraries included with raylib
*       - Multiplatform: Windows, Linux, FreeBSD, OpenBSD, NetBSD, DragonFly, MacOS, UWP, Android, Raspberry Pi, HTML5.
*       - Written in plain C code (C99) in PascalCase/camelCase notation
*       - Hardware accelerated with OpenGL (1.1, 2.1, 3.3 or ES2 - choose at compile)
*       - Unique OpenGL abstraction layer (usable as standalone module): [rlgl]
*       - Multiple Fonts formats supported (TTF, XNA fonts, AngelCode fonts)
*       - Outstanding texture formats support, including compressed formats (DXT, ETC, ASTC)
*       - Full 3d support for 3d Shapes, Models, Billboards, Heightmaps and more!
*       - Flexible Materials system, supporting classic maps and PBR maps
*       - Skeletal Animation support (CPU bones-based animation)
*       - Shaders support, including Model shaders and Postprocessing shaders
*       - Powerful math module for Vector, Matrix and Quaternion operations: [raymath]
*       - Audio loading and playing with streaming support (WAV, OGG, MP3, FLAC, XM, MOD)
*       - VR stereo rendering with configurable HMD device parameters
*       - Bindings to multiple programming languages available!
*
*   NOTES:
*       One custom font is loaded by default when InitWindow () [core]
*       If using OpenGL 3.3 or ES2, one default shader is loaded automatically (internally defined) [rlgl]
*       If using OpenGL 3.3 or ES2, several vertex buffers (VAO/VBO) are created to manage lines-triangles-quads
*
*   DEPENDENCIES (included):
*       [core] rglfw (github.com/glfw/glfw) for window/context management and input (only PLATFORM_DESKTOP)
*       [rlgl] glad (github.com/Dav1dde/glad) for OpenGL 3.3 extensions loading (only PLATFORM_DESKTOP)
*       [raudio] miniaudio (github.com/dr-soft/miniaudio) for audio device/context management
*
*   OPTIONAL DEPENDENCIES (included):
*       [core] rgif (Charlie Tangora, Ramon Santamaria) for GIF recording
*       [textures] stb_image (Sean Barret) for images loading (BMP, TGA, PNG, JPEG, HDR...)
*       [textures] stb_image_write (Sean Barret) for image writting (BMP, TGA, PNG, JPG)
*       [textures] stb_image_resize (Sean Barret) for image resizing algorithms
*       [textures] stb_perlin (Sean Barret) for Perlin noise image generation
*       [text] stb_truetype (Sean Barret) for ttf fonts loading
*       [text] stb_rect_pack (Sean Barret) for rectangles packing
*       [models] par_shapes (Philip Rideout) for parametric 3d shapes generation
*       [models] tinyobj_loader_c (Syoyo Fujita) for models loading (OBJ, MTL)
*       [models] cgltf (Johannes Kuhlmann) for models loading (glTF)
*       [raudio] stb_vorbis (Sean Barret) for OGG audio loading
*       [raudio] dr_flac (David Reid) for FLAC audio file loading
*       [raudio] dr_mp3 (David Reid) for MP3 audio file loading
*       [raudio] jar_xm (Joshua Reisenauer) for XM audio module loading
*       [raudio] jar_mod (Joshua Reisenauer) for MOD audio module loading
*
*
*   LICENSE: zlib/libpng
*
*   raylib is licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software:
*
*   Copyright (c) 2013-2020 Ramon Santamaria (@raysan5)
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

import core.stdc.config;
import core.stdc.stdarg;
import core.stdc.stdlib;

extern (C) @nogc nothrow:

// Required for: va_list - Only used by TraceLogCallback

// We are building raylib as a Win32 shared library (.dll)
// We are using raylib as a Win32 shared library (.dll) // We are building or using raylib as a static library (or Linux shared library)

//----------------------------------------------------------------------------------
// Some basic Defines
//----------------------------------------------------------------------------------

enum PI = 3.14159265358979323846f;

enum DEG2RAD = PI / 180.0f;
enum RAD2DEG = 180.0f / PI;

enum MAX_TOUCH_POINTS = 10; // Maximum number of touch points supported

// Shader and material limits
enum MAX_SHADER_LOCATIONS = 32; // Maximum number of predefined locations stored in shader struct
enum MAX_MATERIAL_MAPS = 12; // Maximum number of texture maps stored in shader struct

// Allow custom memory allocators

alias RL_MALLOC = malloc;

alias RL_CALLOC = calloc;

alias RL_FREE = free;

// NOTE: MSC C++ compiler does not support compound literals (C99 feature)
// Plain structures in C++ (without constructors) can be initialized from { } initializers.

alias CLITERAL = Color;

// Some Basic Colors
// NOTE: Custom raylib color palette for amazing visuals on WHITE background // Light Gray // Gray // Dark Gray // Yellow // Gold // Orange // Pink // Red // Maroon // Green // Lime // Dark Green // Sky Blue // Blue // Dark Blue // Purple // Violet // Dark Purple // Beige // Brown // Dark Brown // White // Black // Blank (Transparent) // Magenta // My own White (raylib logo)
const LIGHTGRAY = Color(200, 200, 200, 255); // Light Gray
const GRAY = Color(130, 130, 130, 255); // Gray
const DARKGRAY = Color(80, 80, 80, 255); // Dark Gray
const YELLOW = Color(253, 249, 0, 255); // Yellow
const GOLD = Color(255, 203, 0, 255); // Gold
const ORANGE = Color(255, 161, 0, 255); // Orange
const PINK = Color(255, 109, 194, 255); // Pink
const RED = Color(230, 41, 55, 255); // Red
const MAROON = Color(190, 33, 55, 255); // Maroon
const GREEN = Color(0, 228, 48, 255); // Green
const LIME = Color(0, 158, 47, 255); // Lime
const DARKGREEN = Color(0, 117, 44, 255); // Dark Green
const SKYBLUE = Color(102, 191, 255, 255); // Sky Blue
const BLUE = Color(0, 121, 241, 255); // Blue
const DARKBLUE = Color(0, 82, 172, 255); // Dark Blue
const PURPLE = Color(200, 122, 255, 255); // Purple
const VIOLET = Color(135, 60, 190, 255); // Violet
const DARKPURPLE = Color(112, 31, 126, 255); // Dark Purple
const BEIGE = Color(211, 176, 131, 255); // Beige
const BROWN = Color(127, 106, 79, 255); // Brown
const DARKBROWN = Color(76, 63, 47, 255); // Dark Brown

const WHITE = Color(255, 255, 255, 255); // White
const BLACK = Color(0, 0, 0, 255); // Black
const BLANK = Color(0, 0, 0, 0); // Blank (Transparent)
const MAGENTA = Color(255, 0, 255, 255); // Magenta
const RAYWHITE = Color(245, 245, 245, 255); // My own White (raylib logo)

//----------------------------------------------------------------------------------
// Structures Definition
//----------------------------------------------------------------------------------
// Vector2 type
struct Vector2
{
    float x = 0.0f;
    float y = 0.0f;
    mixin Linear;
}

struct Bivector2
{
    float xy = 0.0f;
    alias xy this;
    mixin Linear;
}

// Vector3 type
struct Vector3
{
    float x = 0.0f;
    float y = 0.0f;
    float z = 0.0f;
    mixin Linear;
}

// Bivector3 type
/// Beware of the field order
/// xy is the first field
struct Bivector3
{
    float xy = 0.0f;
    float yz = 0.0f;
    float zx = 0.0f;
    mixin Linear;
}

// Rotor type
struct Rotor3
{
    float a = 1.0f;
    float xy = 0.0f;
    float yz = 0.0f;
    float zx = 0.0f;
    mixin Linear;

    alias i = yz;
    alias j = zx;
    alias k = xy;

    @property Bivector3 b()
    {
        return Bivector3(xy, yz, zx);
    }

    @property Bivector3 b(Bivector3 _b)
    {
        xy = _b.xy;
        yz = _b.yz;
        zx = _b.zx;
        return _b;
    }

    this(float _a, Bivector3 _b)
    {
        a = _a;
        b = _b;
    }

    this(float _a, float _xy, float _yz, float _zx)
    {
        a = _a;
        xy = _xy;
        yz = _yz;
        zx = _zx;
    }
}

alias Quaternion = Rotor3;

// Vector4 type
struct Vector4
{
    float x = 0.0f;
    float y = 0.0f;
    float z = 0.0f;
    float w = 0.0f;
    mixin Linear;
}

// Matrix type (OpenGL style 4x4 - right handed, column major)
struct Matrix4
{
    float m0 = 0.0f;
    float m4 = 0.0f;
    float m8 = 0.0f;
    float m12 = 0.0f;
    float m1 = 0.0f;
    float m5 = 0.0f;
    float m9 = 0.0f;
    float m13 = 0.0f;
    float m2 = 0.0f;
    float m6 = 0.0f;
    float m10 = 0.0f;
    float m14 = 0.0f;
    float m3 = 0.0f;
    float m7 = 0.0f;
    float m11 = 0.0f;
    float m15 = 0.0f;
    mixin Linear;
}

alias Matrix = Matrix4;

// Color type, RGBA (32bit)
struct Color
{
    ubyte r;
    ubyte g;
    ubyte b;
    ubyte a;
}

// Rectangle type
struct Rectangle
{
    float x = 0.0f;
    float y = 0.0f;
    float width = 0.0f;
    float height = 0.0f;
    alias w = width;
    alias h = height;
}

// Image type, bpp always RGBA (32bit)
// NOTE: Data stored in CPU memory (RAM)
struct Image
{
    void* data; // Image raw data
    int width; // Image base width
    int height; // Image base height
    int mipmaps; // Mipmap levels, 1 by default
    int format; // Data format (PixelFormat type)
}

// Texture2D type
// NOTE: Data stored in GPU memory
struct Texture2D
{
    uint id; // OpenGL texture id
    int width; // Texture base width
    int height; // Texture base height
    int mipmaps; // Mipmap levels, 1 by default
    int format; // Data format (PixelFormat type)
}

// Texture type, same as Texture2D
alias Texture = Texture2D;

// TextureCubemap type, actually, same as Texture2D
alias TextureCubemap = Texture2D;

// RenderTexture2D type, for texture rendering
struct RenderTexture2D
{
    uint id; // OpenGL Framebuffer Object (FBO) id
    Texture2D texture; // Color buffer attachment texture
    Texture2D depth; // Depth buffer attachment texture
    bool depthTexture; // Track if depth attachment is a texture or renderbuffer
}

// RenderTexture type, same as RenderTexture2D
alias RenderTexture = RenderTexture2D;

// N-Patch layout info
struct NPatchInfo
{
    Rectangle sourceRec; // Region in the texture
    int left; // left border offset
    int top; // top border offset
    int right; // right border offset
    int bottom; // bottom border offset
    int type; // layout of the n-patch: 3x3, 1x3 or 3x1
}

// Font character info
struct CharInfo
{
    int value; // Character value (Unicode)
    int offsetX; // Character offset X when drawing
    int offsetY; // Character offset Y when drawing
    int advanceX; // Character advance position X
    Image image; // Character image data
}

// Font type, includes texture and charSet array data
struct Font
{
    int baseSize; // Base size (default chars height)
    int charsCount; // Number of characters
    Texture2D texture; // Characters texture atlas
    Rectangle* recs; // Characters rectangles in texture
    CharInfo* chars; // Characters info data
}

alias SpriteFont = Font; // SpriteFont type fallback, defaults to Font

// Camera type, defines a camera position/orientation in 3d space
struct Camera3D
{
    Vector3 position; // Camera position
    Vector3 target; // Camera target it looks-at
    Vector3 up; // Camera up vector (rotation over its axis)
    float fovy; // Camera field-of-view apperture in Y (degrees) in perspective, used as near plane width in orthographic
    CameraType type; // Camera type, defines projection type: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
}

alias Camera = Camera3D; // Camera type fallback, defaults to Camera3D

// Camera2D type, defines a 2d camera
struct Camera2D
{
    Vector2 offset; // Camera offset (displacement from target)
    Vector2 target; // Camera target (rotation and zoom origin)
    float rotation = 0.0f; // Camera rotation in degrees
    float zoom = 1.0f; // Camera zoom (scaling), should be 1.0f by default
}

// Vertex data definning a mesh
// NOTE: Data stored in CPU memory (and GPU)
struct Mesh
{
    int vertexCount; // Number of vertices stored in arrays
    int triangleCount; // Number of triangles stored (indexed or not)

    // Default vertex data
    float* vertices; // Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    float* texcoords; // Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    float* texcoords2; // Vertex second texture coordinates (useful for lightmaps) (shader-location = 5)
    float* normals; // Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
    float* tangents; // Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
    ubyte* colors; // Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
    ushort* indices; // Vertex indices (in case vertex data comes indexed)

    // Animation vertex data
    float* animVertices; // Animated vertex positions (after bones transformations)
    float* animNormals; // Animated normals (after bones transformations)
    int* boneIds; // Vertex bone ids, up to 4 bones influence by vertex (skinning)
    float* boneWeights; // Vertex bone weight, up to 4 bones influence by vertex (skinning)

    // OpenGL identifiers
    uint vaoId; // OpenGL Vertex Array Object id
    uint[7] vboId; // OpenGL Vertex Buffer Objects id (default vertex data)
}

// Shader type (generic)
struct Shader
{
    uint id; // Shader program id
    int[MAX_SHADER_LOCATIONS] locs; // Shader locations array
}

// Material texture map
struct MaterialMap
{
    Texture2D texture; // Material map texture
    Color color; // Material map color
    float value; // Material map value
}

// Material type (generic)
struct Material
{
    Shader shader; // Material shader
    MaterialMap[MAX_MATERIAL_MAPS] maps; // Material maps
    float* params; // Material generic parameters (if required)
}

// Transformation properties
struct Transform
{
    Vector3 translation; // Translation
    Quaternion rotation; // Rotation
    Vector3 scale; // Scale
}

// Bone information
struct BoneInfo
{
    char[32] name; // Bone name
    int parent; // Bone parent
}

// Model type
struct Model
{
    Matrix transform; // Local transform matrix

    int meshCount; // Number of meshes
    Mesh* meshes; // Meshes array

    int materialCount; // Number of materials
    Material* materials; // Materials array
    int* meshMaterial; // Mesh material number

    // Animation data
    int boneCount; // Number of bones
    BoneInfo* bones; // Bones information (skeleton)
    Transform* bindPose; // Bones base transformation (pose)
}

// Model animation
struct ModelAnimation
{
    int boneCount; // Number of bones
    BoneInfo* bones; // Bones information (skeleton)

    int frameCount; // Number of animation frames
    Transform** framePoses; // Poses array by frame
}

// Ray type (useful for raycast)
struct Ray
{
    Vector3 position; // Ray position (origin)
    Vector3 direction; // Ray direction
}

// Raycast hit information
struct RayHitInfo
{
    bool hit; // Did the ray hit something?
    float distance; // Distance to nearest hit
    Vector3 position; // Position of nearest hit
    Vector3 normal; // Surface normal of hit
}

// Bounding box type
struct BoundingBox
{
    Vector3 min; // Minimum vertex box-corner
    Vector3 max; // Maximum vertex box-corner
}

// Wave type, defines audio wave data
struct Wave
{
    uint sampleCount; // Number of samples
    uint sampleRate; // Frequency (samples per second)
    uint sampleSize; // Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    uint channels; // Number of channels (1-mono, 2-stereo)
    void* data; // Buffer data pointer
}

struct rAudioBuffer;

// Audio stream type
// NOTE: Useful to create custom audio streams not bound to a specific file
struct AudioStream
{
    uint sampleRate; // Frequency (samples per second)
    uint sampleSize; // Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    uint channels; // Number of channels (1-mono, 2-stereo)

    rAudioBuffer* buffer; // Pointer to internal data used by the audio system
};

// Sound source type
struct Sound
{
    uint sampleCount; // Total number of samples
    AudioStream stream; // Audio stream
};

// Music stream type (audio file streaming from memory)
// NOTE: Anything longer than ~10 seconds should be streamed
struct Music
{
    int ctxType; // Type of music context (audio filetype)
    void* ctxData; // Audio context data, depends on type

    uint sampleCount; // Total number of samples
    uint loopCount; // Loops count (times music will play), 0 means infinite loop

    AudioStream stream; // Audio stream
};

// Head-Mounted-Display device parameters
struct VrDeviceInfo
{
    int hResolution; // HMD horizontal resolution in pixels
    int vResolution; // HMD vertical resolution in pixels
    float hScreenSize; // HMD horizontal size in meters
    float vScreenSize; // HMD vertical size in meters
    float vScreenCenter; // HMD screen center in meters
    float eyeToScreenDistance; // HMD distance between eye and display in meters
    float lensSeparationDistance; // HMD lens separation distance in meters
    float interpupillaryDistance; // HMD IPD (distance between pupils) in meters
    float[4] lensDistortionValues; // HMD lens distortion constant parameters
    float[4] chromaAbCorrection; // HMD chromatic aberration correction parameters
}

//----------------------------------------------------------------------------------
// Enumerators Definition
//----------------------------------------------------------------------------------
// System config flags
// NOTE: Used for bit masks
enum ConfigFlag
{
    FLAG_RESERVED = 1, // Reserved
    FLAG_FULLSCREEN_MODE = 2, // Set to run program in fullscreen
    FLAG_WINDOW_RESIZABLE = 4, // Set to allow resizable window
    FLAG_WINDOW_UNDECORATED = 8, // Set to disable window decoration (frame and buttons)
    FLAG_WINDOW_TRANSPARENT = 16, // Set to allow transparent window
    FLAG_WINDOW_HIDDEN = 128, // Set to create the window initially hidden
    FLAG_WINDOW_ALWAYS_RUN = 256, // Set to allow windows running while minimized
    FLAG_MSAA_4X_HINT = 32, // Set to try enabling MSAA 4X
    FLAG_VSYNC_HINT = 64 // Set to try enabling V-Sync on GPU
}

// Trace log type
enum TraceLogType
{
    LOG_ALL = 0, // Display all logs
    LOG_TRACE = 1,
    LOG_DEBUG = 2,
    LOG_INFO = 3,
    LOG_WARNING = 4,
    LOG_ERROR = 5,
    LOG_FATAL = 6,
    LOG_NONE = 7 // Disable logging
}

// Keyboard keys
enum KeyboardKey
{
    // Alphanumeric keys
    KEY_APOSTROPHE = 39,
    KEY_COMMA = 44,
    KEY_MINUS = 45,
    KEY_PERIOD = 46,
    KEY_SLASH = 47,
    KEY_ZERO = 48,
    KEY_ONE = 49,
    KEY_TWO = 50,
    KEY_THREE = 51,
    KEY_FOUR = 52,
    KEY_FIVE = 53,
    KEY_SIX = 54,
    KEY_SEVEN = 55,
    KEY_EIGHT = 56,
    KEY_NINE = 57,
    KEY_SEMICOLON = 59,
    KEY_EQUAL = 61,
    KEY_A = 65,
    KEY_B = 66,
    KEY_C = 67,
    KEY_D = 68,
    KEY_E = 69,
    KEY_F = 70,
    KEY_G = 71,
    KEY_H = 72,
    KEY_I = 73,
    KEY_J = 74,
    KEY_K = 75,
    KEY_L = 76,
    KEY_M = 77,
    KEY_N = 78,
    KEY_O = 79,
    KEY_P = 80,
    KEY_Q = 81,
    KEY_R = 82,
    KEY_S = 83,
    KEY_T = 84,
    KEY_U = 85,
    KEY_V = 86,
    KEY_W = 87,
    KEY_X = 88,
    KEY_Y = 89,
    KEY_Z = 90,

    // Function keys
    KEY_SPACE = 32,
    KEY_ESCAPE = 256,
    KEY_ENTER = 257,
    KEY_TAB = 258,
    KEY_BACKSPACE = 259,
    KEY_INSERT = 260,
    KEY_DELETE = 261,
    KEY_RIGHT = 262,
    KEY_LEFT = 263,
    KEY_DOWN = 264,
    KEY_UP = 265,
    KEY_PAGE_UP = 266,
    KEY_PAGE_DOWN = 267,
    KEY_HOME = 268,
    KEY_END = 269,
    KEY_CAPS_LOCK = 280,
    KEY_SCROLL_LOCK = 281,
    KEY_NUM_LOCK = 282,
    KEY_PRINT_SCREEN = 283,
    KEY_PAUSE = 284,
    KEY_F1 = 290,
    KEY_F2 = 291,
    KEY_F3 = 292,
    KEY_F4 = 293,
    KEY_F5 = 294,
    KEY_F6 = 295,
    KEY_F7 = 296,
    KEY_F8 = 297,
    KEY_F9 = 298,
    KEY_F10 = 299,
    KEY_F11 = 300,
    KEY_F12 = 301,
    KEY_LEFT_SHIFT = 340,
    KEY_LEFT_CONTROL = 341,
    KEY_LEFT_ALT = 342,
    KEY_LEFT_SUPER = 343,
    KEY_RIGHT_SHIFT = 344,
    KEY_RIGHT_CONTROL = 345,
    KEY_RIGHT_ALT = 346,
    KEY_RIGHT_SUPER = 347,
    KEY_KB_MENU = 348,
    KEY_LEFT_BRACKET = 91,
    KEY_BACKSLASH = 92,
    KEY_RIGHT_BRACKET = 93,
    KEY_GRAVE = 96,

    // Keypad keys
    KEY_KP_0 = 320,
    KEY_KP_1 = 321,
    KEY_KP_2 = 322,
    KEY_KP_3 = 323,
    KEY_KP_4 = 324,
    KEY_KP_5 = 325,
    KEY_KP_6 = 326,
    KEY_KP_7 = 327,
    KEY_KP_8 = 328,
    KEY_KP_9 = 329,
    KEY_KP_DECIMAL = 330,
    KEY_KP_DIVIDE = 331,
    KEY_KP_MULTIPLY = 332,
    KEY_KP_SUBTRACT = 333,
    KEY_KP_ADD = 334,
    KEY_KP_ENTER = 335,
    KEY_KP_EQUAL = 336
}

// Android buttons
enum AndroidButton
{
    KEY_BACK = 4,
    KEY_MENU = 82,
    KEY_VOLUME_UP = 24,
    KEY_VOLUME_DOWN = 25
}

// Mouse buttons
enum MouseButton
{
    MOUSE_LEFT_BUTTON = 0,
    MOUSE_RIGHT_BUTTON = 1,
    MOUSE_MIDDLE_BUTTON = 2
}

// Gamepad number
enum GamepadNumber
{
    GAMEPAD_PLAYER1 = 0,
    GAMEPAD_PLAYER2 = 1,
    GAMEPAD_PLAYER3 = 2,
    GAMEPAD_PLAYER4 = 3
}

// Gamepad Buttons
enum GamepadButton
{
    // This is here just for error checking
    GAMEPAD_BUTTON_UNKNOWN = 0,

    // This is normally a DPAD
    GAMEPAD_BUTTON_LEFT_FACE_UP = 1,
    GAMEPAD_BUTTON_LEFT_FACE_RIGHT = 2,
    GAMEPAD_BUTTON_LEFT_FACE_DOWN = 3,
    GAMEPAD_BUTTON_LEFT_FACE_LEFT = 4,

    // This normally corresponds with PlayStation and Xbox controllers
    // XBOX: [Y,X,A,B]
    // PS3: [Triangle,Square,Cross,Circle]
    // No support for 6 button controllers though..
    GAMEPAD_BUTTON_RIGHT_FACE_UP = 5,
    GAMEPAD_BUTTON_RIGHT_FACE_RIGHT = 6,
    GAMEPAD_BUTTON_RIGHT_FACE_DOWN = 7,
    GAMEPAD_BUTTON_RIGHT_FACE_LEFT = 8,

    // Triggers
    GAMEPAD_BUTTON_LEFT_TRIGGER_1 = 9,
    GAMEPAD_BUTTON_LEFT_TRIGGER_2 = 10,
    GAMEPAD_BUTTON_RIGHT_TRIGGER_1 = 11,
    GAMEPAD_BUTTON_RIGHT_TRIGGER_2 = 12,

    // These are buttons in the center of the gamepad
    GAMEPAD_BUTTON_MIDDLE_LEFT = 13, //PS3 Select
    GAMEPAD_BUTTON_MIDDLE = 14, //PS Button/XBOX Button
    GAMEPAD_BUTTON_MIDDLE_RIGHT = 15, //PS3 Start

    // These are the joystick press in buttons
    GAMEPAD_BUTTON_LEFT_THUMB = 16,
    GAMEPAD_BUTTON_RIGHT_THUMB = 17
}

enum GamepadAxis
{
    // This is here just for error checking
    GAMEPAD_AXIS_UNKNOWN = 0,

    // Left stick
    GAMEPAD_AXIS_LEFT_X = 1,
    GAMEPAD_AXIS_LEFT_Y = 2,

    // Right stick
    GAMEPAD_AXIS_RIGHT_X = 3,
    GAMEPAD_AXIS_RIGHT_Y = 4,

    // Pressure levels for the back triggers
    GAMEPAD_AXIS_LEFT_TRIGGER = 5, // [1..-1] (pressure-level)
    GAMEPAD_AXIS_RIGHT_TRIGGER = 6 // [1..-1] (pressure-level)
}

// Shader location point type
enum ShaderLocationIndex
{
    LOC_VERTEX_POSITION = 0,
    LOC_VERTEX_TEXCOORD01 = 1,
    LOC_VERTEX_TEXCOORD02 = 2,
    LOC_VERTEX_NORMAL = 3,
    LOC_VERTEX_TANGENT = 4,
    LOC_VERTEX_COLOR = 5,
    LOC_MATRIX_MVP = 6,
    LOC_MATRIX_MODEL = 7,
    LOC_MATRIX_VIEW = 8,
    LOC_MATRIX_PROJECTION = 9,
    LOC_VECTOR_VIEW = 10,
    LOC_COLOR_DIFFUSE = 11,
    LOC_COLOR_SPECULAR = 12,
    LOC_COLOR_AMBIENT = 13,
    LOC_MAP_ALBEDO = 14, // LOC_MAP_DIFFUSE
    LOC_MAP_METALNESS = 15, // LOC_MAP_SPECULAR
    LOC_MAP_NORMAL = 16,
    LOC_MAP_ROUGHNESS = 17,
    LOC_MAP_OCCLUSION = 18,
    LOC_MAP_EMISSION = 19,
    LOC_MAP_HEIGHT = 20,
    LOC_MAP_CUBEMAP = 21,
    LOC_MAP_IRRADIANCE = 22,
    LOC_MAP_PREFILTER = 23,
    LOC_MAP_BRDF = 24
}

enum LOC_MAP_DIFFUSE = ShaderLocationIndex.LOC_MAP_ALBEDO;
enum LOC_MAP_SPECULAR = ShaderLocationIndex.LOC_MAP_METALNESS;

// Shader uniform data types
enum ShaderUniformDataType
{
    UNIFORM_FLOAT = 0,
    UNIFORM_VEC2 = 1,
    UNIFORM_VEC3 = 2,
    UNIFORM_VEC4 = 3,
    UNIFORM_INT = 4,
    UNIFORM_IVEC2 = 5,
    UNIFORM_IVEC3 = 6,
    UNIFORM_IVEC4 = 7,
    UNIFORM_SAMPLER2D = 8
}

// Material map type
enum MaterialMapType
{
    MAP_ALBEDO = 0, // MAP_DIFFUSE
    MAP_METALNESS = 1, // MAP_SPECULAR
    MAP_NORMAL = 2,
    MAP_ROUGHNESS = 3,
    MAP_OCCLUSION = 4,
    MAP_EMISSION = 5,
    MAP_HEIGHT = 6,
    MAP_CUBEMAP = 7, // NOTE: Uses GL_TEXTURE_CUBE_MAP
    MAP_IRRADIANCE = 8, // NOTE: Uses GL_TEXTURE_CUBE_MAP
    MAP_PREFILTER = 9, // NOTE: Uses GL_TEXTURE_CUBE_MAP
    MAP_BRDF = 10
}

enum MAP_DIFFUSE = MaterialMapType.MAP_ALBEDO;
enum MAP_SPECULAR = MaterialMapType.MAP_METALNESS;

// Pixel formats
// NOTE: Support depends on OpenGL version and platform
enum PixelFormat
{
    UNCOMPRESSED_GRAYSCALE = 1, // 8 bit per pixel (no alpha)
    UNCOMPRESSED_GRAY_ALPHA = 2, // 8*2 bpp (2 channels)
    UNCOMPRESSED_R5G6B5 = 3, // 16 bpp
    UNCOMPRESSED_R8G8B8 = 4, // 24 bpp
    UNCOMPRESSED_R5G5B5A1 = 5, // 16 bpp (1 bit alpha)
    UNCOMPRESSED_R4G4B4A4 = 6, // 16 bpp (4 bit alpha)
    UNCOMPRESSED_R8G8B8A8 = 7, // 32 bpp
    UNCOMPRESSED_R32 = 8, // 32 bpp (1 channel - float)
    UNCOMPRESSED_R32G32B32 = 9, // 32*3 bpp (3 channels - float)
    UNCOMPRESSED_R32G32B32A32 = 10, // 32*4 bpp (4 channels - float)
    COMPRESSED_DXT1_RGB = 11, // 4 bpp (no alpha)
    COMPRESSED_DXT1_RGBA = 12, // 4 bpp (1 bit alpha)
    COMPRESSED_DXT3_RGBA = 13, // 8 bpp
    COMPRESSED_DXT5_RGBA = 14, // 8 bpp
    COMPRESSED_ETC1_RGB = 15, // 4 bpp
    COMPRESSED_ETC2_RGB = 16, // 4 bpp
    COMPRESSED_ETC2_EAC_RGBA = 17, // 8 bpp
    COMPRESSED_PVRT_RGB = 18, // 4 bpp
    COMPRESSED_PVRT_RGBA = 19, // 4 bpp
    COMPRESSED_ASTC_4x4_RGBA = 20, // 8 bpp
    COMPRESSED_ASTC_8x8_RGBA = 21 // 2 bpp
}

// Texture parameters: filter mode
// NOTE 1: Filtering considers mipmaps if available in the texture
// NOTE 2: Filter is accordingly set for minification and magnification
enum TextureFilterMode
{
    FILTER_POINT = 0, // No filter, just pixel aproximation
    FILTER_BILINEAR = 1, // Linear filtering
    FILTER_TRILINEAR = 2, // Trilinear filtering (linear with mipmaps)
    FILTER_ANISOTROPIC_4X = 3, // Anisotropic filtering 4x
    FILTER_ANISOTROPIC_8X = 4, // Anisotropic filtering 8x
    FILTER_ANISOTROPIC_16X = 5 // Anisotropic filtering 16x
}

// Cubemap layout type
enum CubemapLayoutType
{
    CUBEMAP_AUTO_DETECT = 0, // Automatically detect layout type
    CUBEMAP_LINE_VERTICAL = 1, // Layout is defined by a vertical line with faces
    CUBEMAP_LINE_HORIZONTAL = 2, // Layout is defined by an horizontal line with faces
    CUBEMAP_CROSS_THREE_BY_FOUR = 3, // Layout is defined by a 3x4 cross with cubemap faces
    CUBEMAP_CROSS_FOUR_BY_THREE = 4, // Layout is defined by a 4x3 cross with cubemap faces
    CUBEMAP_PANORAMA = 5 // Layout is defined by a panorama image (equirectangular map)
}

// Texture parameters: wrap mode
enum TextureWrapMode
{
    WRAP_REPEAT = 0, // Repeats texture in tiled mode
    WRAP_CLAMP = 1, // Clamps texture to edge pixel in tiled mode
    WRAP_MIRROR_REPEAT = 2, // Mirrors and repeats the texture in tiled mode
    WRAP_MIRROR_CLAMP = 3 // Mirrors and clamps to border the texture in tiled mode
}

// Font type, defines generation method
enum FontType
{
    FONT_DEFAULT = 0, // Default font generation, anti-aliased
    FONT_BITMAP = 1, // Bitmap font generation, no anti-aliasing
    FONT_SDF = 2 // SDF font generation, requires external shader
}

// Color blending modes (pre-defined)
enum BlendMode
{
    BLEND_ALPHA = 0, // Blend textures considering alpha (default)
    BLEND_ADDITIVE = 1, // Blend textures adding colors
    BLEND_MULTIPLIED = 2 // Blend textures multiplying colors
}

// Gestures type
// NOTE: It could be used as flags to enable only some gestures
enum GestureType
{
    GESTURE_NONE = 0,
    GESTURE_TAP = 1,
    GESTURE_DOUBLETAP = 2,
    GESTURE_HOLD = 4,
    GESTURE_DRAG = 8,
    GESTURE_SWIPE_RIGHT = 16,
    GESTURE_SWIPE_LEFT = 32,
    GESTURE_SWIPE_UP = 64,
    GESTURE_SWIPE_DOWN = 128,
    GESTURE_PINCH_IN = 256,
    GESTURE_PINCH_OUT = 512
}

// Camera system modes
enum CameraMode
{
    CAMERA_CUSTOM = 0,
    CAMERA_FREE = 1,
    CAMERA_ORBITAL = 2,
    CAMERA_FIRST_PERSON = 3,
    CAMERA_THIRD_PERSON = 4
}

// Camera projection modes
enum CameraType : int
{
    CAMERA_PERSPECTIVE = 0,
    CAMERA_ORTHOGRAPHIC = 1
}

// Type of n-patch
enum NPatchType
{
    NPT_9PATCH = 0, // Npatch defined by 3x3 tiles
    NPT_3PATCH_VERTICAL = 1, // Npatch defined by 1x3 tiles
    NPT_3PATCH_HORIZONTAL = 2 // Npatch defined by 3x1 tiles
}

// Callbacks to be implemented by users
alias TraceLogCallback = void function(int logType, const(char)* text, va_list args);

// Prevents name mangling of functions

//------------------------------------------------------------------------------------
// Global Variables Definition
//------------------------------------------------------------------------------------
// It's lonely here...

//------------------------------------------------------------------------------------
// Window and Graphics Device Functions (Module: core)
//------------------------------------------------------------------------------------

// Window-related functions
void InitWindow(int width, int height, const(char)* title); // Initialize window and OpenGL context
bool WindowShouldClose(); // Check if KEY_ESCAPE pressed or Close icon pressed
void CloseWindow(); // Close window and unload OpenGL context
bool IsWindowReady(); // Check if window has been initialized successfully
bool IsWindowMinimized(); // Check if window has been minimized (or lost focus)
bool IsWindowResized(); // Check if window has been resized
bool IsWindowHidden(); // Check if window is currently hidden
bool IsWindowFullscreen(); // Check if window is currently fullscreen
void ToggleFullscreen(); // Toggle fullscreen mode (only PLATFORM_DESKTOP)
void UnhideWindow(); // Show the window
void HideWindow(); // Hide the window
void SetWindowIcon(Image image); // Set icon for window (only PLATFORM_DESKTOP)
void SetWindowTitle(const(char)* title); // Set title for window (only PLATFORM_DESKTOP)
void SetWindowPosition(int x, int y); // Set window position on screen (only PLATFORM_DESKTOP)
void SetWindowMonitor(int monitor); // Set monitor for the current window (fullscreen mode)
void SetWindowMinSize(int width, int height); // Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)
void SetWindowSize(int width, int height); // Set window dimensions
void* GetWindowHandle(); // Get native window handle
int GetScreenWidth(); // Get current screen width
int GetScreenHeight(); // Get current screen height
int GetMonitorCount(); // Get number of connected monitors
int GetMonitorWidth(int monitor); // Get primary monitor width
int GetMonitorHeight(int monitor); // Get primary monitor height
int GetMonitorPhysicalWidth(int monitor); // Get primary monitor physical width in millimetres
int GetMonitorPhysicalHeight(int monitor); // Get primary monitor physical height in millimetres
Vector2 GetWindowPosition(); // Get window position XY on monitor
const(char)* GetMonitorName(int monitor); // Get the human-readable, UTF-8 encoded name of the primary monitor
const(char)* GetClipboardText(); // Get clipboard text content
void SetClipboardText(const(char)* text); // Set clipboard text content

// Cursor-related functions
void ShowCursor(); // Shows cursor
void HideCursor(); // Hides cursor
bool IsCursorHidden(); // Check if cursor is not visible
void EnableCursor(); // Enables cursor (unlock cursor)
void DisableCursor(); // Disables cursor (lock cursor)

// Drawing-related functions
void ClearBackground(Color color); // Set background color (framebuffer clear color)
void BeginDrawing(); // Setup canvas (framebuffer) to start drawing
void EndDrawing(); // End canvas drawing and swap buffers (double buffering)
void BeginMode2D(Camera2D camera); // Initialize 2D mode with custom camera (2D)
void EndMode2D(); // Ends 2D mode with custom camera
void BeginMode3D(Camera3D camera); // Initializes 3D mode with custom camera (3D)
void EndMode3D(); // Ends 3D mode and returns to default 2D orthographic mode
void BeginTextureMode(RenderTexture2D target); // Initializes render texture for drawing
void EndTextureMode(); // Ends drawing to render texture
void BeginScissorMode(int x, int y, int width, int height); // Begin scissor mode (define screen area for following drawing)
void EndScissorMode(); // End scissor mode

// Screen-space-related functions
Ray GetMouseRay(Vector2 mousePosition, Camera camera); // Returns a ray trace from mouse position
Matrix GetCameraMatrix(Camera camera); // Returns camera transform matrix (view matrix)
Matrix GetCameraMatrix2D(Camera2D camera); // Returns camera 2d transform matrix
Vector2 GetWorldToScreen(Vector3 position, Camera camera); // Returns the screen space position for a 3d world space position
Vector2 GetWorldToScreenEx(Vector3 position, Camera camera, int width, int height); // Returns size position for a 3d world space position
Vector2 GetWorldToScreen2D(Vector2 position, Camera2D camera); // Returns the screen space position for a 2d camera world space position
Vector2 GetScreenToWorld2D(Vector2 position, Camera2D camera); // Returns the world space position for a 2d camera screen space position

// Timing-related functions
void SetTargetFPS(int fps); // Set target FPS (maximum)
int GetFPS(); // Returns current FPS
float GetFrameTime(); // Returns time in seconds for last frame drawn
double GetTime(); // Returns elapsed time in seconds since InitWindow ()

// Color-related functions
int ColorToInt(Color color); // Returns hexadecimal value for a Color
Vector4 ColorNormalize(Color color); // Returns color normalized as float [0..1]
Color ColorFromNormalized(Vector4 normalized); // Returns color from normalized values [0..1]
Vector3 ColorToHSV(Color color); // Returns HSV values for a Color
Color ColorFromHSV(Vector3 hsv); // Returns a Color from HSV values
Color GetColor(int hexValue); // Returns a Color struct from hexadecimal value
Color Fade(Color color, float alpha); // Color fade-in or fade-out, alpha goes from 0.0f to 1.0f

// Misc. functions
void SetConfigFlags(ubyte flags); // Setup window configuration flags (view FLAGS)
void SetTraceLogLevel(int logType); // Set the current threshold (minimum) log level
void SetTraceLogExit(int logType); // Set the exit threshold (minimum) log level
void SetTraceLogCallback(TraceLogCallback callback); // Set a trace log callback to enable custom logging
void TraceLog(int logType, const(char)* text, ...); // Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR)
void TakeScreenshot(const(char)* fileName); // Takes a screenshot of current screen (saved a .png)
int GetRandomValue(int min, int max); // Returns a random value between min and max (both included)

// Files management functions
ubyte* LoadFileData(const(char)* fileName, uint* bytesRead); // Load file data as byte array (read)
void SaveFileData(const(char)* fileName, void* data, uint bytesToWrite); // Save data to file from byte array (write)
char* LoadFileText(const(char)* fileName); // Load text data from file (read), returns a '\0' terminated string
void SaveFileText(const(char)* fileName, char* text); // Save text data to file (write), string must be '\0' terminated
bool FileExists(const(char)* fileName); // Check if file exists
bool IsFileExtension(const(char)* fileName, const(char)* ext); // Check file extension
bool DirectoryExists(const(char)* dirPath); // Check if a directory path exists
const(char)* GetExtension(const(char)* fileName); // Get pointer to extension for a filename string
const(char)* GetFileName(const(char)* filePath); // Get pointer to filename for a path string
const(char)* GetFileNameWithoutExt(const(char)* filePath); // Get filename string without extension (uses static string)
const(char)* GetDirectoryPath(const(char)* filePath); // Get full path for a given fileName with path (uses static string)
const(char)* GetPrevDirectoryPath(const(char)* dirPath); // Get previous directory path for a given path (uses static string)
const(char)* GetWorkingDirectory(); // Get current working directory (uses static string)
char** GetDirectoryFiles(const(char)* dirPath, int* count); // Get filenames in a directory path (memory should be freed)
void ClearDirectoryFiles(); // Clear directory files paths buffers (free memory)
bool ChangeDirectory(const(char)* dir); // Change working directory, returns true if success
bool IsFileDropped(); // Check if a file has been dropped into window
char** GetDroppedFiles(int* count); // Get dropped files names (memory should be freed)
void ClearDroppedFiles(); // Clear dropped files paths buffer (free memory)
c_long GetFileModTime(const(char)* fileName); // Get file modification time (last write time)
ubyte* CompressData(ubyte* data, int dataLength, int* compDataLength); // Compress data (DEFLATE algorythm)
ubyte* DecompressData(ubyte* compData, int compDataLength, int* dataLength); // Decompress data (DEFLATE algorythm)

// Persistent storage management
void SaveStorageValue(uint position, int value); // Save integer value to storage file (to defined position)
int LoadStorageValue(uint position); // Load integer value from storage file (from defined position)

void OpenURL(const(char)* url); // Open URL with default system browser (if available)

//------------------------------------------------------------------------------------
// Input Handling Functions (Module: core)
//------------------------------------------------------------------------------------

// Input-related functions: keyboard
bool IsKeyPressed(int key); // Detect if a key has been pressed once
bool IsKeyDown(int key); // Detect if a key is being pressed
bool IsKeyReleased(int key); // Detect if a key has been released once
bool IsKeyUp(int key); // Detect if a key is NOT being pressed
void SetExitKey(int key); // Set a custom key to exit program (default is ESC)
int GetKeyPressed(); // Get key pressed, call it multiple times for chars queued

// Input-related functions: gamepads
bool IsGamepadAvailable(int gamepad); // Detect if a gamepad is available
bool IsGamepadName(int gamepad, const(char)* name); // Check gamepad name (if available)
const(char)* GetGamepadName(int gamepad); // Return gamepad internal name id
bool IsGamepadButtonPressed(int gamepad, int button); // Detect if a gamepad button has been pressed once
bool IsGamepadButtonDown(int gamepad, int button); // Detect if a gamepad button is being pressed
bool IsGamepadButtonReleased(int gamepad, int button); // Detect if a gamepad button has been released once
bool IsGamepadButtonUp(int gamepad, int button); // Detect if a gamepad button is NOT being pressed
int GetGamepadButtonPressed(); // Get the last gamepad button pressed
int GetGamepadAxisCount(int gamepad); // Return gamepad axis count for a gamepad
float GetGamepadAxisMovement(int gamepad, int axis); // Return axis movement value for a gamepad axis

// Input-related functions: mouse
bool IsMouseButtonPressed(int button); // Detect if a mouse button has been pressed once
bool IsMouseButtonDown(int button); // Detect if a mouse button is being pressed
bool IsMouseButtonReleased(int button); // Detect if a mouse button has been released once
bool IsMouseButtonUp(int button); // Detect if a mouse button is NOT being pressed
int GetMouseX(); // Returns mouse position X
int GetMouseY(); // Returns mouse position Y
Vector2 GetMousePosition(); // Returns mouse position XY
void SetMousePosition(int x, int y); // Set mouse position XY
void SetMouseOffset(int offsetX, int offsetY); // Set mouse offset
void SetMouseScale(float scaleX, float scaleY); // Set mouse scaling
int GetMouseWheelMove(); // Returns mouse wheel movement Y

// Input-related functions: touch
int GetTouchX(); // Returns touch position X for touch point 0 (relative to screen size)
int GetTouchY(); // Returns touch position Y for touch point 0 (relative to screen size)
Vector2 GetTouchPosition(int index); // Returns touch position XY for a touch point index (relative to screen size)

//------------------------------------------------------------------------------------
// Gestures and Touch Handling Functions (Module: gestures)
//------------------------------------------------------------------------------------
void SetGesturesEnabled(uint gestureFlags); // Enable a set of gestures using flags
bool IsGestureDetected(int gesture); // Check if a gesture have been detected
int GetGestureDetected(); // Get latest detected gesture
int GetTouchPointsCount(); // Get touch points count
float GetGestureHoldDuration(); // Get gesture hold time in milliseconds
Vector2 GetGestureDragVector(); // Get gesture drag vector
float GetGestureDragAngle(); // Get gesture drag angle
Vector2 GetGesturePinchVector(); // Get gesture pinch delta
float GetGesturePinchAngle(); // Get gesture pinch angle

//------------------------------------------------------------------------------------
// Camera System Functions (Module: camera)
//------------------------------------------------------------------------------------
void SetCameraMode(Camera camera, int mode); // Set camera mode (multiple camera modes available)
void UpdateCamera(Camera* camera); // Update camera position for selected mode

void SetCameraPanControl(int panKey); // Set camera pan key to combine with mouse movement (free camera)
void SetCameraAltControl(int altKey); // Set camera alt key to combine with mouse movement (free camera)
void SetCameraSmoothZoomControl(int szKey); // Set camera smooth zoom key to combine with mouse (free camera)
void SetCameraMoveControls(int frontKey, int backKey, int rightKey, int leftKey,
        int upKey, int downKey); // Set camera move controls (1st person and 3rd person cameras)

//------------------------------------------------------------------------------------
// Basic Shapes Drawing Functions (Module: shapes)
//------------------------------------------------------------------------------------

// Basic shapes drawing functions
void DrawPixel(int posX, int posY, Color color); // Draw a pixel
void DrawPixelV(Vector2 position, Color color); // Draw a pixel (Vector version)
void DrawLine(int startPosX, int startPosY, int endPosX, int endPosY, Color color); // Draw a line
void DrawLineV(Vector2 startPos, Vector2 endPos, Color color); // Draw a line (Vector version)
void DrawLineEx(Vector2 startPos, Vector2 endPos, float thick, Color color); // Draw a line defining thickness
void DrawLineBezier(Vector2 startPos, Vector2 endPos, float thick, Color color); // Draw a line using cubic-bezier curves in-out
void DrawLineStrip(Vector2* points, int numPoints, Color color); // Draw lines sequence
void DrawCircle(int centerX, int centerY, float radius, Color color); // Draw a color-filled circle
void DrawCircleSector(Vector2 center, float radius, int startAngle, int endAngle,
        int segments, Color color); // Draw a piece of a circle
void DrawCircleSectorLines(Vector2 center, float radius, int startAngle,
        int endAngle, int segments, Color color); // Draw circle sector outline
void DrawCircleGradient(int centerX, int centerY, float radius, Color color1, Color color2); // Draw a gradient-filled circle
void DrawCircleV(Vector2 center, float radius, Color color); // Draw a color-filled circle (Vector version)
void DrawCircleLines(int centerX, int centerY, float radius, Color color); // Draw circle outline
void DrawEllipse(int centerX, int centerY, float radiusH, float radiusV, Color color); // Draw ellipse
void DrawEllipseLines(int centerX, int centerY, float radiusH, float radiusV, Color color); // Draw ellipse outline
void DrawRing(Vector2 center, float innerRadius, float outerRadius, int startAngle,
        int endAngle, int segments, Color color); // Draw ring
void DrawRingLines(Vector2 center, float innerRadius, float outerRadius,
        int startAngle, int endAngle, int segments, Color color); // Draw ring outline
void DrawRectangle(int posX, int posY, int width, int height, Color color); // Draw a color-filled rectangle
void DrawRectangleV(Vector2 position, Vector2 size, Color color); // Draw a color-filled rectangle (Vector version)
void DrawRectangleRec(Rectangle rec, Color color); // Draw a color-filled rectangle
void DrawRectanglePro(Rectangle rec, Vector2 origin, float rotation, Color color); // Draw a color-filled rectangle with pro parameters
void DrawRectangleGradientV(int posX, int posY, int width, int height, Color color1, Color color2); // Draw a vertical-gradient-filled rectangle
void DrawRectangleGradientH(int posX, int posY, int width, int height, Color color1, Color color2); // Draw a horizontal-gradient-filled rectangle
void DrawRectangleGradientEx(Rectangle rec, Color col1, Color col2, Color col3, Color col4); // Draw a gradient-filled rectangle with custom vertex colors
void DrawRectangleLines(int posX, int posY, int width, int height, Color color); // Draw rectangle outline
void DrawRectangleLinesEx(Rectangle rec, int lineThick, Color color); // Draw rectangle outline with extended parameters
void DrawRectangleRounded(Rectangle rec, float roundness, int segments, Color color); // Draw rectangle with rounded edges
void DrawRectangleRoundedLines(Rectangle rec, float roundness, int segments,
        int lineThick, Color color); // Draw rectangle with rounded edges outline
void DrawTriangle(Vector2 v1, Vector2 v2, Vector2 v3, Color color); // Draw a color-filled triangle (vertex in counter-clockwise order!)
void DrawTriangleLines(Vector2 v1, Vector2 v2, Vector2 v3, Color color); // Draw triangle outline (vertex in counter-clockwise order!)
void DrawTriangleFan(Vector2* points, int numPoints, Color color); // Draw a triangle fan defined by points (first vertex is the center)
void DrawTriangleStrip(Vector2* points, int pointsCount, Color color); // Draw a triangle strip defined by points
void DrawPoly(Vector2 center, int sides, float radius, float rotation, Color color); // Draw a regular polygon (Vector version)
void DrawPolyLines(Vector2 center, int sides, float radius, float rotation, Color color); // Draw a polygon outline of n sides

// Basic shapes collision detection functions
bool CheckCollisionRecs(Rectangle rec1, Rectangle rec2); // Check collision between two rectangles
bool CheckCollisionCircles(Vector2 center1, float radius1, Vector2 center2, float radius2); // Check collision between two circles
bool CheckCollisionCircleRec(Vector2 center, float radius, Rectangle rec); // Check collision between circle and rectangle
Rectangle GetCollisionRec(Rectangle rec1, Rectangle rec2); // Get collision rectangle for two rectangles collision
bool CheckCollisionPointRec(Vector2 point, Rectangle rec); // Check if point is inside rectangle
bool CheckCollisionPointCircle(Vector2 point, Vector2 center, float radius); // Check if point is inside circle
bool CheckCollisionPointTriangle(Vector2 point, Vector2 p1, Vector2 p2, Vector2 p3); // Check if point is inside a triangle

//------------------------------------------------------------------------------------
// Texture Loading and Drawing Functions (Module: textures)
//------------------------------------------------------------------------------------

// Image loading functions
// NOTE: This functions do not require GPU access
Image LoadImage(const(char)* fileName); // Load image from file into CPU memory (RAM)
Image LoadImageEx(Color* pixels, int width, int height); // Load image from Color array data (RGBA - 32bit)
Image LoadImagePro(void* data, int width, int height, int format); // Load image from raw data with parameters
Image LoadImageRaw(const(char)* fileName, int width, int height, int format, int headerSize); // Load image from RAW file data
void UnloadImage(Image image); // Unload image from CPU memory (RAM)
void ExportImage(Image image, const(char)* fileName); // Export image data to file
void ExportImageAsCode(Image image, const(char)* fileName); // Export image as code file defining an array of bytes
Color* GetImageData(Image image); // Get pixel data from image as a Color struct array
Vector4* GetImageDataNormalized(Image image); // Get pixel data from image as Vector4 array (float normalized)

// Image generation functions
Image GenImageColor(int width, int height, Color color); // Generate image: plain color
Image GenImageGradientV(int width, int height, Color top, Color bottom); // Generate image: vertical gradient
Image GenImageGradientH(int width, int height, Color left, Color right); // Generate image: horizontal gradient
Image GenImageGradientRadial(int width, int height, float density, Color inner, Color outer); // Generate image: radial gradient
Image GenImageChecked(int width, int height, int checksX, int checksY, Color col1, Color col2); // Generate image: checked
Image GenImageWhiteNoise(int width, int height, float factor); // Generate image: white noise
Image GenImagePerlinNoise(int width, int height, int offsetX, int offsetY, float scale); // Generate image: perlin noise
Image GenImageCellular(int width, int height, int tileSize); // Generate image: cellular algorithm. Bigger tileSize means bigger cells

// Image manipulation functions
Image ImageCopy(Image image); // Create an image duplicate (useful for transformations)
Image ImageFromImage(Image image, Rectangle rec); // Create an image from another image piece
Image ImageText(const(char)* text, int fontSize, Color color); // Create an image from text (default font)
Image ImageTextEx(Font font, const(char)* text, float fontSize, float spacing, Color tint); // Create an image from text (custom sprite font)
void ImageToPOT(Image* image, Color fillColor); // Convert image to POT (power-of-two)
void ImageFormat(Image* image, int newFormat); // Convert image data to desired format
void ImageAlphaMask(Image* image, Image alphaMask); // Apply alpha mask to image
void ImageAlphaClear(Image* image, Color color, float threshold); // Clear alpha channel to desired color
void ImageAlphaCrop(Image* image, float threshold); // Crop image depending on alpha value
void ImageAlphaPremultiply(Image* image); // Premultiply alpha channel
void ImageCrop(Image* image, Rectangle crop); // Crop an image to a defined rectangle
void ImageResize(Image* image, int newWidth, int newHeight); // Resize image (Bicubic scaling algorithm)
void ImageResizeNN(Image* image, int newWidth, int newHeight); // Resize image (Nearest-Neighbor scaling algorithm)
void ImageResizeCanvas(Image* image, int newWidth, int newHeight, int offsetX,
        int offsetY, Color color); // Resize canvas and fill with color
void ImageMipmaps(Image* image); // Generate all mipmap levels for a provided image
void ImageDither(Image* image, int rBpp, int gBpp, int bBpp, int aBpp); // Dither image data to 16bpp or lower (Floyd-Steinberg dithering)
void ImageFlipVertical(Image* image); // Flip image vertically
void ImageFlipHorizontal(Image* image); // Flip image horizontally
void ImageRotateCW(Image* image); // Rotate image clockwise 90deg
void ImageRotateCCW(Image* image); // Rotate image counter-clockwise 90deg
void ImageColorTint(Image* image, Color color); // Modify image color: tint
void ImageColorInvert(Image* image); // Modify image color: invert
void ImageColorGrayscale(Image* image); // Modify image color: grayscale
void ImageColorContrast(Image* image, float contrast); // Modify image color: contrast (-100 to 100)
void ImageColorBrightness(Image* image, int brightness); // Modify image color: brightness (-255 to 255)
void ImageColorReplace(Image* image, Color color, Color replace); // Modify image color: replace color
Color* ImageExtractPalette(Image image, int maxPaletteSize, int* extractCount); // Extract color palette from image to maximum size (memory should be freed)
Rectangle GetImageAlphaBorder(Image image, float threshold); // Get image alpha border rectangle

// Image drawing functions
// NOTE: Image software-rendering functions (CPU)
void ImageClearBackground(Image* dst, Color color); // Clear image background with given color
void ImageDrawPixel(Image* dst, int posX, int posY, Color color); // Draw pixel within an image
void ImageDrawPixelV(Image* dst, Vector2 position, Color color); // Draw pixel within an image (Vector version)
void ImageDrawLine(Image* dst, int startPosX, int startPosY, int endPosX, int endPosY, Color color); // Draw line within an image
void ImageDrawLineV(Image* dst, Vector2 start, Vector2 end, Color color); // Draw line within an image (Vector version)
void ImageDrawCircle(Image* dst, int centerX, int centerY, int radius, Color color); // Draw circle within an image
void ImageDrawCircleV(Image* dst, Vector2 center, int radius, Color color); // Draw circle within an image (Vector version)
void ImageDrawRectangle(Image* dst, int posX, int posY, int width, int height, Color color); // Draw rectangle within an image
void ImageDrawRectangleV(Image* dst, Vector2 position, Vector2 size, Color color); // Draw rectangle within an image (Vector version)
void ImageDrawRectangleRec(Image* dst, Rectangle rec, Color color); // Draw rectangle within an image
void ImageDrawRectangleLines(Image* dst, Rectangle rec, int thick, Color color); // Draw rectangle lines within an image
void ImageDraw(Image* dst, Image src, Rectangle srcRec, Rectangle dstRec, Color tint); // Draw a source image within a destination image (tint applied to source)
void ImageDrawText(Image* dst, Vector2 position, const(char)* text, int fontSize, Color color); // Draw text (default font) within an image (destination)
void ImageDrawTextEx(Image* dst, Vector2 position, Font font, const(char)* text,
        float fontSize, float spacing, Color color); // Draw text (custom sprite font) within an image (destination)

// Texture loading functions
// NOTE: These functions require GPU access
Texture2D LoadTexture(const(char)* fileName); // Load texture from file into GPU memory (VRAM)
Texture2D LoadTextureFromImage(Image image); // Load texture from image data
TextureCubemap LoadTextureCubemap(Image image, int layoutType); // Load cubemap from image, multiple image cubemap layouts supported
RenderTexture2D LoadRenderTexture(int width, int height); // Load texture for rendering (framebuffer)
void UnloadTexture(Texture2D texture); // Unload texture from GPU memory (VRAM)
void UnloadRenderTexture(RenderTexture2D target); // Unload render texture from GPU memory (VRAM)
void UpdateTexture(Texture2D texture, const(void)* pixels); // Update GPU texture with new data
Image GetTextureData(Texture2D texture); // Get pixel data from GPU texture and return an Image
Image GetScreenData(); // Get pixel data from screen buffer and return an Image (screenshot)

// Texture2D configuration functions
void GenTextureMipmaps(Texture2D* texture); // Generate GPU mipmaps for a texture
void SetTextureFilter(Texture2D texture, int filterMode); // Set texture scaling filter mode
void SetTextureWrap(Texture2D texture, int wrapMode); // Set texture wrapping mode

// Texture2D drawing functions
void DrawTexture(Texture2D texture, int posX, int posY, Color tint); // Draw a Texture2D
void DrawTextureV(Texture2D texture, Vector2 position, Color tint); // Draw a Texture2D with position defined as Vector2
void DrawTextureEx(Texture2D texture, Vector2 position, float rotation, float scale, Color tint); // Draw a Texture2D with extended parameters
void DrawTextureRec(Texture2D texture, Rectangle sourceRec, Vector2 position, Color tint); // Draw a part of a texture defined by a rectangle
void DrawTextureQuad(Texture2D texture, Vector2 tiling, Vector2 offset, Rectangle quad, Color tint); // Draw texture quad with tiling and offset parameters
void DrawTexturePro(Texture2D texture, Rectangle sourceRec, Rectangle destRec,
        Vector2 origin, float rotation, Color tint); // Draw a part of a texture defined by a rectangle with 'pro' parameters
void DrawTextureNPatch(Texture2D texture, NPatchInfo nPatchInfo,
        Rectangle destRec, Vector2 origin, float rotation, Color tint); // Draws a texture (or part of it) that stretches or shrinks nicely

// Image/Texture misc functions
int GetPixelDataSize(int width, int height, int format); // Get pixel data size in bytes (image or texture)

//------------------------------------------------------------------------------------
// Font Loading and Text Drawing Functions (Module: text)
//------------------------------------------------------------------------------------

// Font loading/unloading functions
Font GetFontDefault(); // Get the default Font
Font LoadFont(const(char)* fileName); // Load font from file into GPU memory (VRAM)
Font LoadFontEx(const(char)* fileName, int fontSize, int* fontChars, int charsCount); // Load font from file with extended parameters
Font LoadFontFromImage(Image image, Color key, int firstChar); // Load font from Image (XNA style)
CharInfo* LoadFontData(const(char)* fileName, int fontSize, int* fontChars,
        int charsCount, int type); // Load font data for further use
Image GenImageFontAtlas(const(CharInfo)* chars, Rectangle** recs,
        int charsCount, int fontSize, int padding, int packMethod); // Generate image font atlas using chars info
void UnloadFont(Font font); // Unload Font from GPU memory (VRAM)

// Text drawing functions
void DrawFPS(int posX, int posY); // Shows current FPS
void DrawText(const(char)* text, int posX, int posY, int fontSize, Color color); // Draw text (using default font)
void DrawTextEx(Font font, const(char)* text, Vector2 position, float fontSize,
        float spacing, Color tint); // Draw text using font and additional parameters
void DrawTextRec(Font font, const(char)* text, Rectangle rec, float fontSize,
        float spacing, bool wordWrap, Color tint); // Draw text using font inside rectangle limits
void DrawTextRecEx(Font font, const(char)* text, Rectangle rec, float fontSize,
        float spacing, bool wordWrap, Color tint, int selectStart,
        int selectLength, Color selectTint, Color selectBackTint); // Draw text using font inside rectangle limits with support for text selection
void DrawTextCodepoint(Font font, int codepoint, Vector2 position, float scale, Color tint); // Draw one character (codepoint)

// Text misc. functions
int MeasureText(const(char)* text, int fontSize); // Measure string width for default font
Vector2 MeasureTextEx(Font font, const(char)* text, float fontSize, float spacing); // Measure string size for Font
int GetGlyphIndex(Font font, int codepoint); // Get index position for a unicode character on font

// Text strings management functions (no utf8 strings, only byte chars)
// NOTE: Some strings allocate memory internally for returned strings, just be careful!
int TextCopy(char* dst, const(char)* src); // Copy one string to another, returns bytes copied
bool TextIsEqual(const(char)* text1, const(char)* text2); // Check if two text string are equal
uint TextLength(const(char)* text); // Get text length, checks for '\0' ending
const(char)* TextFormat(const(char)* text, ...); // Text formatting with variables (sprintf style)
const(char)* TextSubtext(const(char)* text, int position, int length); // Get a piece of a text string
char* TextReplace(char* text, const(char)* replace, const(char)* by); // Replace text string (memory must be freed!)
char* TextInsert(const(char)* text, const(char)* insert, int position); // Insert text in a position (memory must be freed!)
const(char)* TextJoin(const(char)** textList, int count, const(char)* delimiter); // Join text strings with delimiter
const(char)** TextSplit(const(char)* text, char delimiter, int* count); // Split text into multiple strings
void TextAppend(char* text, const(char)* append, int* position); // Append text at specific position and move cursor!
int TextFindIndex(const(char)* text, const(char)* find); // Find first text occurrence within a string
const(char)* TextToUpper(const(char)* text); // Get upper case version of provided string
const(char)* TextToLower(const(char)* text); // Get lower case version of provided string
const(char)* TextToPascal(const(char)* text); // Get Pascal case notation version of provided string
int TextToInteger(const(char)* text); // Get integer value from text (negative values not supported)
char* TextToUtf8(int* codepoints, int length); // Encode text codepoint into utf8 text (memory must be freed!)

// UTF8 text strings management functions
int* GetCodepoints(const(char)* text, int* count); // Get all codepoints in a string, codepoints count returned by parameters
int GetCodepointsCount(const(char)* text); // Get total number of characters (codepoints) in a UTF8 encoded string
int GetNextCodepoint(const(char)* text, int* bytesProcessed); // Returns next codepoint in a UTF8 encoded string; 0x3f ('?') is returned on failure
const(char)* CodepointToUtf8(int codepoint, int* byteLength); // Encode codepoint into utf8 text (char array length returned as parameter)

//------------------------------------------------------------------------------------
// Basic 3d Shapes Drawing Functions (Module: models)
//------------------------------------------------------------------------------------

// Basic geometric 3D shapes drawing functions
void DrawLine3D(Vector3 startPos, Vector3 endPos, Color color); // Draw a line in 3D world space
void DrawPoint3D(Vector3 position, Color color); // Draw a point in 3D space, actually a small line
void DrawCircle3D(Vector3 center, float radius, Vector3 rotationAxis,
        float rotationAngle, Color color); // Draw a circle in 3D world space
void DrawCube(Vector3 position, float width, float height, float length, Color color); // Draw cube
void DrawCubeV(Vector3 position, Vector3 size, Color color); // Draw cube (Vector version)
void DrawCubeWires(Vector3 position, float width, float height, float length, Color color); // Draw cube wires
void DrawCubeWiresV(Vector3 position, Vector3 size, Color color); // Draw cube wires (Vector version)
void DrawCubeTexture(Texture2D texture, Vector3 position, float width,
        float height, float length, Color color); // Draw cube textured
void DrawSphere(Vector3 centerPos, float radius, Color color); // Draw sphere
void DrawSphereEx(Vector3 centerPos, float radius, int rings, int slices, Color color); // Draw sphere with extended parameters
void DrawSphereWires(Vector3 centerPos, float radius, int rings, int slices, Color color); // Draw sphere wires
void DrawCylinder(Vector3 position, float radiusTop, float radiusBottom,
        float height, int slices, Color color); // Draw a cylinder/cone
void DrawCylinderWires(Vector3 position, float radiusTop, float radiusBottom,
        float height, int slices, Color color); // Draw a cylinder/cone wires
void DrawPlane(Vector3 centerPos, Vector2 size, Color color); // Draw a plane XZ
void DrawRay(Ray ray, Color color); // Draw a ray line
void DrawGrid(int slices, float spacing); // Draw a grid (centered at (0, 0, 0))
void DrawGizmo(Vector3 position); // Draw simple gizmo
//DrawTorus (), DrawTeapot () could be useful?

//------------------------------------------------------------------------------------
// Model 3d Loading and Drawing Functions (Module: models)
//------------------------------------------------------------------------------------

// Model loading/unloading functions
Model LoadModel(const(char)* fileName); // Load model from files (meshes and materials)
Model LoadModelFromMesh(Mesh mesh); // Load model from generated mesh (default material)
void UnloadModel(Model model); // Unload model from memory (RAM and/or VRAM)

// Mesh loading/unloading functions
Mesh* LoadMeshes(const(char)* fileName, int* meshCount); // Load meshes from model file
void ExportMesh(Mesh mesh, const(char)* fileName); // Export mesh data to file
void UnloadMesh(Mesh* mesh); // Unload mesh from memory (RAM and/or VRAM)

// Material loading/unloading functions
Material* LoadMaterials(const(char)* fileName, int* materialCount); // Load materials from model file
Material LoadMaterialDefault(); // Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)
void UnloadMaterial(Material material); // Unload material from GPU memory (VRAM)
void SetMaterialTexture(Material* material, int mapType, Texture2D texture); // Set texture for a material map type (MAP_DIFFUSE, MAP_SPECULAR...)
void SetModelMeshMaterial(Model* model, int meshId, int materialId); // Set material for a mesh

// Model animations loading/unloading functions
ModelAnimation* LoadModelAnimations(const(char)* fileName, int* animsCount); // Load model animations from file
void UpdateModelAnimation(Model model, ModelAnimation anim, int frame); // Update model animation pose
void UnloadModelAnimation(ModelAnimation anim); // Unload animation data
bool IsModelAnimationValid(Model model, ModelAnimation anim); // Check model animation skeleton match

// Mesh generation functions
Mesh GenMeshPoly(int sides, float radius); // Generate polygonal mesh
Mesh GenMeshPlane(float width, float length, int resX, int resZ); // Generate plane mesh (with subdivisions)
Mesh GenMeshCube(float width, float height, float length); // Generate cuboid mesh
Mesh GenMeshSphere(float radius, int rings, int slices); // Generate sphere mesh (standard sphere)
Mesh GenMeshHemiSphere(float radius, int rings, int slices); // Generate half-sphere mesh (no bottom cap)
Mesh GenMeshCylinder(float radius, float height, int slices); // Generate cylinder mesh
Mesh GenMeshTorus(float radius, float size, int radSeg, int sides); // Generate torus mesh
Mesh GenMeshKnot(float radius, float size, int radSeg, int sides); // Generate trefoil knot mesh
Mesh GenMeshHeightmap(Image heightmap, Vector3 size); // Generate heightmap mesh from image data
Mesh GenMeshCubicmap(Image cubicmap, Vector3 cubeSize); // Generate cubes-based map mesh from image data

// Mesh manipulation functions
BoundingBox MeshBoundingBox(Mesh mesh); // Compute mesh bounding box limits
void MeshTangents(Mesh* mesh); // Compute mesh tangents
void MeshBinormals(Mesh* mesh); // Compute mesh binormals

// Model drawing functions
void DrawModel(Model model, Vector3 position, float scale, Color tint); // Draw a model (with texture if set)
void DrawModelEx(Model model, Vector3 position, Vector3 rotationAxis,
        float rotationAngle, Vector3 scale, Color tint); // Draw a model with extended parameters
void DrawModelWires(Model model, Vector3 position, float scale, Color tint); // Draw a model wires (with texture if set)
void DrawModelWiresEx(Model model, Vector3 position, Vector3 rotationAxis,
        float rotationAngle, Vector3 scale, Color tint); // Draw a model wires (with texture if set) with extended parameters
void DrawBoundingBox(BoundingBox box, Color color); // Draw bounding box (wires)
void DrawBillboard(Camera camera, Texture2D texture, Vector3 center, float size, Color tint); // Draw a billboard texture
void DrawBillboardRec(Camera camera, Texture2D texture, Rectangle sourceRec,
        Vector3 center, float size, Color tint); // Draw a billboard texture defined by sourceRec

// Collision detection functions
bool CheckCollisionSpheres(Vector3 centerA, float radiusA, Vector3 centerB, float radiusB); // Detect collision between two spheres
bool CheckCollisionBoxes(BoundingBox box1, BoundingBox box2); // Detect collision between two bounding boxes
bool CheckCollisionBoxSphere(BoundingBox box, Vector3 center, float radius); // Detect collision between box and sphere
bool CheckCollisionRaySphere(Ray ray, Vector3 center, float radius); // Detect collision between ray and sphere
bool CheckCollisionRaySphereEx(Ray ray, Vector3 center, float radius, Vector3* collisionPoint); // Detect collision between ray and sphere, returns collision point
bool CheckCollisionRayBox(Ray ray, BoundingBox box); // Detect collision between ray and box
RayHitInfo GetCollisionRayModel(Ray ray, Model model); // Get collision info between ray and model
RayHitInfo GetCollisionRayTriangle(Ray ray, Vector3 p1, Vector3 p2, Vector3 p3); // Get collision info between ray and triangle
RayHitInfo GetCollisionRayGround(Ray ray, float groundHeight); // Get collision info between ray and ground plane (Y-normal plane)

//------------------------------------------------------------------------------------
// Shaders System Functions (Module: rlgl)
// NOTE: This functions are useless when using OpenGL 1.1
//------------------------------------------------------------------------------------

// Shader loading/unloading functions
Shader LoadShader(const(char)* vsFileName, const(char)* fsFileName); // Load shader from files and bind default locations
Shader LoadShaderCode(const(char)* vsCode, const(char)* fsCode); // Load shader from code strings and bind default locations
void UnloadShader(Shader shader); // Unload shader from GPU memory (VRAM)

Shader GetShaderDefault(); // Get default shader
Texture2D GetTextureDefault(); // Get default texture
Texture2D GetShapesTexture(); // Get texture to draw shapes
Rectangle GetShapesTextureRec(); // Get texture rectangle to draw shapes
void SetShapesTexture(Texture2D texture, Rectangle source); // Define default texture used to draw shapes

// Shader configuration functions
int GetShaderLocation(Shader shader, const(char)* uniformName); // Get shader uniform location
void SetShaderValue(Shader shader, int uniformLoc, const(void)* value, int uniformType); // Set shader uniform value
void SetShaderValueV(Shader shader, int uniformLoc, const(void)* value, int uniformType, int count); // Set shader uniform value vector
void SetShaderValueMatrix(Shader shader, int uniformLoc, Matrix mat); // Set shader uniform value (matrix 4x4)
void SetShaderValueTexture(Shader shader, int uniformLoc, Texture2D texture); // Set shader uniform value for texture
void SetMatrixProjection(Matrix proj); // Set a custom projection matrix (replaces internal projection matrix)
void SetMatrixModelview(Matrix view); // Set a custom modelview matrix (replaces internal modelview matrix)
Matrix GetMatrixModelview(); // Get internal modelview matrix
Matrix GetMatrixProjection(); // Get internal projection matrix

// Texture maps generation (PBR)
// NOTE: Required shaders should be provided
Texture2D GenTextureCubemap(Shader shader, Texture2D map, int size); // Generate cubemap texture from 2D texture
Texture2D GenTextureIrradiance(Shader shader, Texture2D cubemap, int size); // Generate irradiance texture using cubemap data
Texture2D GenTexturePrefilter(Shader shader, Texture2D cubemap, int size); // Generate prefilter texture using cubemap data
Texture2D GenTextureBRDF(Shader shader, int size); // Generate BRDF texture

// Shading begin/end functions
void BeginShaderMode(Shader shader); // Begin custom shader drawing
void EndShaderMode(); // End custom shader drawing (use default shader)
void BeginBlendMode(int mode); // Begin blending mode (alpha, additive, multiplied)
void EndBlendMode(); // End blending mode (reset to default: alpha blending)

// VR control functions
void InitVrSimulator(); // Init VR simulator for selected device parameters
void CloseVrSimulator(); // Close VR simulator for current device
void UpdateVrTracking(Camera* camera); // Update VR tracking (position and orientation) and camera
void SetVrConfiguration(VrDeviceInfo info, Shader distortion); // Set stereo rendering configuration parameters
bool IsVrSimulatorReady(); // Detect if VR simulator is ready
void ToggleVrMode(); // Enable/Disable VR experience
void BeginVrDrawing(); // Begin VR simulator stereo rendering
void EndVrDrawing(); // End VR simulator stereo rendering

//------------------------------------------------------------------------------------
// Audio Loading and Playing Functions (Module: audio)
//------------------------------------------------------------------------------------

// Audio device management functions
void InitAudioDevice(); // Initialize audio device and context
void CloseAudioDevice(); // Close the audio device and context
bool IsAudioDeviceReady(); // Check if audio device has been initialized successfully
void SetMasterVolume(float volume); // Set master volume (listener)

// Wave/Sound loading/unloading functions
Wave LoadWave(const(char)* fileName); // Load wave data from file
Sound LoadSound(const(char)* fileName); // Load sound from file
Sound LoadSoundFromWave(Wave wave); // Load sound from wave data
void UpdateSound(Sound sound, const(void)* data, int samplesCount); // Update sound buffer with new data
void UnloadWave(Wave wave); // Unload wave data
void UnloadSound(Sound sound); // Unload sound
void ExportWave(Wave wave, const(char)* fileName); // Export wave data to file
void ExportWaveAsCode(Wave wave, const(char)* fileName); // Export wave sample data to code (.h)

// Wave/Sound management functions
void PlaySound(Sound sound); // Play a sound
void StopSound(Sound sound); // Stop playing a sound
void PauseSound(Sound sound); // Pause a sound
void ResumeSound(Sound sound); // Resume a paused sound
void PlaySoundMulti(Sound sound); // Play a sound (using multichannel buffer pool)
void StopSoundMulti(); // Stop any sound playing (using multichannel buffer pool)
int GetSoundsPlaying(); // Get number of sounds playing in the multichannel
bool IsSoundPlaying(Sound sound); // Check if a sound is currently playing
void SetSoundVolume(Sound sound, float volume); // Set volume for a sound (1.0 is max level)
void SetSoundPitch(Sound sound, float pitch); // Set pitch for a sound (1.0 is base level)
void WaveFormat(Wave* wave, int sampleRate, int sampleSize, int channels); // Convert wave data to desired format
Wave WaveCopy(Wave wave); // Copy a wave to a new wave
void WaveCrop(Wave* wave, int initSample, int finalSample); // Crop a wave to defined samples range
float* GetWaveData(Wave wave); // Get samples data from wave as a floats array

// Music management functions
Music LoadMusicStream(const(char)* fileName); // Load music stream from file
void UnloadMusicStream(Music music); // Unload music stream
void PlayMusicStream(Music music); // Start music playing
void UpdateMusicStream(Music music); // Updates buffers for music streaming
void StopMusicStream(Music music); // Stop music playing
void PauseMusicStream(Music music); // Pause music playing
void ResumeMusicStream(Music music); // Resume playing paused music
bool IsMusicPlaying(Music music); // Check if music is playing
void SetMusicVolume(Music music, float volume); // Set volume for music (1.0 is max level)
void SetMusicPitch(Music music, float pitch); // Set pitch for a music (1.0 is base level)
void SetMusicLoopCount(Music music, int count); // Set music loop count (loop repeats)
float GetMusicTimeLength(Music music); // Get music time length (in seconds)
float GetMusicTimePlayed(Music music); // Get current music time played (in seconds)

// AudioStream management functions
AudioStream InitAudioStream(uint sampleRate, uint sampleSize, uint channels); // Init audio stream (to stream raw audio pcm data)
void UpdateAudioStream(AudioStream stream, const(void)* data, int samplesCount); // Update audio stream buffers with data
void CloseAudioStream(AudioStream stream); // Close audio stream and free memory
bool IsAudioStreamProcessed(AudioStream stream); // Check if any audio stream buffers requires refill
void PlayAudioStream(AudioStream stream); // Play audio stream
void PauseAudioStream(AudioStream stream); // Pause audio stream
void ResumeAudioStream(AudioStream stream); // Resume audio stream
bool IsAudioStreamPlaying(AudioStream stream); // Check if audio stream is playing
void StopAudioStream(AudioStream stream); // Stop audio stream
void SetAudioStreamVolume(AudioStream stream, float volume); // Set volume for audio stream (1.0 is max level)
void SetAudioStreamPitch(AudioStream stream, float pitch); // Set pitch for audio stream (1.0 is base level)
void SetAudioStreamBufferSizeDefault(int size); // Default size for new audio streams

//------------------------------------------------------------------------------------
// Network (Module: network)
//------------------------------------------------------------------------------------

// IN PROGRESS: Check rnet.h for reference

// RAYLIB_H

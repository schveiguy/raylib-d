module raylib.rlgl;

import raylib;

/**********************************************************************************************
*
*   rlgl v5.0 - A multi-OpenGL abstraction layer with an immediate-mode style API
*
*   DESCRIPTION:
*       An abstraction layer for multiple OpenGL versions (1.1, 2.1, 3.3 Core, 4.3 Core, ES 2.0)
*       that provides a pseudo-OpenGL 1.1 immediate-mode style API (rlVertex, rlTranslate, rlRotate...)
*
*   ADDITIONAL NOTES:
*       When choosing an OpenGL backend different than OpenGL 1.1, some internal buffer are
*       initialized on rlglInit() to accumulate vertex data.
*
*       When an internal state change is required all the stored vertex data is renderer in batch,
*       additionally, rlDrawRenderBatchActive() could be called to force flushing of the batch.
*
*       Some resources are also loaded for convenience, here the complete list:
*          - Default batch (RLGL.defaultBatch): RenderBatch system to accumulate vertex data
*          - Default texture (RLGL.defaultTextureId): 1x1 white pixel R8G8B8A8
*          - Default shader (RLGL.State.defaultShaderId, RLGL.State.defaultShaderLocs)
*
*       Internal buffer (and resources) must be manually unloaded calling rlglClose().
*
*   CONFIGURATION:
*       #define GRAPHICS_API_OPENGL_11
*       #define GRAPHICS_API_OPENGL_21
*       #define GRAPHICS_API_OPENGL_33
*       #define GRAPHICS_API_OPENGL_43
*       #define GRAPHICS_API_OPENGL_ES2
*       #define GRAPHICS_API_OPENGL_ES3
*           Use selected OpenGL graphics backend, should be supported by platform
*           Those preprocessor defines are only used on rlgl module, if OpenGL version is
*           required by any other module, use rlGetVersion() to check it
*
*       #define RLGL_IMPLEMENTATION
*           Generates the implementation of the library into the included file.
*           If not defined, the library is in header only mode and can be included in other headers
*           or source files without problems. But only ONE file should hold the implementation.
*
*       #define RLGL_RENDER_TEXTURES_HINT
*           Enable framebuffer objects (fbo) support (enabled by default)
*           Some GPUs could not support them despite the OpenGL version
*
*       #define RLGL_SHOW_GL_DETAILS_INFO
*           Show OpenGL extensions and capabilities detailed logs on init
*
*       #define RLGL_ENABLE_OPENGL_DEBUG_CONTEXT
*           Enable debug context (only available on OpenGL 4.3)
*
*       rlgl capabilities could be customized just defining some internal
*       values before library inclusion (default values listed):
*
*       #define RL_DEFAULT_BATCH_BUFFER_ELEMENTS   8192    // Default internal render batch elements limits
*       #define RL_DEFAULT_BATCH_BUFFERS              1    // Default number of batch buffers (multi-buffering)
*       #define RL_DEFAULT_BATCH_DRAWCALLS          256    // Default number of batch draw calls (by state changes: mode, texture)
*       #define RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS    4    // Maximum number of textures units that can be activated on batch drawing (SetShaderValueTexture())
*
*       #define RL_MAX_MATRIX_STACK_SIZE             32    // Maximum size of internal Matrix stack
*       #define RL_MAX_SHADER_LOCATIONS              32    // Maximum number of shader locations supported
*       #define RL_CULL_DISTANCE_NEAR              0.01    // Default projection matrix near cull distance
*       #define RL_CULL_DISTANCE_FAR             1000.0    // Default projection matrix far cull distance
*
*       When loading a shader, the following vertex attributes and uniform
*       location names are tried to be set automatically:
*
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_POSITION     "vertexPosition"    // Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_LOCATION_POSITION
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD     "vertexTexCoord"    // Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_NORMAL       "vertexNormal"      // Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_LOCATION_NORMAL
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_COLOR        "vertexColor"       // Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_LOCATION_COLOR
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_TANGENT      "vertexTangent"     // Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_LOCATION_TANGENT
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD2    "vertexTexCoord2"   // Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD2
*       #define RL_DEFAULT_SHADER_UNIFORM_NAME_MVP         "mvp"               // model-view-projection matrix
*       #define RL_DEFAULT_SHADER_UNIFORM_NAME_VIEW        "matView"           // view matrix
*       #define RL_DEFAULT_SHADER_UNIFORM_NAME_PROJECTION  "matProjection"     // projection matrix
*       #define RL_DEFAULT_SHADER_UNIFORM_NAME_MODEL       "matModel"          // model matrix
*       #define RL_DEFAULT_SHADER_UNIFORM_NAME_NORMAL      "matNormal"         // normal matrix (transpose(inverse(matModelView)))
*       #define RL_DEFAULT_SHADER_UNIFORM_NAME_COLOR       "colDiffuse"        // color diffuse (base tint color, multiplied by texture color)
*       #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE0  "texture0"          // texture0 (texture slot active 0)
*       #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE1  "texture1"          // texture1 (texture slot active 1)
*       #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE2  "texture2"          // texture2 (texture slot active 2)
*
*   DEPENDENCIES:
*      - OpenGL libraries (depending on platform and OpenGL version selected)
*      - GLAD OpenGL extensions loading library (only for OpenGL 3.3 Core, 4.3 Core)
*
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2014-2024 Ramon Santamaria (@raysan5)
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

extern (C) @nogc nothrow:

enum RLGL_VERSION = "5.0";

// Function specifiers in case library is build/used as a shared library
// NOTE: Microsoft specifiers to tell compiler that symbols are imported/exported from a .dll
// NOTE: visibility(default) attribute makes symbols "visible" when compiled with -fvisibility=hidden

// We are building the library as a Win32 shared library (.dll)

// We are building the library as a Unix shared library (.so/.dylib)

// We are using the library as a Win32 shared library (.dll)

// Function specifiers definition // Functions defined as 'extern' by default (implicit specifiers)

// Support TRACELOG macros

// Allow custom memory allocators

// Security check in case no GRAPHICS_API_OPENGL_* defined

// Security check in case multiple GRAPHICS_API_OPENGL_* defined

// OpenGL 2.1 uses most of OpenGL 3.3 Core functionality
// WARNING: Specific parts are checked with #if defines

// OpenGL 4.3 uses OpenGL 3.3 Core functionality

// OpenGL ES 3.0 uses OpenGL ES 2.0 functionality (and more)

// Support framebuffer objects by default
// NOTE: Some driver implementation do not support it, despite they should

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------

// Default internal render batch elements limits

// This is the maximum amount of elements (quads) per batch
// NOTE: Be careful with text, every letter maps to a quad
enum RL_DEFAULT_BATCH_BUFFER_ELEMENTS = 8192;

// We reduce memory sizes for embedded systems (RPI and HTML5)
// NOTE: On HTML5 (emscripten) this is allocated on heap,
// by default it's only 16MB!...just take care...

enum RL_DEFAULT_BATCH_BUFFERS = 1; // Default number of batch buffers (multi-buffering)

enum RL_DEFAULT_BATCH_DRAWCALLS = 256; // Default number of batch draw calls (by state changes: mode, texture)

enum RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS = 4; // Maximum number of textures units that can be activated on batch drawing (SetShaderValueTexture())

// Internal Matrix stack

enum RL_MAX_MATRIX_STACK_SIZE = 32; // Maximum size of Matrix stack

// Shader limits

enum RL_MAX_SHADER_LOCATIONS = 32; // Maximum number of shader locations supported

// Projection matrix culling

enum RL_CULL_DISTANCE_NEAR = 0.01; // Default near cull distance

enum RL_CULL_DISTANCE_FAR = 1000.0; // Default far cull distance

// Texture parameters (equivalent to OpenGL defines)
enum RL_TEXTURE_WRAP_S = 0x2802; // GL_TEXTURE_WRAP_S
enum RL_TEXTURE_WRAP_T = 0x2803; // GL_TEXTURE_WRAP_T
enum RL_TEXTURE_MAG_FILTER = 0x2800; // GL_TEXTURE_MAG_FILTER
enum RL_TEXTURE_MIN_FILTER = 0x2801; // GL_TEXTURE_MIN_FILTER

enum RL_TEXTURE_FILTER_NEAREST = 0x2600; // GL_NEAREST
enum RL_TEXTURE_FILTER_LINEAR = 0x2601; // GL_LINEAR
enum RL_TEXTURE_FILTER_MIP_NEAREST = 0x2700; // GL_NEAREST_MIPMAP_NEAREST
enum RL_TEXTURE_FILTER_NEAREST_MIP_LINEAR = 0x2702; // GL_NEAREST_MIPMAP_LINEAR
enum RL_TEXTURE_FILTER_LINEAR_MIP_NEAREST = 0x2701; // GL_LINEAR_MIPMAP_NEAREST
enum RL_TEXTURE_FILTER_MIP_LINEAR = 0x2703; // GL_LINEAR_MIPMAP_LINEAR
enum RL_TEXTURE_FILTER_ANISOTROPIC = 0x3000; // Anisotropic filter (custom identifier)
enum RL_TEXTURE_MIPMAP_BIAS_RATIO = 0x4000; // Texture mipmap bias, percentage ratio (custom identifier)

enum RL_TEXTURE_WRAP_REPEAT = 0x2901; // GL_REPEAT
enum RL_TEXTURE_WRAP_CLAMP = 0x812F; // GL_CLAMP_TO_EDGE
enum RL_TEXTURE_WRAP_MIRROR_REPEAT = 0x8370; // GL_MIRRORED_REPEAT
enum RL_TEXTURE_WRAP_MIRROR_CLAMP = 0x8742; // GL_MIRROR_CLAMP_EXT

// Matrix modes (equivalent to OpenGL)
enum RL_MODELVIEW = 0x1700; // GL_MODELVIEW
enum RL_PROJECTION = 0x1701; // GL_PROJECTION
enum RL_TEXTURE = 0x1702; // GL_TEXTURE

// Primitive assembly draw modes
enum RL_LINES = 0x0001; // GL_LINES
enum RL_TRIANGLES = 0x0004; // GL_TRIANGLES
enum RL_QUADS = 0x0007; // GL_QUADS

// GL equivalent data types
enum RL_UNSIGNED_BYTE = 0x1401; // GL_UNSIGNED_BYTE
enum RL_FLOAT = 0x1406; // GL_FLOAT

// GL buffer usage hint
enum RL_STREAM_DRAW = 0x88E0; // GL_STREAM_DRAW
enum RL_STREAM_READ = 0x88E1; // GL_STREAM_READ
enum RL_STREAM_COPY = 0x88E2; // GL_STREAM_COPY
enum RL_STATIC_DRAW = 0x88E4; // GL_STATIC_DRAW
enum RL_STATIC_READ = 0x88E5; // GL_STATIC_READ
enum RL_STATIC_COPY = 0x88E6; // GL_STATIC_COPY
enum RL_DYNAMIC_DRAW = 0x88E8; // GL_DYNAMIC_DRAW
enum RL_DYNAMIC_READ = 0x88E9; // GL_DYNAMIC_READ
enum RL_DYNAMIC_COPY = 0x88EA; // GL_DYNAMIC_COPY

// GL Shader type
enum RL_FRAGMENT_SHADER = 0x8B30; // GL_FRAGMENT_SHADER
enum RL_VERTEX_SHADER = 0x8B31; // GL_VERTEX_SHADER
enum RL_COMPUTE_SHADER = 0x91B9; // GL_COMPUTE_SHADER

// GL blending factors
enum RL_ZERO = 0; // GL_ZERO
enum RL_ONE = 1; // GL_ONE
enum RL_SRC_COLOR = 0x0300; // GL_SRC_COLOR
enum RL_ONE_MINUS_SRC_COLOR = 0x0301; // GL_ONE_MINUS_SRC_COLOR
enum RL_SRC_ALPHA = 0x0302; // GL_SRC_ALPHA
enum RL_ONE_MINUS_SRC_ALPHA = 0x0303; // GL_ONE_MINUS_SRC_ALPHA
enum RL_DST_ALPHA = 0x0304; // GL_DST_ALPHA
enum RL_ONE_MINUS_DST_ALPHA = 0x0305; // GL_ONE_MINUS_DST_ALPHA
enum RL_DST_COLOR = 0x0306; // GL_DST_COLOR
enum RL_ONE_MINUS_DST_COLOR = 0x0307; // GL_ONE_MINUS_DST_COLOR
enum RL_SRC_ALPHA_SATURATE = 0x0308; // GL_SRC_ALPHA_SATURATE
enum RL_CONSTANT_COLOR = 0x8001; // GL_CONSTANT_COLOR
enum RL_ONE_MINUS_CONSTANT_COLOR = 0x8002; // GL_ONE_MINUS_CONSTANT_COLOR
enum RL_CONSTANT_ALPHA = 0x8003; // GL_CONSTANT_ALPHA
enum RL_ONE_MINUS_CONSTANT_ALPHA = 0x8004; // GL_ONE_MINUS_CONSTANT_ALPHA

// GL blending functions/equations
enum RL_FUNC_ADD = 0x8006; // GL_FUNC_ADD
enum RL_MIN = 0x8007; // GL_MIN
enum RL_MAX = 0x8008; // GL_MAX
enum RL_FUNC_SUBTRACT = 0x800A; // GL_FUNC_SUBTRACT
enum RL_FUNC_REVERSE_SUBTRACT = 0x800B; // GL_FUNC_REVERSE_SUBTRACT
enum RL_BLEND_EQUATION = 0x8009; // GL_BLEND_EQUATION
enum RL_BLEND_EQUATION_RGB = 0x8009; // GL_BLEND_EQUATION_RGB   // (Same as BLEND_EQUATION)
enum RL_BLEND_EQUATION_ALPHA = 0x883D; // GL_BLEND_EQUATION_ALPHA
enum RL_BLEND_DST_RGB = 0x80C8; // GL_BLEND_DST_RGB
enum RL_BLEND_SRC_RGB = 0x80C9; // GL_BLEND_SRC_RGB
enum RL_BLEND_DST_ALPHA = 0x80CA; // GL_BLEND_DST_ALPHA
enum RL_BLEND_SRC_ALPHA = 0x80CB; // GL_BLEND_SRC_ALPHA
enum RL_BLEND_COLOR = 0x8005; // GL_BLEND_COLOR

enum RL_READ_FRAMEBUFFER = 0x8CA8; // GL_READ_FRAMEBUFFER
enum RL_DRAW_FRAMEBUFFER = 0x8CA9; // GL_DRAW_FRAMEBUFFER

// Default shader vertex attribute locations

enum RL_DEFAULT_SHADER_ATTRIB_LOCATION_POSITION = 0;

enum RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD = 1;

enum RL_DEFAULT_SHADER_ATTRIB_LOCATION_NORMAL = 2;

enum RL_DEFAULT_SHADER_ATTRIB_LOCATION_COLOR = 3;

enum RL_DEFAULT_SHADER_ATTRIB_LOCATION_TANGENT = 4;

enum RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD2 = 5;

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------

// Boolean type

// Matrix, 4x4 components, column major, OpenGL style, right handed

// Matrix first row (4 components)
// Matrix second row (4 components)
// Matrix third row (4 components)
// Matrix fourth row (4 components)

// Dynamic vertex buffers (position + texcoords + colors + indices arrays)
struct rlVertexBuffer
{
    int elementCount; // Number of elements in the buffer (QUADS)

    float* vertices; // Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    float* texcoords; // Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    float* normals; // Vertex normal (XYZ - 3 components per vertex) (shader-location = 2)
    ubyte* colors; // Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)

    uint* indices; // Vertex indices (in case vertex data comes indexed) (6 indices per quad)

    // Vertex indices (in case vertex data comes indexed) (6 indices per quad)

    uint vaoId; // OpenGL Vertex Array Object id
    uint[5] vboId; // OpenGL Vertex Buffer Objects id (5 types of vertex data)
}

// Draw call type
// NOTE: Only texture changes register a new draw, other state-change-related elements are not
// used at this moment (vaoId, shaderId, matrices), raylib just forces a batch draw call if any
// of those state-change happens (this is done in core module)
struct rlDrawCall
{
    int mode; // Drawing mode: LINES, TRIANGLES, QUADS
    int vertexCount; // Number of vertex of the draw
    int vertexAlignment; // Number of vertex required for index alignment (LINES, TRIANGLES)
    //unsigned int vaoId;       // Vertex array id to be used on the draw -> Using RLGL.currentBatch->vertexBuffer.vaoId
    //unsigned int shaderId;    // Shader id to be used on the draw -> Using RLGL.currentShaderId
    uint textureId; // Texture id to be used on the draw -> Use to create new draw call if changes

    //Matrix projection;        // Projection matrix for this draw -> Using RLGL.projection by default
    //Matrix modelview;         // Modelview matrix for this draw -> Using RLGL.modelview by default
}

// rlRenderBatch type
struct rlRenderBatch
{
    int bufferCount; // Number of vertex buffers (multi-buffering support)
    int currentBuffer; // Current buffer tracking in case of multi-buffering
    rlVertexBuffer* vertexBuffer; // Dynamic buffer(s) for vertex data

    rlDrawCall* draws; // Draw calls array, depends on textureId
    int drawCounter; // Draw calls counter
    float currentDepth; // Current depth value for next draw
}

// OpenGL version
enum rlGlVersion
{
    RL_OPENGL_11 = 1, // OpenGL 1.1
    RL_OPENGL_21 = 2, // OpenGL 2.1 (GLSL 120)
    RL_OPENGL_33 = 3, // OpenGL 3.3 (GLSL 330)
    RL_OPENGL_43 = 4, // OpenGL 4.3 (using GLSL 330)
    RL_OPENGL_ES_20 = 5, // OpenGL ES 2.0 (GLSL 100)
    RL_OPENGL_ES_30 = 6 // OpenGL ES 3.0 (GLSL 300 es)
}

// Trace log level
// NOTE: Organized by priority level
enum rlTraceLogLevel
{
    RL_LOG_ALL = 0, // Display all logs
    RL_LOG_TRACE = 1, // Trace logging, intended for internal use only
    RL_LOG_DEBUG = 2, // Debug logging, used for internal debugging, it should be disabled on release builds
    RL_LOG_INFO = 3, // Info logging, used for program execution info
    RL_LOG_WARNING = 4, // Warning logging, used on recoverable failures
    RL_LOG_ERROR = 5, // Error logging, used on unrecoverable failures
    RL_LOG_FATAL = 6, // Fatal logging, used to abort program: exit(EXIT_FAILURE)
    RL_LOG_NONE = 7 // Disable logging
}

// Texture pixel formats
// NOTE: Support depends on OpenGL version
enum rlPixelFormat
{
    RL_PIXELFORMAT_UNCOMPRESSED_GRAYSCALE = 1, // 8 bit per pixel (no alpha)
    RL_PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA = 2, // 8*2 bpp (2 channels)
    RL_PIXELFORMAT_UNCOMPRESSED_R5G6B5 = 3, // 16 bpp
    RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8 = 4, // 24 bpp
    RL_PIXELFORMAT_UNCOMPRESSED_R5G5B5A1 = 5, // 16 bpp (1 bit alpha)
    RL_PIXELFORMAT_UNCOMPRESSED_R4G4B4A4 = 6, // 16 bpp (4 bit alpha)
    RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8A8 = 7, // 32 bpp
    RL_PIXELFORMAT_UNCOMPRESSED_R32 = 8, // 32 bpp (1 channel - float)
    RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32 = 9, // 32*3 bpp (3 channels - float)
    RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32A32 = 10, // 32*4 bpp (4 channels - float)
    RL_PIXELFORMAT_UNCOMPRESSED_R16 = 11, // 16 bpp (1 channel - half float)
    RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16 = 12, // 16*3 bpp (3 channels - half float)
    RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16A16 = 13, // 16*4 bpp (4 channels - half float)
    RL_PIXELFORMAT_COMPRESSED_DXT1_RGB = 14, // 4 bpp (no alpha)
    RL_PIXELFORMAT_COMPRESSED_DXT1_RGBA = 15, // 4 bpp (1 bit alpha)
    RL_PIXELFORMAT_COMPRESSED_DXT3_RGBA = 16, // 8 bpp
    RL_PIXELFORMAT_COMPRESSED_DXT5_RGBA = 17, // 8 bpp
    RL_PIXELFORMAT_COMPRESSED_ETC1_RGB = 18, // 4 bpp
    RL_PIXELFORMAT_COMPRESSED_ETC2_RGB = 19, // 4 bpp
    RL_PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA = 20, // 8 bpp
    RL_PIXELFORMAT_COMPRESSED_PVRT_RGB = 21, // 4 bpp
    RL_PIXELFORMAT_COMPRESSED_PVRT_RGBA = 22, // 4 bpp
    RL_PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA = 23, // 8 bpp
    RL_PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA = 24 // 2 bpp
}

// Texture parameters: filter mode
// NOTE 1: Filtering considers mipmaps if available in the texture
// NOTE 2: Filter is accordingly set for minification and magnification
enum rlTextureFilter
{
    RL_TEXTURE_FILTER_POINT = 0, // No filter, just pixel approximation
    RL_TEXTURE_FILTER_BILINEAR = 1, // Linear filtering
    RL_TEXTURE_FILTER_TRILINEAR = 2, // Trilinear filtering (linear with mipmaps)
    RL_TEXTURE_FILTER_ANISOTROPIC_4X = 3, // Anisotropic filtering 4x
    RL_TEXTURE_FILTER_ANISOTROPIC_8X = 4, // Anisotropic filtering 8x
    RL_TEXTURE_FILTER_ANISOTROPIC_16X = 5 // Anisotropic filtering 16x
}

// Color blending modes (pre-defined)
enum rlBlendMode
{
    RL_BLEND_ALPHA = 0, // Blend textures considering alpha (default)
    RL_BLEND_ADDITIVE = 1, // Blend textures adding colors
    RL_BLEND_MULTIPLIED = 2, // Blend textures multiplying colors
    RL_BLEND_ADD_COLORS = 3, // Blend textures adding colors (alternative)
    RL_BLEND_SUBTRACT_COLORS = 4, // Blend textures subtracting colors (alternative)
    RL_BLEND_ALPHA_PREMULTIPLY = 5, // Blend premultiplied textures considering alpha
    RL_BLEND_CUSTOM = 6, // Blend textures using custom src/dst factors (use rlSetBlendFactors())
    RL_BLEND_CUSTOM_SEPARATE = 7 // Blend textures using custom src/dst factors (use rlSetBlendFactorsSeparate())
}

// Shader location point type
enum rlShaderLocationIndex
{
    RL_SHADER_LOC_VERTEX_POSITION = 0, // Shader location: vertex attribute: position
    RL_SHADER_LOC_VERTEX_TEXCOORD01 = 1, // Shader location: vertex attribute: texcoord01
    RL_SHADER_LOC_VERTEX_TEXCOORD02 = 2, // Shader location: vertex attribute: texcoord02
    RL_SHADER_LOC_VERTEX_NORMAL = 3, // Shader location: vertex attribute: normal
    RL_SHADER_LOC_VERTEX_TANGENT = 4, // Shader location: vertex attribute: tangent
    RL_SHADER_LOC_VERTEX_COLOR = 5, // Shader location: vertex attribute: color
    RL_SHADER_LOC_MATRIX_MVP = 6, // Shader location: matrix uniform: model-view-projection
    RL_SHADER_LOC_MATRIX_VIEW = 7, // Shader location: matrix uniform: view (camera transform)
    RL_SHADER_LOC_MATRIX_PROJECTION = 8, // Shader location: matrix uniform: projection
    RL_SHADER_LOC_MATRIX_MODEL = 9, // Shader location: matrix uniform: model (transform)
    RL_SHADER_LOC_MATRIX_NORMAL = 10, // Shader location: matrix uniform: normal
    RL_SHADER_LOC_VECTOR_VIEW = 11, // Shader location: vector uniform: view
    RL_SHADER_LOC_COLOR_DIFFUSE = 12, // Shader location: vector uniform: diffuse color
    RL_SHADER_LOC_COLOR_SPECULAR = 13, // Shader location: vector uniform: specular color
    RL_SHADER_LOC_COLOR_AMBIENT = 14, // Shader location: vector uniform: ambient color
    RL_SHADER_LOC_MAP_ALBEDO = 15, // Shader location: sampler2d texture: albedo (same as: RL_SHADER_LOC_MAP_DIFFUSE)
    RL_SHADER_LOC_MAP_METALNESS = 16, // Shader location: sampler2d texture: metalness (same as: RL_SHADER_LOC_MAP_SPECULAR)
    RL_SHADER_LOC_MAP_NORMAL = 17, // Shader location: sampler2d texture: normal
    RL_SHADER_LOC_MAP_ROUGHNESS = 18, // Shader location: sampler2d texture: roughness
    RL_SHADER_LOC_MAP_OCCLUSION = 19, // Shader location: sampler2d texture: occlusion
    RL_SHADER_LOC_MAP_EMISSION = 20, // Shader location: sampler2d texture: emission
    RL_SHADER_LOC_MAP_HEIGHT = 21, // Shader location: sampler2d texture: height
    RL_SHADER_LOC_MAP_CUBEMAP = 22, // Shader location: samplerCube texture: cubemap
    RL_SHADER_LOC_MAP_IRRADIANCE = 23, // Shader location: samplerCube texture: irradiance
    RL_SHADER_LOC_MAP_PREFILTER = 24, // Shader location: samplerCube texture: prefilter
    RL_SHADER_LOC_MAP_BRDF = 25 // Shader location: sampler2d texture: brdf
}

enum RL_SHADER_LOC_MAP_DIFFUSE = rlShaderLocationIndex.RL_SHADER_LOC_MAP_ALBEDO;
enum RL_SHADER_LOC_MAP_SPECULAR = rlShaderLocationIndex.RL_SHADER_LOC_MAP_METALNESS;

// Shader uniform data type
enum rlShaderUniformDataType
{
    RL_SHADER_UNIFORM_FLOAT = 0, // Shader uniform type: float
    RL_SHADER_UNIFORM_VEC2 = 1, // Shader uniform type: vec2 (2 float)
    RL_SHADER_UNIFORM_VEC3 = 2, // Shader uniform type: vec3 (3 float)
    RL_SHADER_UNIFORM_VEC4 = 3, // Shader uniform type: vec4 (4 float)
    RL_SHADER_UNIFORM_INT = 4, // Shader uniform type: int
    RL_SHADER_UNIFORM_IVEC2 = 5, // Shader uniform type: ivec2 (2 int)
    RL_SHADER_UNIFORM_IVEC3 = 6, // Shader uniform type: ivec3 (3 int)
    RL_SHADER_UNIFORM_IVEC4 = 7, // Shader uniform type: ivec4 (4 int)
    RL_SHADER_UNIFORM_UINT = 8, // Shader uniform type: unsigned int
    RL_SHADER_UNIFORM_UIVEC2 = 9, // Shader uniform type: uivec2 (2 unsigned int)
    RL_SHADER_UNIFORM_UIVEC3 = 10, // Shader uniform type: uivec3 (3 unsigned int)
    RL_SHADER_UNIFORM_UIVEC4 = 11, // Shader uniform type: uivec4 (4 unsigned int)
    RL_SHADER_UNIFORM_SAMPLER2D = 12 // Shader uniform type: sampler2d
}

// Shader attribute data types
enum rlShaderAttributeDataType
{
    RL_SHADER_ATTRIB_FLOAT = 0, // Shader attribute type: float
    RL_SHADER_ATTRIB_VEC2 = 1, // Shader attribute type: vec2 (2 float)
    RL_SHADER_ATTRIB_VEC3 = 2, // Shader attribute type: vec3 (3 float)
    RL_SHADER_ATTRIB_VEC4 = 3 // Shader attribute type: vec4 (4 float)
}

// Framebuffer attachment type
// NOTE: By default up to 8 color channels defined, but it can be more
enum rlFramebufferAttachType
{
    RL_ATTACHMENT_COLOR_CHANNEL0 = 0, // Framebuffer attachment type: color 0
    RL_ATTACHMENT_COLOR_CHANNEL1 = 1, // Framebuffer attachment type: color 1
    RL_ATTACHMENT_COLOR_CHANNEL2 = 2, // Framebuffer attachment type: color 2
    RL_ATTACHMENT_COLOR_CHANNEL3 = 3, // Framebuffer attachment type: color 3
    RL_ATTACHMENT_COLOR_CHANNEL4 = 4, // Framebuffer attachment type: color 4
    RL_ATTACHMENT_COLOR_CHANNEL5 = 5, // Framebuffer attachment type: color 5
    RL_ATTACHMENT_COLOR_CHANNEL6 = 6, // Framebuffer attachment type: color 6
    RL_ATTACHMENT_COLOR_CHANNEL7 = 7, // Framebuffer attachment type: color 7
    RL_ATTACHMENT_DEPTH = 100, // Framebuffer attachment type: depth
    RL_ATTACHMENT_STENCIL = 200 // Framebuffer attachment type: stencil
}

// Framebuffer texture attachment type
enum rlFramebufferAttachTextureType
{
    RL_ATTACHMENT_CUBEMAP_POSITIVE_X = 0, // Framebuffer texture attachment type: cubemap, +X side
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_X = 1, // Framebuffer texture attachment type: cubemap, -X side
    RL_ATTACHMENT_CUBEMAP_POSITIVE_Y = 2, // Framebuffer texture attachment type: cubemap, +Y side
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Y = 3, // Framebuffer texture attachment type: cubemap, -Y side
    RL_ATTACHMENT_CUBEMAP_POSITIVE_Z = 4, // Framebuffer texture attachment type: cubemap, +Z side
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Z = 5, // Framebuffer texture attachment type: cubemap, -Z side
    RL_ATTACHMENT_TEXTURE2D = 100, // Framebuffer texture attachment type: texture2d
    RL_ATTACHMENT_RENDERBUFFER = 200 // Framebuffer texture attachment type: renderbuffer
}

// Face culling mode
enum rlCullMode
{
    RL_CULL_FACE_FRONT = 0,
    RL_CULL_FACE_BACK = 1
}

//------------------------------------------------------------------------------------
// Functions Declaration - Matrix operations
//------------------------------------------------------------------------------------

// Prevents name mangling of functions

void rlMatrixMode(int mode); // Choose the current matrix to be transformed
void rlPushMatrix(); // Push the current matrix to stack
void rlPopMatrix(); // Pop latest inserted matrix from stack
void rlLoadIdentity(); // Reset current matrix to identity matrix
void rlTranslatef(float x, float y, float z); // Multiply the current matrix by a translation matrix
void rlRotatef(float angle, float x, float y, float z); // Multiply the current matrix by a rotation matrix
void rlScalef(float x, float y, float z); // Multiply the current matrix by a scaling matrix
void rlMultMatrixf(const(float)* matf); // Multiply the current matrix by another matrix
void rlFrustum(double left, double right, double bottom, double top, double znear, double zfar);
void rlOrtho(double left, double right, double bottom, double top, double znear, double zfar);
void rlViewport(int x, int y, int width, int height); // Set the viewport area
void rlSetClipPlanes(double nearPlane, double farPlane); // Set clip planes distances
double rlGetCullDistanceNear(); // Get cull plane distance near
double rlGetCullDistanceFar(); // Get cull plane distance far

//------------------------------------------------------------------------------------
// Functions Declaration - Vertex level operations
//------------------------------------------------------------------------------------
void rlBegin(int mode); // Initialize drawing mode (how to organize vertex)
void rlEnd(); // Finish vertex providing
void rlVertex2i(int x, int y); // Define one vertex (position) - 2 int
void rlVertex2f(float x, float y); // Define one vertex (position) - 2 float
void rlVertex3f(float x, float y, float z); // Define one vertex (position) - 3 float
void rlTexCoord2f(float x, float y); // Define one vertex (texture coordinate) - 2 float
void rlNormal3f(float x, float y, float z); // Define one vertex (normal) - 3 float
void rlColor4ub(ubyte r, ubyte g, ubyte b, ubyte a); // Define one vertex (color) - 4 byte
void rlColor3f(float x, float y, float z); // Define one vertex (color) - 3 float
void rlColor4f(float x, float y, float z, float w); // Define one vertex (color) - 4 float

//------------------------------------------------------------------------------------
// Functions Declaration - OpenGL style functions (common to 1.1, 3.3+, ES2)
// NOTE: This functions are used to completely abstract raylib code from OpenGL layer,
// some of them are direct wrappers over OpenGL calls, some others are custom
//------------------------------------------------------------------------------------

// Vertex buffers state
bool rlEnableVertexArray(uint vaoId); // Enable vertex array (VAO, if supported)
void rlDisableVertexArray(); // Disable vertex array (VAO, if supported)
void rlEnableVertexBuffer(uint id); // Enable vertex buffer (VBO)
void rlDisableVertexBuffer(); // Disable vertex buffer (VBO)
void rlEnableVertexBufferElement(uint id); // Enable vertex buffer element (VBO element)
void rlDisableVertexBufferElement(); // Disable vertex buffer element (VBO element)
void rlEnableVertexAttribute(uint index); // Enable vertex attribute index
void rlDisableVertexAttribute(uint index); // Disable vertex attribute index

// Enable attribute state pointer
// Disable attribute state pointer

// Textures state
void rlActiveTextureSlot(int slot); // Select and active a texture slot
void rlEnableTexture(uint id); // Enable texture
void rlDisableTexture(); // Disable texture
void rlEnableTextureCubemap(uint id); // Enable texture cubemap
void rlDisableTextureCubemap(); // Disable texture cubemap
void rlTextureParameters(uint id, int param, int value); // Set texture parameters (filter, wrap)
void rlCubemapParameters(uint id, int param, int value); // Set cubemap parameters (filter, wrap)

// Shader state
void rlEnableShader(uint id); // Enable shader program
void rlDisableShader(); // Disable shader program

// Framebuffer state
void rlEnableFramebuffer(uint id); // Enable render texture (fbo)
void rlDisableFramebuffer(); // Disable render texture (fbo), return to default framebuffer
uint rlGetActiveFramebuffer(); // Get the currently active render texture (fbo), 0 for default framebuffer
void rlActiveDrawBuffers(int count); // Activate multiple draw color buffers
void rlBlitFramebuffer(int srcX, int srcY, int srcWidth, int srcHeight, int dstX, int dstY, int dstWidth, int dstHeight, int bufferMask); // Blit active framebuffer to main framebuffer
void rlBindFramebuffer(uint target, uint framebuffer); // Bind framebuffer (FBO)

// General render state
void rlEnableColorBlend(); // Enable color blending
void rlDisableColorBlend(); // Disable color blending
void rlEnableDepthTest(); // Enable depth test
void rlDisableDepthTest(); // Disable depth test
void rlEnableDepthMask(); // Enable depth write
void rlDisableDepthMask(); // Disable depth write
void rlEnableBackfaceCulling(); // Enable backface culling
void rlDisableBackfaceCulling(); // Disable backface culling
void rlColorMask(bool r, bool g, bool b, bool a); // Color mask control
void rlSetCullFace(int mode); // Set face culling mode
void rlEnableScissorTest(); // Enable scissor test
void rlDisableScissorTest(); // Disable scissor test
void rlScissor(int x, int y, int width, int height); // Scissor test
void rlEnableWireMode(); // Enable wire mode
void rlEnablePointMode(); // Enable point mode
void rlDisableWireMode(); // Disable wire (and point) mode
void rlSetLineWidth(float width); // Set the line drawing width
float rlGetLineWidth(); // Get the line drawing width
void rlEnableSmoothLines(); // Enable line aliasing
void rlDisableSmoothLines(); // Disable line aliasing
void rlEnableStereoRender(); // Enable stereo rendering
void rlDisableStereoRender(); // Disable stereo rendering
bool rlIsStereoRenderEnabled(); // Check if stereo render is enabled

void rlClearColor(ubyte r, ubyte g, ubyte b, ubyte a); // Clear color buffer with color
void rlClearScreenBuffers(); // Clear used screen buffers (color and depth)
void rlCheckErrors(); // Check and log OpenGL error codes
void rlSetBlendMode(int mode); // Set blending mode
void rlSetBlendFactors(int glSrcFactor, int glDstFactor, int glEquation); // Set blending mode factor and equation (using OpenGL factors)
void rlSetBlendFactorsSeparate(int glSrcRGB, int glDstRGB, int glSrcAlpha, int glDstAlpha, int glEqRGB, int glEqAlpha); // Set blending mode factors and equations separately (using OpenGL factors)

//------------------------------------------------------------------------------------
// Functions Declaration - rlgl functionality
//------------------------------------------------------------------------------------
// rlgl initialization functions
void rlglInit(int width, int height); // Initialize rlgl (buffers, shaders, textures, states)
void rlglClose(); // De-initialize rlgl (buffers, shaders, textures)
void rlLoadExtensions(void* loader); // Load OpenGL extensions (loader function required)
int rlGetVersion(); // Get current OpenGL version
void rlSetFramebufferWidth(int width); // Set current framebuffer width
int rlGetFramebufferWidth(); // Get default framebuffer width
void rlSetFramebufferHeight(int height); // Set current framebuffer height
int rlGetFramebufferHeight(); // Get default framebuffer height

uint rlGetTextureIdDefault(); // Get default texture id
uint rlGetShaderIdDefault(); // Get default shader id
int* rlGetShaderLocsDefault(); // Get default shader locations

// Render batch management
// NOTE: rlgl provides a default render batch to behave like OpenGL 1.1 immediate mode
// but this render batch API is exposed in case of custom batches are required
rlRenderBatch rlLoadRenderBatch(int numBuffers, int bufferElements); // Load a render batch system
void rlUnloadRenderBatch(rlRenderBatch batch); // Unload render batch system
void rlDrawRenderBatch(rlRenderBatch* batch); // Draw render batch data (Update->Draw->Reset)
void rlSetRenderBatchActive(rlRenderBatch* batch); // Set the active render batch for rlgl (NULL for default internal)
void rlDrawRenderBatchActive(); // Update and draw internal render batch
bool rlCheckRenderBatchLimit(int vCount); // Check internal buffer overflow for a given number of vertex

void rlSetTexture(uint id); // Set current texture for render batch and check buffers limits

//------------------------------------------------------------------------------------------------------------------------

// Vertex buffers management
uint rlLoadVertexArray(); // Load vertex array (vao) if supported
uint rlLoadVertexBuffer(const(void)* buffer, int size, bool dynamic); // Load a vertex buffer object
uint rlLoadVertexBufferElement(const(void)* buffer, int size, bool dynamic); // Load vertex buffer elements object
void rlUpdateVertexBuffer(uint bufferId, const(void)* data, int dataSize, int offset); // Update vertex buffer object data on GPU buffer
void rlUpdateVertexBufferElements(uint id, const(void)* data, int dataSize, int offset); // Update vertex buffer elements data on GPU buffer
void rlUnloadVertexArray(uint vaoId); // Unload vertex array (vao)
void rlUnloadVertexBuffer(uint vboId); // Unload vertex buffer object
void rlSetVertexAttribute(uint index, int compSize, int type, bool normalized, int stride, int offset); // Set vertex attribute data configuration
void rlSetVertexAttributeDivisor(uint index, int divisor); // Set vertex attribute data divisor
void rlSetVertexAttributeDefault(int locIndex, const(void)* value, int attribType, int count); // Set vertex attribute default value, when attribute to provided
void rlDrawVertexArray(int offset, int count); // Draw vertex array (currently active vao)
void rlDrawVertexArrayElements(int offset, int count, const(void)* buffer); // Draw vertex array elements
void rlDrawVertexArrayInstanced(int offset, int count, int instances); // Draw vertex array (currently active vao) with instancing
void rlDrawVertexArrayElementsInstanced(int offset, int count, const(void)* buffer, int instances); // Draw vertex array elements with instancing

// Textures management
uint rlLoadTexture(const(void)* data, int width, int height, int format, int mipmapCount); // Load texture data
uint rlLoadTextureDepth(int width, int height, bool useRenderBuffer); // Load depth texture/renderbuffer (to be attached to fbo)
uint rlLoadTextureCubemap(const(void)* data, int size, int format); // Load texture cubemap data
void rlUpdateTexture(uint id, int offsetX, int offsetY, int width, int height, int format, const(void)* data); // Update texture with new data on GPU
void rlGetGlTextureFormats(int format, uint* glInternalFormat, uint* glFormat, uint* glType); // Get OpenGL internal formats
const(char)* rlGetPixelFormatName(uint format); // Get name string for pixel format
void rlUnloadTexture(uint id); // Unload texture from GPU memory
void rlGenTextureMipmaps(uint id, int width, int height, int format, int* mipmaps); // Generate mipmap data for selected texture
void* rlReadTexturePixels(uint id, int width, int height, int format); // Read texture pixel data
ubyte* rlReadScreenPixels(int width, int height); // Read screen pixel data (color buffer)

// Framebuffer management (fbo)
uint rlLoadFramebuffer(); // Load an empty framebuffer
void rlFramebufferAttach(uint fboId, uint texId, int attachType, int texType, int mipLevel); // Attach texture/renderbuffer to a framebuffer
bool rlFramebufferComplete(uint id); // Verify framebuffer is complete
void rlUnloadFramebuffer(uint id); // Delete framebuffer from GPU

// Shaders management
uint rlLoadShaderCode(const(char)* vsCode, const(char)* fsCode); // Load shader from code strings
uint rlCompileShader(const(char)* shaderCode, int type); // Compile custom shader and return shader id (type: RL_VERTEX_SHADER, RL_FRAGMENT_SHADER, RL_COMPUTE_SHADER)
uint rlLoadShaderProgram(uint vShaderId, uint fShaderId); // Load custom shader program
void rlUnloadShaderProgram(uint id); // Unload shader program
int rlGetLocationUniform(uint shaderId, const(char)* uniformName); // Get shader location uniform
int rlGetLocationAttrib(uint shaderId, const(char)* attribName); // Get shader location attribute
void rlSetUniform(int locIndex, const(void)* value, int uniformType, int count); // Set shader value uniform
void rlSetUniformMatrix(int locIndex, Matrix mat); // Set shader value matrix
void rlSetUniformSampler(int locIndex, uint textureId); // Set shader value sampler
void rlSetShader(uint id, int* locs); // Set shader currently active (id and locations)

// Compute shader management
uint rlLoadComputeShaderProgram(uint shaderId); // Load compute shader program
void rlComputeShaderDispatch(uint groupX, uint groupY, uint groupZ); // Dispatch compute shader (equivalent to *draw* for graphics pipeline)

// Shader buffer storage object management (ssbo)
uint rlLoadShaderBuffer(uint size, const(void)* data, int usageHint); // Load shader storage buffer object (SSBO)
void rlUnloadShaderBuffer(uint ssboId); // Unload shader storage buffer object (SSBO)
void rlUpdateShaderBuffer(uint id, const(void)* data, uint dataSize, uint offset); // Update SSBO buffer data
void rlBindShaderBuffer(uint id, uint index); // Bind SSBO buffer
void rlReadShaderBuffer(uint id, void* dest, uint count, uint offset); // Read SSBO buffer data (GPU->CPU)
void rlCopyShaderBuffer(uint destId, uint srcId, uint destOffset, uint srcOffset, uint count); // Copy SSBO data between buffers
uint rlGetShaderBufferSize(uint id); // Get SSBO buffer size

// Buffer management
void rlBindImageTexture(uint id, uint index, int format, bool readonly); // Bind image texture

// Matrix state management
Matrix rlGetMatrixModelview(); // Get internal modelview matrix
Matrix rlGetMatrixProjection(); // Get internal projection matrix
Matrix rlGetMatrixTransform(); // Get internal accumulated transform matrix
Matrix rlGetMatrixProjectionStereo(int eye); // Get internal projection matrix for stereo render (selected eye)
Matrix rlGetMatrixViewOffsetStereo(int eye); // Get internal view offset matrix for stereo render (selected eye)
void rlSetMatrixProjection(Matrix proj); // Set a custom projection matrix (replaces internal projection matrix)
void rlSetMatrixModelview(Matrix view); // Set a custom modelview matrix (replaces internal modelview matrix)
void rlSetMatrixProjectionStereo(Matrix right, Matrix left); // Set eyes projection matrices for stereo rendering
void rlSetMatrixViewOffsetStereo(Matrix right, Matrix left); // Set eyes view offsets matrices for stereo rendering

// Quick and dirty cube/quad buffers load->draw->unload
void rlLoadDrawCube(); // Load and draw a cube
void rlLoadDrawQuad(); // Load and draw a quad

// RLGL_H

/***********************************************************************************
*
*   RLGL IMPLEMENTATION
*
************************************************************************************/

// Expose OpenGL functions from glad in raylib

// OpenGL 1.1 library for OSX
// OpenGL extensions library

// APIENTRY for OpenGL function pointer declarations is required

// WINGDIAPI definition. Some Windows OpenGL headers need it

// OpenGL 1.1 library

// GLAD extensions loading library, includes OpenGL headers

// OpenGL ES 3.0 library

// OpenGL ES 2.0 extensions library

// NOTE: OpenGL ES 2.0 can be enabled on Desktop platforms,
// in that case, functions are loaded from a custom glad for OpenGL ES 2.0

//#include <EGL/egl.h>          // EGL library -> not required, platform layer
// OpenGL ES 2.0 library
// OpenGL ES 2.0 extensions library

// It seems OpenGL ES 2.0 instancing entry points are not defined on Raspberry Pi
// provided headers (despite being defined in official Khronos GLES2 headers)

// Required for: malloc(), free()
// Required for: strcmp(), strlen() [Used in rlglInit(), on extensions loading]
// Required for: sqrtf(), sinf(), cosf(), floor(), log()

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------

// Default shader vertex attribute names to set location points

// Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_NAME_POSITION

// Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD

// Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_NAME_NORMAL

// Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_NAME_COLOR

// Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_NAME_TANGENT

// Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD2

// model-view-projection matrix

// view matrix

// projection matrix

// model matrix

// normal matrix (transpose(inverse(matModelView))

// color diffuse (base tint color, multiplied by texture color)

// texture0 (texture slot active 0)

// texture1 (texture slot active 1)

// texture2 (texture slot active 2)

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------

// Current render batch
// Default internal render batch

// Current active render batch vertex counter (generic, used for all batches)
// Current active texture coordinate (added on glVertex*())
// Current active normal (added on glVertex*())
// Current active color (added on glVertex*())

// Current matrix mode
// Current matrix pointer
// Default modelview matrix
// Default projection matrix
// Transform matrix to be used with rlTranslate, rlRotate, rlScale
// Require transform matrix application to current draw-call vertex (if required)
// Matrix stack for push/pop
// Matrix stack counter

// Default texture used on shapes/poly drawing (required by shader)
// Active texture ids to be enabled on batch drawing (0 active by default)
// Default vertex shader id (used by default shader program)
// Default fragment shader id (used by default shader program)
// Default shader program id, supports vertex color and diffuse texture
// Default shader locations pointer to be used on rendering
// Current shader id to be used on rendering (by default, defaultShaderId)
// Current shader locations pointer to be used on rendering (by default, defaultShaderLocs)

// Stereo rendering flag
// VR stereo rendering eyes projection matrices
// VR stereo rendering eyes view offset matrices

// Blending variables
// Blending mode active
// Blending source factor
// Blending destination factor
// Blending equation
// Blending source RGB factor
// Blending destination RGB factor
// Blending source alpha factor
// Blending destination alpha factor
// Blending equation for RGB
// Blending equation for alpha
// Custom blending factor and equation modification status

// Current framebuffer width
// Current framebuffer height

// Renderer state

// VAO support (OpenGL ES2 could not support VAO extension) (GL_ARB_vertex_array_object)
// Instancing supported (GL_ANGLE_instanced_arrays, GL_EXT_draw_instanced + GL_EXT_instanced_arrays)
// NPOT textures full support (GL_ARB_texture_non_power_of_two, GL_OES_texture_npot)
// Depth textures supported (GL_ARB_depth_texture, GL_OES_depth_texture)
// Depth textures supported WebGL specific (GL_WEBGL_depth_texture)
// float textures support (32 bit per channel) (GL_OES_texture_float)
// half float textures support (16 bit per channel) (GL_OES_texture_half_float)
// DDS texture compression support (GL_EXT_texture_compression_s3tc, GL_WEBGL_compressed_texture_s3tc, GL_WEBKIT_WEBGL_compressed_texture_s3tc)
// ETC1 texture compression support (GL_OES_compressed_ETC1_RGB8_texture, GL_WEBGL_compressed_texture_etc1)
// ETC2/EAC texture compression support (GL_ARB_ES3_compatibility)
// PVR texture compression support (GL_IMG_texture_compression_pvrtc)
// ASTC texture compression support (GL_KHR_texture_compression_astc_hdr, GL_KHR_texture_compression_astc_ldr)
// Clamp mirror wrap mode supported (GL_EXT_texture_mirror_clamp)
// Anisotropic texture filtering support (GL_EXT_texture_filter_anisotropic)
// Compute shaders support (GL_ARB_compute_shader)
// Shader storage buffer object support (GL_ARB_shader_storage_buffer_object)

// Maximum anisotropy level supported (minimum is 2.0f)
// Maximum bits for depth component

// Extensions supported flags

// OpenGL extension functions loader signature (same as GLADloadproc)

// GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------

// GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2

// NOTE: VAO functionality is exposed through extensions (OES)

// NOTE: Instancing functionality could also be available through extension

//----------------------------------------------------------------------------------
// Module specific Functions Declaration
//----------------------------------------------------------------------------------

// Load default shader
// Unload default shader

// Get compressed format official GL identifier name
// RLGL_SHOW_GL_DETAILS_INFO
// GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2

// Get pixel data size in bytes (image or texture)

// Auxiliar matrix math functions

// Get float array of matrix data
// Get float vector for Matrix
// Get identity matrix
// Multiply two matrices
// Transposes provided matrix
// Invert provided matrix

//----------------------------------------------------------------------------------
// Module Functions Definition - Matrix operations
//----------------------------------------------------------------------------------

// Fallback to OpenGL 1.1 function calls
//---------------------------------------

// Choose the current matrix to be transformed

//else if (mode == RL_TEXTURE) // Not supported

// Push the current matrix into RLGL.State.stack

// Pop lattest inserted matrix from RLGL.State.stack

// Reset current matrix to identity matrix

// Multiply the current matrix by a translation matrix

// NOTE: We transpose matrix with multiplication order

// Multiply the current matrix by a rotation matrix
// NOTE: The provided angle must be in degrees

// Axis vector (x, y, z) normalization

// Rotation matrix generation

// NOTE: We transpose matrix with multiplication order

// Multiply the current matrix by a scaling matrix

// NOTE: We transpose matrix with multiplication order

// Multiply the current matrix by another matrix

// Matrix creation from array

// Multiply the current matrix by a perspective matrix generated by parameters

// Multiply the current matrix by an orthographic matrix generated by parameters

// NOTE: If left-right and top-botton values are equal it could create a division by zero,
// response to it is platform/compiler dependant

// Set the viewport area (transformation from normalized device coordinates to window coordinates)
// NOTE: We store current viewport dimensions

// Set clip planes distances

// Get cull plane distance near

// Get cull plane distance far

//----------------------------------------------------------------------------------
// Module Functions Definition - Vertex level operations
//----------------------------------------------------------------------------------

// Fallback to OpenGL 1.1 function calls
//---------------------------------------

// Initialize drawing mode (how to organize vertex)

// Draw mode can be RL_LINES, RL_TRIANGLES and RL_QUADS
// NOTE: In all three cases, vertex are accumulated over default internal vertex buffer

// Make sure current RLGL.currentBatch->draws[i].vertexCount is aligned a multiple of 4,
// that way, following QUADS drawing will keep aligned with index processing
// It implies adding some extra alignment vertex at the end of the draw,
// those vertex are not processed but they are considered as an additional offset
// for the next set of vertex to be drawn

// Finish vertex providing

// NOTE: Depth increment is dependant on rlOrtho(): z-near and z-far values,
// as well as depth buffer bit-depth (16bit or 24bit or 32bit)
// Correct increment formula would be: depthInc = (zfar - znear)/pow(2, bits)

// Define one vertex (position)
// NOTE: Vertex position data is the basic information required for drawing

// Transform provided vector if required

// WARNING: We can't break primitives when launching a new batch.
// RL_LINES comes in pairs, RL_TRIANGLES come in groups of 3 vertices and RL_QUADS come in groups of 4 vertices.
// We must check current draw.mode when a new vertex is required and finish the batch only if the draw.mode draw.vertexCount is %2, %3 or %4

// Reached the maximum number of vertices for RL_LINES drawing
// Launch a draw call but keep current state for next vertices comming
// NOTE: We add +1 vertex to the check for security

// Add vertices

// Add current texcoord

// Add current normal

// Add current color

// Define one vertex (position)

// Define one vertex (position)

// Define one vertex (texture coordinate)
// NOTE: Texture coordinates are limited to QUADS only

// Define one vertex (normal)
// NOTE: Normals limited to TRIANGLES only?

// Define one vertex (color)

// Define one vertex (color)

// Define one vertex (color)

//--------------------------------------------------------------------------------------
// Module Functions Definition - OpenGL style functions (common to 1.1, 3.3+, ES2)
//--------------------------------------------------------------------------------------

// Set current texture to use

// NOTE: If quads batch limit is reached, we force a draw call and next batch starts

// Make sure current RLGL.currentBatch->draws[i].vertexCount is aligned a multiple of 4,
// that way, following QUADS drawing will keep aligned with index processing
// It implies adding some extra alignment vertex at the end of the draw,
// those vertex are not processed but they are considered as an additional offset
// for the next set of vertex to be drawn

// Select and active a texture slot

// Enable texture

// Disable texture

// Enable texture cubemap

// Disable texture cubemap

// Set texture parameters (wrap mode/filter mode)

// Reset anisotropy filter, in case it was set

// Set cubemap parameters (wrap mode/filter mode)

// Reset anisotropy filter, in case it was set

// Enable shader program

// Disable shader program

// Enable rendering to texture (fbo)

// return the active render texture (fbo)

// Disable rendering to texture

// Blit active framebuffer to main framebuffer

// Bind framebuffer object (fbo)

// Activate multiple draw color buffers
// NOTE: One color buffer is always active by default

// NOTE: Maximum number of draw buffers supported is implementation dependant,
// it can be queried with glGet*() but it must be at least 8
//GLint maxDrawBuffers = 0;
//glGetIntegerv(GL_MAX_DRAW_BUFFERS, &maxDrawBuffers);

//----------------------------------------------------------------------------------
// General render state configuration
//----------------------------------------------------------------------------------

// Enable color blending

// Disable color blending

// Enable depth test

// Disable depth test

// Enable depth write

// Disable depth write

// Enable backface culling

// Disable backface culling

// Set color mask active for screen read/draw

// Set face culling mode

// Enable scissor test

// Disable scissor test

// Scissor test

// Enable wire mode

// NOTE: glPolygonMode() not available on OpenGL ES

// Enable point mode

// NOTE: glPolygonMode() not available on OpenGL ES

// Disable wire mode

// NOTE: glPolygonMode() not available on OpenGL ES

// Set the line drawing width

// Get the line drawing width

// Enable line aliasing

// Disable line aliasing

// Enable stereo rendering

// Disable stereo rendering

// Check if stereo render is enabled

// Clear color buffer with color

// Color values clamp to 0.0f(0) and 1.0f(255)

// Clear used screen buffers (color and depth)

// Clear used buffers: Color and Depth (Depth is used for 3D)
//glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);     // Stencil buffer not used...

// Check and log OpenGL error codes

// Set blend mode

// NOTE: Using GL blend src/dst factors and GL equation configured with rlSetBlendFactors()

// NOTE: Using GL blend src/dst factors and GL equation configured with rlSetBlendFactorsSeparate()

// Set blending mode factor and equation

// Set blending mode factor and equation separately for RGB and alpha

//----------------------------------------------------------------------------------
// Module Functions Definition - OpenGL Debug
//----------------------------------------------------------------------------------

// Ignore non-significant error/warning codes (NVidia drivers)
// NOTE: Here there are the details with a sample output:
// - #131169 - Framebuffer detailed info: The driver allocated storage for renderbuffer 2. (severity: low)
// - #131185 - Buffer detailed info: Buffer object 1 (bound to GL_ELEMENT_ARRAY_BUFFER_ARB, usage hint is GL_ENUM_88e4)
//             will use VIDEO memory as the source for buffer object operations. (severity: low)
// - #131218 - Program/shader state performance warning: Vertex shader in program 7 is being recompiled based on GL state. (severity: medium)
// - #131204 - Texture state usage warning: The texture object (0) bound to texture image unit 0 does not have
//             a defined base level and cannot be used for texture mapping. (severity: low)

//----------------------------------------------------------------------------------
// Module Functions Definition - rlgl functionality
//----------------------------------------------------------------------------------

// Initialize rlgl: OpenGL extensions, default buffers/shaders/textures, OpenGL states

// Enable OpenGL debug context if required

// glDebugMessageControl(GL_DEBUG_SOURCE_API, GL_DEBUG_TYPE_ERROR, GL_DEBUG_SEVERITY_HIGH, 0, 0, GL_TRUE);

// Debug context options:
//  - GL_DEBUG_OUTPUT - Faster version but not useful for breakpoints
//  - GL_DEBUG_OUTPUT_SYNCHRONUS - Callback is in sync with errors, so a breakpoint can be placed on the callback in order to get a stacktrace for the GL error

// Init default white texture
// 1 pixel RGBA (4 bytes)

// Init default Shader (customized for GL 3.3 and ES2)
// Loaded: RLGL.State.defaultShaderId + RLGL.State.defaultShaderLocs

// Init default vertex arrays buffers
// Simulate that the default shader has the location RL_SHADER_LOC_VERTEX_NORMAL to bind the normal buffer for the default render batch

// Init stack matrices (emulating OpenGL 1.1)

// Init internal matrices

// GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2

// Initialize OpenGL default states
//----------------------------------------------------------
// Init state: Depth test
// Type of depth testing to apply
// Disable depth testing for 2D (only used for 3D)

// Init state: Blending mode
// Color blending function (how colors are mixed)
// Enable color blending (required to work with transparencies)

// Init state: Culling
// NOTE: All shapes/models triangles are drawn CCW
// Cull the back face (default)
// Front face are defined counter clockwise (default)
// Enable backface culling

// Init state: Cubemap seamless

// Seamless cubemaps (not supported on OpenGL ES 2.0)

// Init state: Color hints (deprecated in OpenGL 3.0+)
// Improve quality of color and texture coordinate interpolation
// Smooth shading between vertex (vertex colors interpolation)

// Store screen size into global variables

//----------------------------------------------------------

// Init state: Color/Depth buffers clear
// Set clear color (black)
// Set clear depth value (default)
// Clear color and depth buffers (depth buffer required for 3D)

// Vertex Buffer Object deinitialization (memory free)

// Unload default shader

// Unload default texture

// Load OpenGL extensions
// NOTE: External loader function must be provided

// Also defined for GRAPHICS_API_OPENGL_21
// NOTE: glad is generated and contains only required OpenGL 3.3 Core extensions (and lower versions)

// Get number of supported extensions

// Get supported extensions list
// WARNING: glGetStringi() not available on OpenGL 2.1

// Register supported extensions flags
// Optional OpenGL 2.1 extensions

// Register supported extensions flags
// OpenGL 3.3 extensions supported by default (core)

// Optional OpenGL 3.3 extensions

// Texture compression: DXT
// Texture compression: ETC2/EAC

// GRAPHICS_API_OPENGL_33

// Register supported extensions flags
// OpenGL ES 3.0 extensions supported by default (or it should be)

// TODO: Check for additional OpenGL ES 3.0 supported extensions:
//RLGL.ExtSupported.texCompDXT = true;
//RLGL.ExtSupported.texCompETC1 = true;
//RLGL.ExtSupported.texCompETC2 = true;
//RLGL.ExtSupported.texCompPVRT = true;
//RLGL.ExtSupported.texCompASTC = true;
//RLGL.ExtSupported.maxAnisotropyLevel = true;
//RLGL.ExtSupported.computeShader = true;
//RLGL.ExtSupported.ssbo = true;

// TODO: Support GLAD loader for OpenGL ES 3.0

// Get supported extensions list

// Allocate 512 strings pointers (2 KB)
// One big const string

// NOTE: We have to duplicate string because glGetString() returns a const string
// Get extensions string size in bytes

// Check required extensions

// Check VAO support
// NOTE: Only check on OpenGL ES, OpenGL 3.3 has VAO support as core feature

// The extension is supported by our hardware and driver, try to get related functions pointers
// NOTE: emscripten does not support VAOs natively, it uses emulation and it reduces overall performance...

//glIsVertexArray = (PFNGLISVERTEXARRAYOESPROC)loader("glIsVertexArrayOES");     // NOTE: Fails in WebGL, omitted

// Check instanced rendering support
// Web ANGLE

// Standard EXT

// Check NPOT textures support
// NOTE: Only check on OpenGL ES, OpenGL 3.3 has NPOT textures full support as core feature

// Check texture float support

// Check depth texture support

// WebGL requires unsized internal format

// Not available on WebGL
// Not available on WebGL

// Check texture compression support: DXT

// Check texture compression support: ETC1

// Check texture compression support: ETC2/EAC

// Check texture compression support: PVR

// Check texture compression support: ASTC

// Check anisotropic texture filter support

// Check clamp mirror wrap mode support

// Free extensions pointers

// Duplicated string must be deallocated
// GRAPHICS_API_OPENGL_ES2

// Check OpenGL information and capabilities
//------------------------------------------------------------------------------
// Show current OpenGL and GLSL version

// NOTE: Anisotropy levels capability is an extension

// Show some OpenGL GPU capabilities

// GRAPHICS_API_OPENGL_43
// RLGL_SHOW_GL_DETAILS_INFO

// Show some basic info about GL supported features

// RLGL_SHOW_GL_DETAILS_INFO

// GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2

// Get current OpenGL version

// Set current framebuffer width

// Set current framebuffer height

// Get default framebuffer width

// Get default framebuffer height

// Get default internal texture (white texture)
// NOTE: Default texture is a 1x1 pixel UNCOMPRESSED_R8G8B8A8

// Get default shader id

// Get default shader locs

// Render batch management
//------------------------------------------------------------------------------------------------
// Load render batch

// Initialize CPU (RAM) vertex buffers (position, texcoord, color data and indexes)
//--------------------------------------------------------------------------------------------

// 3 float by vertex, 4 vertex by quad
// 2 float by texcoord, 4 texcoord by quad
// 3 float by vertex, 4 vertex by quad
// 4 float by color, 4 colors by quad

// 6 int by quad (indices)

// 6 int by quad (indices)

// Indices can be initialized right now

//--------------------------------------------------------------------------------------------

// Upload to GPU (VRAM) vertex data and initialize VAOs/VBOs
//--------------------------------------------------------------------------------------------

// Initialize Quads VAO

// Quads - Vertex buffers binding and attributes enable
// Vertex position buffer (shader-location = 0)

// Vertex texcoord buffer (shader-location = 1)

// Vertex normal buffer (shader-location = 2)

// Vertex color buffer (shader-location = 3)

// Fill index buffer

// Unbind the current VAO

//--------------------------------------------------------------------------------------------

// Init draw calls tracking system
//--------------------------------------------------------------------------------------------

//batch.draws[i].vaoId = 0;
//batch.draws[i].shaderId = 0;

//batch.draws[i].RLGL.State.projection = rlMatrixIdentity();
//batch.draws[i].RLGL.State.modelview = rlMatrixIdentity();

// Record buffer count
// Reset draws counter
// Reset depth value
//--------------------------------------------------------------------------------------------

// Unload default internal buffers vertex data from CPU and GPU

// Unbind everything

// Unload all vertex buffers data

// Unbind VAO attribs data

// Delete VBOs from GPU (VRAM)

// Delete VAOs from GPU (VRAM)

// Free vertex arrays memory from CPU (RAM)

// Unload arrays

// Draw render batch
// NOTE: We require a pointer to reset batch and increase current buffer (multi-buffer)

// Update batch vertex buffers
//------------------------------------------------------------------------------------------------------------
// NOTE: If there is not vertex data, buffers doesn't need to be updated (vertexCount > 0)
// TODO: If no data changed on the CPU arrays --> No need to re-update GPU arrays (use a change detector flag?)

// Activate elements VAO

// Vertex positions buffer

//glBufferData(GL_ARRAY_BUFFER, sizeof(float)*3*4*batch->vertexBuffer[batch->currentBuffer].elementCount, batch->vertexBuffer[batch->currentBuffer].vertices, GL_DYNAMIC_DRAW);  // Update all buffer

// Texture coordinates buffer

//glBufferData(GL_ARRAY_BUFFER, sizeof(float)*2*4*batch->vertexBuffer[batch->currentBuffer].elementCount, batch->vertexBuffer[batch->currentBuffer].texcoords, GL_DYNAMIC_DRAW); // Update all buffer

// Normals buffer

//glBufferData(GL_ARRAY_BUFFER, sizeof(float)*3*4*batch->vertexBuffer[batch->currentBuffer].elementCount, batch->vertexBuffer[batch->currentBuffer].normals, GL_DYNAMIC_DRAW); // Update all buffer

// Colors buffer

//glBufferData(GL_ARRAY_BUFFER, sizeof(float)*4*4*batch->vertexBuffer[batch->currentBuffer].elementCount, batch->vertexBuffer[batch->currentBuffer].colors, GL_DYNAMIC_DRAW);    // Update all buffer

// NOTE: glMapBuffer() causes sync issue.
// If GPU is working with this buffer, glMapBuffer() will wait(stall) until GPU to finish its job.
// To avoid waiting (idle), you can call first glBufferData() with NULL pointer before glMapBuffer().
// If you do that, the previous data in PBO will be discarded and glMapBuffer() returns a new
// allocated pointer immediately even if GPU is still working with the previous data.

// Another option: map the buffer object into client's memory
// Probably this code could be moved somewhere else...
// batch->vertexBuffer[batch->currentBuffer].vertices = (float *)glMapBuffer(GL_ARRAY_BUFFER, GL_READ_WRITE);
// if (batch->vertexBuffer[batch->currentBuffer].vertices)
// {
// Update vertex data
// }
// glUnmapBuffer(GL_ARRAY_BUFFER);

// Unbind the current VAO

//------------------------------------------------------------------------------------------------------------

// Draw batch vertex buffers (considering VR stereo if required)
//------------------------------------------------------------------------------------------------------------

// Setup current eye viewport (half screen width)

// Set current eye view offset to modelview matrix

// Set current eye projection matrix

// Draw buffers

// Set current shader and upload current MVP matrix

// Create modelview-projection matrix and upload to shader

// WARNING: For the following setup of the view, model, and normal matrices, it is expected that
// transformations and rendering occur between rlPushMatrix and rlPopMatrix.

// Bind vertex attrib: position (shader-location = 0)

// Bind vertex attrib: texcoord (shader-location = 1)

// Bind vertex attrib: normal (shader-location = 2)

// Bind vertex attrib: color (shader-location = 3)

// Setup some default shader values

// Active default sampler2D: texture0

// Activate additional sampler textures
// Those additional textures will be common for all draw calls of the batch

// Activate default sampler2D texture0 (one texture is always active for default batch shader)
// NOTE: Batch system accumulates calls by texture0 changes, additional textures are enabled for all the draw calls

// Bind current draw call texture, activated as GL_TEXTURE0 and Bound to sampler2D texture0 by default

// We need to define the number of indices to be processed: elementCount*6
// NOTE: The final parameter tells the GPU the offset in bytes from the
// start of the index buffer to the location of the first index to process

// Unbind textures

// Unbind VAO

// Unbind shader program

// Restore viewport to default measures

//------------------------------------------------------------------------------------------------------------

// Reset batch buffers
//------------------------------------------------------------------------------------------------------------
// Reset vertex counter for next frame

// Reset depth for next draw

// Restore projection/modelview matrices

// Reset RLGL.currentBatch->draws array

// Reset active texture units for next batch

// Reset draws counter to one draw for the batch

//------------------------------------------------------------------------------------------------------------

// Change to next buffer in the list (in case of multi-buffering)

// Set the active render batch for rlgl

// Update and draw internal render batch

// NOTE: Stereo rendering is checked inside

// Check internal buffer overflow for a given number of vertex
// and force a rlRenderBatch draw call if required

// Store current primitive drawing mode and texture id

// NOTE: Stereo rendering is checked inside

// Restore state of last batch so we can continue adding vertices

// Textures data management
//-----------------------------------------------------------------------------------------
// Convert image data to OpenGL texture (returns OpenGL valid Id)

// Free any old binding

// Check texture format support by OpenGL 1.1 (compressed textures not supported)

// GRAPHICS_API_OPENGL_11

// Generate texture id

// Mipmap data offset, only used for tracelog

// NOTE: Added pointer math separately from function to avoid UBSAN complaining

// Load the different mipmap levels

// Increment offset position to next mipmap
// Increment data pointer to next mipmap

// Security check for NPOT textures

// Texture parameters configuration
// NOTE: glTexParameteri does NOT affect texture uploading, just the way it's used

// NOTE: OpenGL ES 2.0 with no GL_OES_texture_npot support (i.e. WebGL) has limited NPOT support, so CLAMP_TO_EDGE must be used

// Set texture to repeat on x-axis
// Set texture to repeat on y-axis

// NOTE: If using negative texture coordinates (LoadOBJ()), it does not work!
// Set texture to clamp on x-axis
// Set texture to clamp on y-axis

// Set texture to repeat on x-axis
// Set texture to repeat on y-axis

// Magnification and minification filters
// Alternative: GL_LINEAR
// Alternative: GL_LINEAR

// Activate Trilinear filtering if mipmaps are available

// At this point we have the texture loaded in GPU and texture parameters configured

// NOTE: If mipmaps were not in data, they are not generated automatically

// Unbind current texture

// Load depth texture/renderbuffer (to be attached to fbo)
// WARNING: OpenGL ES 2.0 requires GL_OES_depth_texture and WebGL requires WEBGL_depth_texture extensions

// In case depth textures not supported, we force renderbuffer usage

// NOTE: We let the implementation to choose the best bit-depth
// Possible formats: GL_DEPTH_COMPONENT16, GL_DEPTH_COMPONENT24, GL_DEPTH_COMPONENT32 and GL_DEPTH_COMPONENT32F

// WARNING: WebGL platform requires unsized internal format definition (GL_DEPTH_COMPONENT)
// while other platforms using OpenGL ES 2.0 require/support sized internal formats depending on the GPU capabilities

// Create the renderbuffer that will serve as the depth attachment for the framebuffer
// NOTE: A renderbuffer is simpler than a texture and could offer better performance on embedded devices

// Load texture cubemap
// NOTE: Cubemap data is expected to be 6 images in a single data array (one after the other),
// expected the following convention: +X, -X, +Y, -Y, +Z, -Z

// Load cubemap faces

// Set cubemap texture sampling parameters

// Flag not supported on OpenGL ES 2.0

// Update already loaded texture in GPU with new data
// NOTE: We don't know safely if internal texture format is the expected one...

// Get OpenGL internal formats and data type from raylib PixelFormat

// NOTE: on OpenGL ES 2.0 (WebGL), internalFormat must match format and options allowed are: GL_LUMINANCE, GL_RGB, GL_RGBA

// NOTE: Requires extension OES_texture_float
// NOTE: Requires extension OES_texture_float
// NOTE: Requires extension OES_texture_float

// defined(GRAPHICS_API_OPENGL_ES2)
// NOTE: Requires extension OES_texture_half_float
// NOTE: Requires extension OES_texture_half_float
// NOTE: Requires extension OES_texture_half_float

// NOTE: Requires OpenGL ES 2.0 or OpenGL 4.3
// NOTE: Requires OpenGL ES 3.0 or OpenGL 4.3
// NOTE: Requires OpenGL ES 3.0 or OpenGL 4.3
// NOTE: Requires PowerVR GPU
// NOTE: Requires PowerVR GPU
// NOTE: Requires OpenGL ES 3.1 or OpenGL 4.3
// NOTE: Requires OpenGL ES 3.1 or OpenGL 4.3

// Unload texture from GPU memory

// Generate mipmap data for selected texture
// NOTE: Only supports GPU mipmap generation

// Check if texture is power-of-two (POT)

//glHint(GL_GENERATE_MIPMAP_HINT, GL_DONT_CARE);   // Hint for mipmaps generation algorithm: GL_FASTEST, GL_NICEST, GL_DONT_CARE
// Generate mipmaps automatically

// Read texture pixel data

// NOTE: Using texture id, we can retrieve some texture info (but not on OpenGL ES 2.0)
// Possible texture info: GL_TEXTURE_RED_SIZE, GL_TEXTURE_GREEN_SIZE, GL_TEXTURE_BLUE_SIZE, GL_TEXTURE_ALPHA_SIZE
//int width, height, format;
//glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_WIDTH, &width);
//glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_HEIGHT, &height);
//glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_INTERNAL_FORMAT, &format);

// NOTE: Each row written to or read from by OpenGL pixel operations like glGetTexImage are aligned to a 4 byte boundary by default, which may add some padding.
// Use glPixelStorei to modify padding with the GL_[UN]PACK_ALIGNMENT setting.
// GL_PACK_ALIGNMENT affects operations that read from OpenGL memory (glReadPixels, glGetTexImage, etc.)
// GL_UNPACK_ALIGNMENT affects operations that write to OpenGL memory (glTexImage, etc.)

// glGetTexImage() is not available on OpenGL ES 2.0
// Texture width and height are required on OpenGL ES 2.0. There is no way to get it from texture id.
// Two possible Options:
// 1 - Bind texture to color fbo attachment and glReadPixels()
// 2 - Create an fbo, activate it, render quad with texture, glReadPixels()
// We are using Option 1, just need to care for texture format on retrieval
// NOTE: This behaviour could be conditioned by graphic driver...

// Attach our texture to FBO

// We read data as RGBA because FBO texture is configured as RGBA, despite binding another texture format

// Clean up temporal fbo

// Read screen pixel data (color buffer)

// NOTE 1: glReadPixels returns image flipped vertically -> (0,0) is the bottom left corner of the framebuffer
// NOTE 2: We are getting alpha channel! Be careful, it can be transparent if not cleared properly!

// Flip image vertically!

// Flip line

// Set alpha component value to 255 (no trasparent image retrieval)
// NOTE: Alpha value has already been applied to RGB in framebuffer, we don't need it!

// NOTE: image data should be freed

// Framebuffer management (fbo)
//-----------------------------------------------------------------------------------------
// Load a framebuffer to be used for rendering
// NOTE: No textures attached

// Create the framebuffer object
// Unbind any framebuffer

// Attach color buffer texture to an fbo (unloads previous attachment)
// NOTE: Attach type: 0-Color, 1-Depth renderbuffer, 2-Depth texture

// Verify render texture is complete

// Unload framebuffer from GPU memory
// NOTE: All attached textures/cubemaps/renderbuffers are also deleted

// Query depth attachment to automatically delete texture/renderbuffer

// Bind framebuffer to query depth texture type

// TODO: Review warning retrieving object name in WebGL
// WARNING: WebGL: INVALID_ENUM: getFramebufferAttachmentParameter: invalid parameter name
// https://registry.khronos.org/webgl/specs/latest/1.0/

// NOTE: If a texture object is deleted while its image is attached to the *currently bound* framebuffer,
// the texture image is automatically detached from the currently bound framebuffer.

// Vertex data management
//-----------------------------------------------------------------------------------------
// Load a new attributes buffer

// Load a new attributes element buffer

// Enable vertex buffer (VBO)

// Disable vertex buffer (VBO)

// Enable vertex buffer element (VBO element)

// Disable vertex buffer element (VBO element)

// Update vertex buffer with new data
// NOTE: dataSize and offset must be provided in bytes

// Update vertex buffer elements with new data
// NOTE: dataSize and offset must be provided in bytes

// Enable vertex array object (VAO)

// Disable vertex array object (VAO)

// Enable vertex attribute index

// Disable vertex attribute index

// Draw vertex array

// Draw vertex array elements

// NOTE: Added pointer math separately from function to avoid UBSAN complaining

// Draw vertex array instanced

// Draw vertex array elements instanced

// NOTE: Added pointer math separately from function to avoid UBSAN complaining

// Enable vertex state pointer

//case GL_INDEX_ARRAY: if (buffer != NULL) glIndexPointer(GL_SHORT, 0, buffer); break; // Indexed colors

// Disable vertex state pointer

// Load vertex array object (VAO)

// Set vertex attribute

// NOTE: Data type could be: GL_BYTE, GL_UNSIGNED_BYTE, GL_SHORT, GL_UNSIGNED_SHORT, GL_INT, GL_UNSIGNED_INT
// Additional types (depends on OpenGL version or extensions):
//  - GL_HALF_FLOAT, GL_FLOAT, GL_DOUBLE, GL_FIXED,
//  - GL_INT_2_10_10_10_REV, GL_UNSIGNED_INT_2_10_10_10_REV, GL_UNSIGNED_INT_10F_11F_11F_REV

// Set vertex attribute divisor

// Unload vertex array object (VAO)

// Unload vertex buffer (VBO)

//TRACELOG(RL_LOG_INFO, "VBO: Unloaded vertex data from VRAM (GPU)");

// Shaders management
//-----------------------------------------------------------------------------------------------
// Load shader from code strings
// NOTE: If shader string is NULL, using default vertex/fragment shaders

// Compile vertex shader (if provided)
// NOTE: If not vertex shader is provided, use default one

// Compile fragment shader (if provided)
// NOTE: If not vertex shader is provided, use default one

// In case vertex and fragment shader are the default ones, no need to recompile, we can just assign the default shader program id

// One of or both shader are new, we need to compile a new shader program

// We can detach and delete vertex/fragment shaders (if not default ones)
// NOTE: We detach shader before deletion to make sure memory is freed

// WARNING: Shader program linkage could fail and returned id is 0

// WARNING: Shader program linkage could fail and returned id is 0

// In case shader program loading failed, we assign default shader

// In case shader loading fails, we return the default shader

/*
else
{
    // Get available shader uniforms
    // NOTE: This information is useful for debug...
    int uniformCount = -1;
    glGetProgramiv(id, GL_ACTIVE_UNIFORMS, &uniformCount);

    for (int i = 0; i < uniformCount; i++)
    {
        int namelen = -1;
        int num = -1;
        char name[256] = { 0 };     // Assume no variable names longer than 256
        GLenum type = GL_ZERO;

        // Get the name of the uniforms
        glGetActiveUniform(id, i, sizeof(name) - 1, &namelen, &num, &type, name);

        name[namelen] = 0;
        TRACELOGD("SHADER: [ID %i] Active uniform (%s) set at location: %i", id, name, glGetUniformLocation(id, name));
    }
}
*/

// Compile custom shader and return shader id

//case GL_GEOMETRY_SHADER:

//case GL_GEOMETRY_SHADER:

// Load custom shader strings and return program id

// NOTE: Default attribute shader locations must be Bound before linking

// NOTE: If some attrib name is no found on the shader, it locations becomes -1

// NOTE: All uniform variables are intitialised to 0 when a program links

// Get the size of compiled shader program (not available on OpenGL ES 2.0)
// NOTE: If GL_LINK_STATUS is GL_FALSE, program binary length is zero.
//GLint binarySize = 0;
//glGetProgramiv(id, GL_PROGRAM_BINARY_LENGTH, &binarySize);

// Unload shader program

// Get shader location uniform

//if (location == -1) TRACELOG(RL_LOG_WARNING, "SHADER: [ID %i] Failed to find shader uniform: %s", shaderId, uniformName);
//else TRACELOG(RL_LOG_INFO, "SHADER: [ID %i] Shader uniform (%s) set at location: %i", shaderId, uniformName, location);

// Get shader location attribute

//if (location == -1) TRACELOG(RL_LOG_WARNING, "SHADER: [ID %i] Failed to find shader attribute: %s", shaderId, attribName);
//else TRACELOG(RL_LOG_INFO, "SHADER: [ID %i] Shader attribute (%s) set at location: %i", shaderId, attribName, location);

// Set shader value uniform

// TODO: Support glUniform1uiv(), glUniform2uiv(), glUniform3uiv(), glUniform4uiv()

// Set shader value attribute

// Set shader value uniform matrix

// Set shader value uniform sampler

// Check if texture is already active

// Register a new active texture for the internal batch system
// NOTE: Default texture is always activated as GL_TEXTURE0

// Activate new texture unit
// Save texture id for binding on drawing

// Set shader currently active (id and locations)

// Load compute shader program

// NOTE: All uniform variables are intitialised to 0 when a program links

// Get the size of compiled shader program (not available on OpenGL ES 2.0)
// NOTE: If GL_LINK_STATUS is GL_FALSE, program binary length is zero.
//GLint binarySize = 0;
//glGetProgramiv(id, GL_PROGRAM_BINARY_LENGTH, &binarySize);

// Dispatch compute shader (equivalent to *draw* for graphics pilepine)

// Load shader storage buffer object (SSBO)

// Clear buffer data to 0

// Unload shader storage buffer object (SSBO)

// Update SSBO buffer data

// Get SSBO buffer size

// Read SSBO buffer data (GPU->CPU)

// Bind SSBO buffer

// Copy SSBO buffer data

// Bind image texture

// Matrix state management
//-----------------------------------------------------------------------------------------
// Get internal modelview matrix

// Get internal projection matrix

// Get internal accumulated transform matrix

// TODO: Consider possible transform matrices in the RLGL.State.stack
// Is this the right order? or should we start with the first stored matrix instead of the last one?
//Matrix matStackTransform = rlMatrixIdentity();
//for (int i = RLGL.State.stackCounter; i > 0; i--) matStackTransform = rlMatrixMultiply(RLGL.State.stack[i], matStackTransform);

// Get internal projection matrix for stereo render (selected eye)

// Get internal view offset matrix for stereo render (selected eye)

// Set a custom modelview matrix (replaces internal modelview matrix)

// Set a custom projection matrix (replaces internal projection matrix)

// Set eyes projection matrices for stereo rendering

// Set eyes view offsets matrices for stereo rendering

// Load and draw a quad in NDC

// Positions         Texcoords

// Gen VAO to contain VBO

// Gen and fill vertex buffer (VBO)

// Bind vertex attributes (position, texcoords)

// Positions

// Texcoords

// Draw quad

// Delete buffers (VBO and VAO)

// Load and draw a cube in NDC

// Positions          Normals               Texcoords

// Gen VAO to contain VBO

// Gen and fill vertex buffer (VBO)

// Bind vertex attributes (position, normals, texcoords)

// Positions

// Normals

// Texcoords

// Draw cube

// Delete VBO and VAO

// Get name string for pixel format

// 8 bit per pixel (no alpha)
// 8*2 bpp (2 channels)
// 16 bpp
// 24 bpp
// 16 bpp (1 bit alpha)
// 16 bpp (4 bit alpha)
// 32 bpp
// 32 bpp (1 channel - float)
// 32*3 bpp (3 channels - float)
// 32*4 bpp (4 channels - float)
// 16 bpp (1 channel - half float)
// 16*3 bpp (3 channels - half float)
// 16*4 bpp (4 channels - half float)
// 4 bpp (no alpha)
// 4 bpp (1 bit alpha)
// 8 bpp
// 8 bpp
// 4 bpp
// 4 bpp
// 8 bpp
// 4 bpp
// 4 bpp
// 8 bpp
// 2 bpp

//----------------------------------------------------------------------------------
// Module specific Functions Definition
//----------------------------------------------------------------------------------

// Load default shader (just vertex positioning and texture coloring)
// NOTE: This shader program is used for internal buffers
// NOTE: Loaded: RLGL.State.defaultShaderId, RLGL.State.defaultShaderLocs

// NOTE: All locations must be reseted to -1 (no location)

// Vertex shader directly defined, no external file required

// Precision required for OpenGL ES3 (WebGL 2) (on some browsers)

// Precision required for OpenGL ES2 (WebGL) (on some browsers)

// Fragment shader directly defined, no external file required

// Precision required for OpenGL ES3 (WebGL 2)

// Precision required for OpenGL ES2 (WebGL)

// NOTE: Compiled vertex/fragment shaders are not deleted,
// they are kept for re-use as default shaders in case some shader loading fails
// Compile default vertex shader
// Compile default fragment shader

// Set default shader locations: attributes locations

// Set default shader locations: uniform locations

// Unload default shader
// NOTE: Unloads: RLGL.State.defaultShaderId, RLGL.State.defaultShaderLocs

// Get compressed format official GL identifier name

// GL_EXT_texture_compression_s3tc

// GL_3DFX_texture_compression_FXT1

// GL_IMG_texture_compression_pvrtc

// GL_OES_compressed_ETC1_RGB8_texture

// GL_ARB_texture_compression_rgtc

// GL_ARB_texture_compression_bptc

// GL_ARB_ES3_compatibility

// GL_KHR_texture_compression_astc_hdr

// RLGL_SHOW_GL_DETAILS_INFO

// GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2

// Get pixel data size in bytes (image or texture)
// NOTE: Size depends on pixel format

// Size in bytes
// Bits per pixel

// Total data size in bytes

// Most compressed formats works on 4x4 blocks,
// if texture is smaller, minimum dataSize is 8 or 16

// Auxiliar math functions

// Get float array of matrix data

// Get identity matrix

// Get two matrix multiplication
// NOTE: When multiplying matrices... the order matters!

// Transposes provided matrix

// Invert provided matrix

// Cache the matrix values (speed optimization)

// Calculate the invert determinant (inlined to avoid double-caching)

// RLGL_IMPLEMENTATION

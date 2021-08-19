module rlgl;

import raylib;
/**********************************************************************************************
*
*   rlgl v3.7 - raylib OpenGL abstraction layer
*
*   rlgl is a wrapper for multiple OpenGL versions (1.1, 2.1, 3.3 Core, ES 2.0) to
*   pseudo-OpenGL 1.1 style functions (rlVertex, rlTranslate, rlRotate...).
*
*   When chosing an OpenGL version greater than OpenGL 1.1, rlgl stores vertex data on internal
*   VBO buffers (and VAOs if available). It requires calling 3 functions:
*       rlglInit()  - Initialize internal buffers and auxiliary resources
*       rlglClose() - De-initialize internal buffers data and other auxiliar resources
*
*   CONFIGURATION:
*
*   #define GRAPHICS_API_OPENGL_11
*   #define GRAPHICS_API_OPENGL_21
*   #define GRAPHICS_API_OPENGL_33
*   #define GRAPHICS_API_OPENGL_ES2
*       Use selected OpenGL graphics backend, should be supported by platform
*       Those preprocessor defines are only used on rlgl module, if OpenGL version is
*       required by any other module, use rlGetVersion() to check it
*
*   #define RLGL_IMPLEMENTATION
*       Generates the implementation of the library into the included file.
*       If not defined, the library is in header only mode and can be included in other headers
*       or source files without problems. But only ONE file should hold the implementation.
*
*   #define RLGL_STANDALONE
*       Use rlgl as standalone library (no raylib dependency)
*
*   #define SUPPORT_GL_DETAILS_INFO
*       Show OpenGL extensions and capabilities detailed logs on init
*
*   DEPENDENCIES:
*       raymath     - 3D math functionality (Vector3, Matrix, Quaternion)
*       GLAD        - OpenGL extensions loading (OpenGL 3.3 Core only)
*
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2014-2021 Ramon Santamaria (@raysan5)
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

// We are building or using rlgl as a static library (or Linux shared library)

// We are building raylib as a Win32 shared library (.dll)

// We are using raylib as a Win32 shared library (.dll)

// Support TRACELOG macros

// Allow custom memory allocators

// Required for: Shader, Texture2D

// Required for: Vector3, Matrix

// Security check in case no GRAPHICS_API_OPENGL_* defined

// Security check in case multiple GRAPHICS_API_OPENGL_* defined

// OpenGL 2.1 uses most of OpenGL 3.3 Core functionality
// WARNING: Specific parts are checked with #if defines

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------
// Default internal render batch limits

// This is the maximum amount of elements (quads) per batch
// NOTE: Be careful with text, every letter maps to a quad
enum DEFAULT_BATCH_BUFFER_ELEMENTS = 8192;

// We reduce memory sizes for embedded systems (RPI and HTML5)
// NOTE: On HTML5 (emscripten) this is allocated on heap,
// by default it's only 16MB!...just take care...

enum DEFAULT_BATCH_BUFFERS = 1; // Default number of batch buffers (multi-buffering)

enum DEFAULT_BATCH_DRAWCALLS = 256; // Default number of batch draw calls (by state changes: mode, texture)

enum MAX_BATCH_ACTIVE_TEXTURES = 4; // Maximum number of additional textures that can be activated on batch drawing (SetShaderValueTexture())

// Internal Matrix stack

enum MAX_MATRIX_STACK_SIZE = 32; // Maximum size of Matrix stack

// Vertex buffers id limit

enum MAX_MESH_VERTEX_BUFFERS = 7; // Maximum vertex buffers (VBO) per mesh

// Shader and material limits

enum MAX_SHADER_LOCATIONS = 32; // Maximum number of shader locations supported

enum MAX_MATERIAL_MAPS = 12; // Maximum number of shader maps supported

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

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
enum GlVersion
{
    OPENGL_11 = 1,
    OPENGL_21 = 2,
    OPENGL_33 = 3,
    OPENGL_ES_20 = 4
}

enum FramebufferAttachType
{
    RL_ATTACHMENT_COLOR_CHANNEL0 = 0,
    RL_ATTACHMENT_COLOR_CHANNEL1 = 1,
    RL_ATTACHMENT_COLOR_CHANNEL2 = 2,
    RL_ATTACHMENT_COLOR_CHANNEL3 = 3,
    RL_ATTACHMENT_COLOR_CHANNEL4 = 4,
    RL_ATTACHMENT_COLOR_CHANNEL5 = 5,
    RL_ATTACHMENT_COLOR_CHANNEL6 = 6,
    RL_ATTACHMENT_COLOR_CHANNEL7 = 7,
    RL_ATTACHMENT_DEPTH = 100,
    RL_ATTACHMENT_STENCIL = 200
}

enum FramebufferAttachTextureType
{
    RL_ATTACHMENT_CUBEMAP_POSITIVE_X = 0,
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_X = 1,
    RL_ATTACHMENT_CUBEMAP_POSITIVE_Y = 2,
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Y = 3,
    RL_ATTACHMENT_CUBEMAP_POSITIVE_Z = 4,
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Z = 5,
    RL_ATTACHMENT_TEXTURE2D = 100,
    RL_ATTACHMENT_RENDERBUFFER = 200
}

// Dynamic vertex buffers (position + texcoords + colors + indices arrays)
struct VertexBuffer
{
    int elementsCount; // Number of elements in the buffer (QUADS)

    int vCounter; // Vertex position counter to process (and draw) from full buffer
    int tcCounter; // Vertex texcoord counter to process (and draw) from full buffer
    int cCounter; // Vertex color counter to process (and draw) from full buffer

    float* vertices; // Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    float* texcoords; // Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    ubyte* colors; // Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)

    uint* indices; // Vertex indices (in case vertex data comes indexed) (6 indices per quad)

    // Vertex indices (in case vertex data comes indexed) (6 indices per quad)

    uint vaoId; // OpenGL Vertex Array Object id
    uint[4] vboId; // OpenGL Vertex Buffer Objects id (4 types of vertex data)
}

// Draw call type
// NOTE: Only texture changes register a new draw, other state-change-related elements are not
// used at this moment (vaoId, shaderId, matrices), raylib just forces a batch draw call if any
// of those state-change happens (this is done in core module)
struct DrawCall
{
    int mode; // Drawing mode: LINES, TRIANGLES, QUADS
    int vertexCount; // Number of vertex of the draw
    int vertexAlignment; // Number of vertex required for index alignment (LINES, TRIANGLES)
    //unsigned int vaoId;       // Vertex array id to be used on the draw -> Using RLGL.currentBatch->vertexBuffer.vaoId
    //unsigned int shaderId;    // Shader id to be used on the draw -> Using RLGL.currentShader.id
    uint textureId; // Texture id to be used on the draw -> Use to create new draw call if changes

    //Matrix projection;        // Projection matrix for this draw -> Using RLGL.projection by default
    //Matrix modelview;         // Modelview matrix for this draw -> Using RLGL.modelview by default
}

// RenderBatch type
struct RenderBatch
{
    int buffersCount; // Number of vertex buffers (multi-buffering support)
    int currentBuffer; // Current buffer tracking in case of multi-buffering
    VertexBuffer* vertexBuffer; // Dynamic buffer(s) for vertex data

    DrawCall* draws; // Draw calls array, depends on textureId
    int drawsCounter; // Draw calls counter
    float currentDepth; // Current depth value for next draw
}

// Shader attribute data types
enum ShaderAttributeDataType
{
    SHADER_ATTRIB_FLOAT = 0,
    SHADER_ATTRIB_VEC2 = 1,
    SHADER_ATTRIB_VEC3 = 2,
    SHADER_ATTRIB_VEC4 = 3
}

// Boolean type

// Color type, RGBA (32bit)

// Texture type
// NOTE: Data stored in GPU memory

// OpenGL texture id
// Texture base width
// Texture base height
// Mipmap levels, 1 by default
// Data format (PixelFormat)

// Shader type (generic)

// Shader program id
// Shader locations array (MAX_SHADER_LOCATIONS)

// TraceLog message types

// Texture formats (support depends on OpenGL version)

// 8 bit per pixel (no alpha)

// 16 bpp
// 24 bpp
// 16 bpp (1 bit alpha)
// 16 bpp (4 bit alpha)
// 32 bpp
// 32 bpp (1 channel - float)
// 32*3 bpp (3 channels - float)
// 32*4 bpp (4 channels - float)
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

// Texture parameters: filter mode
// NOTE 1: Filtering considers mipmaps if available in the texture
// NOTE 2: Filter is accordingly set for minification and magnification

// No filter, just pixel aproximation
// Linear filtering
// Trilinear filtering (linear with mipmaps)
// Anisotropic filtering 4x
// Anisotropic filtering 8x
// Anisotropic filtering 16x

// Texture parameters: wrap mode

// Repeats texture in tiled mode
// Clamps texture to edge pixel in tiled mode
// Mirrors and repeats the texture in tiled mode
// Mirrors and clamps to border the texture in tiled mode

// Color blending modes (pre-defined)

// Blend textures considering alpha (default)
// Blend textures adding colors
// Blend textures multiplying colors
// Blend textures adding colors (alternative)
// Blend textures subtracting colors (alternative)
// Belnd textures using custom src/dst factors (use SetBlendModeCustom())

// Shader location point type

// SHADER_LOC_MAP_DIFFUSE
// SHADER_LOC_MAP_SPECULAR

// Shader uniform data types

// Prevents name mangling of functions

//------------------------------------------------------------------------------------
// Functions Declaration - Matrix operations
//------------------------------------------------------------------------------------
void rlMatrixMode(int mode); // Choose the current matrix to be transformed
void rlPushMatrix(); // Push the current matrix to stack
void rlPopMatrix(); // Pop lattest inserted matrix from stack
void rlLoadIdentity(); // Reset current matrix to identity matrix
void rlTranslatef(float x, float y, float z); // Multiply the current matrix by a translation matrix
void rlRotatef(float angleDeg, float x, float y, float z); // Multiply the current matrix by a rotation matrix
void rlScalef(float x, float y, float z); // Multiply the current matrix by a scaling matrix
void rlMultMatrixf(float* matf); // Multiply the current matrix by another matrix
void rlFrustum(double left, double right, double bottom, double top, double znear, double zfar);
void rlOrtho(double left, double right, double bottom, double top, double znear, double zfar);
void rlViewport(int x, int y, int width, int height); // Set the viewport area

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

// Textures state
void rlActiveTextureSlot(int slot); // Select and active a texture slot
void rlEnableTexture(uint id); // Enable texture
void rlDisableTexture(); // Disable texture
void rlEnableTextureCubemap(uint id); // Enable texture cubemap
void rlDisableTextureCubemap(); // Disable texture cubemap
void rlTextureParameters(uint id, int param, int value); // Set texture parameters (filter, wrap)

// Shader state
void rlEnableShader(uint id); // Enable shader program
void rlDisableShader(); // Disable shader program

// Framebuffer state
void rlEnableFramebuffer(uint id); // Enable render texture (fbo)
void rlDisableFramebuffer(); // Disable render texture (fbo), return to default framebuffer

// General render state
void rlEnableDepthTest(); // Enable depth test
void rlDisableDepthTest(); // Disable depth test
void rlEnableDepthMask(); // Enable depth write
void rlDisableDepthMask(); // Disable depth write
void rlEnableBackfaceCulling(); // Enable backface culling
void rlDisableBackfaceCulling(); // Disable backface culling
void rlEnableScissorTest(); // Enable scissor test
void rlDisableScissorTest(); // Disable scissor test
void rlScissor(int x, int y, int width, int height); // Scissor test
void rlEnableWireMode(); // Enable wire mode
void rlDisableWireMode(); // Disable wire mode
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

//------------------------------------------------------------------------------------
// Functions Declaration - rlgl functionality
//------------------------------------------------------------------------------------
// rlgl initialization functions
void rlglInit(int width, int height); // Initialize rlgl (buffers, shaders, textures, states)
void rlglClose(); // De-inititialize rlgl (buffers, shaders, textures)
void rlLoadExtensions(void* loader); // Load OpenGL extensions (loader function pointer required)
int rlGetVersion(); // Returns current OpenGL version
int rlGetFramebufferWidth(); // Get default framebuffer width
int rlGetFramebufferHeight(); // Get default framebuffer height

Shader rlGetShaderDefault(); // Get default shader
Texture2D rlGetTextureDefault(); // Get default texture

// Render batch management
// NOTE: rlgl provides a default render batch to behave like OpenGL 1.1 immediate mode
// but this render batch API is exposed in case of custom batches are required
RenderBatch rlLoadRenderBatch(int numBuffers, int bufferElements); // Load a render batch system
void rlUnloadRenderBatch(RenderBatch batch); // Unload render batch system
void rlDrawRenderBatch(RenderBatch* batch); // Draw render batch data (Update->Draw->Reset)
void rlSetRenderBatchActive(RenderBatch* batch); // Set the active render batch for rlgl (NULL for default internal)
void rlDrawRenderBatchActive(); // Update and draw internal render batch
bool rlCheckRenderBatchLimit(int vCount); // Check internal buffer overflow for a given number of vertex
void rlSetTexture(uint id); // Set current texture for render batch and check buffers limits

//------------------------------------------------------------------------------------------------------------------------

// Vertex buffers management
uint rlLoadVertexArray(); // Load vertex array (vao) if supported
uint rlLoadVertexBuffer(void* buffer, int size, bool dynamic); // Load a vertex buffer attribute
uint rlLoadVertexBufferElement(void* buffer, int size, bool dynamic); // Load a new attributes element buffer
void rlUpdateVertexBuffer(int bufferId, void* data, int dataSize, int offset); // Update GPU buffer with new data
void rlUnloadVertexArray(uint vaoId);
void rlUnloadVertexBuffer(uint vboId);
void rlSetVertexAttribute(uint index, int compSize, int type, bool normalized, int stride, void* pointer);
void rlSetVertexAttributeDivisor(uint index, int divisor);
void rlSetVertexAttributeDefault(int locIndex, const(void)* value, int attribType, int count); // Set vertex attribute default value
void rlDrawVertexArray(int offset, int count);
void rlDrawVertexArrayElements(int offset, int count, void* buffer);
void rlDrawVertexArrayInstanced(int offset, int count, int instances);
void rlDrawVertexArrayElementsInstanced(int offset, int count, void* buffer, int instances);

// Textures management
uint rlLoadTexture(void* data, int width, int height, int format, int mipmapCount); // Load texture in GPU
uint rlLoadTextureDepth(int width, int height, bool useRenderBuffer); // Load depth texture/renderbuffer (to be attached to fbo)
uint rlLoadTextureCubemap(void* data, int size, int format); // Load texture cubemap
void rlUpdateTexture(uint id, int offsetX, int offsetY, int width, int height, int format, const(void)* data); // Update GPU texture with new data
void rlGetGlTextureFormats(int format, uint* glInternalFormat, uint* glFormat, uint* glType); // Get OpenGL internal formats
void rlUnloadTexture(uint id); // Unload texture from GPU memory
void rlGenerateMipmaps(Texture2D* texture); // Generate mipmap data for selected texture
void* rlReadTexturePixels(Texture2D texture); // Read texture pixel data
ubyte* rlReadScreenPixels(int width, int height); // Read screen pixel data (color buffer)

// Framebuffer management (fbo)
uint rlLoadFramebuffer(int width, int height); // Load an empty framebuffer
void rlFramebufferAttach(uint fboId, uint texId, int attachType, int texType, int mipLevel); // Attach texture/renderbuffer to a framebuffer
bool rlFramebufferComplete(uint id); // Verify framebuffer is complete
void rlUnloadFramebuffer(uint id); // Delete framebuffer from GPU

// Shaders management
uint rlLoadShaderCode(const(char)* vsCode, const(char)* fsCode); // Load shader from code strings
uint rlCompileShader(const(char)* shaderCode, int type); // Compile custom shader and return shader id (type: GL_VERTEX_SHADER, GL_FRAGMENT_SHADER)
uint rlLoadShaderProgram(uint vShaderId, uint fShaderId); // Load custom shader program
void rlUnloadShaderProgram(uint id); // Unload shader program
int rlGetLocationUniform(uint shaderId, const(char)* uniformName); // Get shader location uniform
int rlGetLocationAttrib(uint shaderId, const(char)* attribName); // Get shader location attribute
void rlSetUniform(int locIndex, const(void)* value, int uniformType, int count); // Set shader value uniform
void rlSetUniformMatrix(int locIndex, Matrix mat); // Set shader value matrix
void rlSetUniformSampler(int locIndex, uint textureId); // Set shader value sampler
void rlSetShader(Shader shader); // Set shader currently active

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

// Check if config flags have been externally provided on compilation line

// Defines module configuration flags

// Required for: Vector3 and Matrix functions

// Required for: malloc(), free()
// Required for: strcmp(), strlen() [Used in rlglInit(), on extensions loading]

// OpenGL 1.1 library for OSX

// APIENTRY for OpenGL function pointer declarations is required

// WINGDIAPI definition. Some Windows OpenGL headers need it

// OpenGL 1.1 library

// OpenGL 3 library for OSX
// OpenGL 3 extensions library for OSX

// GLAD extensions loading library, includes OpenGL headers

// GLAD extensions loading library, includes OpenGL headers

// EGL library
// OpenGL ES 2.0 library
// OpenGL ES 2.0 extensions library

// It seems OpenGL ES 2.0 instancing entry points are not defined on Raspberry Pi
// provided headers (despite being defined in official Khronos GLES2 headers)

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------

// Default shader vertex attribute names to set location points

// Binded by default to shader location: 0

// Binded by default to shader location: 1

// Binded by default to shader location: 2

// Binded by default to shader location: 3

// Binded by default to shader location: 4

// Binded by default to shader location: 5

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------

// Current render batch
// Default internal render batch

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
// Default fragment shader Id (used by default shader program)
// Basic shader, support vertex color and diffuse texture
// Shader to be used on rendering (by default, defaultShader)

// Stereo rendering flag
// VR stereo rendering eyes projection matrices
// VR stereo rendering eyes view offset matrices

// Blending mode active
// Blending source factor
// Blending destination factor
// Blending equation

// Default framebuffer width
// Default framebuffer height

// Renderer state

// VAO support (OpenGL ES2 could not support VAO extension) (GL_ARB_vertex_array_object)
// Instancing supported (GL_ANGLE_instanced_arrays, GL_EXT_draw_instanced + GL_EXT_instanced_arrays)
// NPOT textures full support (GL_ARB_texture_non_power_of_two, GL_OES_texture_npot)
// Depth textures supported (GL_ARB_depth_texture, GL_WEBGL_depth_texture, GL_OES_depth_texture)
// float textures support (32 bit per channel) (GL_OES_texture_float)
// DDS texture compression support (GL_EXT_texture_compression_s3tc, GL_WEBGL_compressed_texture_s3tc, GL_WEBKIT_WEBGL_compressed_texture_s3tc)
// ETC1 texture compression support (GL_OES_compressed_ETC1_RGB8_texture, GL_WEBGL_compressed_texture_etc1)
// ETC2/EAC texture compression support (GL_ARB_ES3_compatibility)
// PVR texture compression support (GL_IMG_texture_compression_pvrtc)
// ASTC texture compression support (GL_KHR_texture_compression_astc_hdr, GL_KHR_texture_compression_astc_ldr)
// Clamp mirror wrap mode supported (GL_EXT_texture_mirror_clamp)
// Anisotropic texture filtering support (GL_EXT_texture_filter_anisotropic)

// Maximum anisotropy level supported (minimum is 2.0f)
// Maximum bits for depth component

// Extensions supported flags

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

// Load default shader (RLGL.State.defaultShader)
// Unload default shader (RLGL.State.defaultShader)

// Get compressed format official GL identifier name
// SUPPORT_GL_DETAILS_INFO
// GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2

// Generate mipmaps data on CPU side
// Generate next mipmap level on CPU side

// Get pixel data size in bytes (image or texture)

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

// NOTE: We transpose matrix with multiplication order

// Multiply the current matrix by a scaling matrix

// NOTE: We transpose matrix with multiplication order

// Multiply the current matrix by another matrix

// Matrix creation from array

// Multiply the current matrix by a perspective matrix generated by parameters

// Multiply the current matrix by an orthographic matrix generated by parameters

// NOTE: If left-right and top-botton values are equal it could create
// a division by zero on MatrixOrtho(), response to it is platform/compiler dependant

// Set the viewport area (transformation from normalized device coordinates to window coordinates)

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

// Make sure vertexCount is the same for vertices, texcoords, colors and normals
// NOTE: In OpenGL 1.1, one glColor call can be made for all the subsequent glVertex calls

// Make sure colors count match vertex count

// Make sure texcoords count match vertex count

// TODO: Make sure normals count match vertex count... if normals support is added in a future... :P

// NOTE: Depth increment is dependant on rlOrtho(): z-near and z-far values,
// as well as depth buffer bit-depth (16bit or 24bit or 32bit)
// Correct increment formula would be: depthInc = (zfar - znear)/pow(2, bits)

// Verify internal buffers limits
// NOTE: This check is combined with usage of rlCheckRenderBatchLimit()

// WARNING: If we are between rlPushMatrix() and rlPopMatrix() and we need to force a rlDrawRenderBatch(),
// we need to call rlPopMatrix() before to recover *RLGL.State.currentMatrix (RLGL.State.modelview) for the next forced draw call!
// If we have multiple matrix pushed, it will require "RLGL.State.stackCounter" pops before launching the draw

// Define one vertex (position)
// NOTE: Vertex position data is the basic information required for drawing

// Transform provided vector if required

// Verify that current vertex buffer elements limit has not been reached

// Define one vertex (position)

// Define one vertex (position)

// Define one vertex (texture coordinate)
// NOTE: Texture coordinates are limited to QUADS only

// Define one vertex (normal)
// NOTE: Normals limited to TRIANGLES only?

// TODO: Normals usage...

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

// Core in OpenGL 1.4

// Disable texture cubemap

// Set texture parameters (wrap mode/filter mode)

// Enable shader program

// Disable shader program

// Enable rendering to texture (fbo)

// Disable rendering to texture

// Enable depth test

// Disable depth test

// Enable depth write

// Disable depth write

// Enable backface culling

// Disable backface culling

// Enable scissor test

// Disable scissor test

// Scissor test

// Enable wire mode

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

// Set blending mode factor and equation

//----------------------------------------------------------------------------------
// Module Functions Definition - rlgl functionality
//----------------------------------------------------------------------------------

// Initialize rlgl: OpenGL extensions, default buffers/shaders/textures, OpenGL states

// Init default white texture
// 1 pixel RGBA (4 bytes)

// Init default Shader (customized for GL 3.3 and ES2)
// RLGL.State.defaultShader

// Init default vertex arrays buffers

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
// NOTE: External loader function could be passed as a pointer

// Also defined for GRAPHICS_API_OPENGL_21
// NOTE: glad is generated and contains only required OpenGL 3.3 Core extensions (and lower versions)

// Get number of supported extensions

// Get supported extensions list
// WARNING: glGetStringi() not available on OpenGL 2.1

// Free extensions pointers

// Register supported extensions flags
// OpenGL 3.3 extensions supported by default (core)

// NOTE: With GLAD, we can check if an extension is supported using the GLAD_GL_xxx booleans
// Texture compression: DXT
// Texture compression: ETC2/EAC

// GRAPHICS_API_OPENGL_33

// Get supported extensions list

// Allocate 512 strings pointers (2 KB)
// One big const string

// NOTE: We have to duplicate string because glGetString() returns a const string

// Check required extensions

// Check VAO support
// NOTE: Only check on OpenGL ES, OpenGL 3.3 has VAO support as core feature

// The extension is supported by our hardware and driver, try to get related functions pointers
// NOTE: emscripten does not support VAOs natively, it uses emulation and it reduces overall performance...

//glIsVertexArray = (PFNGLISVERTEXARRAYOESPROC)eglGetProcAddress("glIsVertexArrayOES");     // NOTE: Fails in WebGL, omitted

// Check instanced rendering support
// Web ANGLE

// Standard EXT

// Check NPOT textures support
// NOTE: Only check on OpenGL ES, OpenGL 3.3 has NPOT textures full support as core feature

// Check texture float support

// Check depth texture support

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

/*
// Following capabilities are only supported by OpenGL 4.3 or greater
glGetIntegerv(GL_MAX_VERTEX_ATTRIB_BINDINGS, &capability);
TRACELOG(LOG_INFO, "    GL_MAX_VERTEX_ATTRIB_BINDINGS: %i", capability);
glGetIntegerv(GL_MAX_UNIFORM_LOCATIONS, &capability);
TRACELOG(LOG_INFO, "    GL_MAX_UNIFORM_LOCATIONS: %i", capability);
*/
// SUPPORT_GL_DETAILS_INFO

// Show some basic info about GL supported features

// SUPPORT_GL_DETAILS_INFO

// GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2

// Returns current OpenGL version

// NOTE: Force OpenGL 3.3 on OSX

// Get default framebuffer width

// Get default framebuffer height

// Get default internal shader (simple texture + tint color)

// Get default internal texture (white texture)

// Render batch management
//------------------------------------------------------------------------------------------------
// Load render batch

// Initialize CPU (RAM) vertex buffers (position, texcoord, color data and indexes)
//--------------------------------------------------------------------------------------------

// 3 float by vertex, 4 vertex by quad
// 2 float by texcoord, 4 texcoord by quad
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

// Vertex color buffer (shader-location = 3)

// Fill index buffer

// Unbind the current VAO

//--------------------------------------------------------------------------------------------

// Init draw calls tracking system
//--------------------------------------------------------------------------------------------

//batch.draws[i].vaoId = 0;
//batch.draws[i].shaderId = 0;

//batch.draws[i].RLGL.State.projection = MatrixIdentity();
//batch.draws[i].RLGL.State.modelview = MatrixIdentity();

// Record buffer count
// Reset draws counter
// Reset depth value
//--------------------------------------------------------------------------------------------

// Unload default internal buffers vertex data from CPU and GPU

// Unbind everything

// Unload all vertex buffers data

// Delete VBOs from GPU (VRAM)

// Delete VAOs from GPU (VRAM)

// Free vertex arrays memory from CPU (RAM)

// Unload arrays

// Draw render batch
// NOTE: We require a pointer to reset batch and increase current buffer (multi-buffer)

// Update batch vertex buffers
//------------------------------------------------------------------------------------------------------------
// NOTE: If there is not vertex data, buffers doesn't need to be updated (vertexCount > 0)
// TODO: If no data changed on the CPU arrays --> No need to re-update GPU arrays (change flag required)

// Activate elements VAO

// Vertex positions buffer

//glBufferData(GL_ARRAY_BUFFER, sizeof(float)*3*4*batch->vertexBuffer[batch->currentBuffer].elementsCount, batch->vertexBuffer[batch->currentBuffer].vertices, GL_DYNAMIC_DRAW);  // Update all buffer

// Texture coordinates buffer

//glBufferData(GL_ARRAY_BUFFER, sizeof(float)*2*4*batch->vertexBuffer[batch->currentBuffer].elementsCount, batch->vertexBuffer[batch->currentBuffer].texcoords, GL_DYNAMIC_DRAW); // Update all buffer

// Colors buffer

//glBufferData(GL_ARRAY_BUFFER, sizeof(float)*4*4*batch->vertexBuffer[batch->currentBuffer].elementsCount, batch->vertexBuffer[batch->currentBuffer].colors, GL_DYNAMIC_DRAW);    // Update all buffer

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

// Bind vertex attrib: position (shader-location = 0)

// Bind vertex attrib: texcoord (shader-location = 1)

// Bind vertex attrib: color (shader-location = 3)

// Setup some default shader values

// Active default sampler2D: texture0

// Activate additional sampler textures
// Those additional textures will be common for all draw calls of the batch

// Activate default sampler2D texture0 (one texture is always active for default batch shader)
// NOTE: Batch system accumulates calls by texture0 changes, additional textures are enabled for all the draw calls

// Bind current draw call texture, activated as GL_TEXTURE0 and binded to sampler2D texture0 by default

// We need to define the number of indices to be processed: quadsCount*6
// NOTE: The final parameter tells the GPU the offset in bytes from the
// start of the index buffer to the location of the first index to process

// Unbind textures

// Unbind VAO

// Unbind shader program

//------------------------------------------------------------------------------------------------------------

// Reset batch buffers
//------------------------------------------------------------------------------------------------------------
// Reset vertex counters for next frame

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
// and force a RenderBatch draw call if required

// NOTE: Stereo rendering is checked inside

// Textures data management
//-----------------------------------------------------------------------------------------
// Convert image data to OpenGL texture (returns OpenGL valid Id)

// Free any old binding

// Check texture format support by OpenGL 1.1 (compressed textures not supported)

// GRAPHICS_API_OPENGL_11

// Generate texture id

// Mipmap data offset

// Load the different mipmap levels

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
// WARNING: OpenGL ES 2.0 requires GL_OES_depth_texture/WEBGL_depth_texture extensions

// In case depth textures not supported, we force renderbuffer usage

// NOTE: We let the implementation to choose the best bit-depth
// Possible formats: GL_DEPTH_COMPONENT16, GL_DEPTH_COMPONENT24, GL_DEPTH_COMPONENT32 and GL_DEPTH_COMPONENT32F

// Create the renderbuffer that will serve as the depth attachment for the framebuffer
// NOTE: A renderbuffer is simpler than a texture and could offer better performance on embedded devices

// Load texture cubemap
// NOTE: Cubemap data is expected to be 6 images in a single data array (one after the other),
// expected the following convention: +X, -X, +Y, -Y, +Z, -Z

// Load cubemap faces

// Instead of using a sized internal texture format (GL_RGB16F, GL_RGB32F), we let the driver to choose the better format for us (GL_RGB)

// Set cubemap texture sampling parameters

// Flag not supported on OpenGL ES 2.0

// Update already loaded texture in GPU with new data
// NOTE: We don't know safely if internal texture format is the expected one...

// Get OpenGL internal formats and data type from raylib PixelFormat

// NOTE: on OpenGL ES 2.0 (WebGL), internalFormat must match format and options allowed are: GL_LUMINANCE, GL_RGB, GL_RGBA

// NOTE: Requires extension OES_texture_float
// NOTE: Requires extension OES_texture_float
// NOTE: Requires extension OES_texture_float

// NOTE: Requires OpenGL ES 2.0 or OpenGL 4.3
// NOTE: Requires OpenGL ES 3.0 or OpenGL 4.3
// NOTE: Requires OpenGL ES 3.0 or OpenGL 4.3
// NOTE: Requires PowerVR GPU
// NOTE: Requires PowerVR GPU
// NOTE: Requires OpenGL ES 3.1 or OpenGL 4.3
// NOTE: Requires OpenGL ES 3.1 or OpenGL 4.3

// Unload texture from GPU memory

// Generate mipmap data for selected texture

// Check if texture is power-of-two (POT)

// WARNING: Manual mipmap generation only works for RGBA 32bit textures!

// Retrieve texture data from VRAM

// NOTE: Texture data size is reallocated to fit mipmaps data
// NOTE: CPU mipmap generation only supports RGBA 32bit data

// Load the mipmaps

// Once mipmaps have been generated and data has been uploaded to GPU VRAM, we can discard RAM data

//glHint(GL_GENERATE_MIPMAP_HINT, GL_DONT_CARE);   // Hint for mipmaps generation algorythm: GL_FASTEST, GL_NICEST, GL_DONT_CARE
// Generate mipmaps automatically

// Activate Trilinear filtering for mipmaps

// Read texture pixel data

// NOTE: Using texture.id, we can retrieve some texture info (but not on OpenGL ES 2.0)
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

// TODO: Create depth texture/renderbuffer for fbo?

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

// NOTE: If a texture object is deleted while its image is attached to the *currently bound* framebuffer,
// the texture image is automatically detached from the currently bound framebuffer.

// Vertex data management
//-----------------------------------------------------------------------------------------
// Load a new attributes buffer

// Load a new attributes element buffer

// Update GPU buffer with new data
// NOTE: dataSize and offset must be provided in bytes

//case GL_INDEX_ARRAY: if (buffer != NULL) glIndexPointer(GL_SHORT, 0, buffer); break; // Indexed colors

//TRACELOG(LOG_INFO, "VBO: Unloaded vertex data from VRAM (GPU)");

// Shaders management
//-----------------------------------------------------------------------------------------------
// Load shader from code strings
// NOTE: If shader string is NULL, using default vertex/fragment shaders

// Detach shader before deletion to make sure memory is freed

// Detach shader before deletion to make sure memory is freed

// Get available shader uniforms
// NOTE: This information is useful for debug...

// Assume no variable names longer than 256

// Get the name of the uniforms

// Compile custom shader and return shader id

//case GL_GEOMETRY_SHADER:
//case GL_COMPUTE_SHADER:

//case GL_GEOMETRY_SHADER:
//case GL_COMPUTE_SHADER:

// Load custom shader strings and return program id

// NOTE: Default attribute shader locations must be binded before linking

// NOTE: If some attrib name is no found on the shader, it locations becomes -1

// NOTE: All uniform variables are intitialised to 0 when a program links

// Unload shader program

// Get shader location uniform

// Get shader location attribute

// Set shader value uniform

// Set shader value attribute

// Set shader value uniform matrix

// Set shader value uniform sampler

// Check if texture is already active

// Register a new active texture for the internal batch system
// NOTE: Default texture is always activated as GL_TEXTURE0

// Activate new texture unit
// Save texture id for binding on drawing

// Set shader currently active

// Matrix state management
//-----------------------------------------------------------------------------------------
// Return internal modelview matrix

// Return internal projection matrix

// Get internal accumulated transform matrix

// TODO: Consider possible transform matrices in the RLGL.State.stack
// Is this the right order? or should we start with the first stored matrix instead of the last one?
//Matrix matStackTransform = MatrixIdentity();
//for (int i = RLGL.State.stackCounter; i > 0; i--) matStackTransform = MatrixMultiply(RLGL.State.stack[i], matStackTransform);

// Get internal projection matrix for stereo render (selected eye)

// Get internal view offset matrix for stereo render (selected eye)

// Set a custom modelview matrix (replaces internal modelview matrix)

// Set a custom projection matrix (replaces internal projection matrix)

// Set eyes projection matrices for stereo rendering

// Set eyes view offsets matrices for stereo rendering

// Load and draw a 1x1 XY quad in NDC

// Positions         Texcoords

// Gen VAO to contain VBO

// Gen and fill vertex buffer (VBO)

// Bind vertex attributes (position, texcoords)

// Positions

// Texcoords

// Draw quad

// Delete buffers (VBO and VAO)

// Load and draw a 1x1 3D cube in NDC

// Positions          Normals               Texcoords

// Gen VAO to contain VBO

// Gen and fill vertex buffer (VBO)

// Bind vertex attributes (position, normals, texcoords)

// Positions

// Normals

// Texcoords

// Draw cube

// Delete VBO and VAO

//----------------------------------------------------------------------------------
// Module specific Functions Definition
//----------------------------------------------------------------------------------

// Load default shader (just vertex positioning and texture coloring)
// NOTE: This shader program is used for internal buffers
// NOTE: It uses global variable: RLGL.State.defaultShader

// NOTE: All locations must be reseted to -1 (no location)

// Vertex shader directly defined, no external file required

// Fragment shader directly defined, no external file required

// Precision required for OpenGL ES2 (WebGL)

// NOTE: Compiled vertex/fragment shaders are kept for re-use
// Compile default vertex shader
// Compile default fragment shader

// Set default shader locations: attributes locations

// Set default shader locations: uniform locations

// Unload default shader
// NOTE: It uses global variable: RLGL.State.defaultShader

// Get compressed format official GL identifier name

// GL_EXT_texture_compression_s3tc

// GL_3DFX_texture_compression_FXT1

// GL_IMG_texture_compression_pvrtc

// GL_OES_compressed_ETC1_RGB8_texture

// GL_ARB_texture_compression_rgtc

// GL_ARB_texture_compression_bptc

// GL_ARB_ES3_compatibility

// GL_KHR_texture_compression_astc_hdr

// SUPPORT_GL_DETAILS_INFO

// GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2

// Mipmaps data is generated after image data
// NOTE: Only works with RGBA (4 bytes) data!

// Required mipmap levels count (including base level)

// Size in bytes (will include mipmaps...), RGBA only

// Count mipmap levels required

// Add mipmap size (in bytes)

// Generate mipmaps
// NOTE: Every mipmap data is stored after data

// Size of last mipmap

// Mipmap size to store after offset

// Add mipmap to data

// free mipmap data

// Manual mipmap generation (basic scaling algorithm)

// Scaling algorithm works perfectly (box-filter)

// GRAPHICS_API_OPENGL_11

// Get pixel data size in bytes (image or texture)
// NOTE: Size depends on pixel format

// Size in bytes
// Bits per pixel

// Total data size in bytes

// Most compressed formats works on 4x4 blocks,
// if texture is smaller, minimum dataSize is 8 or 16

// RLGL_IMPLEMENTATION

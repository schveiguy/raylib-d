module rlgl;

import raylib;

extern (C) @nogc nothrow:
//------------------------------------------------------------------------------------
// Functions Declaration - Matrix operations
//------------------------------------------------------------------------------------
void rlMatrixMode(int mode);                    // Choose the current matrix to be transformed
void rlPushMatrix();                        // Push the current matrix to stack
void rlPopMatrix();                         // Pop lattest inserted matrix from stack
void rlLoadIdentity();                      // Reset current matrix to identity matrix
void rlTranslatef(float x, float y, float z);   // Multiply the current matrix by a translation matrix
void rlRotatef(float angleDeg, float x, float y, float z);  // Multiply the current matrix by a rotation matrix
void rlScalef(float x, float y, float z);       // Multiply the current matrix by a scaling matrix
void rlMultMatrixf(float *matf);                // Multiply the current matrix by another matrix
void rlFrustum(double left, double right, double bottom, double top, double znear, double zfar);
void rlOrtho(double left, double right, double bottom, double top, double znear, double zfar);
void rlViewport(int x, int y, int width, int height); // Set the viewport area

//------------------------------------------------------------------------------------
// Functions Declaration - Vertex level operations
//------------------------------------------------------------------------------------
void rlBegin(int mode);                         // Initialize drawing mode (how to organize vertex)
void rlEnd();                               // Finish vertex providing
void rlVertex2i(int x, int y);                  // Define one vertex (position) - 2 int
void rlVertex2f(float x, float y);              // Define one vertex (position) - 2 float
void rlVertex3f(float x, float y, float z);     // Define one vertex (position) - 3 float
void rlTexCoord2f(float x, float y);            // Define one vertex (texture coordinate) - 2 float
void rlNormal3f(float x, float y, float z);     // Define one vertex (normal) - 3 float
void rlColor4ub(byte r, byte g, byte b, byte a);    // Define one vertex (color) - 4 byte
void rlColor3f(float x, float y, float z);          // Define one vertex (color) - 3 float
void rlColor4f(float x, float y, float z, float w); // Define one vertex (color) - 4 float

//------------------------------------------------------------------------------------
// Functions Declaration - OpenGL equivalent functions (common to 1.1, 3.3+, ES2)
// NOTE: This functions are used to completely abstract raylib code from OpenGL layer
//------------------------------------------------------------------------------------
void rlEnableTexture(uint id);                  // Enable texture usage
void rlDisableTexture();                            // Disable texture usage
void rlTextureParameters(uint id, int param, int value); // Set texture parameters (filter, wrap)
void rlEnableRenderTexture(uint id);            // Enable render texture (fbo)
void rlDisableRenderTexture();                      // Disable render texture (fbo), return to default framebuffer
void rlEnableDepthTest();                           // Enable depth test
void rlDisableDepthTest();                          // Disable depth test
void rlEnableBackfaceCulling();                     // Enable backface culling
void rlDisableBackfaceCulling();                    // Disable backface culling
void rlEnableScissorTest();                         // Enable scissor test
void rlDisableScissorTest();                        // Disable scissor test
void rlScissor(int x, int y, int width, int height);    // Scissor test
void rlEnableWireMode();                            // Enable wire mode
void rlDisableWireMode();                           // Disable wire mode
void rlDeleteTextures(uint id);                 // Delete OpenGL texture from GPU
void rlDeleteRenderTextures(RenderTexture2D target);    // Delete render textures (fbo) from GPU
void rlDeleteShader(uint id);                   // Delete OpenGL shader program from GPU
void rlDeleteVertexArrays(uint id);             // Unload vertex data (VAO) from GPU memory
void rlDeleteBuffers(uint id);                  // Unload vertex data (VBO) from GPU memory
void rlClearColor(byte r, byte g, byte b, byte a);      // Clear color buffer with color
void rlClearScreenBuffers();                        // Clear used screen buffers (color and depth)
void rlUpdateBuffer(int bufferId, void *data, int dataSize); // Update GPU buffer with new data
uint rlLoadAttribBuffer(uint vaoId, int shaderLoc, void *buffer, int size, bool dynamic);   // Load a new attributes buffer

//------------------------------------------------------------------------------------
// Functions Declaration - rlgl functionality
//------------------------------------------------------------------------------------
void rlglInit(int width, int height);           // Initialize rlgl (buffers, shaders, textures, states)
void rlglClose();                           // De-inititialize rlgl (buffers, shaders, textures)
void rlglDraw();                            // Update and draw default internal buffers

int rlGetVersion();                         // Returns current OpenGL version
bool rlCheckBufferLimit(int vCount);            // Check internal buffer overflow for a given number of vertex
void rlSetDebugMarker(const char *text);        // Set debug marker for analysis
void rlLoadExtensions(void *loader);            // Load OpenGL extensions
Vector3 rlUnproject(Vector3 source, Matrix proj, Matrix view);  // Get world coordinates from screen coordinates

// Textures data management
uint rlLoadTexture(void *data, int width, int height, int format, int mipmapCount); // Load texture in GPU
uint rlLoadTextureDepth(int width, int height, int bits, bool useRenderBuffer);     // Load depth texture/renderbuffer (to be attached to fbo)
uint rlLoadTextureCubemap(void *data, int size, int format);                        // Load texture cubemap
void rlUpdateTexture(uint id, int width, int height, int format, const void *data); // Update GPU texture with new data
void rlGetGlTextureFormats(int format, uint *glInternalFormat, uint *glFormat, uint *glType);  // Get OpenGL internal formats
void rlUnloadTexture(uint id);                              // Unload texture from GPU memory

void rlGenerateMipmaps(Texture2D *texture);                         // Generate mipmap data for selected texture
void *rlReadTexturePixels(Texture2D texture);                       // Read texture pixel data
ubyte *rlReadScreenPixels(int width, int height);           // Read screen pixel data (color buffer)

// Render texture management (fbo)
RenderTexture2D rlLoadRenderTexture(int width, int height, int format, int depthBits, bool useDepthTexture);    // Load a render texture (with color and depth attachments)
void rlRenderTextureAttach(RenderTexture target, uint id, int attachType);  // Attach texture/renderbuffer to an fbo
bool rlRenderTextureComplete(RenderTexture target);                 // Verify render texture is complete

// Vertex data management
void rlLoadMesh(Mesh *mesh, bool dynamic);                          // Upload vertex data into GPU and provided VAO/VBO ids
void rlUpdateMesh(Mesh mesh, int buffer, int num);                  // Update vertex or index data on GPU (upload new data to one buffer)
void rlUpdateMeshAt(Mesh mesh, int buffer, int num, int index);     // Update vertex or index data on GPU, at index
void rlDrawMesh(Mesh mesh, Material material, Matrix transform);    // Draw a 3d mesh with material and transform
void rlUnloadMesh(Mesh mesh);                                       // Unload mesh data from CPU and GPU

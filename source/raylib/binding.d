/**
 * D-specialized raylib functions. These functions help the D experience on
 * raylib.
 */
module raylib.binding;
import raylib;

// stored inside raylib to validate the binding
// NOTE: should be private, but D doesn't allow private export symbols
/*private*/ extern(C) extern export __gshared const(char*) raylib_version;

/**
 * Call this function before using any raylib functions to validate the binding
 * matches what the header information says. If you don't call this, it's
 * possible your binding will fail with such fun issues as memory corruption.
 *
 * If the binding is not valid, then the program will exit with a -1 error code.
 *
 * The function is not included when running raylib unittests, so there are no
 * linker errors. (raylib-d unittests do not test the C binding)
 */
version(raylib_test) {} else
void validateRaylibBinding() @nogc nothrow {
    import core.stdc.stdio;
    import core.stdc.stdlib;
    import core.stdc.string;
    auto rlv = raylib_version[0 .. strlen(raylib_version)];
    //if(rlv != RAYLIB_VERSION)
    if(strcmp(raylib_version, RAYLIB_VERSION) != 0)
    {
        printf("FATAL ERROR: Raylib binding expected version %.*s, library version is %.*s\n",
               cast(int)RAYLIB_VERSION.length, RAYLIB_VERSION.ptr,
               cast(int)rlv.length, rlv.ptr);
        exit(-1);
    }
}

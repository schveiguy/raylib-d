/**
 * D-specialized raylib functions. These functions help the D experience on
 * raylib.
 */
module raylib.binding;
import raylib;

// stored inside raylib to validate the binding
private extern(C) extern __gshared const(char)* raylibVersion;

/**
 * Call this function before using any raylib functions to validate the binding
 * matches what the header information says. If you don't call this, it's
 * possible your binding will fail with such fun issues as memory corruption.
 *
 * If the binding is not valid, then the program will exit with a -1 error code.
 *
 * This is a template to avoid requiring linking libraylib for unittests.
 */
void validateRaylibBinding()() @nogc nothrow {
    import core.stdc.stdio;
    import core.stdc.stdlib;
    import core.stdc.string;
    auto rlv = raylibVersion[0 .. strlen(raylibVersion)];
    if(rlv != RAYLIB_VERSION)
    {
        printf("FATAL ERROR: Raylib binding expected version %.*s, library version is %.*s\n",
               cast(int)RAYLIB_VERSION.length, RAYLIB_VERSION.ptr,
               cast(int)rlv.length, rlv.ptr);
        exit(-1);
    }
}

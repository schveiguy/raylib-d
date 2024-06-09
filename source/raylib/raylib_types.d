/// This module defines basic types from Raylib with local modifications to make them easier to use.
module raylib.raylib_types;

import raylib;

// Vector2 type
struct Vector2
{
    float x = 0.0f;
    float y = 0.0f;
    
    enum zero = Vector2(0.0f, 0.0f);
    enum one = Vector2(1.0f, 1.0f);

    @safe @nogc nothrow:

    inout Vector2 opUnary(string op)() if (op == "+" || op == "-") {
        return Vector2(
            mixin(op, "x"),
            mixin(op, "y"),
        );
    }

    inout Vector2 opBinary(string op)(inout Vector2 rhs) if (op == "+" || op == "-") {
        return Vector2(
            mixin("x", op, "rhs.x"),
            mixin("y", op, "rhs.y"),
        );
    }

    ref Vector2 opOpAssign(string op)(inout Vector2 rhs) if (op == "+" || op == "-") {
        mixin("x", op, "=rhs.x;");
        mixin("y", op, "=rhs.y;");
        return this;
    }

    inout Vector2 opBinary(string op)(inout float rhs) if (op == "+" || op == "-" || op == "*" || op ==  "/") {
        return Vector2(
            mixin("x", op, "rhs"),
            mixin("y", op, "rhs"),
        );
    }

    inout Vector2 opBinaryRight(string op)(inout float lhs) if (op == "+" || op == "-" || op == "*" || op ==  "/") {
        return Vector2(
            mixin("lhs", op, "x"),
            mixin("lhs", op, "y"),
        );
    }

    ref Vector2 opOpAssign(string op)(inout float rhs) if (op == "+" || op == "-" || op == "*" || op ==  "/") {
        mixin("x", op, "=rhs;");
        mixin("y", op, "=rhs;");
        return this;
    }
}

// Vector3 type
struct Vector3
{
    float x = 0.0f;
    float y = 0.0f;
    float z = 0.0f;

    enum zero = Vector3(0.0f, 0.0f, 0.0f);
    enum one = Vector3(1.0f, 1.0f, 1.0f);

    @safe @nogc nothrow:

    inout Vector3 opUnary(string op)() if (op == "+" || op == "-") {
        return Vector3(
            mixin(op, "x"),
            mixin(op, "y"),
            mixin(op, "z"),
        );
    }

    inout Vector3 opBinary(string op)(inout Vector3 rhs) if (op == "+" || op == "-") {
        return Vector3(
            mixin("x", op, "rhs.x"),
            mixin("y", op, "rhs.y"),
            mixin("z", op, "rhs.z"),
        );
    }

    ref Vector3 opOpAssign(string op)(inout Vector3 rhs) if (op == "+" || op == "-") {
        mixin("x", op, "=rhs.x;");
        mixin("y", op, "=rhs.y;");
        mixin("z", op, "=rhs.z;");
        return this;
    }

    inout Vector3 opBinary(string op)(inout float rhs) if (op == "+" || op == "-" || op == "*" || op ==  "/") {
        return Vector3(
            mixin("x", op, "rhs"),
            mixin("y", op, "rhs"),
            mixin("z", op, "rhs"),
        );
    }

    inout Vector3 opBinaryRight(string op)(inout float lhs) if (op == "+" || op == "-" || op == "*" || op ==  "/") {
        return Vector3(
            mixin("lhs", op, "x"),
            mixin("lhs", op, "y"),
            mixin("lhs", op, "z"),
        );
    }

    ref Vector3 opOpAssign(string op)(inout float rhs) if (op == "+" || op == "-" || op == "*" || op ==  "/") {
        mixin("x", op, "=rhs;");
        mixin("y", op, "=rhs;");
        mixin("z", op, "=rhs;");
        return this;
    }
}

// Vector4 type
struct Vector4
{
    float x = 0.0f;
    float y = 0.0f;
    float z = 0.0f;
    float w = 0.0f;

    enum zero = Vector4(0.0f, 0.0f, 0.0f, 0.0f);
    enum one = Vector4(1.0f, 1.0f, 1.0f, 1.0f);

    @safe @nogc nothrow:

    inout Vector4 opUnary(string op)() if (op == "+" || op == "-") {
        return Vector4(
            mixin(op, "x"),
            mixin(op, "y"),
            mixin(op, "z"),
            mixin(op, "w"),
        );
    }

    inout Vector4 opBinary(string op)(inout Vector4 rhs) if (op == "+" || op == "-") {
        return Vector4(
            mixin("x", op, "rhs.x"),
            mixin("y", op, "rhs.y"),
            mixin("z", op, "rhs.z"),
            mixin("w", op, "rhs.w"),
        );
    }

    ref Vector4 opOpAssign(string op)(inout Vector4 rhs) if (op == "+" || op == "-") {
        mixin("x", op, "=rhs.x;");
        mixin("y", op, "=rhs.y;");
        mixin("z", op, "=rhs.z;");
        mixin("w", op, "=rhs.w;");
        return this;
    }

    inout Vector4 opBinary(string op)(inout float rhs) if (op == "+" || op == "-" || op == "*" || op ==  "/") {
        return Vector4(
            mixin("x", op, "rhs"),
            mixin("y", op, "rhs"),
            mixin("z", op, "rhs"),
            mixin("w", op, "rhs"),
        );
    }

    inout Vector4 opBinaryRight(string op)(inout float lhs) if (op == "+" || op == "-" || op == "*" || op ==  "/") {
        return Vector4(
            mixin("lhs", op, "x"),
            mixin("lhs", op, "y"),
            mixin("lhs", op, "z"),
            mixin("lhs", op, "w"),
        );
    }

    ref Vector4 opOpAssign(string op)(inout float rhs) if (op == "+" || op == "-" || op == "*" || op ==  "/") {
        mixin("x", op, "=rhs;");
        mixin("y", op, "=rhs;");
        mixin("z", op, "=rhs;");
        mixin("w", op, "=rhs;");
        return this;
    }
}

// Quaternion type, same as Vector4
alias Quaternion = Vector4;

// Matrix type (OpenGL style 4x4 - right handed, column major)
struct Matrix
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
}

// Rectangle type
struct Rectangle
{
    float x;
    float y;
    float width;
    float height;
    alias w = width;
    alias h = height;

    @safe @nogc nothrow:

    Vector2 origin() { // Rectangle function exclusive to raylib-d
        return Vector2(x, y);
    }
    alias position = origin;
    
    Vector2 dimensions() {
        return Vector2(width, height);
    }

    alias topLeft = origin;

    Vector2 topRight() const {
        return Vector2(x:(x + width), y:y);
    }

    Vector2 bottomLeft() const {
        return Vector2(x:x, y:(y + height));
    }

    Vector2 bottomRight() const {
        return Vector2(x:(x + width), y:(y + height));
    }

    Vector2 center() const {
        return Vector2(x:(x + width/2.0f), y:(y + height/2.0f));
    }
    alias centre = center;

    void opOpAssign(string op)(Vector2 offset) if (op == "+" || op == "-") {
        mixin("this.x ", op, "= offset.x;");
        mixin("this.y ", op, "= offset.y;");
    }

    Rectangle opBinary(string op)(Vector2 offset) const if(op=="+" || op=="-") {
        Rectangle result = this;
        result.opOpAssign!op(offset);
        return result;
    }
}

// Color type, R8G8B8A8 (32bit)
struct Color
{
    ubyte r;
    ubyte g;
    ubyte b;
    ubyte a = 255;

    @safe @nogc nothrow:

    this(ubyte r, ubyte g, ubyte b, ubyte a = 255) {
        this.r = r;
        this.g = g;
        this.b = b;
        this.a = a;
    }

    this(ubyte[4] rgba) {
        this(rgba[0], rgba[1], rgba[2], rgba[3]);
    }

    this(ubyte[3] rgb) {
        this(rgb[0], rgb[1], rgb[2], 255);
    }
}

enum Colors
{
    // Some Basic Colors
    // NOTE: Custom raylib color palette for amazing visuals on WHITE background
    LIGHTGRAY = Color(200, 200, 200, 255), // Light Gray
    GRAY = Color(130, 130, 130, 255), // Gray
    DARKGRAY = Color(80, 80, 80, 255), // Dark Gray
    YELLOW = Color(253, 249, 0, 255), // Yellow
    GOLD = Color(255, 203, 0, 255), // Gold
    ORANGE = Color(255, 161, 0, 255), // Orange
    PINK = Color(255, 109, 194, 255), // Pink
    RED = Color(230, 41, 55, 255), // Red
    MAROON = Color(190, 33, 55, 255), // Maroon
    GREEN = Color(0, 228, 48, 255), // Green
    LIME = Color(0, 158, 47, 255), // Lime
    DARKGREEN = Color(0, 117, 44, 255), // Dark Green
    SKYBLUE = Color(102, 191, 255, 255), // Sky Blue
    BLUE = Color(0, 121, 241, 255), // Blue
    DARKBLUE = Color(0, 82, 172, 255), // Dark Blue
    PURPLE = Color(200, 122, 255, 255), // Purple
    VIOLET = Color(135, 60, 190, 255), // Violet
    DARKPURPLE = Color(112, 31, 126, 255), // Dark Purple
    BEIGE = Color(211, 176, 131, 255), // Beige
    BROWN = Color(127, 106, 79, 255), // Brown
    DARKBROWN = Color(76, 63, 47, 255), // Dark Brown

    WHITE = Color(255, 255, 255, 255), // White
    BLACK = Color(0, 0, 0, 255), // Black
    BLANK = Color(0, 0, 0, 0), // Blank (Transparent)
    MAGENTA = Color(255, 0, 255, 255), // Magenta
    RAYWHITE = Color(245, 245, 245, 255), // My own White (raylib logo)
}

unittest
{
    import std.conv;
    
    float x = 543.3f;
    float y = 235.9f;
    float width = 50.0f;
    float height = 20.0f;
    Rectangle rect = Rectangle(x, y, width, height);
    assert(rect.origin.x == 543.3f, "`rect.origin.x` should be 543.3, not "~to!string(rect.origin.x));
    assert(rect.origin.y == 235.9f, "`rect.centre.y` should be 235.9, not "~to!string(rect.origin.y));
    assert(rect.dimensions == Vector2(50.0f, 20.0f));
    assert(rect.topLeft == Vector2(x:543.3f, y:235.9f), "`rect.topLeft` should be Vector2(543.3, 235.9), not "~to!string(rect.topLeft));
    assert(rect.topRight.x == 593.3f);
    assert(rect.bottomLeft == Vector2(543.3f, 255.9f), "`rect.bottomLeft` should be Vector2(543.3, 255.9), not "~to!string(rect.bottomLeft));
    assert(rect.bottomRight == Vector2(593.3f, 255.9f), "`rect.bottomRight` should be Vector2(593.3, 255.9), not "~to!string(rect.bottomRight));
    assert(rect.centre == Vector2(568.3f, 245.9f), "`rect.centre` should be Vector2(568.3, 245.9), not "~to!string(rect.centre));

    x += 26.3f;
    y += 43.2f;
    assert((rect + Vector2(26.3f, 0.0f)).x == rect.origin.x + 26.3f);
    rect.x = 10.0f;
    rect.y = 14.0f;
    rect += Vector2(19.0f, 7.3f);
    assert(rect.origin == Vector2(29.0f, 21.3f));
    rect -= Vector2(4.5f, 2.3f);
    assert(rect.x == 24.5f, "`rect.x` should be 24.5f. Instead it is "~to!string(rect.x));
    assert(rect.y == 19.0f, "`rect.y` should be 20.7f. Instead it is "~to!string(rect.y));
}

/// This module defines basic types from Raylib with local modifications to make them easier to use.
module raylib.raylib_types;

import raylib;

// Vector2 type
struct Vector2
{
    float x = 0.0f;
    float y = 0.0f;
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

// Vector4 type
struct Vector4
{
    float x = 0.0f;
    float y = 0.0f;
    float z = 0.0f;
    float w = 0.0f;
    mixin Linear;
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

    Vector2 origin() { // Rectangle function exclusive to raylib-d
        return Vector2(x, y);
    }
    
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

    void opOpAssign(string op)(Vector2 offset) {
        static assert(op=="+" || op=="-");
        
        static if (op=="+") {
            this.x += offset.x;
            this.y += offset.y;
        } else static if (op=="-") {
            this.x -= offset.x;
            this.y -= offset.y;
        }
    }

    Rectangle opBinary(string op)(Vector2 offset) const {
        static assert(op=="+" || op=="-");

        Rectangle result = this;
        static if (op=="+") {
            result.x += offset.x;
            result.y += offset.y;
        } else static if (op=="-") {
            result.x -= offset.x;
            result.y -= offset.y;
        }
        return result;
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
    
    float x = cast(float)(GetRandomValue(-500, 1000) / 7.0f);
    float y = cast(float)(GetRandomValue(-500, 1000) / 7.0f);
    float width = cast(float)(GetRandomValue(0, 200) / 7.0f);
    float height = cast(float)(GetRandomValue(0, 200) / 7.0f);
    Rectangle rect = Rectangle(x, y, width, height);
    assert(rect.origin.x == x);
    assert(rect.origin.y == y);
    assert(rect.dimensions.x == width);
    assert(rect.dimensions.y == height);
    assert(rect.topLeft == Vector2(x:x, y:y));
    assert(rect.topRight.x == x + width);
    assert(rect.bottomLeft == Vector2(x:x, y:(y + height)));
    assert(rect.bottomRight == Vector2(x:(x+width), y:(y + height)));

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

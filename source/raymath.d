import raylib;
import std.math;

mixin template Linear()
{
    import std.algorithm : canFind, map;
    import std.range : join;
    import std.traits : FieldNameTuple;

    private static alias T = typeof(this);

    static T zero()
    {
        enum fragment = [FieldNameTuple!T].map!(field => "0.").join(",");
        return mixin("T(" ~ fragment ~ ")");
    }

    static T one()
    {
        enum fragment = [FieldNameTuple!T].map!(field => "1.").join(",");
        return mixin("T(" ~ fragment ~ ")");
    }

    T opUnary(string op)() if (["+", "-"].canFind(op))
    {
        enum fragment = [FieldNameTuple!T].map!(field => op ~ field).join(",");
        return mixin("T(" ~ fragment ~ ")");
    }

    T opBinary(string op)(T rhs) if (["+", "-", "*", "/"].canFind(op))
    {
        enum fragment = [FieldNameTuple!T].map!(field => field ~ op ~ "rhs." ~ field).join(",");
        return mixin("T(" ~ fragment ~ ")");
    }

    T opBinary(string op)(float rhs) if (["+", "-", "*", "/"].canFind(op))
    {
        enum fragment = [FieldNameTuple!T].map!(field => field ~ op ~ "rhs").join(",");
        return mixin("T(" ~ fragment ~ ")");
    }

    T opBinaryRight(string op)(float lhs) if (["+", "-", "*", "/"].canFind(op))
    {
        enum fragment = [FieldNameTuple!T].map!(field => "lhs" ~ op ~ field).join(",");
        return mixin("T(" ~ fragment ~ ")");
    }
}

import std.traits : FieldNameTuple;
import std.algorithm : map;
import std.range : join;

float length(T)(T v) if (__traits(compiles, v * v))
{
    enum fragment = [FieldNameTuple!T].map!(field => "v." ~ field ~ "*" ~ "v." ~ field).join("+");
    return mixin("sqrt(" ~ fragment ~ ")");
}

T normalize(T)(T v)
{
    return v / this.length;
}

float distance(T)(T lhs, T rhs)
{
    return (lhs - rhs).length;
}

T dot(T)(T lhs, T rhs)
{
    return lhs * rhs;
}

unittest
{
    assert(-Vector2(1, 2) == Vector2(-1, -2));
    assert(Vector3(1, 2, 9) + Vector3(3, 4, 9) == Vector3(4, 6, 18));
    assert(4.0f - Vector2.zero == Vector2(4, 4));
    assert(Vector2.one - 3.0f == Vector2(-2, -2));
    assert(Vector2(3, 4).length == 5.0);
}

/// Mix `amount` of `lhs` with `1-amount` of `rhs`
///   `amount` should be between 0 and 1, but can be anything
///   lerp(lhs, rhs, 0) == lhs
///   lerp(lhs, rhs, 1) == rhs
T lerp(T)(T lhs, T rhs, float amount)
{
    return lhs + amount * (rhs - lhs);
}

float angle(Vector2 v)
{
    return atan2(v.y, v.x);
}

/// Rotate on imaginary plane
Vector2 rotate(Vector2 lhs, Vector2 rhs)
{
    return Vector2(lhs.x * rhs.x - lhs.y * rhs.y, lhs.x * rhs.y + lhs.y * rhs.x);
}

Vector2 rotate(Vector2 v, float angle)
{
    return Vector2(v.x * cos(angle) - v.y * sin(angle), v.x * sin(angle) + v.y * cos(angle));
}

Vector3 cross(Vector3 lhs, Vector3 rhs)
{
    return Vector3(lhs.y * rhs.z - lhs.z * rhs.y, lhs.z * rhs.x - lhs.x * rhs.z,
            lhs.x * rhs.y - lhs.y * rhs.x);
}

// dfmt off
Vector3 transform(Vector3 v, Matrix4 mat)
{
    with (v) with (mat)
        return Vector3(
            m0 * x + m4 * y + m8 * z + m12,
            m1 * x + m5 * y + m9 * z + m13,
            m2 * x + m6 * y + m10 * z + m14
        );
}
// dfmt on

// TODO implement rotor3
// Vector3 rotate(Vector3 v, Rotor3 r) {
//     return ;
// }

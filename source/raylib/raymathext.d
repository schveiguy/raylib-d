module raylib.raymathext;

import raylib;
import core.stdc.math;
import std.traits : FieldNameTuple;

pragma(inline, true):

// Bivector2 type
struct Bivector2
{
    float xy = 0.0f;
    alias xy this;

    enum zero = Bivector2(0.0f);
    enum one = Bivector2(1.0f);

    @safe @nogc nothrow:

    inout Bivector2 opUnary(string op)() if (op == "+" || op == "-") {
        return Bivector2(
            mixin(op, "xy"),
        );
    }

    inout Bivector2 opBinary(string op)(inout Bivector2 rhs) if (op == "+" || op == "-") {
        return Bivector2(
            mixin("xy", op, "rhs.xy"),
        );
    }

    ref Bivector2 opOpAssign(string op)(inout Bivector2 rhs) if (op == "+" || op == "-") {
        mixin("xy", op, "=rhs.xy;");
        return this;
    }

    inout Bivector2 opBinary(string op)(inout float rhs) if (op == "+" || op == "-" || op == "*" || op ==  "/") {
        return Bivector2(
            mixin("xy", op, "rhs"),
        );
    }

    inout Bivector2 opBinaryRight(string op)(inout float lhs) if (op == "+" || op == "-" || op == "*" || op ==  "/") {
        return Bivector2(
            mixin("lhs", op, "xy"),
        );
    }

    ref Bivector2 opOpAssign(string op)(inout float rhs) if (op == "+" || op == "-" || op == "*" || op ==  "/") {
        mixin("xy", op, "=rhs;");
        return this;
    }
}

// Bivector3 type
/// Beware of the field order
/// xy is the first field
struct Bivector3
{
    float xy = 0.0f;
    float yz = 0.0f;
    float zx = 0.0f;

    enum zero = Bivector3(0.0f, 0.0f, 0.0f);
    enum one = Bivector3(1.0f, 1.0f, 1.0f);

    @safe @nogc nothrow:

    inout Bivector3 opUnary(string op)() if (op == "+" || op == "-") {
        return Bivector3(
            mixin(op, "xy"),
            mixin(op, "yz"),
            mixin(op, "zx"),
        );
    }

    inout Bivector3 opBinary(string op)(inout Bivector3 rhs) if (op == "+" || op == "-") {
        return Bivector3(
            mixin("xy", op, "rhs.xy"),
            mixin("yz", op, "rhs.yz"),
            mixin("zx", op, "rhs.zx"),
        );
    }

    ref Bivector3 opOpAssign(string op)(inout Bivector3 rhs) if (op == "+" || op == "-") {
        mixin("xy", op, "=rhs.xy;");
        mixin("yz", op, "=rhs.yz;");
        mixin("zx", op, "=rhs.zx;");
        return this;
    }

    inout Bivector3 opBinary(string op)(inout float rhs) if (op == "+" || op == "-" || op == "*" || op ==  "/") {
        return Bivector3(
            mixin("xy", op, "rhs"),
            mixin("yz", op, "rhs"),
            mixin("zx", op, "rhs"),
        );
    }

    inout Bivector3 opBinaryRight(string op)(inout float lhs) if (op == "+" || op == "-" || op == "*" || op ==  "/") {
        return Bivector3(
            mixin("lhs", op, "xy"),
            mixin("lhs", op, "yz"),
            mixin("lhs", op, "zx"),
        );
    }

    ref Bivector3 opOpAssign(string op)(inout float rhs) if (op == "+" || op == "-" || op == "*" || op ==  "/") {
        mixin("xy", op, "=rhs;");
        mixin("yz", op, "=rhs;");
        mixin("zx", op, "=rhs;");
        return this;
    }
}

// Rotor type
struct Rotor3
{
    float a = 1.0f;
    float xy = 0.0f;
    float yz = 0.0f;
    float zx = 0.0f;

    enum zero = Rotor3(0.0f, 0.0f, 0.0f, 0.0f);
    enum one = Rotor3(1.0f, 1.0f, 1.0f, 1.0f);

    alias i = yz;
    alias j = zx;
    alias k = xy;

    @safe @nogc nothrow:

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

    inout Rotor3 opUnary(string op)() if (op == "+" || op == "-") {
        return Rotor3(
            mixin(op, "a"),
            mixin(op, "xy"),
            mixin(op, "yz"),
            mixin(op, "zx"),
        );
    }

    /// Returns a rotor equivalent to first apply p, then apply q
    inout Rotor3 opBinary(string op)(inout Rotor3 q) if (op == "*") {
        alias p = this;
        Rotor3 r;
        r.a = p.a * q.a - p.i * q.i - p.j * q.j - p.k * q.k;
        r.i = p.i * q.a + p.a * q.i + p.j * q.k - p.k * q.j;
        r.j = p.j * q.a + p.a * q.j + p.k * q.i - p.i * q.k;
        r.k = p.k * q.a + p.a * q.k + p.i * q.j - p.j * q.i;
        return r;
    }

    inout Vector3 opBinary(string op)(inout Vector3 v) if (op == "*") {
        Vector3 rv;
        rv.x = a * v.x + xy * v.y - zx * v.z;
        rv.y = a * v.y + yz * v.z - xy * v.x;
        rv.z = a * v.z + zx * v.x - yz * v.y;
        return rv;
    }

    inout Vector3 opBinaryRight(string op)(inout Vector3 v) if (op == "*") {
        Vector3 vr;
        vr.x = v.x * a - v.y * xy + v.z * zx;
        vr.y = v.y * a - v.z * yz + v.x * xy;
        vr.z = v.z * a - v.x * zx + v.y * yz;
        return vr;
    }

    inout Rotor3 opBinary(string op)(inout float rhs) if (op == "+" || op == "-" || op == "*" || op ==  "/") {
        return Rotor3(
            mixin("a", op, "rhs"),
            mixin("xy", op, "rhs"),
            mixin("yz", op, "rhs"),
            mixin("zx", op, "rhs"),
        );
    }

    inout Rotor3 opBinaryRight(string op)(inout float lhs) if (op == "+" || op == "-" || op == "*" || op ==  "/") {
        return Rotor3(
            mixin("lhs", op, "a"),
            mixin("lhs", op, "xy"),
            mixin("lhs", op, "yz"),
            mixin("lhs", op, "zx"),
        );
    }

    ref Rotor3 opOpAssign(string op)(inout float rhs) if (op == "+" || op == "-" || op == "*" || op ==  "/") {
        mixin("a", op, "=rhs;");
        mixin("xy", op, "=rhs;");
        mixin("yz", op, "=rhs;");
        mixin("zx", op, "=rhs;");
        return this;
    }
}

alias Matrix4 = Matrix;

unittest
{
    assert(Vector2.init == Vector2.zero);
    assert(Vector2() == Vector2.zero);
    assert(-Vector2(1, 2) == Vector2(-1, -2));
    auto a = Vector3(1, 2, 9);
    immutable b = Vector3(3, 4, 9);
    Vector3 c = a + b;
    assert(c == Vector3(4, 6, 18));
    assert(4.0f - Vector2.zero == Vector2(4, 4));
    assert(Vector2.one - 3.0f == Vector2(-2, -2));
    a += 5;
    assert(a == Vector3(6, 7, 14));
    a *= 0.5;
    assert(a == Vector3(3, 3.5, 7));
    a += Vector3(3, 2.5, -1);
    assert(a == Vector3(6, 6, 6));
}

//import std.algorithm : map;
//import std.range : join;

float length(T)(T v)
{
    enum fragment = () {
        string result;
        foreach(string fn; FieldNameTuple!T)
            result ~= fn ~ "*" ~ fn ~ "+";
        return result[0 .. $-1]; // trim off last +
    }();
    with(v) return mixin("sqrt(", fragment, ")");
}

T normal(T)(T v)
{
    return v / v.length;
}

float distance(T)(T lhs, T rhs)
{
    return (lhs - rhs).length;
}

float dot(T)(T lhs, T rhs)
{
    enum fragment = {
        string result;
        foreach(fn; FieldNameTuple!T)
            result ~= "lhs." ~ fn ~ "*" ~ "rhs." ~ fn ~ "+";
        return result[0 .. $-1]; // trim off last +
    }();
    return mixin(fragment);
}

unittest
{
    assert(Vector2(3, 4).length == 5);
    const a = Vector2(-3, 4);
    assert(a.normal == Vector2(-3. / 5., 4. / 5.));
    immutable b = Vector2(9, 8);
    assert(b.distance(Vector2(-3, 3)) == 13);
    assert(Vector3(2, 3, 4).dot(Vector3(4, 5, 6)) == 47);
    assert(Vector2.one.length == cast(float)sqrt(2.0f));
}

unittest
{
    assert(Rotor3(1, 2, 3, 4) == Rotor3(1, Bivector3(2, 3, 4)));
}

/// Mix `amount` of `lhs` with `1-amount` of `rhs`
///   `amount` should be between 0 and 1, but can be anything
///   lerp(lhs, rhs, 0) == lhs
///   lerp(lhs, rhs, 1) == rhs
T lerp(T)(T lhs, T rhs, float amount)
{
    return lhs + amount * (rhs - lhs);
}

/// angle betwenn vector and x-axis (+y +x -> positive)
float angle(Vector2 v)
{
    return atan2(v.y, v.x);
}

Vector2 rotate(Vector2 v, float angle)
{
    return Vector2(v.x * cos(angle) - v.y * sin(angle), v.x * sin(angle) + v.y * cos(angle));
}

Vector2 slide(Vector2 v, Vector2 along)
{
    return along.normal * dot(v, along);
}

Bivector2 wedge(Vector2 lhs, Vector2 rhs)
{
    Bivector2 result = {xy: lhs.x * rhs.y - lhs.y * rhs.x};
    return result;
}

// dfmt off
Bivector3 wedge(Vector3 lhs, Vector3 rhs)
{
    Bivector3 result = {
        xy: lhs.x * rhs.y - lhs.y * rhs.x,
        yz: lhs.y * rhs.z - lhs.z * rhs.y,
        zx: lhs.z * rhs.x - lhs.x * rhs.z,
    };
    return result;
}

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

Vector3 cross(Vector3 lhs, Vector3 rhs)
{
    auto v = wedge(lhs, rhs);
    return Vector3(v.yz, v.zx, v.xy);
}

unittest {
    // TODO
}

/// Returns a unit rotor that rotates `from` to `to`
Rotor3 rotation(Vector3 from, Vector3 to)
{
    return Rotor3(1 + dot(to, from), wedge(to, from)).normal;
}

Rotor3 rotation(float angle, Bivector3 plane)
{
    return Rotor3(cos(angle / 2.0f), -sin(angle / 2.0f) * plane);
}

/// Rotate q by p
Rotor3 rotate(Rotor3 p, Rotor3 q)
{
    return p * q * p.reverse;
}

/// Rotate v by r
Vector3 rotate(Rotor3 r, Vector3 v)
{
    return r * v * r.reverse;
}

Rotor3 reverse(Rotor3 r)
{
    return Rotor3(r.a, -r.b);
}

unittest
{
    // TODO
}

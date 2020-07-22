module raymathext;

import raylib;
import std.math;

pragma(inline, true):

version (unittest)
{
    import fluent.asserts;
}

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

    inout T opUnary(string op)() if (["+", "-"].canFind(op))
    {
        enum fragment = [FieldNameTuple!T].map!(field => op ~ field).join(",");
        return mixin("T(" ~ fragment ~ ")");
    }

    static if (is(T == Rotor3))
    {
        /// Returns a rotor equivalent to first apply p, then apply q
        inout Rotor3 opBinary(string op)(inout Rotor3 q) if (op == "*")
        {
            alias p = this;
            Rotor3 r;
            r.a = p.a * q.a - p.i * q.i - p.j * q.j - p.k * q.k;
            r.i = p.i * q.a + p.a * q.i + p.j * q.k - p.k * q.j;
            r.j = p.j * q.a + p.a * q.j + p.k * q.i - p.i * q.k;
            r.k = p.k * q.a + p.a * q.k + p.i * q.j - p.j * q.i;
            return r;
        }

        inout Vector3 opBinary(string op)(inout Vector3 v) if (op == "*")
        {
            Vector3 rv;
            rv.x = a * v.x + xy * v.y - zx * v.z;
            rv.y = a * v.y + yz * v.z - xy * v.x;
            rv.z = a * v.z + zx * v.x - yz * v.y;
            return rv;
        }

        inout Vector3 opBinaryRight(string op)(inout Vector3 v) if (op == "*")
        {
            Vector3 vr;
            vr.x = v.x * a - v.y * xy + v.z * zx;
            vr.y = v.y * a - v.z * yz + v.x * xy;
            vr.z = v.z * a - v.x * zx + v.y * yz;
            return vr;
        }
    }
    else
    {
        inout T opBinary(string op)(inout T rhs) if (["+", "-"].canFind(op))
        {
            enum fragment = [FieldNameTuple!T].map!(field => field ~ op ~ "rhs." ~ field).join(",");
            return mixin("T(" ~ fragment ~ ")");
        }
    }

    inout T opBinary(string op)(inout float rhs) if (["+", "-", "*", "/"].canFind(op))
    {
        enum fragment = [FieldNameTuple!T].map!(field => field ~ op ~ "rhs").join(",");
        return mixin("T(" ~ fragment ~ ")");
    }

    inout T opBinaryRight(string op)(inout float lhs) if (["+", "-", "*", "/"].canFind(op))
    {
        enum fragment = [FieldNameTuple!T].map!(field => "lhs" ~ op ~ field).join(",");
        return mixin("T(" ~ fragment ~ ")");
    }
}

unittest
{
    Assert.equal(Vector2.init, Vector2.zero);
    Assert.equal(Vector2(), Vector2.zero);
    Assert.equal(-Vector2(1, 2), Vector2(-1, -2));
    auto a = Vector3(1, 2, 9);
    immutable b = Vector3(3, 4, 9);
    Vector3 c = a + b;
    Assert.equal(c, Vector3(4, 6, 18));
    Assert.equal(4.0f - Vector2.zero, Vector2(4, 4));
    Assert.equal(Vector2.one - 3.0f, Vector2(-2, -2));
}

import std.traits : FieldNameTuple;
import std.algorithm : map;
import std.range : join;

float length(T)(T v)
{
    enum fragment = [FieldNameTuple!T].map!(field => "v." ~ field ~ "*" ~ "v." ~ field).join("+");
    return mixin("sqrt(" ~ fragment ~ ")");
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
    enum fragment = [FieldNameTuple!T].map!(field => "lhs." ~ field ~ "*" ~ "rhs." ~ field).join(
                "+");
    return mixin(fragment);
}

unittest
{
    Assert.equal(Vector2(3, 4).length, 5);
    const a = Vector2(-3, 4);
    Assert.equal(a.normal, Vector2(-3. / 5., 4. / 5.));
    immutable b = Vector2(9, 8);
    Assert.equal(b.distance(Vector2(-3, 3)), 13);
    Assert.equal(Vector3(2, 3, 4).dot(Vector3(4, 5, 6)), 47);
    Assert.equal(Vector2.one.length, sqrt(2.0f));
}

unittest
{
    Assert.equal(Rotor3(1, 2, 3, 4), Rotor3(1, Bivector3(2, 3, 4)));
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

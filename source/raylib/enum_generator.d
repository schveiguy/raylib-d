module raylib.old_enums;

import std.traits;
import std.conv;

string EnumPrefixes(T)(string oldName, string prefix) {
    string result = "enum " ~ oldName ~ " {\n";
    static foreach(member; __traits(allMembers, T)) {
        result ~= "    " ~ prefix ~ member ~ " = " ~ __traits(getMember, T, member).to!int.to!string ~ ",\n";
    }
    return result ~ "}\n";
}

string EnumPrefixes(T)(string prefix) {
    string result;
    static foreach(member; __traits(allMembers, T)) {
        result ~= "enum " ~ T.stringof ~ " " ~ prefix ~ member ~ " = " ~ T.stringof ~ "." ~ member ~ ";\n";
    }
    return result;
}
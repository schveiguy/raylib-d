module raylibd_templates;

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

template OverloadWithString(Args) {
    static if (is(Args == function)) {
        // Extract function name
        alias Func FunctionType;
        enum funcName = __traits(identifier, FunctionType);

        // Extract function parameters
        alias Params = ParameterTypeTuple!FunctionType;

        // Convert const(char)* to string
        alias ConvertedParams = staticMap!(ToConstCharPointer, Params);

        // Generate overloaded function signature with string arguments
        string generateOverload(alias name, alias params)() {
            bool hasCString;
            
            string result = "void " ~ name ~ "(";
            foreach (param; params) {
                if (param.stringof == "const(char)*") {
                    result ~= "string " ~ __traits(identifier, param) ~ ", ";
                    hasCString = true;
                } else result ~= param.stringof ~ " " ~ __traits(identifier, param) ~ ", ";
            }
            if (!hasCString) return "";
            result ~= ") {" ~ name ~ "(";
            foreach (param; params) {
                result ~= "toStringz(" ~ __traits(identifier, param) ~ "), ";
            }
            result ~= "); }";
            return result;
        }

        // Generate and mixin the overloaded function definition
        mixin(generateOverload!(funcName, ConvertedParams));
    }
}

template GenerateOverloadsWithStrings(string moduleName) {
    static foreach (f; __traits(allMembers, mixin(moduleName))) {
        mixin("OverloadWithString!" ~ f ~ "();");
    }
}

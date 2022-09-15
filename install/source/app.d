import std.stdio;
import std.file;
import std.path;
import std.compiler;
import std.system;
import std.format;
import std.conv;
import std.process;
import iopipe.json.serialize;
import iopipe.json.parser;
import std.exception;
import iopipe.traits;

version(X86)
	enum arch="x86";
else version(X86_64)
	enum arch="x86_64";
else version(ARM)
	enum arch="arm";
else version(AArch64)
	enum arch="arm64";
else
	static assert(false, "Unsupported architecture");

// establish the runtime
version(CRuntime_Microsoft)
	enum CRT="MSVC";
else version(CRuntime_Glibc)
	enum CRT="glibc";
else version(CppRuntime_Clang)
	enum CRT="llvm";
else
	static assert(false, "Unsupported runtime");

enum baseDir = buildPath("install", "lib", os.to!string, arch.to!string, CRT.to!string);

int main()
{
    writeln("raylib-d library installation");
    // look at the dub.selections.json file
    auto dubConfig = execute(["dub", "describe"], null, Config.stderrPassThrough);
    string raylibdPath;
    if(dubConfig.status != 0)
    {
        stderr.writeln("Error executing dub describe");
        return dubConfig.status;
    }
    char[] getRaylibPath(char[] jsonStr)
    {
        auto tokens = jsonTokenizer(jsonStr);
        enforce(tokens.parseTo("packages"), "Could not find packages in dub json output!");
        auto nt = tokens.next.token;
        enforce(nt == JSONToken.ArrayStart, "Expected array start in packages");
        while(nt != JSONToken.ArrayEnd)
        {
            tokens.releaseParsed();
            tokens.startCache;
            enforce(tokens.parseTo("name"), "Could not find package name in json file");
            auto n = tokens.next;
            jsonExpect(n, JSONToken.String, "Expected string for package name");
            if(n.data(tokens.chain) == "raylib-d")
            {
                tokens.rewind;
                tokens.parseTo("path");
                auto p = tokens.next;
                jsonExpect(p, JSONToken.String, "Expected string for path");
                return p.data(tokens.chain);
            }
            tokens.rewind;
            tokens.endCache;
            nt = tokens.skipItem.token;
        }
        throw new Exception("Could not find raylib-d dependency for current project!");
    }
    try {
        auto path = getRaylibPath(dubConfig.output.dup);
        auto libpath = buildPath(path, baseDir);
        writeln("Copying library files from ", libpath);
        foreach(ent; dirEntries(libpath, SpanMode.shallow))
        {
            auto newLoc = buildPath(".", ent.name.baseName);
            version(Posix)
            {
                if(ent.isSymlink)
                {
                    // recreate the symlink
                    auto origln = readLink(ent.name);
                    writefln("Creating symlink %s -> %s", newLoc, origln);
                    symlink(origln, newLoc);
                    continue;
                }
            }
            writeln("Installing library file ", newLoc);
            copy(ent.name, newLoc, PreserveAttributes.yes);
        }
    } catch(Exception ex) {
        stderr.writeln("Error: ", ex.msg);
        return 1;
    }
    return 0;
}

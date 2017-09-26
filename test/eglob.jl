import Eglob: eglob, eglobt

using Base.Test

include("inc_helpers.jl")

function run_eglob_tests(globber::Function)
    # Basic glob test against generated files.
    withtempfiles("foo/x.c", "bar/y.c", "foo/bar/baz.c") do tempdir, files
        cd(tempdir) do
            c_files = Set([abspath(f) for f in files if endswith(f, ".c")])
            @test Set(abspath.(globber("**/*.c"))) == c_files

            foo_c_files = Set([f for f in files if ismatch(r"^foo/.*\.c$", f)])
            @test Set(globber("f*/**/*.c")) == foo_c_files
        end
    end

    # Basic glob test against existing files.
    expected = Set(abspath.(shellglob("**/*.jl")))
    @test Set(abspath.(globber("**/*.jl"))) == expected

    # Glob test that is guaranteed not to match.
    withtempfiles("quux/foo", "quux/baz/bar") do tempdir, files
        @test isempty(globber("quux/**/*.c"))
    end

    # Case-sensitivity check.
    files = ["foo/first.cc", "bar/second.c", "bar/third.cc",
             "foo/bar/fourth.c", "foo/bar/baz/FIFTH.C", "bar/sixth.cc"]
    withtempfiles(files...) do tempdir,  files
      cd(tempdir) do
          expected = Set([abspath(f) for f in files if ismatch(r"\.[Cc]$", f)])
          @test Set(abspath.(globber("**/*.[Cc]"))) == expected

          expected = Set([abspath(f) for f in files if ismatch(r"^f.*\.c$", f)])
          @test Set(abspath.(globber("f*/**/*.c"))) == expected
      end
    end

    # Check with complicated patterns.
    files = ["aaa/kjhasd.txt", "aaa/bbb/ioua.txt", "abc/ccc/ddd/foo.c",
             "xyz/ddd/eee/bar.java", "abc/ddd/eee/baz.c", "aaaa/quux.java",
             "abcc/ccc/ddd/foo.c", "bbb/ccccccc/ddddddd/e/hello.java",
             "bbb/iswadf/abs.txt", "ghsadfkjhasdf/kd/8wequ/wog.txt"]
    withtempfiles(files...) do tempdir, files

        data = [
            # pattern              # expected
            ("a??/*/[cd]*/**/*.c", ["abc/ccc/ddd/foo.c"]),
            ("[ab]*/**/*.java",    ["aaaa/quux.java",
                                    "bbb/ccccccc/ddddddd/e/hello.java"]),
            ("[^a]*/**/*.txt",     ["bbb/iswadf/abs.txt",
                                    "ghsadfkjhasdf/kd/8wequ/wog.txt"]),
        ]
         
        cd(tempdir) do
            for (pattern, expected) in data
                @test Set(globber(pattern)) == Set(expected)
            end
        end
    end
end

@testset "eglob" begin
    run_eglob_tests(eglob)
end

@testset "eglobt" begin
    run_eglob_tests(eglob)
end

{}: let
  withVersion = super: name: params:
    assert nixpkgs.lib.asserts.assertMsg (params ? version) "a version must be specified";
      super.${name}.overridePythonAttrs (oldAttrs: rec {
        inherit (oldAttrs) pname;
        inherit (params) version;

        src =
          if params ? url
          then
            builtins.fetchurl
            {
              inherit (params) url;
              sha256 = params.sha256 or "";
            }
          else
            super.fetchPypi {
              inherit (oldAttrs) pname;
              inherit (params) version;
              sha256 = params.sha256 or "";
            };

        pytestFlagsArray = (oldAttrs.pytestFlagsArray or []) ++ params.pytestFlagsArray;
        checkInputs = (oldAttrs.checkInputs or []) ++ params.checkInputs;
      });
in {
  overlays.default = final: prev: {
    # openjdk17_headless = with prev; openjdk17_headless.overrideAttrs (oldAttrs: rec {
    #   patches = (oldAttrs.patches or [ ]) ++ [
    #     (prev.writeTextFile {
    #       name = "0001-Fix-for-wsl2-detection.patch";
    #       text = ''
    #         From f064ffc3c80e9b65498283f4fdd7998d5aa2979f Mon Sep 17 00:00:00 2001
    #         From: James Sweet <james.sweet88@gmail.com>
    #         Date: Thu, 29 Sep 2022 16:07:09 -0400
    #         Subject: [PATCH] Fix for wsl2 detection

    #         ---
    #          make/autoconf/basic_windows.m4 | 7 ++++---
    #          1 file changed, 4 insertions(+), 3 deletions(-)

    #         diff --git a/make/autoconf/basic_windows.m4 b/make/autoconf/basic_windows.m4
    #         index a8686e45d89..37683184013 100644
    #         --- a/make/autoconf/basic_windows.m4
    #         +++ b/make/autoconf/basic_windows.m4
    #         @@ -34,9 +34,10 @@ AC_DEFUN([BASIC_SETUP_PATHS_WINDOWS],
    #                OPENJDK_BUILD_OS_ENV=windows.wsl1
    #              else
    #                # This test is not guaranteed, but there is no documented way of
    #         -      # distinguishing between WSL1 and WSL2. Assume only WSL2 has WSL_INTEROP
    #         -      # in /run/WSL
    #         -      if test -d "/run/WSL" ; then
    #         +      # distinguishing between WSL1 and WSL2.
    #         +      # Check whether "Hyper-V" appears in /proc/interrupts because WSL2 runs on Hyper-V.
    #         +      $GREP -q Hyper-V /proc/interrupts;
    #         +      if test $? -eq 0; then
    #                  OPENJDK_BUILD_OS_ENV=windows.wsl2
    #                else
    #                  OPENJDK_BUILD_OS_ENV=windows.wsl1
    #         --
    #         2.37.2
    #       '';
    #     })
    #   ];
    # });

    psl = with final;
      stdenv.mkDerivation rec {
        pname = "psl";
        version = "2.3.0";

        src = fetchgit {
          url = "https://github.com/linqs/${pname}";
          deepClone = true;
          rev = "5547e0ef49558d5eef0e7191010434ec34e98880";
          sha256 = "uLOxuR4iVyRWoDCr8aiB5YkZ/sGAmWzC+LHAuxtGOgI=";
        };

        maven-jdk8 = prev.maven.override {
          jdk = prev.jdk8;
        };

        # perform fake build to make a fixed-output derivation out of the files downloaded from maven central
        maven-deps = stdenv.mkDerivation {
          inherit src version;
          pname = "psl-deps";

          nativeBuildInputs = [curl cacert];
          buildInputs = [maven-jdk8];
          buildPhase = ''
            mvn -Dmaven.repo.local=$out de.qaware.maven:go-offline-maven-plugin:resolve-dependencies
            curl -O https://repo1.maven.org/maven2/org/apache/maven/surefire/surefire-junit4/2.19/surefire-junit4-2.19.jar
            mvn -Dmaven.repo.local=$out org.apache.maven.plugins:maven-install-plugin:2.5.2:install-file -Dfile=surefire-junit4-2.19.jar
          '';

          # keep only *.{pom,jar,sha1,nbm} and delete all ephemeral files with lastModified timestamps inside
          installPhase = ''
            find $out -type f \
              -name \*.lastUpdated -or \
              -name resolver-status.properties -or \
              -name _remote.repositories \
              -delete
          '';

          dontFixup = true;
          outputHashAlgo = "sha256";
          outputHashMode = "recursive";
          outputHash = "BpmmLWiFXwcmcdgOTljJruBBpfeaXY6uPgoHcsDoqD0="; #nixpkgs.lib.fakeSha256; #"EllBMTUpq3YlR2L8E3k+nv9WvYD4eAzEGy7N7hxghHA=";
        };

        depsBuildBuild = [xmlstarlet];
        buildInputs = [maven-jdk8 python39Packages.tensorflow];

        buildPhase = ''
          xmlstarlet edit --inplace -N pom=http://maven.apache.org/POM/4.0.0 --update "//pom:gitDescribe/pom:skip" --value "true" psl-core/pom.xml
          mvn -o -Dmaven.repo.local=${maven-deps} package -Dmaven.test.skip=true
        '';

        doCheck = true;
        checkPhase = ''
          mvn -o -Dmaven.repo.local=${maven-deps} '-Dtest=!%regex[.*(DataStore|Postgres).*],!%regex[.*(DCD|MPE|ADMM|SGD).*Inference.*],!%regex[.*Hyperband.*]' test
        '';

        installPhase = ''
          mvn -o -Dmaven.repo.local=$out install
        '';
      };

    pythonPackagesOverlays =
      (prev.pythonPackagesOverlays or [])
      ++ [
        (python-final: python-prev: {
          rdflib = withVersion python-prev "rdflib" {
            version = "6.2.0";
            sha256 = "Ytw8htFxLbD1V4W6+AR/Y3MfpZsmgr4DIZy4kmIGWUI=";
            pytestFlagsArray = [
              "--deselect=rdflib/extras/infixowl.py::rdflib.extras.infixowl"
              "--deselect=test/test_extras/test_infixowl/test_context.py::test_context"
              "--deselect=test/test_extras/test_infixowl/test_basic.py::test_infix_owl_example1"
              "--deselect=test/test_graph/test_graph.py::test_guess_format_for_parse"
              "--deselect=test/test_sparql/test_prepare.py::test_prepare_query"
            ];
            checkInputs = [python-prev.pytest-cov];
          };

          setuptools-scm = with final;
            callPackage setuptools-scm-7 {
              inherit (python-final) buildPythonPackage fetchPypi packaging typing-extensions tomli setuptools;
            };

          owlrl = with python-final;
            buildPythonPackage rec {
              pname = "owlrl";
              version = "6.0.2";

              src = fetchPypi {
                inherit pname version;
                sha256 = "kE4zEP9N8VEBR1d2aT0kJ9H4JE7ppqn54Tw8V/rpC3Q=";
              };

              checkInputs = [pytest];
              propagatedBuildInputs = [
                rdflib
              ];
            };

          jsonpath-python = with python-final;
            buildPythonPackage
            rec {
              pname = "jsonpath-python";
              version = "1.0.6";

              src = fetchPypi {
                inherit pname version;
                sha256 = "3Vvkpy2KKZXD9YPPgr880alUTP2r8tIllbZ6/wc0lmY=";
              };

              checkInputs = [pytest];
            };

          pyoxigraph = with python-final;
            buildPythonPackage
            rec {
              pname = "pyoxigraph";
              version = "0.3.5";

              src = final.fetchgit {
                url = "https://github.com/oxigraph/oxigraph.git";
                rev = "v" + version;
                fetchSubmodules = true;
                sha256 = "rtWeYxmgrEla6CKCtaEPCzgL8G20hO9YbOzPak+fVYo=";
              };

              buildAndTestSubdir = "./python/";

              cargoDeps = final.rustPlatform.fetchCargoTarball {
                inherit src;
                name = "${pname}-${version}";
                sha256 = "+DweLeloKjxSmpPuYgCLTGl8YKoP5l0UtZpmQrwcqao=";
              };

              LIBCLANG_PATH = "${final.libclang.lib}/lib";
              BINDGEN_EXTRA_CLANG_ARGS = "-isystem ${final.libclang.lib}/lib/clang/${final.lib.getVersion final.clang}/include";
              LLVM_CONFIG_PATH = "${final.llvm}/bin/llvm-config";

              nativeBuildInputs = with final.rustPlatform; [
                final.libclang
                cargoSetupHook
                maturinBuildHook
              ];

              format = "pyproject";
            };

          sql-metadata = with python-final;
            buildPythonPackage
            rec {
              pname = "sql_metadata";
              version = "2.6.0";

              src = fetchPypi {
                inherit pname version;
                sha256 = "IkJgNJe7zbblZciD33tI64XhlDmsq1QCag4rHK5rX+Y=";
              };

              checkInputs = [pytest];
              propagatedBuildInputs = [
                sqlparse
              ];
            };

          morph-kgc = with python-final;
            buildPythonPackage
            rec {
              pname = "morph-kgc";
              version = "2.2.0";

              src = final.fetchFromGitHub {
                owner = "oeg-upm";
                repo = pname;
                rev = version;
                sha256 = "h7MYXkD+VseRK62EtAoeQO+S+prhyQ6xpNgdHBlzPyE=";
              };

              checkInputs = [pytest];
              propagatedBuildInputs = [
                elementpath
                jsonpath-python
                pyoxigraph
                pandas
                rdflib
                falcon
                sqlalchemy
                sql-metadata
              ];
            };

          urlpath = with python-final;
            buildPythonPackage
            rec {
              pname = "urlpath";
              version = "1.2.0";

              src = final.fetchurl {
                url = "https://files.pythonhosted.org/packages/21/aa/e19a74232b82435d483aff27a37d411f1cbf3d478fc632180b7fe87a6396/urlpath-1.2.0.tar.gz";
                sha256 = "e54c0c82db4894a7217772150bdbc01413794576996e7834f81d67f22359c9d0";
              };

              checkInputs = [pytest];
              propagatedBuildInputs = [
                requests
              ];
            };

          rdflib-jsonld = with python-final;
            buildPythonPackage
            rec {
              pname = "rdflib-jsonld";
              version = "0.6.2";

              src = python-final.fetchPypi {
                inherit pname version;
                sha256 = "107cd3019d41354c31687e64af5e3fd3c3e3fa5052ce635f5ce595fd31853a63";
              };

              nativeBuildInputs = [nose];
              propagatedBuildInputs = [rdflib];

              meta = with final.lib; {
                homepage = "https://github.com/RDFLib/rdflib-jsonld";
                license = licenses.bsdOriginal;
                description = "rdflib extension adding JSON-LD parser and serializer";
                maintainers = [maintainers.koslambrou];
                # incomptiable with rdflib 6.0.0, half of the test suite fails with import and atrribute errors
                broken = false;
              };
            };

          language-tags = with python-final;
            buildPythonPackage
            rec {
              pname = "language_tags";
              version = "1.1.0";

              src = fetchPypi {
                inherit pname version;
                sha256 = "DJqCjuY7XMlIdml/TVhEmw5N6t2rM0+YOyom1peejU8=";
              };

              checkInputs = [nose];
              propagatedBuildInputs = [];
            };

          csvwlib = with python-final;
            buildPythonPackage
            rec {
              pname = "csvwlib";
              version = "0.3.2";

              src = fetchPypi {
                inherit pname version;
                sha256 = "0ymduGAXt58WTU4+nX3xRHtwo75WkBZPGevcSOYgz9s=";
              };

              propagatedBuildInputs = [uritemplate python-dateutil rdflib-jsonld language-tags requests];
            };

          chocolate = with python-final;
            buildPythonPackage
            rec {
              pname = "chocolate";
              version = "0.0.2";

              src = fetchPypi {
                inherit pname version;
                sha256 = "NHSvRH4RxZJjWvriV42PQlNRBFlJ3Bwv06mN2Fm1gWw=";
              };

              propagatedBuildInputs = [];
            };

          oxrdflib = with python-final;
            buildPythonPackage
            rec {
              pname = "oxrdflib";
              version = "0.3.2";

              src = fetchPypi {
                inherit pname version;
                sha256 = "MnN6iClYT57NDG7p867J+URUmwhooXSCqjMJZ2zA/iM=";
              };

              propagatedBuildInputs = [pyoxigraph rdflib];
            };

          prettytable = with python-final;
            buildPythonPackage
            rec {
              pname = "prettytable";
              version = "2.5.0";

              src = builtins.fetchGit {
                url = "https://github.com/jazzband/${pname}";
                ref = "refs/tags/${version}";
                rev = "e844aa0f8c1aee97a12ac7e2343897aa5b9ac6e5";
                allRefs = true;
              };

              patch =
                final.writeTextFile
                {
                  name = "0001-add-archival-information.patch";
                  text = ''
                    From 1c14fea24a454907f01073132eb157a5195283a0 Mon Sep 17 00:00:00 2001
                    From: James Sweet <james.sweet88@gmail.com>
                    Date: Tue, 27 Sep 2022 17:04:39 -0400
                    Subject: [PATCH] add archival information

                    ---
                    .git_archival.txt | 4 ++++
                    1 file changed, 4 insertions(+)
                    create mode 100644 .git_archival.txt

                    diff --git a/.git_archival.txt b/.git_archival.txt
                    new file mode 100644
                    index 0000000..e0c3e21
                    --- /dev/null
                    +++ b/.git_archival.txt
                    @@ -0,0 +1,4 @@
                    +node: e844aa0f8c1aee97a12ac7e2343897aa5b9ac6e5
                    +node-date: 2021-10-20T17:23:11+02:00
                    +describe-name: 2.5.0-0-g4060507
                    +ref-names: HEAD, tag: 2.5.1
                    --
                    2.37.2
                  '';
                };

              patches = [
                patch
              ];

              preBuild = ''
                ${python.interpreter} setup.py --version
              '';

              checkInputs = [pytest];
              nativeBuildInputs = [final.git setuptools-scm];
              propagatedBuildInputs = [setuptools wcwidth];
            };

          pyshacl = with python-final;
            buildPythonPackage
            rec {
              pname = "pyshacl";
              version = "0.20.0";
              format = "pyproject";

              src = fetchPypi {
                inherit pname version;
                sha256 = "R/AUxSzGkWe5AsibOUDdQA9/XSFppi+X+DfzQZtKc30=";
              };

              postBuild = ''
                python3 -m pip list
                ls -lah
              '';

              checkInputs = [pytest poetry];
              propagatedBuildInputs = [prettytable rdflib owlrl packaging];
            };

          hatch-vcs =
            python-prev.hatch-vcs.overrideAttrs
            (finalAttrs: previousAttrs: {
              patches =
                previousAttrs.patches
                or []
                ++ [
                  (final.writeTextFile
                    {
                      name = "0001-fix-for-setuptools-scm-v7.patch";
                      text = ''
                        From 216abe2371e527cdbf1966ac766990a6169004b3 Mon Sep 17 00:00:00 2001
                        From: James Sweet <james.sweet88@gmail.com>
                        Date: Wed, 28 Sep 2022 08:16:56 -0400
                        Subject: [PATCH] fix for setuptools-scm v7

                        ---
                         tests/test_build.py | 3 ++-
                         1 file changed, 2 insertions(+), 1 deletion(-)

                        diff --git a/tests/test_build.py b/tests/test_build.py
                        index 2d719a9..6b907ef 100644
                        --- a/tests/test_build.py
                        +++ b/tests/test_build.py
                        @@ -75,7 +75,8 @@ def test_write(new_project_write):
                             assert os.path.isfile(version_file)

                             lines = read_file(version_file).splitlines()
                        -    assert lines[3] == "version = '1.2.3'"
                        +    assert lines[3].startswith(('version =', '__version__ ='))
                        +    assert lines[3].endswith("version = '1.2.3'")


                         @pytest.mark.skipif(sys.version_info[0] == 2, reason='Depends on fix in 6.4.0 which is Python 3-only')
                        --
                        2.37.2
                      '';
                    })
                ];
            });

          kglab = with python-final;
            buildPythonPackage
            rec {
              pname = "kglab";
              version = "0.6.1";

              src = final.fetchFromGitHub {
                owner = "DerwenAI";
                repo = pname;
                rev = "v" + version;
                sha256 = "v8Q1IXvHRrM+ulUR3XAwDQimkIW6XYKinOiwkGU3RGM=";
              };

              checkInputs = [pytest];
              propagatedBuildInputs = [
                aiohttp
                chocolate
                cryptography
                csvwlib
                decorator
                fsspec
                gcsfs
                icecream
                morph-kgc
                networkx
                numpy
                owlrl
                oxrdflib
                pandas
                final.psl
                pyarrow
                pynvml
                pyshacl
                python-dateutil
                pyvis
                rdflib
                requests
                statsmodels
                tqdm
                urlpath
              ];
            };
        })
      ];

    python3 = let
      self =
        prev.python3.override
        {
          inherit self;
          packageOverrides = prev.lib.composeManyExtensions final.pythonPackagesOverlays;
        };
    in
      self;

    awk-kg = with final;
      python3.pkgs.buildPythonPackage
      rec {
        pname = "awk-kg";
        format = "pyproject";
        version = builtins.substring 0 8 self.lastModifiedDate;

        src = ./.;

        propagatedBuildInputs = with python3.pkgs; [
          kglab
          jupyter
        ];
      };
  };
}

{
  description = "A Nix-flake-based mbed development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";

  outputs =
    { self, ... }@inputs:

    let
      tool_chain = "GCC_ARM";
      target = "LPC1768";

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        inputs.nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import inputs.nixpkgs { inherit system; };

          }
        );
    in
    {
      packages = forEachSupportedSystem (
        { pkgs }:
        {
          mbed-tools = pkgs.python311Packages.buildPythonPackage rec {
            pname = "mbed-tools";
            version = "7.58.0";

            src = pkgs.fetchPypi {
              inherit pname version;
              sha256 = "sha256-tFMpKkb1z86eYboQxPGbhVLBrUzx5xOVwXCieeXYHB0==";
            };

            pyproject = true;

            build-system = with pkgs.python311Packages; [
              setuptools
              setuptools-scm
            ];

            propagatedBuildInputs = with pkgs.python311Packages; [
              click
              pyserial
              intelhex
              prettytable
              packaging
              cmsis-pack-manager
              python-dotenv
              gitpython
              tqdm
              tabulate
              requests
              jinja2
              setuptools
              future
            ];

            doCheck = false;

            meta = with pkgs.lib; {
              description = "Arm Mbed command line tools";
              homepage = "https://github.com/ARMmbed/mbed-tools";
              license = licenses.asl20;
            };
          };

          gcc-arm-embedded = pkgs.stdenv.mkDerivation {
            pname = "gcc-arm-embedded";
            version = "10.3";

            platform =
              {
                aarch64-darwin = "darwin-arm64";
                aarch64-linux = "aarch64";
                x86_64-linux = "x86_64";
              }
              .${pkgs.stdenv.hostPlatform.system}
                or (throw "Unsupported system: ${pkgs.stdenv.hostPlatform.system}");

            src = pkgs.fetchurl {
              url = "https://developer.arm.com/-/media/files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-mac.tar.bz2";
              sha256 =
                {
                  aarch64-darwin = "+2E9rLJRSfFA9z/p/2w4C7QzKOa/gTRzmG6RJ+K8KDs=";
                  aarch64-linux = "2d465847eb1d05f876270494f51034de9ace9abe87a4222d079f3360240184d3";
                  x86_64-linux = "8f6903f8ceb084d9227b9ef991490413014d991874a1e34074443c2a72b14dbd";
                }
                .${pkgs.stdenv.hostPlatform.system}
                  or (throw "Unsupported system: ${pkgs.stdenv.hostPlatform.system}");
            };

            dontConfigure = true;
            dontBuild = true;
            dontPatchELF = true;
            dontStrip = true;

            installPhase = ''
              mkdir -p $out
              cp -r * $out
              rm $out/bin/{arm-none-eabi-gdb-py,arm-none-eabi-gdb-add-index-py} || :
            '';

            preFixup = pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
              find $out -type f | while read f; do
                patchelf "$f" > /dev/null 2>&1 || continue
                patchelf --set-interpreter $(cat ${pkgs.stdenv.cc}/nix-support/dynamic-linker) "$f" || true
                patchelf --set-rpath ${
                  pkgs.lib.makeLibraryPath [
                    "$out"
                    pkgs.stdenv.cc.cc
                    pkgs.ncurses6
                    pkgs.libxcrypt-legacy
                    pkgs.xz
                    pkgs.zstd
                  ]
                } "$f" || true
              done
            '';

            meta = with pkgs.lib; {
              description = "Pre-built GNU toolchain from ARM Cortex-M & Cortex-R processors";
              homepage = "https://developer.arm.com/open-source/gnu-toolchain/gnu-rm";
              license = with licenses; [
                bsd2
                gpl2
                gpl3
                lgpl21
                lgpl3
                mit
              ];
              platforms = [
                "x86_64-linux"
                "aarch64-linux"
                "aarch64-darwin"
              ];
            };
          };
        }
      );

      devShells = forEachSupportedSystem (
        { pkgs }:
        let
          # Get the actual package reference
          arm-gcc = self.packages.${pkgs.system}.gcc-arm-embedded;

          # Correctly locate the C++ headers inside the Nix store package
          # For GCC 10.3, the path is usually arm-none-eabi/include/c++/10.3.1
          cppHeaders = "${arm-gcc}/arm-none-eabi/include/c++/10.3.1";

          clangdConfig = pkgs.writeText "clangd-config" ''
            CompileFlags:
              Add:
                - "--target=arm-none-eabi"
                - "-isystem"
                - "${cppHeaders}"
                - "-isystem"
                - "${cppHeaders}/arm-none-eabi"
                - "-isystem"
                - "${arm-gcc}/arm-none-eabi/include"
                - "-D__GNUC__=12"
                - "-D__ARM_EABI__"
                - "-Wno-unknown-attributes"
              CompilationDatabase: "."

            Index:
              StandardLibrary: Yes
          '';

          # Correct the query-driver path for the shell variable
          # This tells clangd it can execute the compiler to check its own paths
          queryDriver = "${arm-gcc}/bin/arm-none-eabi-gcc";

          # Define a helper script to "initialize" the project
          initProject = pkgs.writeShellScriptBin "mbed-setup" ''
            echo "configuring and building"
            mbed-tools configure -t ${tool_chain} -m ${target}

            cmake -S . -B cmake_build/${target}/develop/${tool_chain} -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -GNinja

            echo "Setting up project symlinks..."
            ln -sf ${clangdConfig} .clangd

            if [ -d "cmake_build" ]; then
              # Find the first compile_commands.json in the build tree
              JSON_PATH=$(find cmake_build -name compile_commands.json | head -n 1)
              if [ -n "$JSON_PATH" ]; then
                ln -sf "$JSON_PATH" compile_commands.json
                echo "✅ Linked compile_commands.json"
              fi
            fi
            echo "✅ .clangd file created"
          '';

          build_command = pkgs.writeShellScriptBin "build" ''
            mbed-tools compile -t ${tool_chain} -m ${target}
          '';

          flash_command = pkgs.writeShellScriptBin "flash" ''
            mbed-tools compile -t ${tool_chain} -m ${target} -f
          '';
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              (pkgs.python311.withPackages (
                ps: with ps; [
                  future
                  ninja
                  prettytable
                  intelhex
                  pip
                ]
              ))

              clang-tools

              build_command
              flash_command

              self.packages.${pkgs.system}.mbed-tools
              self.packages.${pkgs.system}.gcc-arm-embedded

              initProject
            ];

            shellHook = ''
              export CLANGD_FLAGS="--query-driver=${arm-gcc}/bin/arm-none-eabi-*"

              mbed-setup
            '';
          };
        }
      );
    };
}

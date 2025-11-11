# Z80 assembler helper for this workspace

A lightweight helper and VS Code task to assemble a single Z80 `.asm` file into a `.bin` next to the source file.

What this workspace contains
- `.vscode/tasks.json` — a Build task named "Assemble Z80" that runs the PowerShell helper on the active editor file.
- `tools/assemble.ps1` — PowerShell helper that finds a supported assembler and invokes it to produce a binary output beside the `.asm`.

Supported assemblers (checked in this order)
1. sjasmplus (featureful; recommended)
2. pasmo
3. z80asm

How the helper chooses an assembler
- First it checks environment variables (full path allowed): `SJASMPLUS`, `PASMO`, `Z80ASM`.
- If none set, it looks for `sjasmplus.exe`, `pasmo.exe`, or `z80asm.exe` in `tools/` then in the system PATH.
- Once found, it runs the assembler with sensible defaults to create `yourfile.bin` in the same folder as `yourfile.asm`.

Environment variables and flags
- SJASMPLUS, PASMO, Z80ASM — point to a specific assembler executable (full path or just the exe name).
- ASFLAGS — optional. If present, its contents are appended to the assembler command line (useful for adding custom assembler flags).

Usage (VS Code)
1. Open any `.asm` file from the workspace (for example `projects/helloworld/helloworld.asm`).
2. Run the task: Run Task -> "Assemble Z80" (or press Ctrl+Shift+B if prompted).
3. The script will choose an assembler and produce `helloworld.bin` next to the `.asm`.

Manual invocation (PowerShell)
Run the helper directly to see detailed output:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\assemble.ps1 .\projects\helloworld\helloworld.asm
```
You can set environment variables inline if needed:
```powershell
$env:SJASMPLUS = "C:\tools\sjasmplus.exe"
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\assemble.ps1 .\projects\helloworld\helloworld.asm
```

Troubleshooting
- If the task fails, ensure an assembler binary is in `tools/` or available on PATH.
- Run the helper manually (see above) to view its detection and invocation messages.
- If you need special assembler flags or produce listings/map files, set `ASFLAGS` or edit `tools/assemble.ps1` to add an assembler-specific branch with your preferred flags.

Getting an assembler on Windows
- Recommended: sjasmplus — https://github.com/z00m128/sjasmplus — download the Windows release and put `sjasmplus.exe` into `tools/` or add it to PATH.
- Alternative: pasmo — https://github.com/michaliskambi/pasmo
- Other: z80asm — check usage and available builds.

Next steps (optional)
- Add a small script to download sjasmplus releases into `tools/`.
- Extend tasks.json with assembler-specific tasks that produce listings, map files or different outputs.
- Add problem matchers for assembler error parsing.

License / notes
- The helper aims to be minimal and editable — edit `tools/assemble.ps1` to tweak flags, outputs, or support other assemblers.

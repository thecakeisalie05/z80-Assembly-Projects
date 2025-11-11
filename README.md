# Z80 assembler integration for this workspace

This workspace includes a small VS Code task and a PowerShell helper to run a Z80 assembler on the current `.asm` file.

What was added
- `.vscode/tasks.json` — a Build task called "Assemble Z80" that runs the helper on the current file.
- `tools/assemble.ps1` — PowerShell script that finds an assembler (sjasmplus, pasmo, or z80asm) and runs it to produce a `.bin` file next to the input.

How to get a Z80 assembler (Windows)
1. Recommended: sjasmplus (featureful, common for ZX Spectrum dev).
   - Project: https://github.com/z00m128/sjasmplus
   - Download the Windows release and put `sjasmplus.exe` into the `tools` folder of this repo (create it if missing), or add it to your PATH.
2. Simpler alternative: pasmo (small raw binary assembler).
   - Project: https://github.com/michaliskambi/pasmo (or search for Pasmo builds)
3. Other: z80asm (check its usage and available builds).

You can also set environment variables to point directly to an executable:
- `SJASMPLUS` -> full path to sjasmplus.exe
- `PASMO` -> full path to pasmo.exe
- `Z80ASM` -> full path to z80asm.exe

Usage
1. Put your `.asm` file anywhere in the workspace (for example `projects/helloworld/helloworld.asm`).
2. In VS Code open the file and run the task: Run Task -> "Assemble Z80" (or press Ctrl+Shift+B if prompted).
3. The helper will attempt to find an assembler and produce `helloworld.bin` in the same folder as the `.asm`.

If the task fails
- Make sure you have an assembler binary in `tools/` or installed in PATH.
- Run the helper manually from PowerShell to see more messages:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\assemble.ps1 .\projects\helloworld\helloworld.asm
```

Custom arguments
- The helper currently chooses sensible defaults. If you need custom assembler flags, you can edit `tools/assemble.ps1` and add a branch for your assembler with the desired flags.

Next steps (optional)
- Add a convenience download script to fetch sjasmplus releases automatically.
- Add problem matchers or assembler-specific task variants to produce listings and map files.

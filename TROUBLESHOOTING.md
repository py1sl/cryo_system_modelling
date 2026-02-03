# Troubleshooting OpenModelica Package Loading

## Error: "expected package to have within ; but got within CryoSystem"

This error typically occurs when trying to load a file in the wrong way.

### ❌ INCORRECT: Loading LiquidHydrogenSystem.mo directly
```bash
# DON'T DO THIS:
loadFile("CryoSystem/LiquidHydrogenSystem.mo")
```

### ✅ CORRECT: Load the package.mo file
```bash
# DO THIS INSTEAD:
loadFile("CryoSystem/package.mo")
```

The package.mo file is the entry point that tells OpenModelica about the package structure.

## Error: "redefining classes"

This error can occur due to:

### 1. OpenModelica Cache Issue
**Solution:** Clear the OpenModelica cache and restart OMEdit

On Linux/Mac:
```bash
rm -rf ~/.openmodelica/
```

On Windows:
```bash
rmdir /s %APPDATA%\.openmodelica
```

### 2. Multiple loadFile() calls
**Solution:** Only load the package once per session

```modelica
// In omc console or script:
loadFile("CryoSystem/package.mo");  // Load once
checkModel(CryoSystem.LiquidHydrogenSystem);  // Then use it
```

### 3. Conflicting Model Paths
**Solution:** Make sure you're in the correct directory

```bash
# Navigate to the repository root
cd /path/to/cryo_system_modelling

# Then load
omc run_simulation.mos
```

## How to Load the Model Correctly

### Method 1: Using OMEdit (GUI)
1. **File → Open Model/Library File**
2. Navigate to and select `CryoSystem/package.mo` (NOT LiquidHydrogenSystem.mo)
3. In the Libraries Browser, expand `CryoSystem`
4. Double-click `LiquidHydrogenSystem`
5. Click the "Simulate" button

### Method 2: Using omc (Command Line)
```bash
omc run_simulation.mos
```

### Method 3: Using omc Interactive
```bash
omc
> cd("/path/to/cryo_system_modelling")
> loadFile("CryoSystem/package.mo")
> checkModel(CryoSystem.LiquidHydrogenSystem)
> simulate(CryoSystem.LiquidHydrogenSystem)
> plot({T_coldBox, T_moderator})
> quit()
```

## Verifying Package Structure

The package structure is:
```
CryoSystem/
├── package.mo              ← Entry point (has "within ;")
├── package.order           ← Lists: Components, LiquidHydrogenSystem
├── LiquidHydrogenSystem.mo ← Has "within CryoSystem;"
└── Components/
    ├── package.mo          ← Has "within CryoSystem;"
    ├── package.order       ← Lists all components
    └── *.mo files          ← Each has "within CryoSystem.Components;"
```

You can verify with:
```bash
# Check top-level package (should show "within ;")
head -1 CryoSystem/package.mo

# Check model (should show "within CryoSystem;")
head -1 CryoSystem/LiquidHydrogenSystem.mo

# Check sub-package (should show "within CryoSystem;")
head -1 CryoSystem/Components/package.mo

# Check component (should show "within CryoSystem.Components;")
head -1 CryoSystem/Components/ColdBox.mo
```

## Still Having Issues?

1. Make sure you have OpenModelica v1.19.0 or later installed
2. Try creating a fresh workspace in OMEdit
3. Check that no other Modelica files are in your MODELICAPATH
4. Verify package.order files are present and correctly formatted

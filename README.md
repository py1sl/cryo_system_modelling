# cryo_system_modelling

OpenModelica model of a liquid hydrogen cryogenic system for an accelerator facility.

## Overview

This repository contains an OpenModelica model of a liquid hydrogen cooling system where hydrogen is cooled to liquid temperatures in a cold box, passes through a catalyst vessel for ortho-para conversion, flows through transfer lines to a moderator vessel, and returns to the cold box. The system includes:

- **Cold Box**: Cools hydrogen to ~20K with PID temperature control
- **Catalyst Vessel**: Converts ortho-hydrogen to para-hydrogen using a catalyst (iron oxide, chromium oxide, or nickel)
- **Moderator Vessel**: Receives heat load from particle beam
- **Transfer Lines**: Transport hydrogen with thermal losses
- **PID Controller**: Maintains target temperature

## Quick Start

1. Install OpenModelica: https://openmodelica.org/download/
2. Open the model in OMEdit:
   ```bash
   OMEdit CryoSystem/package.mo
   ```
   **Important:** Always load `CryoSystem/package.mo` (the package entry point), not `LiquidHydrogenSystem.mo` directly.
3. In OMEdit's Libraries Browser, expand `CryoSystem` and double-click `LiquidHydrogenSystem`
4. Click the "Simulate" button

See [MODEL_DOCUMENTATION.md](MODEL_DOCUMENTATION.md) for detailed documentation.

**Having loading issues?** See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common solutions.

## System Behavior

- **0-1000s**: Beam OFF - System cools from ambient to 20K, catalyst converts ortho to para hydrogen
- **1000-1200s**: Beam ramps up - Heat load gradually increases from 0 to 2000W
- **1200s+**: Beam at variable power - Operates at ~2000W with 10% fluctuations simulating realistic beam variations

## Key Outputs

- `T_coldBox`: Cold box temperature
- `T_catalyst`: Catalyst vessel temperature
- `T_moderator`: Moderator vessel temperature  
- `T_supplyLine`: Supply line temperature
- `T_returnLine`: Return line temperature
- `controlSignal`: PID controller output
- `currentBeamPower`: Time-varying beam heat load
- `orthoFraction_catalyst`: Ortho-hydrogen fraction after catalyst
- `paraFraction_catalyst`: Para-hydrogen fraction after catalyst
- `orthoFraction_moderator`: Ortho-hydrogen fraction in moderator
- `paraFraction_moderator`: Para-hydrogen fraction in moderator

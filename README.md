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
3. Navigate to `CryoSystem.LiquidHydrogenSystem` and simulate

See [MODEL_DOCUMENTATION.md](MODEL_DOCUMENTATION.md) for detailed documentation.

## System Behavior

- **0-1000s**: Beam OFF - System cools from ambient to 20K, catalyst converts ortho to para hydrogen
- **1000s+**: Beam ON - Heat load applied, PID compensates, back-conversion occurs

## Key Outputs

- `T_coldBox`: Cold box temperature
- `T_catalyst`: Catalyst vessel temperature
- `T_moderator`: Moderator vessel temperature  
- `T_supplyLine`: Supply line temperature
- `T_returnLine`: Return line temperature
- `controlSignal`: PID controller output
- `orthoFraction_catalyst`: Ortho-hydrogen fraction after catalyst
- `paraFraction_catalyst`: Para-hydrogen fraction after catalyst
- `orthoFraction_moderator`: Ortho-hydrogen fraction in moderator
- `paraFraction_moderator`: Para-hydrogen fraction in moderator

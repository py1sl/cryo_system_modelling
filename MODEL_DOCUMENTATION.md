# Liquid Hydrogen Cryogenic System Model

## Overview
This OpenModelica model simulates a liquid hydrogen cooling system for an accelerator facility with ortho-para hydrogen conversion. The system consists of:

1. **Cold Box** - Cools hydrogen to liquid temperatures (~20K)
2. **Catalyst Vessel** - Converts ortho-hydrogen to para-hydrogen using a catalyst
3. **Supply Transfer Line** - Transports cold hydrogen to the moderator
4. **Moderator Vessel** - Contains hydrogen that absorbs beam heat load
5. **Return Transfer Line** - Returns warmed hydrogen to cold box
6. **PID Controller** - Maintains cold box temperature at target setpoint

## Model Structure

```
CryoSystem/
├── package.mo                    # Main package definition
├── package.order                 # Package loading order
├── LiquidHydrogenSystem.mo      # Complete system model
└── Components/                   # Component models
    ├── package.mo
    ├── package.order
    ├── ColdBox.mo               # Cold box with cooling
    ├── CatalystVessel.mo        # Catalyst for ortho-para conversion
    ├── ModeratorVessel.mo       # Moderator with beam heat
    ├── TransferLine.mo          # Transfer line with heat leak
    └── PIDController.mo         # PID temperature controller
```

## Ortho-Para Hydrogen Conversion

### Physical Background
Hydrogen exists in two nuclear spin isomers:
- **Ortho-hydrogen**: Parallel nuclear spins (higher energy state)
- **Para-hydrogen**: Anti-parallel nuclear spins (lower energy state)

At room temperature (300K), hydrogen exists in equilibrium as approximately 75% ortho and 25% para. At cryogenic temperatures (~20K), the equilibrium shifts dramatically to nearly 100% para-hydrogen.

### Why Conversion Matters
1. **Slow Natural Conversion**: Without a catalyst, the conversion from ortho to para takes days or months
2. **Heat Release**: Ortho-to-para conversion is exothermic, releasing 527 kJ/kg
3. **Storage Issues**: Unconverted ortho-hydrogen slowly converts in storage, causing boil-off
4. **System Efficiency**: Pre-converting to para-hydrogen in a controlled manner improves system efficiency

### Catalyst Types
The model supports three catalyst types:
- **Iron oxide (Fe₂O₃)**: Reference catalyst (effectiveness = 1.0)
- **Chromium oxide (Cr₂O₃)**: High efficiency catalyst (effectiveness = 1.2)
- **Nickel (Ni)**: Moderate efficiency catalyst (effectiveness = 0.8)

### Back-Conversion
Para-hydrogen can convert back to ortho-hydrogen due to:
- **Temperature increase**: Higher temperatures thermally activate back-conversion
- **Surface interactions**: Pipe walls and vessel surfaces catalyze back-conversion
- **Beam heating**: Energy deposition in moderator promotes back-conversion

The model tracks these effects in:
- Transfer lines (wall interactions)
- Moderator vessel (wall interactions + beam heating)

## System Operation

### Initial Phase (0-1000s)
- Beam is OFF
- System cools hydrogen from ambient temperature (~300K) to target temperature (20K)
- Catalyst converts ortho-hydrogen to para-hydrogen
- Conversion heat is removed by cryogenic system
- PID controller adjusts cooling power to reach and maintain setpoint

### Operating Phase (1000s+)
- Beam turns ON
- Beam deposits heat load (2000W) into moderator vessel
- Moderator temperature rises
- Back-conversion increases due to higher temperature
- Warm hydrogen returns to cold box
- PID controller increases cooling power to compensate
- System reaches new steady state

## Key Parameters

### Cold Box
- Mass: 100 kg
- Cooling power: 5000 W
- Target temperature: 20 K

### Catalyst Vessel
- Mass: 20 kg (hydrogen)
- Catalyst mass: 5 kg (configurable)
- Catalyst type: iron_oxide (configurable)
- Conversion heat: 527 kJ/kg
- Heat leak: 10 W

### Moderator Vessel
- Mass: 50 kg
- Beam heat load: 2000 W

### Transfer Lines
- Length: 10 m each
- Heat leak: 5 W/m

### PID Controller
- Kp: 100 (Proportional gain)
- Ki: 10 (Integral gain)
- Kd: 5 (Derivative gain)

## Running the Model

### Using OpenModelica GUI (OMEdit)
1. Open OMEdit
2. File → Open Model/Library File
3. Navigate to `CryoSystem/package.mo`
4. Browse to `CryoSystem.LiquidHydrogenSystem`
5. Click "Simulate"
6. Plot the following variables:
   - `T_coldBox` - Cold box temperature
   - `T_catalyst` - Catalyst vessel temperature
   - `T_moderator` - Moderator vessel temperature
   - `T_supplyLine` - Supply line temperature
   - `T_returnLine` - Return line temperature
   - `controlSignal` - PID control output
   - `orthoFraction_catalyst` - Ortho fraction after catalyst
   - `paraFraction_catalyst` - Para fraction after catalyst
   - `orthoFraction_moderator` - Ortho fraction in moderator
   - `paraFraction_moderator` - Para fraction in moderator

### Using OpenModelica Compiler (omc)
```bash
omc
> loadFile("CryoSystem/package.mo")
> simulate(CryoSystem.LiquidHydrogenSystem, stopTime=2000)
> plot({T_coldBox, T_catalyst, T_moderator})
> plot({orthoFraction_catalyst, paraFraction_catalyst})
```

### Using OMPython
```python
from OMPython import OMCSessionZMQ

omc = OMCSessionZMQ()
omc.sendExpression("loadFile(\"CryoSystem/package.mo\")")
omc.sendExpression("simulate(CryoSystem.LiquidHydrogenSystem, stopTime=2000)")
```

## Expected Results

### Temperature Profiles
- **Cold Box**: Starts at ~300K, cools to 20K, slight increase when beam turns on
- **Catalyst Vessel**: Follows cold box, may be slightly warmer due to conversion heat
- **Moderator**: Starts at 20K, rises significantly when beam turns on
- **Supply Line**: Close to catalyst temperature with slight heat leak
- **Return Line**: Close to moderator temperature with slight heat leak

### Ortho-Para Conversion
- **Initial State**: System starts at ~75% ortho (room temperature equilibrium)
- **After Catalyst**: Ortho fraction drops significantly (target: <5% at steady state)
- **In Moderator**: Para fraction slightly decreases due to back-conversion
- **Beam Effect**: When beam turns on, back-conversion increases with temperature

### Control Signal
- Initially high (1.0) during cool-down
- Decreases as target temperature is reached
- Must compensate for catalyst conversion heat
- Increases when beam turns on to provide additional cooling

## Model Validation

The model includes:
- ✅ Energy balance equations for all components
- ✅ Mass flow conservation through the system
- ✅ Ortho-para conversion kinetics with catalyst
- ✅ Back-conversion due to temperature and surface effects
- ✅ Heat of conversion (527 kJ/kg for ortho-to-para)
- ✅ PID controller with anti-windup (output saturation)
- ✅ Heat leak in transfer lines
- ✅ Beam on/off switching logic
- ✅ Proper initial conditions

## Customization

### Changing Parameters
Edit the component instantiation in `LiquidHydrogenSystem.mo`:

```modelica
Components.ColdBox coldBox(
  T_setpoint=20,      // Target temperature
  mass=100,           // Hydrogen mass
  coolingPower=5000   // Maximum cooling power
);

Components.CatalystVessel catalystVessel(
  catalystType="iron_oxide",  // Options: iron_oxide, chromium_oxide, nickel
  catalystMass=5,             // Catalyst mass affects conversion rate
  mass=20                     // Hydrogen mass in vessel
);
```

### Changing Catalyst Type
Three catalyst types are available with different effectiveness:
- `"iron_oxide"`: Effectiveness = 1.0 (reference)
- `"chromium_oxide"`: Effectiveness = 1.2 (20% faster conversion)
- `"nickel"`: Effectiveness = 0.8 (slower conversion)

### Changing Beam Schedule
Modify the equation in `LiquidHydrogenSystem.mo`:

```modelica
if time < 1000 then
  beamStatus = 0;  // Change 1000 to desired beam-on time
else
  beamStatus = 1;
end if;
```

## Physical Properties

### Liquid Hydrogen Properties (at 20K)
- Specific heat capacity: 14,300 J/(kg·K)
- Density: ~71 kg/m³
- Boiling point: 20.28 K (at 1 atm)

## Notes

- The model uses simplified thermal dynamics
- Heat transfer is modeled using lumped capacitance
- Transfer lines include thermal mass and heat leak
- PID controller is tuned for stability around 20K setpoint
- All temperatures are in Kelvin
- All powers are in Watts
- Time is in seconds

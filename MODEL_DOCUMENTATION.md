# Liquid Hydrogen Cryogenic System Model

## Overview
This OpenModelica model simulates a liquid hydrogen cooling system for an accelerator facility. The system consists of:

1. **Cold Box** - Cools hydrogen to liquid temperatures (~20K)
2. **Supply Transfer Line** - Transports cold hydrogen to the moderator
3. **Moderator Vessel** - Contains hydrogen that absorbs beam heat load
4. **Return Transfer Line** - Returns warmed hydrogen to cold box
5. **PID Controller** - Maintains cold box temperature at target setpoint

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
    ├── ModeratorVessel.mo       # Moderator with beam heat
    ├── TransferLine.mo          # Transfer line with heat leak
    └── PIDController.mo         # PID temperature controller
```

## System Operation

### Initial Phase (0-1000s)
- Beam is OFF
- System cools hydrogen from ambient temperature (~300K) to target temperature (20K)
- PID controller adjusts cooling power to reach and maintain setpoint

### Operating Phase (1000s+)
- Beam turns ON
- Beam deposits heat load (2000W) into moderator vessel
- Moderator temperature rises
- Warm hydrogen returns to cold box
- PID controller increases cooling power to compensate
- System reaches new steady state

## Key Parameters

### Cold Box
- Mass: 100 kg
- Cooling power: 5000 W
- Target temperature: 20 K

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
   - `T_moderator` - Moderator vessel temperature
   - `T_supplyLine` - Supply line temperature
   - `T_returnLine` - Return line temperature
   - `controlSignal` - PID control output

### Using OpenModelica Compiler (omc)
```bash
omc
> loadFile("CryoSystem/package.mo")
> simulate(CryoSystem.LiquidHydrogenSystem, stopTime=2000)
> plot({T_coldBox, T_moderator})
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
- **Moderator**: Starts at 20K, rises significantly when beam turns on
- **Supply Line**: Close to cold box temperature with slight heat leak
- **Return Line**: Close to moderator temperature with slight heat leak

### Control Signal
- Initially high (1.0) during cool-down
- Decreases as target temperature is reached
- Increases when beam turns on to provide additional cooling

## Model Validation

The model includes:
- ✅ Energy balance equations for all components
- ✅ Mass flow conservation through the system
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
```

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

# System Diagram

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                  LIQUID HYDROGEN CRYOGENIC SYSTEM                         ║
╚═══════════════════════════════════════════════════════════════════════════╝

                    ┌─────────────────────────────┐
                    │     PID CONTROLLER          │
                    │   Target: 20K               │
                    │   Kp=100, Ki=10, Kd=5      │
                    └──────────┬──────────────────┘
                               │ control signal (0-1)
                               ↓
    ┌───────────────────────────────────────────────────────┐
    │                    COLD BOX                           │
    │  • Cools hydrogen to liquid temp (~20K)              │
    │  • Mass: 100 kg                                      │
    │  • Max cooling power: 5000 W                         │
    │  • Temperature sensor → PID                          │
    └───────┬───────────────────────────────────────────────┘
            │ T_out ≈ 20K
            │ mass flow: 0.1 kg/s
            ↓
    ┌───────────────────────────────────────────────────────┐
    │              SUPPLY TRANSFER LINE                     │
    │  • Length: 10 m                                      │
    │  • Heat leak: 5 W/m (50 W total)                     │
    │  • Slight temperature rise                           │
    └───────┬───────────────────────────────────────────────┘
            │ T ≈ 20-21K
            │ mass flow: 0.1 kg/s
            ↓
    ┌───────────────────────────────────────────────────────┐
    │              MODERATOR VESSEL                         │
    │  • Mass: 50 kg                                       │
    │  • Beam heat load: 2000 W (when ON)                  │
    │  • Beam OFF: 0-1000s                                 │
    │  • Beam ON:  1000s+                                  │
    └───────┬───────────────────────────────────────────────┘
            │ T increases when beam ON
            │ mass flow: 0.1 kg/s
            ↓
    ┌───────────────────────────────────────────────────────┐
    │              RETURN TRANSFER LINE                     │
    │  • Length: 10 m                                      │
    │  • Heat leak: 5 W/m (50 W total)                     │
    │  • Returns warm H2 to cold box                       │
    └───────┬───────────────────────────────────────────────┘
            │ T ≈ moderator temp + heat leak
            │ mass flow: 0.1 kg/s
            └──────────────────┐
                               │ (loops back to Cold Box)
                               ↑

═══════════════════════════════════════════════════════════════════════════

TEMPERATURE PROFILE TIMELINE:

Cold Box Temperature:
  300 K ┤                                                   
        │ ╲                                                
        │  ╲ Cooling down                        
        │   ╲                                             
  150 K ┤    ╲                                            
        │     ╲                                           
        │      ╲                                          
        │       ╲_______________                          
   20 K ┤                       ╲___/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾    
        │                          (slight rise when beam ON)
        └────────────────────────────────────────────────
        0 s                    1000 s                   2000 s

Moderator Temperature:
   50 K ┤                                                   
        │                                                
        │                           ____/‾‾‾‾‾‾‾‾‾‾‾‾‾                     
   40 K ┤                       ___/                          
        │                      /                          
   30 K ┤                     / Beam turns ON             
        │____________________/                            
   20 K ┤                                                  
        └────────────────────────────────────────────────
        0 s                    1000 s                   2000 s

═══════════════════════════════════════════════════════════════════════════

KEY VARIABLES:
  • T_coldBox      - Temperature of cold box (K)
  • T_moderator    - Temperature of moderator vessel (K)
  • T_supplyLine   - Temperature of supply line (K)
  • T_returnLine   - Temperature of return line (K)
  • controlSignal  - PID output: 0 (no cooling) to 1 (max cooling)
  • beamStatus     - Beam status: 0 (OFF) or 1 (ON)

═══════════════════════════════════════════════════════════════════════════

PHYSICAL PROPERTIES (Liquid Hydrogen at 20K):
  • Specific heat capacity: 14,300 J/(kg·K)
  • Density: ~71 kg/m³
  • Boiling point: 20.28 K @ 1 atm
  • Latent heat: 446 kJ/kg

═══════════════════════════════════════════════════════════════════════════
```

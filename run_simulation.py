#!/usr/bin/env python3
"""
Example simulation script for the Liquid Hydrogen System
This script demonstrates how to run the model using OMPython
"""

import sys

try:
    from OMPython import OMCSessionZMQ
except ImportError:
    print("ERROR: OMPython not installed")
    print("Install with: pip install OMPython")
    sys.exit(1)

def main():
    """Run the liquid hydrogen system simulation"""
    print("=" * 70)
    print("Liquid Hydrogen Cryogenic System Simulation")
    print("=" * 70)
    
    # Create OpenModelica session
    print("\n1. Starting OpenModelica session...")
    omc = OMCSessionZMQ()
    
    # Load the model
    print("2. Loading CryoSystem package...")
    result = omc.sendExpression('loadFile("CryoSystem/package.mo")')
    if not result:
        print("   ERROR: Failed to load model")
        return 1
    print("   ✅ Model loaded successfully")
    
    # Check the model
    print("3. Checking model...")
    check_result = omc.sendExpression('checkModel(CryoSystem.LiquidHydrogenSystem)')
    print(f"   Check result: {check_result}")
    
    # Simulate the model
    print("4. Running simulation (this may take a minute)...")
    sim_result = omc.sendExpression('''
        simulate(
            CryoSystem.LiquidHydrogenSystem,
            startTime=0,
            stopTime=2000,
            numberOfIntervals=2000,
            tolerance=1e-6
        )
    ''')
    
    if 'resultFile' in str(sim_result):
        print("   ✅ Simulation completed successfully")
        print(f"   Result: {sim_result}")
    else:
        print("   ⚠️  Simulation completed with messages:")
        print(f"   {sim_result}")
    
    # Plot results
    print("5. Generating plots...")
    try:
        omc.sendExpression('''
            plotAll(
                title="Liquid Hydrogen System Temperatures",
                legend=true
            )
        ''')
        print("   ✅ Plots generated")
    except Exception as e:
        print(f"   Note: Plotting may require GUI: {e}")
    
    # Get some results
    print("\n6. Extracting key results...")
    try:
        # Get final temperatures
        t_coldbox_final = omc.sendExpression('val(T_coldBox, 2000)')
        t_moderator_final = omc.sendExpression('val(T_moderator, 2000)')
        
        print(f"   Final Cold Box Temperature: {t_coldbox_final} K")
        print(f"   Final Moderator Temperature: {t_moderator_final} K")
    except Exception as e:
        print(f"   Note: Could not extract values: {e}")
    
    print("\n" + "=" * 70)
    print("Simulation complete!")
    print("Check the result files in the current directory")
    print("=" * 70)
    
    return 0

if __name__ == '__main__':
    exit(main())

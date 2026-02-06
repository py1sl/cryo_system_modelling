within CryoSystem;
model LiquidHydrogenSystem "Complete Liquid Hydrogen Cryogenic System"
  // Import components
  Components.ColdBox coldBox(T_setpoint=20) annotation(Placement(transformation(extent={{-80,-10},{-60,10}})));
  Components.CatalystVessel catalystVessel(catalystType="iron_oxide", catalystMass=5) annotation(Placement(transformation(extent={{-40,-10},{-20,10}})));
  Components.TransferLine supplyLine(length=10) annotation(Placement(transformation(extent={{0,-10},{20,10}})));
  Components.ModeratorVessel moderatorVessel annotation(Placement(transformation(extent={{40,-10},{60,10}})));
  Components.TransferLine returnLine(length=10) annotation(Placement(transformation(extent={{80,-10},{100,10}})));
  Components.PIDController pidController(T_setpoint=20, Kp=100, Ki=10, Kd=5) annotation(Placement(transformation(extent={{-100,20},{-80,40}})));
  
  // System variables
  Real beamStatus(start=0) "Beam status: 0=off, 1=on";
  
  // Output variables for monitoring
  Real T_coldBox "Temperature of cold box (K)";
  Real T_catalyst "Temperature of catalyst vessel (K)";
  Real T_moderator "Temperature of moderator vessel (K)";
  Real T_supplyLine "Temperature of supply line (K)";
  Real T_returnLine "Temperature of return line (K)";
  Real controlSignal "PID control signal";
  
  // Ortho-para fraction monitoring
  Real orthoFraction_coldBox "Ortho fraction at cold box";
  Real paraFraction_coldBox "Para fraction at cold box";
  Real orthoFraction_catalyst "Ortho fraction after catalyst";
  Real paraFraction_catalyst "Para fraction after catalyst";
  Real orthoFraction_moderator "Ortho fraction at moderator";
  Real paraFraction_moderator "Para fraction at moderator";
  
equation
  // Beam control logic - beam turns on after 1000 seconds
  if time < 1000 then
    beamStatus = 0;
  else
    beamStatus = 1;
  end if;
  
  // Connect cold box to catalyst vessel
  catalystVessel.T_in = coldBox.T_out;
  catalystVessel.massFlowIn = coldBox.massFlowOut;
  catalystVessel.orthoFraction_in = coldBox.orthoFraction_out;
  
  // Connect catalyst vessel to supply line
  supplyLine.T_in = catalystVessel.T_out;
  supplyLine.massFlow = catalystVessel.massFlowOut;
  supplyLine.orthoFraction_in = catalystVessel.orthoFraction_out;
  
  // Connect supply line to moderator vessel
  moderatorVessel.T_in = supplyLine.T_out;
  moderatorVessel.massFlowIn = supplyLine.massFlowOut;
  moderatorVessel.orthoFraction_in = supplyLine.orthoFraction_out;
  moderatorVessel.beamOn = beamStatus;
  
  // Connect moderator vessel to return line
  returnLine.T_in = moderatorVessel.T_out;
  returnLine.massFlow = moderatorVessel.massFlowOut;
  returnLine.orthoFraction_in = moderatorVessel.orthoFraction_out;
  
  // Connect return line to cold box
  coldBox.T_in = returnLine.T_out;
  coldBox.massFlowIn = returnLine.massFlowOut;
  coldBox.orthoFraction_in = returnLine.orthoFraction_out;
  
  // PID controller
  pidController.T_measured = coldBox.T;
  coldBox.u_control = pidController.u;
  
  // Monitor outputs
  T_coldBox = coldBox.T;
  T_catalyst = catalystVessel.T;
  T_moderator = moderatorVessel.T;
  T_supplyLine = supplyLine.T;
  T_returnLine = returnLine.T;
  controlSignal = pidController.u;
  
  // Monitor ortho-para fractions
  orthoFraction_coldBox = coldBox.orthoFraction;
  paraFraction_coldBox = coldBox.paraFraction;
  orthoFraction_catalyst = catalystVessel.orthoFraction;
  paraFraction_catalyst = catalystVessel.paraFraction;
  orthoFraction_moderator = moderatorVessel.orthoFraction;
  paraFraction_moderator = moderatorVessel.paraFraction;
  
  annotation(
    experiment(StartTime=0, StopTime=2000, Tolerance=1e-6, Interval=1),
    Documentation(info="<html>
<h2>Liquid Hydrogen Cryogenic System with Ortho-Para Conversion</h2>
<p>This model simulates a liquid hydrogen cooling system for an accelerator facility
with ortho-para hydrogen conversion capability.</p>
<h3>System Description:</h3>
<ul>
<li><b>Cold Box:</b> Cools hydrogen to liquid temperatures (~20K)</li>
<li><b>Catalyst Vessel:</b> Converts ortho-hydrogen to para-hydrogen using a catalyst</li>
<li><b>Supply Transfer Line:</b> Transports cold hydrogen to moderator with heat leak</li>
<li><b>Moderator Vessel:</b> Contains hydrogen that absorbs beam heat load</li>
<li><b>Return Transfer Line:</b> Returns warmed hydrogen to cold box</li>
<li><b>PID Controller:</b> Maintains cold box temperature at setpoint</li>
</ul>
<h3>Ortho-Para Hydrogen Conversion:</h3>
<p>Hydrogen exists in two spin isomers: ortho (75% at room temp) and para (25% at room temp).
At cryogenic temperatures, the equilibrium favors para-hydrogen (~100% at 20K).
The catalyst vessel accelerates this conversion, which is important because:</p>
<ul>
<li>Ortho-to-para conversion is exothermic (releases 527 kJ/kg)</li>
<li>Without catalyst, conversion takes days/months</li>
<li>Slow conversion in storage causes boil-off</li>
</ul>
<p>The system also models back-conversion (para to ortho) due to:</p>
<ul>
<li>Wall interactions in transfer lines</li>
<li>Temperature increase in moderator vessel</li>
<li>Beam heating effects</li>
</ul>
<h3>Operation:</h3>
<p>The system starts with the beam off, cooling the hydrogen to the target temperature.
After 1000 seconds, the beam turns on, adding heat load to the moderator vessel.
The PID controller adjusts the cold box cooling power to maintain stable temperatures.</p>
<h3>Key Outputs:</h3>
<ul>
<li>T_coldBox: Temperature of the cold box (K)</li>
<li>T_catalyst: Temperature of the catalyst vessel (K)</li>
<li>T_moderator: Temperature of the moderator vessel (K)</li>
<li>T_supplyLine: Temperature in the supply line (K)</li>
<li>T_returnLine: Temperature in the return line (K)</li>
<li>controlSignal: PID controller output (0-1)</li>
<li>orthoFraction_catalyst: Ortho-hydrogen fraction after catalyst (0-1)</li>
<li>paraFraction_catalyst: Para-hydrogen fraction after catalyst (0-1)</li>
<li>orthoFraction_moderator: Ortho-hydrogen fraction in moderator (0-1)</li>
<li>paraFraction_moderator: Para-hydrogen fraction in moderator (0-1)</li>
</ul>
</html>"));
end LiquidHydrogenSystem;

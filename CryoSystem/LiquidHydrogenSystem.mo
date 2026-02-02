within CryoSystem;
model LiquidHydrogenSystem "Complete Liquid Hydrogen Cryogenic System"
  // Import components
  Components.ColdBox coldBox(T_setpoint=20) annotation(Placement(transformation(extent={{-60,-10},{-40,10}})));
  Components.TransferLine supplyLine(length=10) annotation(Placement(transformation(extent={{-20,-10},{0,10}})));
  Components.ModeratorVessel moderatorVessel annotation(Placement(transformation(extent={{20,-10},{40,10}})));
  Components.TransferLine returnLine(length=10) annotation(Placement(transformation(extent={{60,-10},{80,10}})));
  Components.PIDController pidController(T_setpoint=20, Kp=100, Ki=10, Kd=5) annotation(Placement(transformation(extent={{-80,20},{-60,40}})));
  
  // System variables
  Real beamStatus(start=0) "Beam status: 0=off, 1=on";
  
  // Output variables for monitoring
  Real T_coldBox "Temperature of cold box (K)";
  Real T_moderator "Temperature of moderator vessel (K)";
  Real T_supplyLine "Temperature of supply line (K)";
  Real T_returnLine "Temperature of return line (K)";
  Real controlSignal "PID control signal";
  
equation
  // Beam control logic - beam turns on after 1000 seconds
  if time < 1000 then
    beamStatus = 0;
  else
    beamStatus = 1;
  end if;
  
  // Connect cold box to supply line
  supplyLine.T_in = coldBox.T_out;
  supplyLine.massFlow = coldBox.massFlowOut;
  
  // Connect supply line to moderator vessel
  moderatorVessel.T_in = supplyLine.T_out;
  moderatorVessel.massFlowIn = supplyLine.massFlowOut;
  moderatorVessel.beamOn = beamStatus;
  
  // Connect moderator vessel to return line
  returnLine.T_in = moderatorVessel.T_out;
  returnLine.massFlow = moderatorVessel.massFlowOut;
  
  // Connect return line to cold box
  coldBox.T_in = returnLine.T_out;
  coldBox.massFlowIn = returnLine.massFlowOut;
  
  // PID controller
  pidController.T_measured = coldBox.T;
  coldBox.u_control = pidController.u;
  
  // Monitor outputs
  T_coldBox = coldBox.T;
  T_moderator = moderatorVessel.T;
  T_supplyLine = supplyLine.T;
  T_returnLine = returnLine.T;
  controlSignal = pidController.u;
  
  annotation(
    experiment(StartTime=0, StopTime=2000, Tolerance=1e-6, Interval=1),
    Documentation(info="<html>
<h2>Liquid Hydrogen Cryogenic System</h2>
<p>This model simulates a liquid hydrogen cooling system for an accelerator facility.</p>
<h3>System Description:</h3>
<ul>
<li><b>Cold Box:</b> Cools hydrogen to liquid temperatures (~20K)</li>
<li><b>Supply Transfer Line:</b> Transports cold hydrogen to moderator with heat leak</li>
<li><b>Moderator Vessel:</b> Contains hydrogen that absorbs beam heat load</li>
<li><b>Return Transfer Line:</b> Returns warmed hydrogen to cold box</li>
<li><b>PID Controller:</b> Maintains cold box temperature at setpoint</li>
</ul>
<h3>Operation:</h3>
<p>The system starts with the beam off, cooling the hydrogen to the target temperature.
After 1000 seconds, the beam turns on, adding heat load to the moderator vessel.
The PID controller adjusts the cold box cooling power to maintain stable temperatures.</p>
<h3>Key Outputs:</h3>
<ul>
<li>T_coldBox: Temperature of the cold box (K)</li>
<li>T_moderator: Temperature of the moderator vessel (K)</li>
<li>T_supplyLine: Temperature in the supply line (K)</li>
<li>T_returnLine: Temperature in the return line (K)</li>
<li>controlSignal: PID controller output (0-1)</li>
</ul>
</html>"));
end LiquidHydrogenSystem;

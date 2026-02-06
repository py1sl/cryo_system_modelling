within CryoSystem.Components;
model TransferLine "Transfer Line for Hydrogen Flow"
  // Parameters
  parameter Real length = 10 "Length of transfer line (m)";
  parameter Real heatLeakPerMeter = 5 "Heat leak per meter (W/m)";
  parameter Real thermalMass = 10 "Thermal mass of line (kg)";
  parameter Real cp = 14300 "Specific heat capacity (J/(kg*K))";
  parameter Real k_backconversion_wall = 0.0002 "Back conversion rate due to wall interactions (1/s)" annotation(Dialog(tab="Advanced"));
  parameter Real T_backconversion_scale = 50 "Temperature scale for back-conversion rate (K)" annotation(Dialog(tab="Advanced"));
  
  // Variables
  Real T(start=20) "Average temperature of transfer line (K)";
  Real orthoFraction(start=0.25) "Fraction of ortho-hydrogen (0 to 1)";
  Real paraFraction "Fraction of para-hydrogen (0 to 1)";
  Real backConversionRate "Rate of para to ortho back-conversion due to walls (kg/s)";
  Real Q_leak "Heat leak into line (W)";
  Real Q_flow "Heat transfer by flow (W)";
  Real massFlow "Mass flow rate (kg/s)";
  Real T_in "Inlet temperature (K)";
  Real orthoFraction_in "Incoming ortho fraction";
  
  // Outputs
  output Real T_out "Outlet temperature (K)";
  output Real massFlowOut "Mass flow rate output (kg/s)";
  output Real orthoFraction_out "Outgoing ortho fraction";
  output Real paraFraction_out "Outgoing para fraction";
  
equation
  // Calculate para fraction
  paraFraction = 1 - orthoFraction;
  
  // Heat leak from environment
  Q_leak = heatLeakPerMeter * length;
  
  // Heat transfer by flow
  Q_flow = massFlow * cp * (T_in - T);
  
  // Energy balance
  thermalMass * cp * der(T) = Q_leak + Q_flow;
  
  // Back-conversion due to wall interactions (minimal but present)
  // Pipe walls can catalyze para-to-ortho conversion
  backConversionRate = k_backconversion_wall * paraFraction * thermalMass * exp(T/T_backconversion_scale);
  
  // Net change in ortho fraction (back-conversion increases ortho)
  der(orthoFraction) = backConversionRate / thermalMass;
  
  // Output conditions
  T_out = T;
  massFlowOut = massFlow; // Mass conservation
  orthoFraction_out = orthoFraction;
  paraFraction_out = paraFraction;
  
  annotation(Documentation(info="<html>
<p>Model of a transfer line connecting components with heat leak.</p>
<p>Represents thermal losses during hydrogen transport.</p>
<h3>Ortho-Para Back-conversion:</h3>
<p>Transfer line walls can cause some back-conversion of para-hydrogen to ortho-hydrogen
through surface interactions. This effect is typically small but increases with:</p>
<ul>
<li>Higher temperatures</li>
<li>Longer residence time (lower flow rates)</li>
<li>Surface material properties</li>
</ul>
<h3>Parameters:</h3>
<ul>
<li><b>T_backconversion_scale:</b> Temperature scale for wall-induced back-conversion kinetics (K)</li>
</ul>
</html>"));
end TransferLine;

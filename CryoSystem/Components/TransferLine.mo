within CryoSystem.Components;
model TransferLine "Transfer Line for Hydrogen Flow"
  // Parameters
  parameter Real length = 10 "Length of transfer line (m)";
  parameter Real heatLeakPerMeter = 5 "Heat leak per meter (W/m)";
  parameter Real thermalMass = 10 "Thermal mass of line (kg)";
  parameter Real cp = 14300 "Specific heat capacity (J/(kg*K))";
  
  // Variables
  Real T(start=20) "Average temperature of transfer line (K)";
  Real Q_leak "Heat leak into line (W)";
  Real Q_flow "Heat transfer by flow (W)";
  Real massFlow "Mass flow rate (kg/s)";
  Real T_in "Inlet temperature (K)";
  
  // Outputs
  output Real T_out "Outlet temperature (K)";
  output Real massFlowOut "Mass flow rate output (kg/s)";
  
equation
  // Heat leak from environment
  Q_leak = heatLeakPerMeter * length;
  
  // Heat transfer by flow
  Q_flow = massFlow * cp * (T_in - T);
  
  // Energy balance
  thermalMass * cp * der(T) = Q_leak + Q_flow;
  
  // Output conditions
  T_out = T;
  massFlowOut = massFlow; // Mass conservation
  
  annotation(Documentation(info="<html>
<p>Model of a transfer line connecting components with heat leak.</p>
<p>Represents thermal losses during hydrogen transport.</p>
</html>"));
end TransferLine;

within CryoSystem.Components;
model ColdBox "Cold Box Model for Cooling Liquid Hydrogen"
  // Parameters
  parameter Real mass = 100 "Mass of hydrogen in cold box (kg)";
  parameter Real cp = 14300 "Specific heat capacity of liquid H2 (J/(kg*K))";
  parameter Real coolingPower = 5000 "Maximum cooling power (W)";
  parameter Real T_setpoint = 20 "Target temperature (K)";
  
  // Variables
  Real T(start=300) "Temperature of cold box (K)";
  Real Q_cooling "Cooling power applied (W)";
  Real Q_in "Heat input from return flow (W)";
  Real massFlowIn "Mass flow rate into cold box (kg/s)";
  Real T_in "Temperature of return flow (K)";
  
  // Control input
  input Real u_control "Control signal from PID (0 to 1)";
  
  // Outputs
  output Real T_out "Temperature output to transfer line (K)";
  output Real massFlowOut "Mass flow rate output (kg/s)";
  
equation
  // Cooling power proportional to control signal
  Q_cooling = -coolingPower * u_control;
  
  // Heat input from return flow
  Q_in = massFlowIn * cp * (T_in - T);
  
  // Energy balance
  mass * cp * der(T) = Q_cooling + Q_in;
  
  // Output conditions
  T_out = T;
  massFlowOut = 0.1; // Constant mass flow rate (kg/s)
  
  annotation(Documentation(info="<html>
<p>Model of a cold box that cools liquid hydrogen to cryogenic temperatures.</p>
<p>The cold box receives warm hydrogen from the moderator vessel and cools it back down.</p>
</html>"));
end ColdBox;

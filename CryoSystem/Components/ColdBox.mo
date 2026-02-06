within CryoSystem.Components;
model ColdBox "Cold Box Model for Cooling Liquid Hydrogen"
  // Parameters
  parameter Real mass = 100 "Mass of hydrogen in cold box (kg)";
  parameter Real cp = 14300 "Specific heat capacity of liquid H2 (J/(kg*K))";
  parameter Real coolingPower = 5000 "Maximum cooling power (W)";
  parameter Real T_setpoint = 20 "Target temperature (K)";
  parameter Real massFlowRate = 0.1 "Mass flow rate through system (kg/s)";
  
  // Variables
  Real T(start=300) "Temperature of cold box (K)";
  Real orthoFraction(start=0.75) "Fraction of ortho-hydrogen (0 to 1)";
  Real paraFraction "Fraction of para-hydrogen (0 to 1)";
  Real Q_cooling "Cooling power applied (W)";
  Real Q_in "Heat input from return flow (W)";
  Real massFlowIn "Mass flow rate into cold box (kg/s)";
  Real T_in "Temperature of return flow (K)";
  Real orthoFraction_in "Incoming ortho fraction from return";
  
  // Control input
  input Real u_control "Control signal from PID (0 to 1)";
  
  // Outputs
  output Real T_out "Temperature output to transfer line (K)";
  output Real massFlowOut "Mass flow rate output (kg/s)";
  output Real orthoFraction_out "Outgoing ortho fraction";
  output Real paraFraction_out "Outgoing para fraction";
  
equation
  // Calculate para fraction
  paraFraction = 1 - orthoFraction;
  
  // Cooling power proportional to control signal
  Q_cooling = -coolingPower * u_control;
  
  // Heat input from return flow
  Q_in = massFlowIn * cp * (T_in - T);
  
  // Energy balance
  mass * cp * der(T) = Q_cooling + Q_in;
  
  // Ortho-para fraction passes through (no conversion in cold box without catalyst)
  der(orthoFraction) = 0; // Cold box doesn't change ortho-para ratio
  
  // Output conditions
  T_out = T;
  massFlowOut = massFlowRate;
  orthoFraction_out = orthoFraction;
  paraFraction_out = paraFraction;
  
  annotation(Documentation(info="<html>
<p>Model of a cold box that cools liquid hydrogen to cryogenic temperatures.</p>
<p>The cold box receives warm hydrogen from the moderator vessel and cools it back down.</p>
<p>Ortho-para fractions pass through unchanged unless a catalyst is present downstream.</p>
</html>"));
end ColdBox;

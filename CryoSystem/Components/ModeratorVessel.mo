within CryoSystem.Components;
model ModeratorVessel "Moderator Vessel with Beam Heat Load"
  // Parameters
  parameter Real mass = 50 "Mass of hydrogen in vessel (kg)";
  parameter Real cp = 14300 "Specific heat capacity of liquid H2 (J/(kg*K))";
  parameter Real beamPower = 2000 "Beam heat load when on (W)";
  
  // Variables
  Real T(start=20) "Temperature of moderator vessel (K)";
  Real Q_beam "Heat load from beam (W)";
  Real Q_in "Heat input from incoming flow (W)";
  Real massFlowIn "Mass flow rate into vessel (kg/s)";
  Real T_in "Temperature of incoming flow (K)";
  
  // Beam control
  input Real beamOn "Beam status (0=off, 1=on)";
  
  // Outputs
  output Real T_out "Temperature output to return line (K)";
  output Real massFlowOut "Mass flow rate output (kg/s)";
  
equation
  // Beam heat load
  Q_beam = beamPower * beamOn;
  
  // Heat input from incoming flow
  Q_in = massFlowIn * cp * (T_in - T);
  
  // Energy balance
  mass * cp * der(T) = Q_beam + Q_in;
  
  // Output conditions
  T_out = T;
  massFlowOut = massFlowIn; // Mass conservation
  
  annotation(Documentation(info="<html>
<p>Model of a moderator vessel where liquid hydrogen is heated by beam interaction.</p>
<p>The beam can be turned on/off to apply heat load.</p>
</html>"));
end ModeratorVessel;

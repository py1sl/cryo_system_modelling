within CryoSystem.Components;
model ModeratorVessel "Moderator Vessel with Beam Heat Load"
  // Parameters
  parameter Real mass = 0.059 "Mass of hydrogen in vessel (kg)";
  parameter Real cp = 14300 "Specific heat capacity of liquid H2 (J/(kg*K))";
  parameter Real nominalBeamPower = 200 "Nominal beam power for scaling back-conversion (W)";
  parameter Real k_backconversion_wall = 0.0005 "Back conversion rate due to wall interactions (1/s)" annotation(Dialog(tab="Advanced"));
  parameter Real beamBackconversionFactor = 0.5 "Beam heating effect on back-conversion rate (dimensionless)" annotation(Dialog(tab="Advanced"));
  parameter Real T_backconversion_scale = 50 "Temperature scale for back-conversion rate (K)" annotation(Dialog(tab="Advanced"));
  
  // Variables
  Real T(start=20) "Temperature of moderator vessel (K)";
  Real orthoFraction(start=0.25) "Fraction of ortho-hydrogen (0 to 1)";
  Real paraFraction "Fraction of para-hydrogen (0 to 1)";
  Real backConversionRate "Rate of para to ortho back-conversion due to walls (kg/s)";
  Real Q_beam "Heat load from beam (W)";
  Real Q_in "Heat input from incoming flow (W)";
  Real massFlowIn "Mass flow rate into vessel (kg/s)";
  Real T_in "Temperature of incoming flow (K)";
  Real orthoFraction_in "Incoming ortho fraction";
  
  // Beam control
  input Real beamPower "Time-varying beam heat load (W)";
  
  // Outputs
  output Real T_out "Temperature output to return line (K)";
  output Real massFlowOut "Mass flow rate output (kg/s)";
  output Real orthoFraction_out "Outgoing ortho fraction";
  output Real paraFraction_out "Outgoing para fraction";
  
equation
  // Calculate para fraction
  paraFraction = 1 - orthoFraction;
  
  // Beam heat load
  Q_beam = beamPower;
  
  // Heat input from incoming flow
  Q_in = massFlowIn * cp * (T_in - T);
  
  // Back-conversion due to wall interactions and beam heating
  // Increases with temperature and para content
  // Beam heating effect is proportional to actual beam power relative to nominal
  backConversionRate = k_backconversion_wall * paraFraction * mass * (1 + (beamPower/nominalBeamPower) * beamBackconversionFactor) * exp(T/T_backconversion_scale);
  
  // Net change in ortho fraction (back-conversion increases ortho)
  der(orthoFraction) = backConversionRate / mass;
  
  // Energy balance
  mass * cp * der(T) = Q_beam + Q_in;
  
  // Output conditions
  T_out = T;
  massFlowOut = massFlowIn; // Mass conservation
  orthoFraction_out = orthoFraction;
  paraFraction_out = paraFraction;
  
  annotation(Documentation(info="<html>
<p>Model of a moderator vessel where liquid hydrogen is heated by beam interaction.</p>
<p>The beam power can vary over time to simulate realistic accelerator operation with
variable beam parameters.</p>
<h3>Ortho-Para Conversion:</h3>
<p>The moderator vessel also models back-conversion of para-hydrogen to ortho-hydrogen due to:</p>
<ul>
<li>Interaction with vessel walls</li>
<li>Elevated temperatures when beam power is applied</li>
<li>Beam heating effects (proportional to beam power)</li>
</ul>
<p>This back-conversion partially reverses the catalyst effect and must be accounted for
in the overall system hydrogen composition.</p>
<h3>Parameters:</h3>
<ul>
<li><b>beamBackconversionFactor:</b> Multiplier for how much beam heating increases back-conversion (dimensionless)</li>
<li><b>T_backconversion_scale:</b> Temperature scale for back-conversion kinetics (K)</li>
</ul>
</html>"));
end ModeratorVessel;

within CryoSystem.Components;
model CatalystVessel "Catalyst Vessel for Ortho-Para Hydrogen Conversion"
  // Parameters
  parameter Real mass = 20 "Mass of hydrogen in catalyst vessel (kg)";
  parameter Real cp = 14300 "Specific heat capacity of liquid H2 (J/(kg*K))";
  parameter Real catalystMass = 5 "Mass of catalyst material (kg)";
  parameter String catalystType = "iron_oxide" "Type of catalyst: iron_oxide, chromium_oxide, nickel";
  parameter Real conversionHeat = 527000 "Heat of ortho-para conversion (J/kg)" annotation(Dialog(tab="Advanced"));
  parameter Real heatLeak = 10 "Heat leak to environment (W)";
  
  // Ortho-para conversion parameters
  parameter Real k_conversion = 0.05 "Conversion rate constant (1/s)" annotation(Dialog(tab="Advanced"));
  parameter Real k_backconversion = 0.001 "Back conversion rate constant (1/s)" annotation(Dialog(tab="Advanced"));
  parameter Real T_equilibrium = 20 "Temperature for equilibrium calculations (K)" annotation(Dialog(tab="Advanced"));
  
  // Variables
  Real T(start=20) "Temperature of catalyst vessel (K)";
  Real orthoFraction(start=0.75) "Fraction of ortho-hydrogen (0 to 1)";
  Real paraFraction "Fraction of para-hydrogen (0 to 1)";
  Real conversionRate "Rate of ortho to para conversion (kg/s)";
  Real backConversionRate "Rate of para to ortho back-conversion (kg/s)";
  Real Q_conversion "Heat released by conversion (W)";
  Real Q_in "Heat input from incoming flow (W)";
  Real Q_leak "Heat leak (W)";
  Real massFlowIn "Mass flow rate into vessel (kg/s)";
  Real T_in "Temperature of incoming flow (K)";
  Real orthoFraction_in "Incoming ortho fraction";
  
  // Catalyst effectiveness factor based on type
  Real catalystEffectiveness "Effectiveness factor for catalyst type";
  
  // Outputs
  output Real T_out "Temperature output to next component (K)";
  output Real massFlowOut "Mass flow rate output (kg/s)";
  output Real orthoFraction_out "Outgoing ortho fraction";
  output Real paraFraction_out "Outgoing para fraction";
  
equation
  // Calculate para fraction
  paraFraction = 1 - orthoFraction;
  
  // Catalyst effectiveness based on type
  if catalystType == "iron_oxide" then
    catalystEffectiveness = 1.0; // Reference catalyst
  elseif catalystType == "chromium_oxide" then
    catalystEffectiveness = 1.2; // 20% more effective
  elseif catalystType == "nickel" then
    catalystEffectiveness = 0.8; // 80% effectiveness
  else
    catalystEffectiveness = 1.0; // Default
  end if;
  
  // Ortho to para conversion rate (depends on catalyst effectiveness, mass, and ortho fraction)
  // Higher conversion at lower temperatures and with more ortho present
  conversionRate = k_conversion * catalystEffectiveness * (catalystMass/5.0) * orthoFraction * mass * exp(-T/30);
  
  // Para to ortho back-conversion (thermal activation increases with temperature)
  // Back conversion increases with temperature and para content
  backConversionRate = k_backconversion * paraFraction * mass * exp(T/50);
  
  // Net change in ortho fraction due to conversion
  der(orthoFraction) = (backConversionRate - conversionRate) / mass;
  
  // Heat released by ortho-para conversion (exothermic)
  // Negative because conversion releases heat
  Q_conversion = -conversionHeat * conversionRate;
  
  // Heat input from incoming flow
  Q_in = massFlowIn * cp * (T_in - T);
  
  // Heat leak to environment
  Q_leak = heatLeak;
  
  // Energy balance
  mass * cp * der(T) = Q_conversion + Q_in + Q_leak;
  
  // Output conditions
  T_out = T;
  massFlowOut = massFlowIn; // Mass conservation
  orthoFraction_out = orthoFraction;
  paraFraction_out = paraFraction;
  
  annotation(Documentation(info="<html>
<h2>Catalyst Vessel for Ortho-Para Hydrogen Conversion</h2>
<p>This model simulates the conversion of ortho-hydrogen to para-hydrogen using a catalyst.</p>

<h3>Physical Background:</h3>
<p>Hydrogen exists in two spin isomers:</p>
<ul>
<li><b>Ortho-hydrogen:</b> Parallel nuclear spins (higher energy state)</li>
<li><b>Para-hydrogen:</b> Anti-parallel nuclear spins (lower energy state)</li>
</ul>

<p>At room temperature, hydrogen is approximately 75% ortho and 25% para (equilibrium mixture).
At cryogenic temperatures (~20K), the equilibrium shifts to nearly 100% para-hydrogen.
Without a catalyst, this conversion is extremely slow (days to months).</p>

<h3>Catalyst Function:</h3>
<p>A catalyst (e.g., iron oxide, chromium oxide, or nickel) dramatically accelerates the conversion.
The conversion is exothermic, releasing ~527 kJ/kg of hydrogen converted. This heat must be removed
by the cryogenic system.</p>

<h3>Back-conversion:</h3>
<p>Para-hydrogen can convert back to ortho-hydrogen when:</p>
<ul>
<li>Temperature increases (thermal activation)</li>
<li>Interaction with surfaces (pipe walls)</li>
<li>Time passes (slow equilibration toward room temperature ratio)</li>
</ul>

<h3>Parameters:</h3>
<ul>
<li><b>mass:</b> Hydrogen mass in vessel (kg)</li>
<li><b>catalystMass:</b> Mass of catalyst material (kg) - affects conversion rate</li>
<li><b>catalystType:</b> Type of catalyst (iron_oxide, chromium_oxide, nickel)</li>
<li><b>conversionHeat:</b> Heat of conversion, 527 kJ/kg (exothermic)</li>
<li><b>k_conversion:</b> Forward conversion rate constant</li>
<li><b>k_backconversion:</b> Backward conversion rate constant</li>
</ul>

<h3>Outputs:</h3>
<ul>
<li><b>orthoFraction_out:</b> Fraction of ortho-hydrogen in output (0-1)</li>
<li><b>paraFraction_out:</b> Fraction of para-hydrogen in output (0-1)</li>
<li><b>T_out:</b> Output temperature (K)</li>
</ul>

<h3>References:</h3>
<p>Physical properties and conversion heat based on standard hydrogen thermodynamics literature.</p>
</html>"));
end CatalystVessel;

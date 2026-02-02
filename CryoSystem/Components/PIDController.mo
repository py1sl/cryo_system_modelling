within CryoSystem.Components;
model PIDController "PID Controller for Temperature Control"
  // Parameters
  parameter Real Kp = 100 "Proportional gain";
  parameter Real Ki = 10 "Integral gain";
  parameter Real Kd = 5 "Derivative gain";
  parameter Real T_setpoint = 20 "Temperature setpoint (K)";
  
  // Variables
  Real error "Temperature error (K)";
  Real integral(start=0) "Integral of error";
  Real derivative "Derivative of error";
  Real error_prev(start=0) "Previous error for derivative";
  
  // Inputs
  input Real T_measured "Measured temperature (K)";
  
  // Output
  output Real u "Control signal (0 to 1)";
  
equation
  // Calculate error
  error = T_setpoint - T_measured;
  
  // Integral term
  der(integral) = error;
  
  // Derivative term (approximation)
  derivative = der(error);
  error_prev = error;
  
  // PID control law
  u = max(0, min(1, (Kp * error + Ki * integral + Kd * derivative) / 1000));
  
  annotation(Documentation(info="<html>
<p>PID controller for maintaining target temperature in the cold box.</p>
<p>Output is saturated between 0 and 1.</p>
</html>"));
end PIDController;

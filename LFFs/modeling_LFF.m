function model = modeling_LFF(TR, n_dyn)

f = [0.01, 0.02, 0.04, 0.08];
t = [TR:TR:TR*n_dyn]';
c1s = sin(2*pi*f(1)*t);
c1c = sin(2*pi*f(1)*t-pi/2);
c2s = sin(2*pi*f(2)*t);
c2c = sin(2*pi*f(2)*t-pi/2);
c3s = sin(2*pi*f(3)*t);
c3c = sin(2*pi*f(3)*t-pi/2);
c4s = sin(2*pi*f(4)*t);
c4c = sin(2*pi*f(4)*t-pi/2);

model = [c1s, c1c, c2s, c2c, c3s, c3c, c4s, c4c];


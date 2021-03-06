clear all
close all
clc

%% User Inputs:
l1 = 1; l2 = 1; l3 = 1;
p1 = [1,0,1]; p2 = [sqrt(2)/2, sqrt(2)/2, 1.2];
pp = p2 - p1;

alpha = atan2(pp(2), pp(1)); % angle between x and y
gamma = atan2(  pp(3), sqrt(pp(1)^2 + pp(2)^2) ); % angle with z axis

dt = 1/100;
vmax = 1;
amax = 10;

%% Implementation
n = 100; % number of points

px = linspace(p1(1),p2(1),n);
py = linspace(p1(2),p2(2),n);
pz = linspace(p1(3),p2(3),n);

dp = sqrt( sum((p1 - p2).^2) )/(n-1);

% Finding t1
trapTime = TrajectoryTime(vmax, amax, dp);
trap(amax, trapTime(1), trapTime(2));

%% Finding t1 that is suitable with the controller
t1 = trapTime(1);
fprintf("t1 before the ocntroller %f seconds\n", t1)
t1 = ceil(t1/dt)*dt;
fprintf("t1 after the ocntroller %f seconds\n", t1)
amax = dp/t1^2;

segmentTime = sum(trapTime);

p = [];
totalTime = [];
p0 = 0;
figure
for i = 1:n-1
    
    % first path a/2 * (t-t1)^2 + p0
    time = linspace(segmentTime*(i-1), segmentTime*(i-1)+t1, 10);
    totalTime = [totalTime time];
    p = [p (amax/2)*(time-time(1)).^2 + p0];
    % second path -a/2 * (t-2t1)^2 + p0 + 2t1
    p0 = p(end);
    time = linspace(time(end), time(end)+t1, 10);
    totalTime = [totalTime time];
    p = [p (-amax/2)*(time-time(1)-t1).^2 + p0 + 0.5*amax*t1^2];
    p0 = p(end);
end

x = px(1)+p*cos(gamma)*cos(alpha);
y = py(1)+p*cos(gamma)*sin(alpha);
z = pz(1)+p*sin(gamma);

subplot(3,1,1)
plot(totalTime, x)
grid on
subplot(3,1,2)
plot(totalTime, y, 'r')
grid on
subplot(3,1,3)
plot(totalTime, z, 'g')
grid on    
    
    
%% Finding joint space equivilant   
% finding the equivilant joints using IK, with one solution only for
% simplicity

for i=1:length(x)
    joints(:,i) = IK(x(i),y(i), z(i), 1); % the one here denotes one solution 
end

robot = figure;
global axes_plot links_plot joints_plot end_effector_plot
for i = 1:15:length(x)
    if ~ishandle(robot), break, end
    delete([links_plot,joints_plot,end_effector_plot]), delete(axes_plot)
    
    FK(joints(1,i),joints(2,i),joints(3,i),1,0);
    drawnow
end
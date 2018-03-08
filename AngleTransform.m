function [ SGSP_Angle ] = AngleTransform( Incident_Angle )
% Incident angle --> SGSP angle
% 进行入射角与转台实际角度的转换 
% Edited 2016 01 14
n_Glass = 1.51682;
n_Air = 1;
tmp = Incident_Angle -45;
SGSP_Angle =fix( 10*asin( n_Glass*sin( tmp/180*pi )/n_Air )/pi*180 )/10+45;

function [ Incident_Angle ] = AngleInverseTransform( SGSP_Angle )
% SGSP angle --> Incident angle
% 进行入射角与转台实际角度的转换 
% Edited 2016 01 14
n_Glass = 1.51682;
n_Air = 1;
tmp = SGSP_Angle -45;
Incident_Angle  = asin( n_Air*sin( tmp/180*pi )/n_Glass )/pi*180 +45;
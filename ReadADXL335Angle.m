function [ Current_Angle ] = ReadADXL335Angle( S_Obj )

Perform_Get_Angle = 5;
fwrite( S_Obj , Perform_Get_Angle);
pause(0.1);
Angle_Dat= fread( S_Obj , S_Obj.BytesAvailable );

X_Dat = Angle_Dat(1)*256+Angle_Dat(2);
Y_Dat = Angle_Dat(3)*256+Angle_Dat(4);

% Zero data 512 as the half of the 1023(3.3V)
% % g_sacle = 0.33*1024/3.3; 0.33 is the sensitivity of the ADXL335 330mV/g
% g_sacle = 0.33*1024/3.3; 
% 电机装反了，效果还不错，这里把角度也反过来 加了一个 - 号
Current_Angle = -(180/pi)*atan( (X_Dat-512)/(Y_Dat-512) );
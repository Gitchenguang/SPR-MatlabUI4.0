function [Temp] = ReadTemp( Serial , QureyTemp )
% 由读到的电压值推算出当前的温度值  Arduino 采集温度命令字 9

% 常数定义
B = 3435;
K = 273.15; % 绝对零度
Rs = 10000; % 与热敏电阻串联的电阻阻值 
Vcc = 3.3; % 热敏电阻一头接Vcc=3.3V，一头接Rs电阻，并且与其并联一个10uF电容，以滤除高频噪声
Vref = 3.3;
T0 = 25 + K; % 参考温度25℃对应的绝对温度
R0 = 10000;  % 25℃ 电阻10K

% 发送温度获取命令
if( Serial.BytesAvailable ~= 0 ) 
    fread( Serial , Serial.BytesAvailable); 
end % 先清零缓冲区
fwrite( Serial , QureyTemp , 'uint8' );
while( Serial.BytesAvailable == 0 )
end
pause(0.1);
TempDat = fread( Serial, Serial.BytesAvailable );
TempVolt = Vref*(TempDat(1)*256+TempDat(2))/1024;
if( Serial.BytesAvailable ~= 0 ) 
    fread( Serial , Serial.BytesAvailable); 
end % 用完清零缓冲区

% Rnow/（Vcc-TempVolt） = Rs /TempVolt -> Rnow = Rs *( Vcc -TempVolt
% )/TempVolt
% Rntc一端接vcc的话可以用这个公式
%Rnow = Rs * ( Vcc - TempVolt )/ TempVolt;
% 若 Rntc一端接地的话
Rnow = Rs*TempVolt/(Vcc-TempVolt);

% T = (B*T0)/( T*ln( Rnow / R0 ) + B )
Temp = ( B * T0 )/( T0*log( Rnow/R0 ) + B )-273.15;

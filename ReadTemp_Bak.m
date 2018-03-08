function [Temp] = ReadTemp( Serial , QureyTemp )
% �ɶ����ĵ�ѹֵ�������ǰ���¶�ֵ  Arduino �ɼ��¶������� 9

% ��������
B = 3435;
K = 273.15; % �������
Rs = 10000; % ���������贮���ĵ�����ֵ 
Vcc = 3.3; % ��������һͷ��Vcc=3.3V��һͷ��Rs���裬�������䲢��һ��10uF���ݣ����˳���Ƶ����
Vref = 3.3;
T0 = 25 + K; % �ο��¶�25���Ӧ�ľ����¶�
R0 = 10000;  % 25�� ����10K

% �����¶Ȼ�ȡ����
if( Serial.BytesAvailable ~= 0 ) 
    fread( Serial , Serial.BytesAvailable); 
end % �����㻺����
fwrite( Serial , QureyTemp , 'uint8' );
while( Serial.BytesAvailable == 0 )
end
pause(0.1);
TempDat = fread( Serial, Serial.BytesAvailable );
TempVolt = Vref*(TempDat(1)*256+TempDat(2))/1024;
if( Serial.BytesAvailable ~= 0 ) 
    fread( Serial , Serial.BytesAvailable); 
end % �������㻺����

% Rnow/��Vcc-TempVolt�� = Rs /TempVolt -> Rnow = Rs *( Vcc -TempVolt
% )/TempVolt
% Rntcһ�˽�vcc�Ļ������������ʽ
%Rnow = Rs * ( Vcc - TempVolt )/ TempVolt;
% �� Rntcһ�˽ӵصĻ�
Rnow = Rs*TempVolt/(Vcc-TempVolt);

% T = (B*T0)/( T*ln( Rnow / R0 ) + B )
Temp = ( B * T0 )/( T0*log( Rnow/R0 ) + B )-273.15;

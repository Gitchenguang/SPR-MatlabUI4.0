function Temp = ReadTemp( Serial , QureyTemp )
% �ɶ����ĵ�ѹֵ�������ǰ���¶�ֵ  Arduino �ɼ��¶������� 9

% ��������
B = 3435;
K = 273.15; % �������
Rs = 10000; % ���������贮���ĵ�����ֵ 
%Vcc = 3.31; % ��������һͷ��Vcc=3.3V��һͷ��Rs���裬�������䲢��һ��10uF���ݣ����˳���Ƶ����
Vcc = 4.98; % Ҫע��оƬ�Ĺ����ѹ��Ŀǰʹ��5V���緽ʽ��ʵ�ʵ�ѹΪ4.98V����������һͷ��GND��һͷ��Rs����
Vref = 4.096;
T0 = 25 + K; % �ο��¶�25���Ӧ�ľ����¶�
R0 = 10000;  % 25�� ����10K

% �����¶Ȼ�ȡ����
if( Serial.BytesAvailable ~= 0 ) 
    fread( Serial , Serial.BytesAvailable); 
end % �����㻺����
fwrite( Serial , QureyTemp , 'uint8' );
while( Serial.BytesAvailable <4 )
end
pause(0.1);
TempDat = fread( Serial, 4);
TempVolt(1) = Vref*(TempDat(1)*256+TempDat(2))/32768;
TempVolt(2) = Vref*(TempDat(3)*256+TempDat(4))/32768;
if( Serial.BytesAvailable ~= 0 ) 
    fread( Serial , Serial.BytesAvailable); 
end % �������㻺����

% Rnow/��Vcc-TempVolt�� = Rs /TempVolt -> Rnow = Rs *( Vcc -TempVolt
% )/TempVolt
% Rntcһ�˽�vcc�Ļ������������ʽ
%Rnow = Rs * ( Vcc - TempVolt )/ TempVolt;
% �� Rntcһ�˽ӵصĻ�
Rnow1 = Rs*TempVolt(1)/(Vcc-TempVolt(1));
Rnow2 = Rs*TempVolt(2)/(Vcc-TempVolt(2));
% T = (B*T0)/( T*ln( Rnow / R0 ) + B )
Temp(1) = ( B * T0 )/( T0*log( Rnow1/R0 ) + B )-273.15;
Temp(2) = ( B * T0 )/( T0*log( Rnow2/R0 ) + B )-273.15;

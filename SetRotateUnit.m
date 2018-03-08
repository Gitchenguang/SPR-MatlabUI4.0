function Flag = SetRotateUnit( Serial_Obj , Angle , Cmd)
% Flag = SetRotateAngle( Serial_Obj , Angle )
% Flag : Flag==0 ����˳��ִ�����
% Serial_Obj : ���ڶ���
% Angle �����ת�Ƕ� 

% ���������������ת̨����ת�ǶȵĴ�С
% ���ڴ�ƽ̨�����64΢��==ƽ̨0.01��
% Edited by chenguang 2015-05-28 && Email��guang@zchenguang.com
% -------------------------------------------------------------------------

% ����Ƕ�Ϊ���΢��
Steps_Element = 32;
Angle_Element = 0.005;
Steps = Angle/Angle_Element*Steps_Element;

% Constants and varibles might be used 

% 1> Check the serial status
% if ~strcmp( Serial_Obj.Status, 'open' )
%     error('MotorSetSteps:Serial Port is closed!');
% end
if abs(Steps)>32700
    error('MotorSetSteps:Variable "Steps" is to large');
end
if Steps >= 0    % �����Ϊ������ֻ��־Ϳ��ԣ�����ת���ɲ������ʽ
    Steps_HighBits = fix( Steps / 256 );
    Steps_LowBits = Steps - Steps_HighBits*256;
else 
    Steps_Compl = 2^15 + Steps;
    Steps_LowBits = abs( Steps_Compl -  fix( Steps_Compl  / 256 )*256);
    Steps_HighBits = fix( Steps_Compl  / 256 ) + 128 ;
end


if Serial_Obj.Status ~='open'
    error('Motor:Serial Port is closed!');
end
if Serial_Obj.BytesAvailable
    fread( Serial_Obj , Serial_Obj.BytesAvailable );
end

% Get the positions
fwrite( Serial_Obj , Cmd , 'uint8' );

% 2> Confirm and write the steps to write to the device
fwrite( Serial_Obj , 2 , 'uint8' );
fwrite( Serial_Obj , 0 , 'uint8' );
fwrite( Serial_Obj , Steps_HighBits , 'uint8' );
fwrite( Serial_Obj , Steps_LowBits ,'uint8');
tic;
while toc <= abs(Steps)*0.0005  % �������Ϊ0.1�ȣ���ô0.00048һ������������ת�������������0.05һ���������ֶ���
end


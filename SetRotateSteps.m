function [ Flag ] = SetRotateSteps( Serial_Obj , Steps , Cmd ) 
% [ Flag ] = SetRotateSteps( S_Obj , Steps ) 
% �õ����תһ���Ĳ�����
% Edited by chenguang 2015-06-08 && guang@zchenguang.com

% Constants and varibles might be used  
Dev_ACK = hex2dec( 'D' );

% 1> Check the serial status
if Serial_Obj.Status~='open'
    error('MotorSetSteps:Serial Port is closed!');
end
if abs(Steps)>32700
    error('MotorSetSteps:Variable "Steps" is to large');
end
if Steps >= 0    % �����Ϊ������ֻ��־Ϳ��ԣ�����ת���ɲ������ʽ
    Steps_HighBits = fix( Steps / 256 );
    Steps_LowBits = Steps - Steps_HighBits*256;
else 
    % ����
    Steps_Compl = 2^15 + Steps;  % ���λ��15λΪ����λ
    Steps_LowBits = abs( Steps_Compl -  fix( Steps_Compl  / 256 )*256);
    Steps_HighBits = fix( Steps_Compl  / 256 ) + 128 ;
end


fwrite( Serial_Obj , Cmd , 'uint8' );
% 2> Confirm and write the steps to write to the device
fwrite( Serial_Obj , 2 , 'uint8' );
fwrite( Serial_Obj , 0 , 'uint8' );
fwrite( Serial_Obj , Steps_HighBits , 'uint8' );
fwrite( Serial_Obj , Steps_LowBits ,'uint8');
tic;
while toc<abs(Steps)*0.0005
end
function [ MotorPos ] = MotorReadPos( Serial_Obj ,CmdType )
% function [ Motor1_Pos ] = MotorReadPos( Serial_Obj )
% Motor1_Pos : ת̨1��λ����Ϣ
% Motor2_Pos : ת̨2��λ����Ϣ
% Serial_Obj �� ���ڶ���

% �ú���Ϊ��ȡ����ת̨��λ����Ϣ�ĺ���

% Edited by chenguang 2015-05-14 && Email: guang@zchenguang.com 
% -------------------------------------------------------------------------

% Constants and varibles might be used 


% Check status of serial object Serial_Obj
if Serial_Obj.Status ~='open'
    error('Motor:Serial Port is closed!');
end
if Serial_Obj.BytesAvailable
    fread( Serial_Obj , Serial_Obj.BytesAvailable );
end
% Get the positions
fwrite( Serial_Obj , CmdType , 'uint8' );
Dat = fread( Serial_Obj , 33 );
% Postion 
Dat = Dat';
PosData(1,1:6) = Dat(1,4:9) - 48;  %�ӵ���λ��ʼ���ܹ���λ����λ
i = 0:1:5;
MotorPos = sum(PosData.*(10.^(5-i) ) );


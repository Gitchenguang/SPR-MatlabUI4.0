function [ Dat ] = RotateAndRecord( Serial_Obj , Steps , S_Sensor )
% ������͸�ת̨��������ʱ�����в���������������ֹͣ��ʱ��

% Edited by chenguang 2015-05-28 && Email��guang@zchenguang.com
% -------------------------------------------------------------------------

% Constants and varibles might be used 
Flag = 1; 
Dev_ACK = hex2dec( 'D' );
Max_Steps = 32700;
DatNum=308;
if Serial_Obj.BytesAvailable
    fread( Serial_Obj , Serial_Obj.BytesAvailable );%������������
end

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
    Steps_Compl = 2^15 + Steps;
    Steps_LowBits = abs( Steps_Compl -  fix( Steps_Compl  / 256 )*256);
    Steps_HighBits = fix( Steps_Compl  / 256 ) + 128 ;
end

% 2> Confirm and write the steps to write to the device
fwrite( Serial_Obj , 2 , 'uint8' );
if fread( Serial_Obj , 1 ) ~= Dev_ACK
    error('MotorSetSteps:The first time handshaking failed!');
else
    fwrite( Serial_Obj , 0 , 'uint8' );
    if fread(Serial_Obj , 1 ) ~= Dev_ACK
        error('MotorSetSteps:The second time handshaking failed!');
    else
        fwrite( Serial_Obj , Steps_HighBits , 'uint8' );
        if fread( Serial_Obj , 1 ) ~= Dev_ACK 
            error( 'MotorSetSteps: Setting motor steps high 8bits failed!' );
        else 
            if S_Sensor.BytesAvailable
                fread( S_Sensor , S_Sensor.BytesAvailable );%������������
            end
            fwrite( Serial_Obj , Steps_LowBits ,'uint8');
            % �����ȳ��Բ��ö�ʱ������ʹ��arduino����һ���Բ�����������
            % ���Ͳ����ź�
%            tic;
%             while toc<=0.09 %��ת̨��ADCͬ�� 0.084is41  0.081is25 and 0.00795is the right so 0.084-0.00795=0.0761(0116֮ǰ��ֵ)
%             end
            fwrite( S_Sensor ,4 ); % ��������
           
            if fread( Serial_Obj ,1 ) ~= Dev_ACK
                msgbox( 'MotorSetSteps: Setting motor steps low 8 bits failed!' );
                fwrite( S_Sensor , 3 ); % ��ֹ���������������� 
                while S_Sensor.BytesAvailable<2*DatNum    % �ȵ����ݵ�ȫ
                end
                fread( S_Sensor , S_Sensor.BytesAvailable );
            else 
                tic;
                while toc <= abs(Steps)*0.0004096  % �������Ϊ0.1�ȣ���ô0.00048һ������������ת�������������0.05һ���������ֶ���
                end
                %pause( abs(Steps)*0.00048 );%ʹ����while 
                % �����ȳ��Բ��ö�ʱ������ʹ��arduino����һ���Բ�����������     
                % 1> ������ֹͣ�ɼ�����
                % 2> PC�ɼ����ݴ������������ź�
                fwrite( S_Sensor , 3 ); % ��ֹ����������������
                tic 
                while toc<0.01
                end
                while S_Sensor.BytesAvailable<2*DatNum    % �ȵ����ݵ�ȫ
                end   
                Dat=fread( S_Sensor , S_Sensor.BytesAvailable );
                Dat=Dat';
            end
        end 
    end
end
function Flag = SetRotateSpeed( Serial_Obj , Speed )
% Flag = SetRotateAngle( Serial_Obj , Angle )
% Flag : Flag==0 ����˳��ִ�����
% Serial_Obj : ���ڶ���
% Angle �����ת�Ƕ� 

% ���������������ת̨����ת�ǶȵĴ�С
% ���ڴ�ƽ̨�����64΢��==ƽ̨0.01��
% Edited by chenguang 2015-05-28 && Email��guang@zchenguang.com
% -------------------------------------------------------------------------
Flag = 1; 
Dev_ACK = hex2dec( 'D' );
% ����Ƕ�Ϊ���΢��

% Constants and varibles might be used 
if Serial_Obj.BytesAvailable
    fread( Serial_Obj , Serial_Obj.BytesAvailable );%������������
end

% 1> Check the serial status
% if ~strcmp( Serial_Obj.Status, 'open' )
%     error('MotorSetSpeed:Serial Port is closed!');
% end
if abs(Speed)>511
    error('MotorSetSpeed:Variable "Speed" is to large');
end
if Speed >= 0    % �����Ϊ������ֻ��־Ϳ��ԣ�����ת���ɲ������ʽ
    Speed_HighBits = fix( Speed / 256 );
    Speed_LowBits = Speed - Speed_HighBits*256;
else 
    Speed_Compl = 2^15 + Speed;
    Speed_LowBits = abs( Speed_Compl -  fix( Speed_Compl  / 256 )*256);
    Speed_HighBits = fix( Speed_Compl  / 256 ) + 128 ;
end

% 2> Confirm and write the Speed to write to the device
fwrite( Serial_Obj , 0 , 'uint8' );
if fread( Serial_Obj , 1 ) ~= Dev_ACK
    error('MotorSetSpeed:The first time handshaking failed!');
else
    fwrite( Serial_Obj , 0 , 'uint8' );
    if fread(Serial_Obj , 1 ) ~= Dev_ACK
        error('MotorSetSpeed:The second time handshaking failed!');
    else
        fwrite( Serial_Obj , Speed_HighBits , 'uint8' );
        if fread( Serial_Obj , 1 ) ~= Dev_ACK 
            error( 'MotorSetSpeed: Setting motor Speed high 8bits failed!' );
        else 
            fwrite( Serial_Obj , Speed_LowBits ,'uint8');
            if fread( Serial_Obj ,1 ) ~= Dev_ACK
                error( 'MotorSetSpeed: Setting motor Speed low 8 bits failed!' );
            else 
                Flag = 0;
                end
            end
        end 
    end
end
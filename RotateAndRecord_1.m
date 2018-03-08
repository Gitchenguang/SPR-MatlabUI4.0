function [ Signal Real_Angle_RT ind ] = RotateAndRecord_1( S_Sensor, Steps , Real_Angle,SGSP_Angle, AxesRealtimeSignal_handles,Direction)
% RotateAndRecord_1( Serial_Obj , Steps , S_Sensor,  Real_Angle,SGSP_Angle, AxesRealtimeSignal_handle)
% Real_Angle=[ Real_MeaInitialAngle Real_MeaFinalAngle ]   SGSP_Angle=[ SGSP_MeaInitialAngle SGSP_MeaFinalAngle ]
% ��������֧�ֵײ�ʵ�ּ��������Ĺ���
% By chenguang Email:chen@zchenguang.com UCAS

% Constants and varibles might be used 
Dev_ACK = hex2dec( 'D' );
Max_Steps = 32700;
Dat_Ind=1;
Real_Angle_RT=[]; % RT=Real Time 
Dat_Incre=[];
Dat_Conversion_Ind=0;
Angle_Scale = 0.0003815; % 0.15625/0.4096=0.3815 degree/ms
Full_Range_Voltage = 3.3;

% Ҫ�Դ��ڲ��������������㻺����
if Serial_Obj.BytesAvailable
    fread( Serial_Obj , Serial_Obj.BytesAvailable );%������������
end
if S_Sensor.BytesAvailable
    fread( S_Sensor , S_Sensor.BytesAvailable );%������������
end

% 1> Check the serial status
if Serial_Obj.Status~='open'
    error('MotorSetSteps:Serial Port is closed!');
end
if abs(Steps)>Max_Steps
    error('MotorSetSteps:Variable "Steps" is to large');
end
if Steps >= 0    % �����Ϊ������ֻ��־Ϳ��ԣ�����ת���ɲ������ʽ
    HighBit1 = fix(Steps./256);
    if (Steps - HighBit1*256 -255 )>0
        HighBit2 = 1;
    else 
        HighBit2 = 0;
    end
    Steps_HighBits = HighBit1+ HighBit2;
    Steps_LowBits = fix( Steps - Steps_HighBits*256);

else 
    Steps_Compl = 2^15 + Steps;
    Steps_LowBits = fix(abs( Steps_Compl -  fix( Steps_Compl  / 256 )*256));
%     if Steps_LowBits<1
%         Steps_LowBits =0;
%     end
    Steps_HighBits = fix( Steps_Compl  / 256 ) + 128;
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
            
            fwrite( S_Sensor ,7 ); % �������� 
            if fread( Serial_Obj ,1 ) ~= Dev_ACK
                msgbox( 'MotorSetSteps: Setting motor steps low 8 bits failed!' );
                fwrite( S_Sensor , 8 ); % ��ֹ���������������� 
                if S_Sensor.BytesAvailable
                    fread( Serial_Obj , S_Sensor.BytesAvailable );%������������
                end
            else 
                tic;
                while toc <= abs(Steps)*0.0003960 % �������Ϊ0.1�ȣ���ô0.0004096����ʦ˵0.0004096�룬���Ǹ�Ϊ0.0003950(���������0.005�� )�о�������
                    if(S_Sensor.BytesAvailable)
                        Dat_Incre = S_Sensor.BytesAvailable; %����ǰֵ����Increment��������ֹ�ڴ��ڼ�BytesAvailable�����ı�
                        Dat(1,Dat_Ind:(Dat_Ind+Dat_Incre-1))=fread( S_Sensor , Dat_Incre );
                        Dat_Ind=Dat_Ind+Dat_Incre; % Dat_Indָ����һ��������
                        if( Dat_Ind >= 3)
                            % �������������1ms����ôÿ���������ʱ�伴Ϊ
                            % ����ɨ��ʱ��Angle_ScaleΪ��ֵ������ʱΪ����SGSP_Angle������ҲҪ��Ϊ2
                            % �����������һ���ֽ�һ���ֽڵģ��Ҹ�λ��ǰ����λ�ں�
                            Dat_Conversion_Cend = fix( (Dat_Ind-1)/2 );   % ����ת����ǰ���ָ��
                            % Conversion_Indָ��ǰ���µ��źţ���Dat_Indָ������ݲ�ͬ
                            if( (Dat_Conversion_Cend - Dat_Conversion_Ind)>=1)
                                ind = (Dat_Conversion_Ind+1):1:Dat_Conversion_Cend;
                                Signal(1,ind ) = (Dat( 1,2*ind-1 )*256 + Dat( 1,2*ind ))/1023*Full_Range_Voltage;
                                        
                                Real_Angle_RT(1,(Dat_Conversion_Ind+1):1:Dat_Conversion_Cend ) = AngleInverseTransform(SGSP_Angle(1,1) + ( (Dat_Conversion_Ind+1):1:Dat_Conversion_Cend )*Angle_Scale*Direction );
                                plot(AxesRealtimeSignal_handles, Real_Angle_RT , Signal );axis( AxesRealtimeSignal_handles , [Real_Angle 0 3.5] ); 
                                Dat_Conversion_Ind = Dat_Conversion_Cend;
                            end
                        end
                    end
                end
                %pause( abs(Steps)*0.00048 );%ʹ����while 
                % �����ȳ��Բ��ö�ʱ������ʹ��arduino����һ���Բ�����������     
                % 1> ������ֹͣ�ɼ�����
                % 2> PC�ɼ����ݴ������������ź�
                fwrite( S_Sensor , 8 ); % ��ֹ����������������
                tic 
                while toc<0.5%%%%%%% 0.01
                end
                if S_Sensor.BytesAvailable
                    fread( S_Sensor , S_Sensor.BytesAvailable );%����������,��ֹ��ɢ����
                end
            end
        end 
    end
end
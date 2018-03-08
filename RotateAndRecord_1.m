function [ Signal Real_Angle_RT ind ] = RotateAndRecord_1( S_Sensor, Steps , Real_Angle,SGSP_Angle, AxesRealtimeSignal_handles,Direction)
% RotateAndRecord_1( Serial_Obj , Steps , S_Sensor,  Real_Angle,SGSP_Angle, AxesRealtimeSignal_handle)
% Real_Angle=[ Real_MeaInitialAngle Real_MeaFinalAngle ]   SGSP_Angle=[ SGSP_MeaInitialAngle SGSP_MeaFinalAngle ]
% 程序用于支持底层实现即传即画的功能
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

% 要对串口操作，必须先清零缓冲区
if Serial_Obj.BytesAvailable
    fread( Serial_Obj , Serial_Obj.BytesAvailable );%读缓冲区清零
end
if S_Sensor.BytesAvailable
    fread( S_Sensor , S_Sensor.BytesAvailable );%读缓冲区清零
end

% 1> Check the serial status
if Serial_Obj.Status~='open'
    error('MotorSetSteps:Serial Port is closed!');
end
if abs(Steps)>Max_Steps
    error('MotorSetSteps:Variable "Steps" is to large');
end
if Steps >= 0    % 如果不为负，则只拆分就可以，否则转换成补码的形式
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
                fread( S_Sensor , S_Sensor.BytesAvailable );%读缓冲区清零
            end
            fwrite( Serial_Obj , Steps_LowBits ,'uint8');
            
            fwrite( S_Sensor ,7 ); % 启动测量 
            if fread( Serial_Obj ,1 ) ~= Dev_ACK
                msgbox( 'MotorSetSteps: Setting motor steps low 8 bits failed!' );
                fwrite( S_Sensor , 8 ); % 终止测量，并发回数据 
                if S_Sensor.BytesAvailable
                    fread( Serial_Obj , S_Sensor.BytesAvailable );%读缓冲区清零
                end
            else 
                tic;
                while toc <= abs(Steps)*0.0003960 % 如果步进为0.1度，那么0.0004096工程师说0.0004096秒，但是改为0.0003950(正向方向相差0.005度 )感觉更合适
                    if(S_Sensor.BytesAvailable)
                        Dat_Incre = S_Sensor.BytesAvailable; %将当前值赋给Increment变量，防止在此期间BytesAvailable发生改变
                        Dat(1,Dat_Ind:(Dat_Ind+Dat_Incre-1))=fread( S_Sensor , Dat_Incre );
                        Dat_Ind=Dat_Ind+Dat_Incre; % Dat_Ind指向下一个空索引
                        if( Dat_Ind >= 3)
                            % 将采样速率设成1ms，那么每个样本点的时间即为
                            % 正向扫描时，Angle_Scale为正值，反向时为负，SGSP_Angle的索引也要改为2
                            % 这里的数据是一个字节一个字节的，且高位在前，低位在后
                            Dat_Conversion_Cend = fix( (Dat_Ind-1)/2 );   % 数据转换当前最大指针
                            % Conversion_Ind指向当前最新的信号，与Dat_Ind指向空内容不同
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
                %pause( abs(Steps)*0.00048 );%使用了while 
                % 这里先尝试不用定时器，改使用arduino板子一次性测量大量数据     
                % 1> 传感器停止采集数据
                % 2> PC采集数据传感器传来的信号
                fwrite( S_Sensor , 8 ); % 终止测量，并发回数据
                tic 
                while toc<0.5%%%%%%% 0.01
                end
                if S_Sensor.BytesAvailable
                    fread( S_Sensor , S_Sensor.BytesAvailable );%缓冲区清零,防止零散数据
                end
            end
        end 
    end
end
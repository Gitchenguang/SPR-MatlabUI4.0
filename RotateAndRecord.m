function [ Dat ] = RotateAndRecord( Serial_Obj , Steps , S_Sensor )
% 将命令发送给转台后，启动计时器进行测量，测量结束后，停止计时器

% Edited by chenguang 2015-05-28 && Email：guang@zchenguang.com
% -------------------------------------------------------------------------

% Constants and varibles might be used 
Flag = 1; 
Dev_ACK = hex2dec( 'D' );
Max_Steps = 32700;
DatNum=308;
if Serial_Obj.BytesAvailable
    fread( Serial_Obj , Serial_Obj.BytesAvailable );%读缓冲区清零
end

% 1> Check the serial status
if Serial_Obj.Status~='open'
    error('MotorSetSteps:Serial Port is closed!');
end
if abs(Steps)>32700
    error('MotorSetSteps:Variable "Steps" is to large');
end
if Steps >= 0    % 如果不为负，则只拆分就可以，否则转换成补码的形式
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
                fread( S_Sensor , S_Sensor.BytesAvailable );%读缓冲区清零
            end
            fwrite( Serial_Obj , Steps_LowBits ,'uint8');
            % 这里先尝试不用定时器，改使用arduino板子一次性测量大量数据
            % 发送测量信号
%            tic;
%             while toc<=0.09 %让转台与ADC同步 0.084is41  0.081is25 and 0.00795is the right so 0.084-0.00795=0.0761(0116之前的值)
%             end
            fwrite( S_Sensor ,4 ); % 启动测量
           
            if fread( Serial_Obj ,1 ) ~= Dev_ACK
                msgbox( 'MotorSetSteps: Setting motor steps low 8 bits failed!' );
                fwrite( S_Sensor , 3 ); % 终止测量，并发回数据 
                while S_Sensor.BytesAvailable<2*DatNum    % 等到数据到全
                end
                fread( S_Sensor , S_Sensor.BytesAvailable );
            else 
                tic;
                while toc <= abs(Steps)*0.0004096  % 如果步进为0.1度，那么0.00048一步可以正常旋转，但是如果换成0.05一步，则会出现丢步
                end
                %pause( abs(Steps)*0.00048 );%使用了while 
                % 这里先尝试不用定时器，改使用arduino板子一次性测量大量数据     
                % 1> 传感器停止采集数据
                % 2> PC采集数据传感器传来的信号
                fwrite( S_Sensor , 3 ); % 终止测量，并发回数据
                tic 
                while toc<0.01
                end
                while S_Sensor.BytesAvailable<2*DatNum    % 等到数据到全
                end   
                Dat=fread( S_Sensor , S_Sensor.BytesAvailable );
                Dat=Dat';
            end
        end 
    end
end
function RotateAndRecord_2( S_Sensor, Steps ,Cmd, MeaStartMicroDelay , MeaMiliDuration)
% RotateAndRecord_1( Serial_Obj , Steps , S_Sensor,  Real_Angle,SGSP_Angle, AxesRealtimeSignal_handle)
% Real_Angle=[ Real_MeaInitialAngle Real_MeaFinalAngle ]   SGSP_Angle=[ SGSP_MeaInitialAngle SGSP_MeaFinalAngle ]
% 程序用于支持底层实现即传即画的功能
% By chenguang Email:chen@zchenguang.com UCAS

% Constants and varibles might be used 
Max_Steps = 32700;

% 要对串口操作，必须先清零缓冲区
if S_Sensor.BytesAvailable
    fread( S_Sensor , S_Sensor.BytesAvailable );%读缓冲区清零
end

% 1> Check the serial status
if ~strcmp( S_Sensor.Status,'open')
    error('Serial Port is closed!');
end
if abs(Steps)>Max_Steps
    error('MotorSetSteps:Variable "Steps" is to large');
end


if MeaStartMicroDelay<0 || MeaStartMicroDelay>16355
    error('Measure Start Delay is too large');
end

if MeaMiliDuration<0
    error('Measure Duration is too large');
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
    Steps_HighBits = fix( Steps_Compl  / 256 ) + 128;
end

MeaStartMicroDelay_H =  fix( MeaStartMicroDelay./256 );
MeaStartMicroDelay_L = MeaStartMicroDelay - MeaStartMicroDelay_H*256;

MeaMiliDuration_H =  fix( MeaMiliDuration./256 );
MeaMiliDuration_L = MeaMiliDuration - MeaMiliDuration_H*256;

% 2> Confirm and write the steps to write to the device
fwrite( S_Sensor , Cmd , 'uint8' );

fwrite( S_Sensor ,  MeaStartMicroDelay_H , 'uint8' );
fwrite( S_Sensor ,  MeaStartMicroDelay_L , 'uint8' );
fwrite( S_Sensor ,  MeaMiliDuration_H , 'uint8')
fwrite( S_Sensor ,  MeaMiliDuration_L , 'uint8' )

fwrite( S_Sensor , 2 , 'uint8' );
fwrite( S_Sensor , 0 , 'uint8' );
fwrite( S_Sensor , Steps_HighBits , 'uint8' );
fwrite( S_Sensor , Steps_LowBits ,'uint8');
disp('Am I right?')

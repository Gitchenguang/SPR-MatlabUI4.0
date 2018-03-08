function [ TimeDelayCmd, RotateCmd ] = CmdGenerator( Steps , MeaStartMicroDelay , MeaMiliDuration )

% Constants and varibles might be used 
Max_Steps = 32700;

if abs(Steps)>Max_Steps
    error('MotorSetSteps:Variable "Steps" is to large');
end


if MeaStartMicroDelay<0 || MeaStartMicroDelay>16355
    error('Measure Start Delay is too large');
end

if MeaMiliDuration<0
    error('Measure Duration is too large');
end

disp('Steps to rotate');
disp(Steps);

if Steps >= 0    % 如果不为负，则只拆分就可以，否则转换成补码的形式
%    IntSteps = uint16( Steps );
%     HighBit1 = fix(Steps./256);
%     if (Steps - HighBit1*256 -255 )>0
%         HighBit2 = 1;
%     else 
%         HighBit2 = 0;
%     end
    Steps_HighBits = uint16( floor( Steps/256 ) );
    Steps_LowBits = uint16( Steps- Steps_HighBits*256 );
    if Steps_LowBits==256
        Steps_LowBits = 0;
        Steps_HighBits = Steps_HighBits + 1;
    end
    disp('Steps');
    disp(Steps);
    disp('Steps_LowBits');
    disp(Steps_LowBits);
    disp('Steps_HighBits');
    disp(Steps_HighBits);    
%    Steps_LowBits = fix( Steps - Steps_HighBits*256);
else 
    Steps_Compl = 2^15 + Steps ;
    Steps_HighBits = uint16(floor(Steps_Compl/256 ));
    Steps_LowBits = Steps_Compl - Steps_HighBits*256;
    if Steps_LowBits==256
        Steps_LowBits = 0;
        Steps_HighBits = Steps_HighBits + 1;
    end
    Steps_HighBits = Steps_HighBits + 128;
    disp('Steps_Compl');
    disp(Steps_Compl);
    disp('Steps_LowBits');
    disp(Steps_LowBits);
    disp('Steps_HighBits');
    disp(Steps_HighBits);    
%     if ( flag == 0)
%         disp('in')
%         Steps_LowBits = 0
%         Steps_HighBits = fix( Steps_Compl  / 256 ) + 128
%     else
%         disp('in else')
%         Steps_LowBits = fix(abs( Steps_Compl -  fix( Steps_Compl  / 256 )*256))
%         Steps_HighBits = fix( Steps_Compl  / 256 ) + 128
%     end
end
MeaStartMicroDelay_H =  fix( MeaStartMicroDelay./256 );
MeaStartMicroDelay_L = MeaStartMicroDelay - MeaStartMicroDelay_H*256;

MeaMiliDuration_H =  fix( MeaMiliDuration./256 );
MeaMiliDuration_L = MeaMiliDuration - MeaMiliDuration_H*256;

TimeDelayCmd =[ MeaStartMicroDelay_H, MeaStartMicroDelay_L, MeaMiliDuration_H, MeaMiliDuration_L ];
RotateCmd= [ 2 , 0 , Steps_HighBits, Steps_LowBits];
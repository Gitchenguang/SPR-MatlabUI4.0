function [ New_Pos_Info ]= PosInvTranslation( RotateAngle ,Position_Info )
% ��Ҫ��ת�ĽǶ�����ת��Ϊת̨�Ŀ�������ԭʼλ��,���ｫ���������ת̨������λ��
% ��������Position_Info

% Edited by chenguang 2015-06-07 && Email:guang@zchenguang.com

% Position_Info �����ת̨ԭ��ԭʼ����  ת̨ԭʼ�Ƕ� ת̨��ǰԭʼ���� ת̨��ǰ�Ƕ�����  �������ڱ�־
% Position_Info.Origin_CyclePostion = MotorPos;
% Position_Info.Origin_Angle = 0; 
% Position_Info.Current_CyclePostion = MotorPos;
% Position_Info.Current_Angle 
% Position_Info.CycleFlag 

New_Pos_Info.Origin_CyclePostion = Position_Info.Origin_CyclePostion;
New_Pos_Info.Origin_Angle = Position_Info.Origin_Angle;

New_Pos_Info.Current_Angle = Position_Info.Current_Angle + RotateAngle;
New_Pos_Info.CycleFlag = Position_Info.CycleFlag ;

Steps = RotateAngle/0.00015625;
FinalRawPos = Steps + Position_Info.Current_CyclePostion;
if FinalRawPos < 0
    while FinalRawPos < 0
        New_Pos_Info.CycleFlag = -1 + New_Pos_Info.CycleFlag ;
        New_Pos_Info.Current_CyclePostion = 1000000 + FinalRawPos;
        %disp('Forward final')
        FinalRawPos = FinalRawPos + 1000000;
    end
elseif FinalRawPos >= 1000000   % 2015 08 31 ��ӡ�=����
    while FinalRawPos >= 1000000
        New_Pos_Info.CycleFlag = 1 + New_Pos_Info.CycleFlag;
        New_Pos_Info.Current_CyclePostion = FinalRawPos - 1000000;
        %disp('Backward final')
        FinalRawPos = FinalRawPos - 1000000;
    end
else 
    New_Pos_Info.Current_CyclePostion = FinalRawPos;
    New_Pos_Info.CycleFlag = 0 + New_Pos_Info.CycleFlag;
end

%  �����Position д����Postion
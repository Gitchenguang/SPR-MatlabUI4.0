function varargout = SPR_SystemUI(varargin)
% SPR_SYSTEMUI MATLAB code for SPR_SystemUI.fig
%      SPR_SYSTEMUI, by itself, creates a new SPR_SYSTEMUI or raises the existing
%      singleton*.
%
%      H = SPR_SYSTEMUI returns the handle to a new SPR_SYSTEMUI or the handle to
%      the existing singleton*.
%
%      SPR_SYSTEMUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPR_SYSTEMUI.M with the given input arguments.
%
%      SPR_SYSTEMUI('Property','Value',...) creates a new SPR_SYSTEMUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SPR_SystemUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SPR_SystemUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SPR_SystemUI

% Last Modified by GUIDE v2.5 19-Jun-2017 16:33:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SPR_SystemUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SPR_SystemUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SPR_SystemUI is made visible.
function SPR_SystemUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SPR_SystemUI (see VARARGIN)

% Choose default command line output for SPR_SystemUI
handles.output = hObject;
% 
% ���ó�������Ҫ��ȫ�ֱ���
handles.ArduinoMega = [];

% �˲���ϵ��
handles.Window_Size = 1300;
handles.Window_Size_1 = 130;

% Pseudo original angle,�����Դ�ֵΪԭ��Ĳο���

handles.Rotate_Scan_Rate = 640;
handles.Full_Range_Voltage =  3.3; % Full Range 3.3 V
% ��������ز���(����������ʼ������ֹ�ǵ�UserData�洢�����Ϣ��ʹ��handles����������Щ����)


handles.Resonance_Angle = [];
handles.AmbientTemperature = []; % �����¶�
handles.Resonance_Time = [];

Temp = 25;
set( handles.DisplayTemp , 'String' , Temp );
set( handles.SetTemperatureButton , 'UserData',Temp );
set( handles.StartTempRegButton , 'UserData', 0 );

set( handles.PushMeaInitialAngle , 'UserData',0 );
set( handles.PushMeaFinalAngle , 'UserData',0 );

% ������־λ
StopFlag = 0;
set( handles.PushMeaStop , 'UserData' , StopFlag );


% �䶯��
PumpSpeed = 50;
set( handles.TextPumpVelocity , 'String' , num2str(PumpSpeed) );
set( handles.TextPumpVelocity , 'UserData' , PumpSpeed );
% ����õ�������ʱ��
Pump = [] ;
set( handles.PushPumpVelocity , 'UserData' , Pump);

% ��ʼ�������б�,�������ʼ�����ٶȷǳ���
% S_Info = instrhwinfo('serial');
% set( handles.COMPopUp , 'String' ,S_Info.SerialPorts );
% 
%*******Arduino�����������Ͷ���
handles.MachineQuery = 1;
handles.GetPhotodiodeVal = 2;
% 3,4 ,5 reserved
handles.PumpSetSpeed = 6;%(cmd,param)
handles.TimerStart = 7;
handles.TimerStop = 8;

handles.TemperatureCellPrism =9;% return 4
handles.UnoIdle = 10;
handles.CellPrismSetTemperature = 11;
handles.CellPrismOn = 12;
handles.CellOn = 13;
handles.PrismOn = 14;
handles.CellOff = 15;
handles.PrismOff = 16;

handles.WaterBoxOn = 48;
handles.WaterBoxOff = 49;
handles.WaterBoxSetTemperature = 40;
handles.WaterBoxDefaultTemperature = 25;

handles.PumpOff = 17;

handles.ReturnOrigin = 18;
handles.CmdTransfer = 19;
handles.PositionInfo = 20;
handles.RotateAndMea = 21;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SPR_SystemUI wait for user response (see UIRESUME)
% uiwait(handles.figure);


% --- Outputs from this function are returned to the command line.
function varargout = SPR_SystemUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.figure;
%delete( hObject);

% --- Executes on button press in PushMeaFinalAngle.
function PushMeaFinalAngle_Callback(hObject, eventdata, handles)
% hObject    handle to PushMeaFinalAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = {'������ֹ�Ƕȣ�0�b��75�b��:'};
dlg_title = '�趨��ֹ��';
num_lines = 1;
def = {num2str( get( hObject ,'UserData') ) };
answer = inputdlg(prompt,dlg_title,num_lines,def);
if( ~isempty( answer ))
    StopAngle = str2num( answer{1} );
    StartAngle = get( handles.PushMeaInitialAngle, 'UserData');
    
    if (StopAngle>=0) && ( StopAngle <= 75 ) &&( StopAngle> StartAngle )
        set( hObject, 'UserData' , StopAngle );
        set( handles.EditMeaFinalAngle , 'String',answer{1} );
    else
        msgbox('��Ч����ֹ�Ƕ�ֵ');
    end
end


% SetMeaFinalAngle( 'SPR_SystemUI',handles.figure );
% MeaFinalAngle = get(hObject,'UserData');
% if isempty( MeaFinalAngle )
%     msgbox('��������ȷ���ò�����ֹ��','��ֹ������','error');
% else
%     set( handles.EditMeaFinalAngle , 'String',num2str( MeaFinalAngle ) );
% end


% --- Executes on button press in PushMeaInitialAngle.
function PushMeaInitialAngle_Callback(hObject, eventdata, handles)
% hObject    handle to PushMeaInitialAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = {'������ʼ�Ƕȣ�0�b��75�b��:'};
dlg_title = '�趨��ʼ��';
num_lines = 1;
def = {num2str( get( hObject ,'UserData') ) };
answer = inputdlg(prompt,dlg_title,num_lines,def);
StartAngle = str2num( answer{1} );
if( ~isempty( answer ))
    if (StartAngle>=0) && ( StartAngle <= 75 )
        set( hObject, 'UserData' , StartAngle );
        set( handles.EditMeaInitialAngle , 'String',answer{1} );
    else
        msgbox('��Ч����ʼ�Ƕ�ֵ');
    end
end

% SetMeaInitialAngle( 'SPR_SystemUI',handles.figure );
% MeaInitialAngle = get(hObject,'UserData');
% if isempty( MeaInitialAngle )
%     msgbox('��������ȷ���ò�����ʼ��','��ʼ������','error');
% else
%     set( handles.EditMeaInitialAngle , 'String',num2str( MeaInitialAngle ) );
% end
% �ж���ʼ������ֹ�ǵĴ�С

% --- Executes on button press in HwRefresh.
function HwRefresh_Callback(hObject, eventdata, handles)
% hObject    handle to HwRefresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% �ȴ򿪴������д��� 
% ���֮ǰû�м�������ôUserDataӦ��Ϊ�գ�����Ҫ�����
% if ~isempty( get( handles.HwRefresh,'UserData' ) )
%     S_Objs = get( handles.HwRefresh,'UserData' );
%     for i=1:length( S_Objs )
%         if strcmp(class( S_Objs{ 1, i} ) , 'serial')
%             fclose( S_Objs{1,i} );
%             delete( S_Objs{1,i} );
%         end
%     end 
%     S_Objs = [];
% end  

S_Info = instrhwinfo('serial');
set( handles.COMPopUp , 'String' ,S_Info.SerialPorts );
guidata(hObject,handles);

% --- Executes on button press in HwConnect.
function HwConnect_Callback(hObject, eventdata, handles)
% hObject    handle to HwConnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = get( handles.COMPopUp , 'Value' );
str = get( handles.COMPopUp , 'String' );
handles.ArduinoMega = serial( str{val} , 'BaudRate',115200, 'InputBufferSize',102400 );
fopen( handles.ArduinoMega );
msgbox('System connected successfully');
% ���� Arduino Mega �� SGSP ��PC
% S_Objs = get( handles.HwRefresh , 'UserData' );
% for i=1:length( S_Objs )
%     if S_Objs{1,i}.BytesAvailable ~= 0   %������������
%         fread( S_Objs{1,i} , S_Objs(1,i).BytesAvailable );
%     end
%     fwrite( S_Objs{1,i} , 1 ,'int8' );
%     fwrite( S_Objs{1,i} , 1 ,'int8' );
%     fwrite( S_Objs{1,i} , 1 ,'int8' );
%     fwrite( S_Objs{1,i} , 1 ,'int8' );
%     pause(1) % ת̨��Ӧ��Ҫʱ��
%     if S_Objs{1,i}.BytesAvailable == ( 33+4 )
%         handles.S_SGSP = S_Objs{ 1, i};
%         handles.SGSP_Status ='idle';
%             if S_Objs{1,i}.BytesAvailable
%                 fread( S_Objs{1,i} , S_Objs{1,i}.BytesAvailable );%������������
%             end
%     elseif S_Objs{ 1 , i }.BytesAvailable == ( 4*2 )
%         handles.ArduinoMega = S_Objs{ 1 , i };
%         handles.Arduino_Status = 'idle';
%         if S_Objs{1,i}.BytesAvailable
%             fread( S_Objs{1,i} , S_Objs{1,i}.BytesAvailable );%������������
%         end
%     else
%         if S_Objs{1,i}.BytesAvailable
%             fread( S_Objs{1,i} , S_Objs{1,i}.BytesAvailable );%������������
%         end
%         fclose( S_Objs{ 1 , i } );
%     end
% end
% 
% if ~isempty( handles.ArduinoMega ) && ~isempty( handles.S_SGSP )
%     % ����Ӧ�ռ���Ϊ�״̬
%     
%     % Msg : All hardware done!
%     msgbox( 'Hardwares are connected, done' , 'Status' );
% else
%     if isempty( handles.ArduinoMega )
%         msgbox( 'Error:Arduino Mega is not connected' , 'ArduinoMega','error' );
%     end
%     if isempty( handles.S_SGSP )
%         msgbox( 'Error:SGSP is not connected' , 'SGSP','error' );
%     end
% end

guidata( hObject , handles );

% --- Executes on button press in HwDisconnect.
function HwDisconnect_Callback(hObject, eventdata, handles)
% hObject    handle to HwDisconnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isa( handles.ArduinoMega , 'serial')
    if strcmp( handles.ArduinoMega.Status , 'open')
        fclose( handles.ArduinoMega );
        handles.ArduinoMega = [];
        msgbox('System disconnected successfully');
    end
end
guidata( hObject , handles );

% --- Executes on button press in OriginalPointCheck.
function OriginalPointCheck_Callback(hObject, eventdata, handles)
% hObject    handle to OriginalPointCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% �������ػ�
disp('Return to zero')
ArduinoMega = handles.ArduinoMega;
%SGSP = handles.S_SGSP;
%  �����ٶ�250�ȽϺ��ʣ����������ٻ���1�ȣ�ʹ�������ػָ�ԭ��״̬
if( ArduinoMega.BytesAvailable)
    fread(ArduinoMega,ArduinoMega.BytesAvailable);
end

fwrite( ArduinoMega , handles.ReturnOrigin ,'uint8' ); % ԭ��У׼����
ArduinoMega.BytesAvailable
while( ~ArduinoMega.BytesAvailable)
end
tmp = fread(ArduinoMega,ArduinoMega.BytesAvailable);
if( tmp == 44 )
    msgbox( 'Error:System is not responding' , 'System','error' );
else
    pause(5);
    MotorPos = MotorReadPos( ArduinoMega , handles.PositionInfo);
    CurrentError = mod( MotorPos , 64 );
    if CurrentError ~=0     
        ToModify = 64- CurrentError;
        Steps_HighBits = fix( ToModify / 256 );
        Steps_LowBits = ToModify - Steps_HighBits*256;
        fwrite( ArduinoMega , handles.CmdTransfer , 'uint8' );
        % 2> Confirm and write the steps to write to the device
        fwrite( ArduinoMega , 2 , 'uint8' );
        fwrite( ArduinoMega , 0 , 'uint8' );
        fwrite( ArduinoMega , Steps_HighBits , 'uint8' );
        fwrite( ArduinoMega , Steps_LowBits ,'uint8');
        pause(2);
    end
    MotorPos = MotorReadPos( ArduinoMega , handles.PositionInfo);
    
    % ����Position_Info�ṹ��
    Position_Info.Origin_CyclePostion = MotorPos;
    Position_Info.Origin_Angle = 90;    

    Position_Info.Current_CyclePostion = MotorPos;
    Position_Info.Current_Angle = 90;   % �˴����������������Origin_Anlge ������һ��

    Position_Info.CycleFlag = 0;

    handles.Position_Info = Position_Info;

    set( handles.SampleOn,'UserData',0);
end

% �趨ˮ��Ĭ���¶�
setTemp = Temp2ADCVal( handles.WaterBoxDefaultTemperature);
setTemp_H = fix( setTemp / 256 );
setTemp_L =fix( setTemp -setTemp_H*256 );
WaterBoxTemp_H = setTemp_H;
WaterBoxTemp_L = setTemp_L;
%fwrite( ArduinoMega , handles.WaterBoxSetTemperature , 'uint8');
%fwrite( ArduinoMega , WaterBoxTemp_H , 'uint8');
%fwrite( ArduinoMega , WaterBoxTemp_L , 'uint8');  

fwrite( ArduinoMega , handles.WaterBoxOn , 'uint8');
disp('WaterBoxOn');
% SetRotateSpeed( SGSP , 250 );
% while( ~ArduinoMega.BytesAvailable )
% end
% SetRotateSpeed( SGSP , 0 );
% disp('Endstop');
% if( ArduinoMega.BytesAvailable)
%     fread(ArduinoMega,ArduinoMega.BytesAvailable);
% end
% SetRotateSteps( SGSP , -6400); % �ָ���������
% 
% MotorPos = MotorReadPos( SGSP );
% handles.SGSP_Status = 'idle';
% % ����Position_Info�ṹ��
% Position_Info.Origin_CyclePostion = MotorPos;
% Position_Info.Origin_Angle = 90;    % ����ADXL�뼤��������ļн�Ϊ45�ȣ����Ե�ADXL�ĽǶ�Ϊ��ֱ�����ʱ������������ĽǶȾ�Ϊ45��Ҳ��ת̨�ĵ�ǰ�Ƕ�ֵ
% 
% Position_Info.Current_CyclePostion = MotorPos;
% Position_Info.Current_Angle = 90;   % �˴����������������Origin_Anlge ������һ��
% 
% Position_Info.CycleFlag = 0;
% 
% set( handles.SampleOn,'UserData',0);
% 
% handles.Position_Info = Position_Info;

guidata( hObject , handles );


% --- Executes on button press in PushPumpStop.
function PushPumpStop_Callback(hObject, eventdata, handles)
% hObject    handle to PushPumpStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ArduinoMega = handles.ArduinoMega;
%PumpSpeed = 0 ;
%set( handles.TextPumpVelocity , 'UserData' , PumpSpeed );
%set( handles.TextPumpVelocity , 'String' , num2str(PumpSpeed) );
fwrite( ArduinoMega , 6 , 'uint8' );
fwrite( ArduinoMega , 0 , 'uint8'); % 

% --- Executes on button press in PushPumpStart.
function PushPumpStart_Callback(hObject, eventdata, handles)
% hObject    handle to PushPumpStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ArduinoMega = handles.ArduinoMega;
PumpSpeed = get( handles.TextPumpVelocity , 'UserData');
fwrite( ArduinoMega , 6 , 'uint8' );
fwrite( ArduinoMega , fix(PumpSpeed*1.5) , 'uint8'); % 


% --- Executes on button press in PushPumpVelocity.
function PushPumpVelocity_Callback(hObject, eventdata, handles)
% hObject    handle to PushPumpVelocity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%SetPumpVelocity( 'SPR_SystemUI',handles.figure );

prompt = {'�����������٣���λuL/mL��:'};
dlg_title = '�趨����';
num_lines = 1;
def = {num2str( get(handles.TextPumpVelocity ,'UserData') ) };
answer = inputdlg(prompt,dlg_title,num_lines,def);
Speed = str2num( answer{1} );
if( ~isempty( answer ))
    if (Speed>=0) && ( Speed <= 200 )
        set( handles.TextPumpVelocity , 'UserData' , Speed );
        set( handles.TextPumpVelocity , 'String',answer{1} );
    else
        msgbox('��Ч������ֵ');
    end
end

function TextPumpVelocity_Callback(hObject, eventdata, handles)
% hObject    handle to TextPumpVelocity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PumpSpeed = get(handles.TextPumpVelocity , 'String');
set( handles.TextPumpVelocity , 'String' , num2str(PumpSpeed) );
set( handles.TextPumpVelocity , 'UserData' , num2str(PumpSpeed) );
% Hints: get(hObject,'String') returns contents of TextPumpVelocity as text
%        str2double(get(hObject,'String')) returns contents of TextPumpVelocity as a double


% --- Executes during object creation, after setting all properties.
function TextPumpVelocity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TextPumpVelocity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushMeaStop.
function PushMeaStop_Callback(hObject, eventdata, handles)
% hObject    handle to PushMeaStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
StopFlag = 1;
set( hObject , 'UserData' , StopFlag );

ArduinoMega = handles.ArduinoMega;

fwrite( ArduinoMega , 6 , 'uint8' );
fwrite( ArduinoMega , 0 , 'uint8'); % 15uL/min
fwrite( ArduinoMega, handles.UnoIdle ,'uint8');
fwrite( ArduinoMega, 49 ,'uint8'); % ��ˮ���¿�
%set( handles.TextPumpVelocity , 'String' , 0 );
%set( handles.TextPumpVelocity , 'UserData' , 0);
guidata( hObject ,handles );

% --- Executes on button press in PushMeaStart.
function PushMeaStart_Callback(hObject, eventdata, handles)
% hObject    handle to PushMeaStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ArduinoMega = handles.ArduinoMega;
Window_Size = handles.Window_Size;
Window_Size_1 = 300;%handles.Window_Size_1;
Full_Range_Voltage = handles.Full_Range_Voltage;
Position_Info = handles.Position_Info;

% Data�����ʽ����
FormatSpec_F = 'F%d_%d_%d_%d_%d%dConf%d_%d.mat';
FormatSpec_B = 'B%d_%d_%d_%d_%d_%dConf%d_%d.mat';
FormatSpec_MeaAgnleTime = 'LastMea%d_%d_%d_%d_%d_%d.mat';
FormatSpec_MeaPump = 'LastMeaPump%d_%d_%d_%d_%d_%d.mat';

FolderName = clock;
FolderName = sprintf( 'Dat%d_%d_%d_%d',  FolderName(1,2:5));
SavePath = [ pwd ,'\', FolderName ];
mkdir(SavePath);
SavePath = [SavePath , '\']; 


if ~isempty( handles.Resonance_Angle ) ||~isempty( get( handles.PushPumpVelocity, 'UserData') )||~isempty( handles.AmbientTemperature )
    Pump =[];
    set( handles.PushPumpVelocity, 'UserData' , Pump );
    handles.Resonance_Angle= [] ;
    handles.Resonance_Time = [] ;
    handles.AmbientTemperature = [];
    guidata( hObject ,handles );
end
Resonance_Angle = handles.Resonance_Angle;
Resonance_Time = handles.Resonance_Time;
AmbientTemperature = handles.AmbientTemperature;

% ����������
MeaInitialAngle = get( handles.PushMeaInitialAngle, 'UserData' );
MeaFinalAngle = get( handles.PushMeaFinalAngle , 'UserData' );

% �Ƕ�ת�� %Ϊ��ø��õľ��ȣ�ʹת̨��ת�ĽǶȸ���һ�£�����ֻ����С�����һλ����ֵ
SGSP_MeaInitialAngle = AngleTransform( MeaInitialAngle );
SGSP_MeaFinalAngle = AngleTransform( MeaFinalAngle );
Real_MeaInitialAngle = AngleInverseTransform( SGSP_MeaInitialAngle );
Real_MeaFinalAngle = AngleInverseTransform( SGSP_MeaFinalAngle );

Real_Angle = [ Real_MeaInitialAngle Real_MeaFinalAngle ];
SGSP_Angle = [ SGSP_MeaInitialAngle SGSP_MeaFinalAngle ];
Angle_Rotate = abs((SGSP_MeaInitialAngle-SGSP_MeaFinalAngle));
Angle_Step = Angle_Rotate*6400; % Ϊ�ֲ���Ƕ�ɨ�������ı��� ��/��
MeaMiliDuration = 0.4096*Angle_Step;%�Ժ���Ϊ��λ
MeaStartMicroDelay =0;  %us
Angle_Scale = 0.0003815;

% ����ϵ��ʼ��
axis( handles.AxesRealtimeSignal , [Real_MeaInitialAngle Real_MeaFinalAngle 0 3.5 ]); 
axis( handles.AxesPumpVelocity , [0 300 0 14 ]); 
axis( handles.AxesResonAngleTime , [0 300 Real_MeaInitialAngle-1 Real_MeaFinalAngle+1 ]); 
axis( handles.AxesResonDiff , [ 0 300 0 3.5 ]); 


% ��ת����ʼ��
if isempty( ArduinoMega )
    msgbox('�뱣��ϵͳ����״̬','������������');
else
    % ��ת����ʼ��
    Angle_To_Rotate = SGSP_MeaInitialAngle - Position_Info.Current_Angle;
    Rotate_Directon = Angle_To_Rotate / abs( Angle_To_Rotate );
    for i=1:1:( abs( Angle_To_Rotate ))
        SetRotateUnit( ArduinoMega , Rotate_Directon ,  handles.CmdTransfer );
        disp('��λ��')
    end
    pause(1);% ��֤ת̨�Ѿ�ֹͣ�˶���,�����ȡλ�ò�׼ȷ
    %%%
    % ��ת�󣬼�¼��ǰ��ת�ĽǶȵ�ֵ����ԭʼλ��ֵ��CycleFlagֵ�����ʵ�����
    New_Pos_Info = PosInvTranslation( Angle_To_Rotate ,Position_Info );
    MotorPos = MotorReadPos( ArduinoMega , handles.PositionInfo);
    if New_Pos_Info.Current_CyclePostion ~= MotorPos
        New_Pos_Info.Current_CyclePostion
        ToRotate = New_Pos_Info.Current_CyclePostion-MotorPos;
        if abs( ToRotate )< 6400*4  % 4������
            SetRotateSteps( ArduinoMega , ToRotate ,handles.CmdTransfer); 
        else
            if ToRotate > 0
                SetRotateSteps( ArduinoMega , New_Pos_Info.Current_CyclePostion-MotorPos - 1000000,handles.CmdTransfer );
            else
                SetRotateSteps( ArduinoMega , New_Pos_Info.Current_CyclePostion-MotorPos + 1000000,handles.CmdTransfer );
            end
        end     
    end
    % ��ת��ɺ� RawPosition �� CycleFlagsд��Position_Info�ṹ����
    Position_Info = New_Pos_Info;
    % �������״̬
    Mea_Step_Angle = handles.Rotate_Scan_Rate / 6400;
    Mea_Direction_Flag = 1;
    Voltage_Half_Cycle = [];
    % ��������
    Temp =get( handles.SetTemperatureButton , 'UserData');
    setTemp = Temp2ADCVal( Temp );
    setTemp_H = fix( setTemp / 256 );
    setTemp_L =fix( setTemp -setTemp_H*256 );
    PrismTemp_H = setTemp_H;
    PrismTemp_L = setTemp_L;
    
    fwrite( ArduinoMega , handles.CellPrismSetTemperature , 'uint8');
    fwrite( ArduinoMega , setTemp_H , 'uint8');
    fwrite( ArduinoMega , setTemp_L , 'uint8');    
    fwrite( ArduinoMega , PrismTemp_H , 'uint8');
    fwrite( ArduinoMega , PrismTemp_L , 'uint8');  
    pause(0.5);
    fwrite( ArduinoMega , handles.CellPrismOn ,'uint8');
    fwrite( ArduinoMega , handles.WaterBoxOn ,'uint8');
    % ����䶯��ģʽ 

    PumpSpeed = get( handles.TextPumpVelocity , 'UserData' );
    Pump.Speed = PumpSpeed;
    Pump.Time = 0;
    fwrite( ArduinoMega , 6 , 'uint8' );
    fwrite( ArduinoMega , fix(PumpSpeed*1.5) , 'uint8'); % 15uL/min
    set( handles.TextPumpVelocity , 'String' , num2str(PumpSpeed) );
    set( handles.TextPumpVelocity , 'UserData' , PumpSpeed );
    set( handles.PushPumpVelocity , 'UserData' , Pump);
    
    % ������ʱ��
    handles.MeaStartTime = clock;
    guidata( hObject ,handles );
    StopFlag = 0;
    set( handles.PushMeaStop , 'UserData' , StopFlag );
    while ~get( handles.PushMeaStop , 'UserData')
        % �ж��Ƿ���Ҫ�ı�����
        if( get( handles.ChangeTempCheckBox ,'Value') )
            Temp =0;
            while( Temp <18 || Temp > 35 )
                tmp = inputdlg('������Ҫ�趨���¶�','�ı��¶�');
                Temp = str2double( tmp{1} );
            end
            set( handles.DisplayTemp , 'String' , Temp );
            set( handles.SetTemperatureButton , 'UserData',Temp );
            setTemp = Temp2ADCVal( Temp );
            setTemp_H = fix( setTemp / 256 );
            setTemp_L =fix( setTemp -setTemp_H*256 );
            PrismTemp_H = setTemp_H;
            PrismTemp_L = setTemp_L;
            fwrite( ArduinoMega , handles.CellPrismSetTemperature , 'uint8');
            fwrite( ArduinoMega , setTemp_H , 'uint8');
            fwrite( ArduinoMega , setTemp_L , 'uint8');    
            fwrite( ArduinoMega , PrismTemp_H , 'uint8');
            fwrite( ArduinoMega , PrismTemp_L , 'uint8');  

            pause(1);disp('Pause 1 seconds');
        elseif( get( handles.ChangeSampleRateCheckBox ,'Value'))
            PumpSpeed=-1;
            while( PumpSpeed < 0 || PumpSpeed > 200 )
                tmp = inputdlg('������Ҫ�趨������','�ı�����');
                PumpSpeed = str2double( tmp{1} );            
            end
            fwrite( ArduinoMega , 6 , 'uint8' );
            fwrite( ArduinoMega , fix(PumpSpeed*1.5), 'uint8'); % 15uL/min
            set( handles.TextPumpVelocity , 'String' , num2str(PumpSpeed) );
            set( handles.TextPumpVelocity , 'UserData' , PumpSpeed );
            pause(2);disp('Pause 2 seconds');
        elseif( get(handles.ChangeSampleCheckBox , 'Value'))
            % ͣ��
            fwrite( ArduinoMega , 6 , 'uint8' );
            fwrite( ArduinoMega , 0, 'uint8');
            choice='No';
            while( ~strcmp( choice , 'Yes') && ~strcmp( choice , 'Cancel') )
                choice = questdlg('��Ʒ�Ѿ���������','����');
            end
            PumpSpeed = get( handles.TextPumpVelocity , 'UserData' );
            fwrite( ArduinoMega , 6 , 'uint8' );
            fwrite( ArduinoMega , fix(PumpSpeed*1.5) , 'uint8'); % 15uL/min
            pause(2);
        end
        set( handles.RegularCheckBox ,'Value',1.0 );
        
        % ��ȡ�¶�ֵ
        CurrentTemp = ReadTemp( ArduinoMega , 9 );
        %���ȹ��䱣��
        if ( CurrentTemp(1)<10 || CurrentTemp(2)<10 || CurrentTemp(1)>40|| CurrentTemp(2)>40)
            fwrite( ArduinoMega , 10 ,'uint8');
        end    
        %***************
        disp('������ʼ')
        %cla(handles.AxesRealtimeSignal)
        if(Position_Info.Current_Angle == SGSP_MeaInitialAngle && Mea_Direction_Flag==1 ) 
            disp('Forward');
            %[ Dat ,Real_Angle_RT Dat_Len]=RotateAndRecord_1( SGSP , Angle_Step*Mea_Direction_Flag , ArduinoMega ,Real_Angle ,SGSP_Angle, handles.AxesRealtimeSignal,Mea_Direction_Flag);
            if ArduinoMega.BytesAvailable
                fread( ArduinoMega , ArduinoMega.BytesAvailable );%������������
            end
            [ TimeDelayCmd, RotateCmd ] = CmdGenerator( Angle_Step*Mea_Direction_Flag , MeaStartMicroDelay , MeaMiliDuration );
            fwrite( ArduinoMega , handles.RotateAndMea , 'uint8' );
            
            fwrite( ArduinoMega ,  TimeDelayCmd(1) , 'uint8' );
            fwrite( ArduinoMega ,  TimeDelayCmd(2) , 'uint8' );
            fwrite( ArduinoMega ,  TimeDelayCmd(3) , 'uint8')
            fwrite( ArduinoMega ,  TimeDelayCmd(4) , 'uint8' )

            fwrite( ArduinoMega , RotateCmd(1) , 'uint8' );
            fwrite( ArduinoMega , RotateCmd(2) , 'uint8' );
            fwrite( ArduinoMega , RotateCmd(3) , 'uint8' );
            fwrite( ArduinoMega , RotateCmd(4) ,'uint8');
            %RotateAndRecord_2( ArduinoMega, Angle_Step*Mea_Direction_Flag ,handles.RotateAndMea , 0 , MeaMiliDuration );
            disp('RotateCmd(3)*256+RotateCmd(4)');
            RotateCmd(3)*256+RotateCmd(4)
            Dat_Ind = 1;
            Dat_Conversion_Ind = 0;
            
            tic;
            while toc<( MeaMiliDuration/1000+0.1 )
                pause(0.1);
                if ArduinoMega.BytesAvailable
                    Dat_Incre = ArduinoMega.BytesAvailable;
                    Dat_Raw(1,Dat_Ind:(Dat_Ind+Dat_Incre-1))=fread( ArduinoMega , Dat_Incre );
                    Dat_Ind=Dat_Ind+Dat_Incre;
                    if Dat_Ind > 3 
                        Dat_Conversion_Cend = fix( (Dat_Ind-1)/2 ); 
                        if ( (Dat_Conversion_Cend - Dat_Conversion_Ind)>=1 )
                            ind = (Dat_Conversion_Ind+1):1:Dat_Conversion_Cend;
                            Dat( 1 ,ind ) = (Dat_Raw( 1,2*ind-1 )*256 + Dat_Raw( 1,2*ind ))/1023*Full_Range_Voltage;
                            Real_Angle_RT(1,(Dat_Conversion_Ind+1):1:Dat_Conversion_Cend ) = AngleInverseTransform(SGSP_Angle(1,1) + ( (Dat_Conversion_Ind+1):1:Dat_Conversion_Cend )*Angle_Scale*Mea_Direction_Flag );
                            %plot(handles.AxesRealtimeSignal, Real_Angle_RT , Dat );axis( handles.AxesRealtimeSignal , [Real_Angle 0 3.5] ); 
                            Dat_Conversion_Ind = Dat_Conversion_Cend;
                        end 
                    end
                end
            end
            
            Dat_Raw=[];
            cla(handles.AxesRealtimeSignal)
            plot(handles.AxesRealtimeSignal, Real_Angle_RT , Dat );axis( handles.AxesRealtimeSignal , [Real_Angle 0 3.5] ); 
            
            % ����λ��
            New_Pos_Info = PosInvTranslation( Mea_Direction_Flag*Angle_Rotate ,Position_Info );
            Position_Info = New_Pos_Info; 
            MinAngle = Data_Filter_1(  Window_Size_1 , Dat , Mea_Direction_Flag , SGSP_Angle);
            ComputeResCTime = clock - handles.MeaStartTime ; 
            ResCTime = ComputeResCTime(4)*3600+ComputeResCTime(5)*60+ComputeResCTime(6);
            Resonance_Angle = [ Resonance_Angle , MinAngle ];
            Resonance_Time = [ Resonance_Time , ResCTime ];
            AmbientTemperature =[ AmbientTemperature , CurrentTemp' ];

            RA=filter(ones(1,4)/4,1,[ones(1,4)*mean(Resonance_Angle(1)),Resonance_Angle]);
            RA=RA(5:length(RA));
            plot( handles.AxesResonAngleTime , Resonance_Time ,RA );
           % plot( handles.AxesResonAngleTime , Resonance_Time ,Resonance_Angle );
            % �¶���ͼ
            plot( handles.AxesResonDiff , Resonance_Time , AmbientTemperature(1,:) );
            hold on;
            plot( handles.AxesResonDiff , Resonance_Time , AmbientTemperature(2,:),'r' );
            hold off;
            Mea_Direction_Flag = -1;
            Current_Time = clock;
            File_Name = sprintf( FormatSpec_F, fix([Current_Time, Real_MeaInitialAngle, Real_MeaFinalAngle] ) );
            save( [SavePath File_Name] , 'Dat');
            save( [SavePath 'Importantdata'] , 'Resonance_Angle' , 'Resonance_Time','SGSP_Angle','Real_Angle','AmbientTemperature');
            Voltage_Half_Cycle = [];

        elseif(Position_Info.Current_Angle == SGSP_MeaFinalAngle && Mea_Direction_Flag == -1)  
            disp('backward')
            %[ Dat ,Real_Angle_RT Dat_Len]=RotateAndRecord_1( SGSP , Angle_Step*Mea_Direction_Flag , ArduinoMega ,Real_Angle ,flipdim( SGSP_Angle , 2), handles.AxesRealtimeSignal,Mea_Direction_Flag);
            if ArduinoMega.BytesAvailable
                fread( ArduinoMega , ArduinoMega.BytesAvailable );%������������
            end
            [ TimeDelayCmd, RotateCmd ] = CmdGenerator( Angle_Step*Mea_Direction_Flag , MeaStartMicroDelay , MeaMiliDuration );
            fwrite( ArduinoMega , handles.RotateAndMea , 'uint8' );
            fwrite( ArduinoMega ,  TimeDelayCmd(1) , 'uint8' );
            fwrite( ArduinoMega ,  TimeDelayCmd(2) , 'uint8' );
            fwrite( ArduinoMega ,  TimeDelayCmd(3) , 'uint8')
            fwrite( ArduinoMega ,  TimeDelayCmd(4) , 'uint8' )

            fwrite( ArduinoMega , RotateCmd(1) , 'uint8' );
            fwrite( ArduinoMega , RotateCmd(2) , 'uint8' );
            fwrite( ArduinoMega , RotateCmd(3) , 'uint8' );
            fwrite( ArduinoMega , RotateCmd(4) ,'uint8');
            disp('( double( RotateCmd(3)*256+RotateCmd(4)-128*256))-2^15');
            ( double( RotateCmd(3)*256+RotateCmd(4)-128*256))-2^15
            
            %RotateAndRecord_2( ArduinoMega, Angle_Step*Mea_Direction_Flag ,handles.RotateAndMea , 0 , MeaMiliDuration );
            Dat_Ind = 1;
            Dat_Conversion_Ind = 0;
            
            tic;
            while toc<( MeaMiliDuration/1000 + 0.1 )
                pause(0.1);
                if ArduinoMega.BytesAvailable
                    Dat_Incre = ArduinoMega.BytesAvailable;
                    Dat_Raw(1,Dat_Ind:(Dat_Ind+Dat_Incre-1))=fread( ArduinoMega , Dat_Incre );
                    Dat_Ind=Dat_Ind+Dat_Incre;
                    if Dat_Ind > 3 
                        Dat_Conversion_Cend = fix( (Dat_Ind-1)/2 ); 
                        if ( (Dat_Conversion_Cend - Dat_Conversion_Ind)>=1 )
                            ind = (Dat_Conversion_Ind+1):1:Dat_Conversion_Cend;
                            Dat( 1 ,ind ) = (Dat_Raw( 1,2*ind-1 )*256 + Dat_Raw( 1,2*ind ))/1023*Full_Range_Voltage;
                            Real_Angle_RT(1,(Dat_Conversion_Ind+1):1:Dat_Conversion_Cend ) = AngleInverseTransform(SGSP_Angle(1,2) + ( (Dat_Conversion_Ind+1):1:Dat_Conversion_Cend )*Angle_Scale*Mea_Direction_Flag );
                            %plot(handles.AxesRealtimeSignal, Real_Angle_RT , Dat );axis( handles.AxesRealtimeSignal , [Real_Angle 0 3.5] ); 
                            Dat_Conversion_Ind = Dat_Conversion_Cend;
                        end 
                    end
                end
            end
            
            Dat_Raw=[];
            cla(handles.AxesRealtimeSignal)
            plot(handles.AxesRealtimeSignal, Real_Angle_RT , Dat );axis( handles.AxesRealtimeSignal , [Real_Angle 0 3.5] ); 
            
            % ����λ��
            New_Pos_Info = PosInvTranslation( Mea_Direction_Flag*Angle_Rotate ,Position_Info );
            Position_Info = New_Pos_Info;
            MinAngle = Data_Filter_1(  Window_Size_1 , Dat , Mea_Direction_Flag , SGSP_Angle);
            ComputeResCTime = clock - handles.MeaStartTime ; 
            ResCTime = ComputeResCTime(4)*3600+ComputeResCTime(5)*60+ComputeResCTime(6);
            Resonance_Angle = [ Resonance_Angle , MinAngle  ];
            Resonance_Time = [ Resonance_Time , ResCTime ];
            AmbientTemperature =[ AmbientTemperature , CurrentTemp' ];
            
            RA=filter(ones(1,4)/4,1,[ones(1,4)*mean(Resonance_Angle(1:1)),Resonance_Angle]);
            RA=RA(5:length(RA));
            plot( handles.AxesResonAngleTime , Resonance_Time ,RA );
            
%            plot( handles.AxesResonAngleTime , Resonance_Time ,Resonance_Angle );
            % �¶���ͼ
            plot( handles.AxesResonDiff , Resonance_Time , AmbientTemperature(1,:) );
            hold on;
            plot( handles.AxesResonDiff , Resonance_Time , AmbientTemperature(2,:) ,'r');
            hold off;

            Mea_Direction_Flag = 1;
            Current_Time = clock;
            File_Name = sprintf( FormatSpec_B, fix([Current_Time, Real_MeaInitialAngle, Real_MeaFinalAngle] ) );
            save([SavePath File_Name] , 'Dat');
            save( [SavePath,'Importantdata'] , 'Resonance_Angle' , 'Resonance_Time','SGSP_Angle','Real_Angle','AmbientTemperature');
            Voltage_Half_Cycle = [];
        end
        
    handles.Position_Info = Position_Info;
    handles.Resonance_Angle = Resonance_Angle;
    handles.Resonance_Time = Resonance_Time;
    handles.AmbientTemperature= AmbientTemperature;
    guidata( hObject , handles );     
    end
handles.Position_Info = Position_Info;
handles.Resonance_Angle = Resonance_Angle;
handles.Resonance_Time = Resonance_Time;
handles.AmbientTemperature= AmbientTemperature;
guidata( hObject , handles );    
end


% --- Executes on button press in PushRotateUSDangle.
function PushRotateUSDangle_Callback(hObject, eventdata, handles)
% hObject    handle to PushRotateUSDangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function TextCurrentAngle_Callback(hObject, eventdata, handles)
% hObject    handle to TextCurrentAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TextCurrentAngle as text
%        str2double(get(hObject,'String')) returns contents of TextCurrentAngle as a double


% --- Executes during object creation, after setting all properties.
function TextCurrentAngle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TextCurrentAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditCurrentVoltage_Callback(hObject, eventdata, handles)
% hObject    handle to EditCurrentVoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditCurrentVoltage as text
%        str2double(get(hObject,'String')) returns contents of EditCurrentVoltage as a double


% --- Executes during object creation, after setting all properties.
function EditCurrentVoltage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditCurrentVoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditMeaInitialAngle_Callback(hObject, eventdata, handles)
% hObject    handle to EditMeaInitialAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditMeaInitialAngle as text
%        str2double(get(hObject,'String')) returns contents of EditMeaInitialAngle as a double


% --- Executes during object creation, after setting all properties.
function EditMeaInitialAngle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditMeaInitialAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditMeaFinalAngle_Callback(hObject, eventdata, handles)
% hObject    handle to EditMeaFinalAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditMeaFinalAngle as text
%        str2double(get(hObject,'String')) returns contents of EditMeaFinalAngle as a double


% --- Executes during object creation, after setting all properties.
function EditMeaFinalAngle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditMeaFinalAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushClose.
function PushClose_Callback(hObject, eventdata, handles)
% hObject    handle to PushClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%uiresume( handles.figure);

% --- Executes on button press in PushSave.
function PushSave_Callback(hObject, eventdata, handles)
% hObject    handle to PushSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PushAdvanced.
function PushAdvanced_Callback(hObject, eventdata, handles)
% hObject    handle to PushAdvanced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure.
function figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in ChangeSampleRateCheckBox.
function ChangeSampleRateCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeSampleRateCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ChangeSampleRateCheckBox


% --- Executes on button press in ChangeTempCheckBox.
function ChangeTempCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeTempCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ChangeTempCheckBox


% --- Executes on button press in SampleOn.
function SampleOn_Callback(hObject, eventdata, handles)
% hObject    handle to SampleOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set( handles.SampleOn,'UserData',0);
set( handles.SampleOn ,'Enable','inactive');
set( handles.SampleOff ,'Enable','on');
guidata( hObject , handles );  

% --- Executes on button press in SampleOff.
function SampleOff_Callback(hObject, eventdata, handles)
% hObject    handle to SampleOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set( handles.SampleOn,'UserData',1);
set( handles.SampleOn ,'Enable','on');
set( handles.SampleOff ,'Enable','inactive');
guidata( hObject , handles );  


% --- Executes on button press in SetTemperatureButton.
function SetTemperatureButton_Callback(hObject, eventdata, handles)
% hObject    handle to SetTemperatureButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ArduinoMega = handles.ArduinoMega;
Temp =0;
while( Temp <18 || Temp > 40 )
    tmp = inputdlg('������Ҫ�趨���¶�ֵ','�ı��¶�');
    Temp = str2double( tmp );
end
set( handles.DisplayTemp , 'String' , Temp );
set( handles.SetTemperatureButton , 'UserData',Temp );
setTemp = Temp2ADCVal( Temp );
setTemp_H = fix( setTemp / 256 );
setTemp_L =fix( setTemp -setTemp_H*256 );
PrismTemp_H = setTemp_H;
PrismTemp_L = setTemp_L;
fwrite( ArduinoMega , 11 , 'uint8');
fwrite( ArduinoMega , setTemp_H , 'uint8');
fwrite( ArduinoMega , setTemp_L , 'uint8');    
fwrite( ArduinoMega , PrismTemp_H , 'uint8');
fwrite( ArduinoMega , PrismTemp_L , 'uint8');  


function DisplayTemp_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DisplayTemp as text
%        str2double(get(hObject,'String')) returns contents of DisplayTemp as a double


% --- Executes during object creation, after setting all properties.
function DisplayTemp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DisplayTemp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1


% --- Executes on button press in StartTempRegButton.
function StartTempRegButton_Callback(hObject, eventdata, handles)
% hObject    handle to StartTempRegButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ArduinoMega = handles.ArduinoMega;
if(~get( handles.StartTempRegButton , 'UserData'))
    fwrite( ArduinoMega , 12 , 'uint8');
    set( handles.StartTempRegButton , 'UserData',1);
end

% --- Executes on button press in StopTempRegButton.
function StopTempRegButton_Callback(hObject, eventdata, handles)
% hObject    handle to StopTempRegButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ArduinoMega = handles.ArduinoMega;
if(get( handles.StartTempRegButton , 'UserData'))
    fwrite( ArduinoMega , 10 , 'uint8');
    set( handles.StartTempRegButton , 'UserData',0);
end


% --- Executes during object creation, after setting all properties.
function SetTemperatureButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SetTemperatureButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes during object creation, after setting all properties.
function COMPopUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to COMPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function figure_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp( class( handles.ArduinoMega ) , 'serial')
    if strcmp( handles.ArduinoMega.Status , 'open')
        fclose( handles.ArduinoMega );
    end
end


% --- Executes during object creation, after setting all properties.
function figure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in COMPopUp.
function COMPopUp_Callback(hObject, eventdata, handles)
% hObject    handle to COMPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns COMPopUp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from COMPopUp


% --------------------------------------------------------------------
function Open_Callback(hObject, eventdata, handles)
% hObject    handle to Open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Test_Callback(hObject, eventdata, handles)
% hObject    handle to Test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

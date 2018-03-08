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
% 设置程序中需要的全局变量
handles.ArduinoMega = [];

% 滤波器系数
handles.Window_Size = 1300;
handles.Window_Size_1 = 130;

% Pseudo original angle,暂且以此值为原点的参考点

handles.Rotate_Scan_Rate = 640;
handles.Full_Range_Voltage =  3.3; % Full Range 3.3 V
% 测量的相关参数(这里先用起始角与终止角的UserData存储相关信息，使用handles共享数据有些困难)


handles.Resonance_Angle = [];
handles.AmbientTemperature = []; % 环境温度
handles.Resonance_Time = [];

Temp = 25;
set( handles.DisplayTemp , 'String' , Temp );
set( handles.SetTemperatureButton , 'UserData',Temp );
set( handles.StartTempRegButton , 'UserData', 0 );

set( handles.PushMeaInitialAngle , 'UserData',0 );
set( handles.PushMeaFinalAngle , 'UserData',0 );

% 测量标志位
StopFlag = 0;
set( handles.PushMeaStop , 'UserData' , StopFlag );


% 蠕动泵
PumpSpeed = 50;
set( handles.TextPumpVelocity , 'String' , num2str(PumpSpeed) );
set( handles.TextPumpVelocity , 'UserData' , PumpSpeed );
% 保存泵的流速与时间
Pump = [] ;
set( handles.PushPumpVelocity , 'UserData' , Pump);

% 初始化串口列表,在这里初始化，速度非常慢
% S_Info = instrhwinfo('serial');
% set( handles.COMPopUp , 'String' ,S_Info.SerialPorts );
% 
%*******Arduino控制命令类型定义
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

prompt = {'输入终止角度（0゜～75゜）:'};
dlg_title = '设定终止角';
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
        msgbox('无效的终止角度值');
    end
end


% SetMeaFinalAngle( 'SPR_SystemUI',handles.figure );
% MeaFinalAngle = get(hObject,'UserData');
% if isempty( MeaFinalAngle )
%     msgbox('错误：请正确设置测量终止角','终止角设置','error');
% else
%     set( handles.EditMeaFinalAngle , 'String',num2str( MeaFinalAngle ) );
% end


% --- Executes on button press in PushMeaInitialAngle.
function PushMeaInitialAngle_Callback(hObject, eventdata, handles)
% hObject    handle to PushMeaInitialAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = {'输入起始角度（0゜～75゜）:'};
dlg_title = '设定起始角';
num_lines = 1;
def = {num2str( get( hObject ,'UserData') ) };
answer = inputdlg(prompt,dlg_title,num_lines,def);
StartAngle = str2num( answer{1} );
if( ~isempty( answer ))
    if (StartAngle>=0) && ( StartAngle <= 75 )
        set( hObject, 'UserData' , StartAngle );
        set( handles.EditMeaInitialAngle , 'String',answer{1} );
    else
        msgbox('无效的起始角度值');
    end
end

% SetMeaInitialAngle( 'SPR_SystemUI',handles.figure );
% MeaInitialAngle = get(hObject,'UserData');
% if isempty( MeaInitialAngle )
%     msgbox('错误：请正确设置测量起始角','起始角设置','error');
% else
%     set( handles.EditMeaInitialAngle , 'String',num2str( MeaInitialAngle ) );
% end
% 判断起始角与终止角的大小

% --- Executes on button press in HwRefresh.
function HwRefresh_Callback(hObject, eventdata, handles)
% hObject    handle to HwRefresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 先打开串口所有串口 
% 如果之前没有检测过，那么UserData应该为空，否则要先清除
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
% 连接 Arduino Mega 和 SGSP 至PC
% S_Objs = get( handles.HwRefresh , 'UserData' );
% for i=1:length( S_Objs )
%     if S_Objs{1,i}.BytesAvailable ~= 0   %读缓冲区清零
%         fread( S_Objs{1,i} , S_Objs(1,i).BytesAvailable );
%     end
%     fwrite( S_Objs{1,i} , 1 ,'int8' );
%     fwrite( S_Objs{1,i} , 1 ,'int8' );
%     fwrite( S_Objs{1,i} , 1 ,'int8' );
%     fwrite( S_Objs{1,i} , 1 ,'int8' );
%     pause(1) % 转台反应需要时间
%     if S_Objs{1,i}.BytesAvailable == ( 33+4 )
%         handles.S_SGSP = S_Objs{ 1, i};
%         handles.SGSP_Status ='idle';
%             if S_Objs{1,i}.BytesAvailable
%                 fread( S_Objs{1,i} , S_Objs{1,i}.BytesAvailable );%读缓冲区清零
%             end
%     elseif S_Objs{ 1 , i }.BytesAvailable == ( 4*2 )
%         handles.ArduinoMega = S_Objs{ 1 , i };
%         handles.Arduino_Status = 'idle';
%         if S_Objs{1,i}.BytesAvailable
%             fread( S_Objs{1,i} , S_Objs{1,i}.BytesAvailable );%读缓冲区清零
%         end
%     else
%         if S_Objs{1,i}.BytesAvailable
%             fread( S_Objs{1,i} , S_Objs{1,i}.BytesAvailable );%读缓冲区清零
%         end
%         fclose( S_Objs{ 1 , i } );
%     end
% end
% 
% if ~isempty( handles.ArduinoMega ) && ~isempty( handles.S_SGSP )
%     % 将相应空间设为活动状态
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

% 变量本地化
disp('Return to zero')
ArduinoMega = handles.ArduinoMega;
%SGSP = handles.S_SGSP;
%  归零速度250比较合适，归零后可以再回退1度，使触碰开关恢复原来状态
if( ArduinoMega.BytesAvailable)
    fread(ArduinoMega,ArduinoMega.BytesAvailable);
end

fwrite( ArduinoMega , handles.ReturnOrigin ,'uint8' ); % 原点校准命令
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
    
    % 设置Position_Info结构体
    Position_Info.Origin_CyclePostion = MotorPos;
    Position_Info.Origin_Angle = 90;    

    Position_Info.Current_CyclePostion = MotorPos;
    Position_Info.Current_Angle = 90;   % 此处的设置情况与上面Origin_Anlge 的设置一样

    Position_Info.CycleFlag = 0;

    handles.Position_Info = Position_Info;

    set( handles.SampleOn,'UserData',0);
end

% 设定水槽默认温度
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
% SetRotateSteps( SGSP , -6400); % 恢复触碰开关
% 
% MotorPos = MotorReadPos( SGSP );
% handles.SGSP_Status = 'idle';
% % 设置Position_Info结构体
% Position_Info.Origin_CyclePostion = MotorPos;
% Position_Info.Origin_Angle = 90;    % 由于ADXL与激光接收器的夹角为45度，所以挡ADXL的角度为垂直的零度时，激光接收器的角度就为45度也即转台的当前角度值
% 
% Position_Info.Current_CyclePostion = MotorPos;
% Position_Info.Current_Angle = 90;   % 此处的设置情况与上面Origin_Anlge 的设置一样
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

prompt = {'输入送样流速（单位uL/mL）:'};
dlg_title = '设定流速';
num_lines = 1;
def = {num2str( get(handles.TextPumpVelocity ,'UserData') ) };
answer = inputdlg(prompt,dlg_title,num_lines,def);
Speed = str2num( answer{1} );
if( ~isempty( answer ))
    if (Speed>=0) && ( Speed <= 200 )
        set( handles.TextPumpVelocity , 'UserData' , Speed );
        set( handles.TextPumpVelocity , 'String',answer{1} );
    else
        msgbox('无效的流速值');
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
fwrite( ArduinoMega, 49 ,'uint8'); % 关水箱温控
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

% Data保存格式设置
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

% 测量的配置
MeaInitialAngle = get( handles.PushMeaInitialAngle, 'UserData' );
MeaFinalAngle = get( handles.PushMeaFinalAngle , 'UserData' );

% 角度转换 %为获得更好的精度，使转台所转的角度更加一致，这里只保留小数点后一位的数值
SGSP_MeaInitialAngle = AngleTransform( MeaInitialAngle );
SGSP_MeaFinalAngle = AngleTransform( MeaFinalAngle );
Real_MeaInitialAngle = AngleInverseTransform( SGSP_MeaInitialAngle );
Real_MeaFinalAngle = AngleInverseTransform( SGSP_MeaFinalAngle );

Real_Angle = [ Real_MeaInitialAngle Real_MeaFinalAngle ];
SGSP_Angle = [ SGSP_MeaInitialAngle SGSP_MeaFinalAngle ];
Angle_Rotate = abs((SGSP_MeaInitialAngle-SGSP_MeaFinalAngle));
Angle_Step = Angle_Rotate*6400; % 为局部大角度扫描而定义的变量 步/度
MeaMiliDuration = 0.4096*Angle_Step;%以毫秒为单位
MeaStartMicroDelay =0;  %us
Angle_Scale = 0.0003815;

% 坐标系初始化
axis( handles.AxesRealtimeSignal , [Real_MeaInitialAngle Real_MeaFinalAngle 0 3.5 ]); 
axis( handles.AxesPumpVelocity , [0 300 0 14 ]); 
axis( handles.AxesResonAngleTime , [0 300 Real_MeaInitialAngle-1 Real_MeaFinalAngle+1 ]); 
axis( handles.AxesResonDiff , [ 0 300 0 3.5 ]); 


% 旋转至初始角
if isempty( ArduinoMega )
    msgbox('请保持系统连接状态','启动测量错误');
else
    % 旋转至初始角
    Angle_To_Rotate = SGSP_MeaInitialAngle - Position_Info.Current_Angle;
    Rotate_Directon = Angle_To_Rotate / abs( Angle_To_Rotate );
    for i=1:1:( abs( Angle_To_Rotate ))
        SetRotateUnit( ArduinoMega , Rotate_Directon ,  handles.CmdTransfer );
        disp('归位中')
    end
    pause(1);% 保证转台已经停止运动了,否则读取位置不准确
    %%%
    % 旋转后，记录当前旋转的角度的值包括原始位置值与CycleFlag值，并适当修正
    New_Pos_Info = PosInvTranslation( Angle_To_Rotate ,Position_Info );
    MotorPos = MotorReadPos( ArduinoMega , handles.PositionInfo);
    if New_Pos_Info.Current_CyclePostion ~= MotorPos
        New_Pos_Info.Current_CyclePostion
        ToRotate = New_Pos_Info.Current_CyclePostion-MotorPos;
        if abs( ToRotate )< 6400*4  % 4度以内
            SetRotateSteps( ArduinoMega , ToRotate ,handles.CmdTransfer); 
        else
            if ToRotate > 0
                SetRotateSteps( ArduinoMega , New_Pos_Info.Current_CyclePostion-MotorPos - 1000000,handles.CmdTransfer );
            else
                SetRotateSteps( ArduinoMega , New_Pos_Info.Current_CyclePostion-MotorPos + 1000000,handles.CmdTransfer );
            end
        end     
    end
    % 旋转完成后将 RawPosition 与 CycleFlags写入Position_Info结构体中
    Position_Info = New_Pos_Info;
    % 进入测量状态
    Mea_Step_Angle = handles.Rotate_Scan_Rate / 6400;
    Mea_Direction_Flag = 1;
    Voltage_Half_Cycle = [];
    % 启动控温
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
    % 检查蠕动泵模式 

    PumpSpeed = get( handles.TextPumpVelocity , 'UserData' );
    Pump.Speed = PumpSpeed;
    Pump.Time = 0;
    fwrite( ArduinoMega , 6 , 'uint8' );
    fwrite( ArduinoMega , fix(PumpSpeed*1.5) , 'uint8'); % 15uL/min
    set( handles.TextPumpVelocity , 'String' , num2str(PumpSpeed) );
    set( handles.TextPumpVelocity , 'UserData' , PumpSpeed );
    set( handles.PushPumpVelocity , 'UserData' , Pump);
    
    % 启动定时器
    handles.MeaStartTime = clock;
    guidata( hObject ,handles );
    StopFlag = 0;
    set( handles.PushMeaStop , 'UserData' , StopFlag );
    while ~get( handles.PushMeaStop , 'UserData')
        % 判读是否需要改变条件
        if( get( handles.ChangeTempCheckBox ,'Value') )
            Temp =0;
            while( Temp <18 || Temp > 35 )
                tmp = inputdlg('请输入要设定的温度','改变温度');
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
                tmp = inputdlg('请输入要设定的流速','改变流速');
                PumpSpeed = str2double( tmp{1} );            
            end
            fwrite( ArduinoMega , 6 , 'uint8' );
            fwrite( ArduinoMega , fix(PumpSpeed*1.5), 'uint8'); % 15uL/min
            set( handles.TextPumpVelocity , 'String' , num2str(PumpSpeed) );
            set( handles.TextPumpVelocity , 'UserData' , PumpSpeed );
            pause(2);disp('Pause 2 seconds');
        elseif( get(handles.ChangeSampleCheckBox , 'Value'))
            % 停泵
            fwrite( ArduinoMega , 6 , 'uint8' );
            fwrite( ArduinoMega , 0, 'uint8');
            choice='No';
            while( ~strcmp( choice , 'Yes') && ~strcmp( choice , 'Cancel') )
                choice = questdlg('样品已经换好了吗？','换样');
            end
            PumpSpeed = get( handles.TextPumpVelocity , 'UserData' );
            fwrite( ArduinoMega , 6 , 'uint8' );
            fwrite( ArduinoMega , fix(PumpSpeed*1.5) , 'uint8'); % 15uL/min
            pause(2);
        end
        set( handles.RegularCheckBox ,'Value',1.0 );
        
        % 获取温度值
        CurrentTemp = ReadTemp( ArduinoMega , 9 );
        %过热过冷保护
        if ( CurrentTemp(1)<10 || CurrentTemp(2)<10 || CurrentTemp(1)>40|| CurrentTemp(2)>40)
            fwrite( ArduinoMega , 10 ,'uint8');
        end    
        %***************
        disp('测量开始')
        %cla(handles.AxesRealtimeSignal)
        if(Position_Info.Current_Angle == SGSP_MeaInitialAngle && Mea_Direction_Flag==1 ) 
            disp('Forward');
            %[ Dat ,Real_Angle_RT Dat_Len]=RotateAndRecord_1( SGSP , Angle_Step*Mea_Direction_Flag , ArduinoMega ,Real_Angle ,SGSP_Angle, handles.AxesRealtimeSignal,Mea_Direction_Flag);
            if ArduinoMega.BytesAvailable
                fread( ArduinoMega , ArduinoMega.BytesAvailable );%读缓冲区清零
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
            
            % 更新位置
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
            % 温度作图
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
                fread( ArduinoMega , ArduinoMega.BytesAvailable );%读缓冲区清零
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
            
            % 更新位置
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
            % 温度作图
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
    tmp = inputdlg('请输入要设定的温度值','改变温度');
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

function [ Resonance_Angle Dat] = Data_Filter(  WindowSize , VoltageSignal , Direction ,Real_Angle_Axes ) 

Dat_Len = length( VoltageSignal );
a = 1;
b = ones(1,WindowSize)/WindowSize;
Appended_Dat_Length = WindowSize;

if Direction == 1
    Appended_Dat_F=filter( b,a ,[ ones(1,Appended_Dat_Length)*VoltageSignal(1,1),VoltageSignal ] );
    Dat  = Appended_Dat_F( 1, Appended_Dat_Length+1: Dat_Len + Appended_Dat_Length );
    [ Val_F , Ind_F ] = min( Dat  , [] , 2 );
    Resonance_Angle = Real_Angle_Axes( Ind_F(1,1) );
    
elseif Direction == -1
    % 反转之后再滤波可以不用考虑滤波时产生的时延
    VoltageSignal = flipdim( VoltageSignal , 2 );
    Appended_Dat_B=filter( b,a ,[ ones(1,Appended_Dat_Length)*VoltageSignal(1,1), VoltageSignal] );
    Dat  = Appended_Dat_B( 1, Appended_Dat_Length+1: Dat_Len + Appended_Dat_Length );
    [ Val_B , Ind_B ] = min( Dat  , [] , 2 ); 
    Resonance_Angle = Real_Angle_Axes( Ind_B );
end

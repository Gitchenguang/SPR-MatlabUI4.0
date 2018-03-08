function [ Resonance_Angle Dat] = Data_Filter_1(  WindowSize , VoltageSignal , Direction , SGSP_Angle ) 

Dat_Len = length( VoltageSignal );
a = 1;
b = ones(1,WindowSize)/WindowSize;
Appended_Dat_Length = WindowSize;

SGSP_x = linspace( SGSP_Angle(1,1) , SGSP_Angle(1,2) , Dat_Len );

if Direction == 1
    Appended_Dat_F=filter( b,a ,[ ones(1,Appended_Dat_Length)*VoltageSignal(1,1),VoltageSignal ] );
    Dat  = Appended_Dat_F( 1, Appended_Dat_Length+1: Dat_Len + Appended_Dat_Length );
    
    mx = mean( SGSP_x );stx=std( SGSP_x );
    z = (SGSP_x-mx)/stx;
    [ p ,s ] = polyfit( z, Dat , 6 );
    Fitted_Dat = p * [ z.^6; z.^5; z.^4; z.^3; z.^2; z.^1; z.^0 ];
    
    [ Val_F , Ind_F ] = min( Fitted_Dat  , [] , 2 );
    Resonance_Angle = AngleInverseTransform(SGSP_x(Ind_F(1,1)));
    
elseif Direction == -1
    % 反转之后再滤波可以不用考虑滤波时产生的时延
    VoltageSignal = flipdim( VoltageSignal , 2 );
    Appended_Dat_B=filter( b,a ,[ ones(1,Appended_Dat_Length)*VoltageSignal(1,1), VoltageSignal] );
    Dat  = Appended_Dat_B( 1, Appended_Dat_Length+1: Dat_Len + Appended_Dat_Length );

    mx = mean( SGSP_x );stx=std( SGSP_x );
    z = (SGSP_x-mx)/stx;
    [ p ,s ] = polyfit( z, Dat , 6 );
    Fitted_Dat = p * [ z.^6; z.^5; z.^4; z.^3; z.^2; z.^1; z.^0 ];
    
    [ Val_B , Ind_B ] = min( Fitted_Dat  , [] , 2 ); 
    Resonance_Angle = AngleInverseTransform( SGSP_x( Ind_B ));
end

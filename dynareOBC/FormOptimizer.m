function dynareOBC = FormOptimizer( dynareOBC )

    Ts = dynareOBC.TimeToEscapeBounds;
    ns = dynareOBC.NumberOfMax;

    if ns == 0
        return
    end
    
    M = dynareOBC.MMatrix;
    Ms = dynareOBC.MsMatrix;
    omega = dynareOBC.Omega;

    Input = sdpvar( size( M, 1 ) + 1, 1 ); % [ qScaled; Tss ]
    Output = sdpvar( Ts * ns + 1, 1 );     % [ yScaled; alpha ]
    
    z = binvar( Ts * ns, 1 );
    
    qScaled = Input( 1 : ( end - 1 ), 1 );
    qsScaled = qScaled( dynareOBC.sIndices );
    Tss = Input( end );

    yScaled = Output( 1 : ( end - 1 ), 1 );
    alpha = Output( end );
    
    zWeights = repmat( ( 1 : Ts )', ns, 1 );
    
    Constraints = [ 0 <= yScaled, yScaled <= z, z .* zWeights <= Tss, 0 <= alpha, 0 <= alpha * qScaled + M * yScaled, alpha * qsScaled + Ms * yScaled <= omega * ( 1 - z ) ];
    Objective = -alpha;
    dynareOBC.Optimizer = optimizer( Constraints, Objective, dynareOBC.MILPOptions, Input, Output );
    
    yalmip( 'clear' );
    
end
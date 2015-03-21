%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This method matches two nodes in two super pixel graphs
%
%   @param A1                       - Attribute/feature matrix for G1
%   @param A2                       - Attribute/feature matrix for G2
%   @param cdm                      - Color Drift Model
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ X12, X_SMAC, W2, timing ] = balancedGraphMatching( A1, A2, cdm )

    options.constraintMode      = 'both';                           %'both' for 1-1 graph matching
    options.isAffine            = 1;                                % affine constraint
    options.isOrth              = 1;                                %orthonormalization before discretization
    options.normalization       = 'iterative';                      %bistochastic kronecker normalization, 'none'
    options.discretisation      = @discretisationGradAssignment;    %function for discretization
    options.is_discretisation_on_original_W=0;

    N1  = length( A1 );
    N2  = length( A2 );
    N12 = N1 * N2;

    if ( N1 > 0 &&  N2 > 0 )
        
        E12 = ones( N1, N2 );
        
        % list all possible matches
        W_index = cell( N12, 1 );
        counter = 1;
        for j = 1 : N2
            for i = 1 : N1
                W_index{ counter } = [ i, j ];
                counter = counter + 1;
            end
        end
        
        % Build the similarity matrix
        W   = zeros( N12, N12 );
        Wnn = zeros( N12, N12 );
        Wee = zeros( N12, N12 );
        for i = 1 : N12
            for j = 1 : N12

                rowID    = W_index{i};
                columnID = W_index{j};

                if ( rowID( 1 ) == columnID( 1 ) && rowID( 2 ) == columnID( 2 ) )
                    % Compute Node-to-Node relationship
                    a1 = A1{rowID( 1 )};
                    a2 = A2{rowID( 2 )};
                    
                    f1 = a1(4:end) ./ sum(a1(4:end));
                    f2 = a2(4:end) ./ sum(a2(4:end));
                                        
                    z = [f1 f2];
                    
                    assert( length(f1) == length(f2) );
                    
                    Wnn(i, j) = GraphMatching.compareHistograms(f1, f2) .* ColorDrift.evaluateDensity(z, cdm);                    
                    
                elseif ( rowID( 1 ) == columnID( 1 ) && rowID( 2 ) ~= columnID( 2 ) )
                   W( i, j ) = 0;
                elseif ( rowID( 1 ) ~= columnID( 1 ) && rowID( 2 ) == columnID( 2 ) )
                   W( i, j ) = 0;
                else
                    % Compute Edge-to-Edge relationship 
                    f11 = A1{rowID( 1 )};
                    f12 = A1{columnID(1)};
                    c11y = f11(2);
                    c12y = f12(2);
                    yConf1 = [c11y < c12y c11y > c12y];
                    f1 = abs((f11(4:end)./ sum(f11(4:end))) - (f12(4:end) ./ sum(f12(4:end))));
                    
                    f21    = A2{rowID( 2 )};
                    f22    = A2{columnID(2)};
                    c21y   = f21(2);
                    c22y   = f22(2);
                    yConf2 = [c21y < c22y c21y > c22y];
                    f2 = abs((f21(4:end)./sum(f21(4:end))) - (f22(4:end)./sum(f22(4:end))));
                    
                    Wee( i, j ) = GraphMatching.compareDifferenceHistograms(f1, f2) .* sum(yConf1 .* yConf2 );
                end
            end
        end
        
        maxWnn = max(Wnn(:));
        if maxWnn > 0
            Wnn = Wnn ./ maxWnn;
        end
        
        maxWee = max(Wee(:));
        if maxWee > 0
            Wee = Wee ./ maxWee;
        end
        
        W = Wnn + Wee;

        % graph matching computation
        [ X12, X_SMAC, timing, W2 ] = compute_graph_matching_SMAC( W, E12, options );
    end
end
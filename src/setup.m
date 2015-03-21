%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Sets up various libraries
%
%   Website -- http://www.vision.ece.ucsb.edu/~santhosh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setup
    fprintf('############################################################ \n');
    fprintf('Setting up the libraries... \n');
     
    currentDirectory  = pwd;

    addpath(genpath('../libs/'));
    addpath(genpath(fullfile('../libs/', 'utils')));
    
    % graph matching library
    addpath(genpath(fullfile('../libs/', 'graph_matching_SMAC')));
    
    % setup Dollar's toolbox
    addpath(genpath(fullfile('../libs/', 'pdollar_toolbox_301', 'images')));
    addpath(genpath(fullfile('../libs/', 'pdollar_toolbox_301', 'channels')));
    addpath(genpath(fullfile('../libs/', 'pdollar_toolbox_301', 'classify')));
    addpath(genpath(fullfile('../libs/', 'pdollar_toolbox_301', 'filters')));
    addpath(genpath(fullfile('../libs/', 'pdollar_toolbox_301', 'matlab')));
    
    % setup vlfeat    
    addpath_recurse('../libs/vlfeat-0.9.16/toolbox'); 
    vl_setup;
    
    cd(currentDirectory);

    fprintf('Completed setting up the libraries... \n');
    fprintf('\n ############################################################ \n');
    
    % start the connector
    try
        connector on;
    catch
        fprintf('Failed to start the connector \n');
    end
end
    
% Example script for processing multiple floats in bulk mode using the Argo
% and, optionally, the CTD reference database (if doCTD = true).
%
% - Output plots are saved with the suffix '_ctd' or '_argo'. 
% - Plots are not displayed interactively but directly saved to
% files (if goHeadless = true)
% 
% This workflow requires creating two files from the original wmo_boxes.mat :
%   • wmo_boxes_argo.mat : to use only Argo reference data (columns 2 and 3
%   of la_wmo_boxes array are set to all 0s). 
%   • wmo_boxes_ctd.mat  : to use only CTD reference data (columns 3 and 4 
%   la_wmo_boxes array are set to all 0s. 
%   This can be done using the following code:  
%   load ('./data/constants/wmo_boxes.mat')
%   la_wmo_boxes(:,[2,3])=0; 
%   save('./data/constants/wmo_boxes_argo.data','la_wmo_boxes') 
%   load ('./data/constants/wmo_boxes.mat') 
%   la_wmo_boxes(:,[3,4])=0;
%   save('./data/constants/wmo_boxes_ctd.data','la_wmo_boxes')
%
% 
%  *** From ow_calibration_bulk_CSIRO.m
%
% [07/07/21 Dirk Slawinski
% - lets get this script localized and portable
% [18/09/2025] C.Cabanes 
% - addapt the call to the function plot_diagnostics_ow.m
% - simplify the handling of mapping files avoiding redundant copies:
%  mapped files are saved in ./float_mapped/argo/ and ./float_mapped/ctd/
%  directories. Changes are not tracked for readabitliy


% float areas
flt_dir = '';
% the floats to process
%wmoids = [5905405];
wmoids = [5905025, 5905414];
% do we also for CTD?
doCTD = true;
% go headless 
goHeadless = true;
%goHeadless = false;
%[CC20250918/] 
% format of output plot ('-dpng','-depcs',...)
pltFileType = '-dpng';
%[/CC20250918] 

% some configs
% the current Matlab based OWC directory
OWCdir = '/home/argo/ArgoDM/dmqc_ow/OWC_3_dev';
currentDir = pwd();

% go to OWC 
cd(OWCdir);

% set the path
owroot = OWCdir; % '/home/argo/ArgoDM/dmqc_ow/OWC_3_dev';
addpath(genpath(owroot))



% now loop over the lo_system_configuration = load_configuration( 'ow_config.txt' );floats
for wmoid = wmoids
    % get a local version of the config fata
    lo_system_configuration = load_configuration( 'ow_config.txt' );
    %[CC20250918/]   save before modifications
    save_lo_system_configuration = lo_system_configuration;
    %[/CC20250918]

    %flt_dir = '';
    flt_name = sprintf('%d', wmoid);
    
    fprintf('%s Working on %d\n', datestr(now), wmoid);
    %fprintf('%s\n', lo_system_configuration.CONFIG_WMO_BOXES);


    % sometimes we want to use the historical CTD data
    if(doCTD)

        lo_system_configuration.CONFIG_WMO_BOXES = 'wmo_boxes_ctd.mat'; 
        la_wmo_boxes_file=strcat( lo_system_configuration.CONFIG_DIRECTORY, lo_system_configuration.CONFIG_WMO_BOXES);

        if exist(la_wmo_boxes_file,"file")==0;
            error ('file %s not foud',la_wmo_boxes_file)
        end
        lo_system_configuration.FLOAT_MAPPED_DIRECTORY = ...
            strcat(save_lo_system_configuration.FLOAT_MAPPED_DIRECTORY, 'ctd/');
        disp(lo_system_configuration)
        ctdMappedName = fullfile( lo_system_configuration.FLOAT_MAPPED_DIRECTORY, flt_name, strcat( lo_system_configuration.FLOAT_MAPPED_PREFIX, flt_name, lo_system_configuration.FLOAT_MAPPED_POSTFIX ) );

        % now run it again
        update_salinity_mapping( flt_dir, flt_name, lo_system_configuration );
        set_calseries( flt_dir, flt_name, lo_system_configuration );
        calculate_piecewisefit( flt_dir, flt_name, lo_system_configuration );
% [CC20250918/]        
        %plot_diagnostics_ow_CSIRO( flt_dir, flt_name, lo_system_configuration, goHeadless );
        plot_diagnostics_ow( flt_dir, flt_name, lo_system_configuration,'pltFileType',pltFileType,'appendRef','_ctd','goHeadless',goHeadless);
% [/CC20250918]  
         fprintf('mapped file saved as %s during ctd comparison\n', ctdMappedName);

    end % if(doCTD)
    
    % let's use the ARGO boxes data
    
    lo_system_configuration.CONFIG_WMO_BOXES = 'wmo_boxes_argo.mat';
    la_wmo_boxes_file=strcat( lo_system_configuration.CONFIG_DIRECTORY, lo_system_configuration.CONFIG_WMO_BOXES);

    if exist(la_wmo_boxes_file,"file")==0;
        error ('file %s not foud',la_wmo_boxes_file)
    end
    lo_system_configuration.FLOAT_MAPPED_DIRECTORY = ...
        strcat(save_lo_system_configuration.FLOAT_MAPPED_DIRECTORY, 'argo/');
    disp(lo_system_configuration)
    argoMappedName = fullfile(lo_system_configuration.FLOAT_MAPPED_DIRECTORY, flt_name, strcat(lo_system_configuration.FLOAT_MAPPED_PREFIX, flt_name, lo_system_configuration.FLOAT_MAPPED_POSTFIX ) );


    update_salinity_mapping( flt_dir, flt_name, lo_system_configuration );
    set_calseries( flt_dir, flt_name, lo_system_configuration );
    calculate_piecewisefit( flt_dir, flt_name, lo_system_configuration );
%[CC20250618/]
    %plot_diagnostics_ow_CSIRO( flt_dir, flt_name, lo_system_configuration, goHeadless );
    plot_diagnostics_ow( flt_dir, flt_name, lo_system_configuration,'pltFileType',pltFileType,'appendRef','_argo','goHeadless',goHeadless);
%[CC20250618/]


    fprintf('mapped file saved as %s during argo comparison\n', argoMappedName);

end % wmoid

% now return to the previous dir
fprintf('All Done!\n');
cd(currentDir);
return

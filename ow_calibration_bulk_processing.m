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
%   save('./data/constants/wmo_boxes_argo.data') 
%   load ('./data/constants/wmo_boxes.mat') 
%   la_wmo_boxes(:,[3,4])=0;
%   save('./data/constants/wmo_boxes_ctd.data')
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
%  directories


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

%[CC20250918/]      
%     % the default OWC mapped name
%     genericMappedName = sprintf('%s/data/float_mapped/map_%d.mat', OWCdir, wmoid);
%     % CTD name we want it to have
%     ctdMappedName = sprintf('%s/data/float_mapped/map_%d_ctd.mat', OWCdir, wmoid);
%     % ARGO name we want it to have
%     argoMappedName = sprintf('%s/data/float_mapped/map_%d_argo.mat', OWCdir, wmoid);
%[/CC20250918] 


    % sometimes we want to use the historical CTD data
    if(doCTD)
%[CC20250918/]             
%         % swap argo for ctd comparison
%         lo_system_configuration.CONFIG_WMO_BOXES = ...
%             strrep(lo_system_configuration.CONFIG_WMO_BOXES, 'argo',
%             'ctd'); % problem if CONFIG_WMO_BOXES is wmo_boxes.mat 
        lo_system_configuration.CONFIG_WMO_BOXES = 'wmo_boxes_ctd.mat'; 
        la_wmo_boxes_file=strcat( lo_system_configuration.CONFIG_DIRECTORY, lo_system_configuration.CONFIG_WMO_BOXES);

        if exist(la_wmo_boxes_file,"file")==0;
            error ('file %s not foud',la_wmo_boxes_file)
        end
        lo_system_configuration.FLOAT_MAPPED_DIRECTORY = ...
            strcat(save_lo_system_configuration.FLOAT_MAPPED_DIRECTORY, 'ctd/');
        disp(lo_system_configuration)
        ctdMappedName = fullfile( lo_system_configuration.FLOAT_MAPPED_DIRECTORY, flt_name, strcat( lo_system_configuration.FLOAT_MAPPED_PREFIX, flt_name, lo_system_configuration.FLOAT_MAPPED_POSTFIX ) );

%[/CC20250918] 
%[CC20250918/] 
%         % check on mapped file status
%         if(exist(ctdMappedName, 'file'))
%             % we have run CTD before so lets copy it to the working/generic
%             % name - copyfile(src, dest)
%             % but 1st check if _argo exists.
%             if(exist(argoMappedName, 'file'))
%                 % yes, so no need to backup
%                 fprintf('keeping existing _argo file during ctd comparison\n');
%             elseif (exist(genericMappedName, 'file')) % if(exist(argoMappedName, 'file'))
%                 % rename generic as _argo ie backup
%                 mvStat = movefile(genericMappedName, argoMappedName);
%                 % if a move error happens go back
%                 if(~mvStat)
%                     fprintf('error whilst renaming generic to %s\n', argoMappedName);
%                     % now return to the previous dir
%                     cd(currentDir);
%                     return
%                 end % if(~mvStat)
%                 fprintf('backing up generic file as %s during ctd comparison\n', argoMappedName);
%             end % if(exist(argoMappedName, 'file'))
%             % ow copy the _ctd file to generic
%             mvStat = copyfile(ctdMappedName, genericMappedName);
%             % if a move error happens go back
%             if(~mvStat)
%                 fprintf('error whilst copying _ctd to %s\n', genericMappedName);
%                 % now return to the previous dir
%                 cd(currentDir);
%                 return
%             end % if(~mvStat)
%             fprintf('using %s as generic file\n', ctdMappedName);
%         else % if(exist(ctdMappedName, 'file'))
%             % ctd does not yet exist, so assume generic file is the _argo one
%             % which needs to be backed up to _argo
%             % 1st check if it exists
%             if(exist(genericMappedName, 'file'))
%                 mvStat = movefile(genericMappedName, argoMappedName);
%                 % if a move error happens go back
%                 if(~mvStat)
%                     fprintf('error whilst renaming generic to %s\n', argoMappedName);
%                     % now return to the previous dir
%                     cd(currentDir);
%                     return
%                 end % if(~mvStat)
%                 fprintf('backing up generic file as %s during ctd comparison\n', argoMappedName);
%             else % if(exist(genericMappedName, 'file'))
%                 % does not exist let it create the generic
%                 fprintf('no existing generic file during ctd comparison\n');
%             end % if(exist(genericMappedName, 'file'))
%         end % if(exist(ctdMappedName, 'file'))
%         % at this point the generic mapped name should either be the _ctd one or
%         % none at all, 1st ctd run
%[/CC20250918]     

        % now run it again
        update_salinity_mapping( flt_dir, flt_name, lo_system_configuration );
        set_calseries( flt_dir, flt_name, lo_system_configuration );
        calculate_piecewisefit( flt_dir, flt_name, lo_system_configuration );
% [CC20250918/]        
        %plot_diagnostics_ow_CSIRO( flt_dir, flt_name, lo_system_configuration, goHeadless );
        plot_diagnostics_ow( flt_dir, flt_name, lo_system_configuration,'pltFileType',pltFileType,'appendRef','_ctd','goHeadless',goHeadless);
% [/CC20250918]  
% [CC20250918/] 
%         % swap ctd back to argo
%         lo_system_configuration.CONFIG_WMO_BOXES = ...
%             strrep(lo_system_configuration.CONFIG_WMO_BOXES, 'ctd', 'argo');
%         
%         % backup the _ctd mapped data 
%         mvStat = movefile(genericMappedName, ctdMappedName);
%         % if a move error happens go back
%         if(~mvStat)
%             fprintf('error whilst renaming to %s\n', ctdMappedName);
%             % now return to the previous dir
%             cd(currentDir);
%             return
%         end % if(~mvStat)
%         fprintf('generic file saved as %s during ctd comparison\n', ctdMappedName);
         fprintf('mapped file saved as %s during ctd comparison\n', ctdMappedName);
% [/CC20250918] 

    end % if(doCTD)
    
    % let's use the ARGO boxes data
    
% [CC20250918/]
%     % swap ctd to argo, just to be safe
%     lo_system_configuration.CONFIG_WMO_BOXES = ...
%         strrep(lo_system_configuration.CONFIG_WMO_BOXES, 'ctd', 'argo');
    lo_system_configuration.CONFIG_WMO_BOXES = 'wmo_boxes_argo.mat';
    la_wmo_boxes_file=strcat( lo_system_configuration.CONFIG_DIRECTORY, lo_system_configuration.CONFIG_WMO_BOXES);

    if exist(la_wmo_boxes_file,"file")==0;
        error ('file %s not foud',la_wmo_boxes_file)
    end
    lo_system_configuration.FLOAT_MAPPED_DIRECTORY = ...
        strcat(save_lo_system_configuration.FLOAT_MAPPED_DIRECTORY, 'argo/');
    disp(lo_system_configuration)
    argoMappedName = fullfile(lo_system_configuration.FLOAT_MAPPED_DIRECTORY, flt_name, strcat(lo_system_configuration.FLOAT_MAPPED_PREFIX, flt_name, lo_system_configuration.FLOAT_MAPPED_POSTFIX ) );

% [/CC20250918] 

% [CC20250918/]
%     % check on mapped file status
%     if(exist(argoMappedName, 'file'))
%         % we have an _argo, copy it to the working/generic name - 
%         % copyfile(src, dest)
%         mvStat = copyfile(argoMappedName, genericMappedName);
%         % if a move error happens go back
%         if(~mvStat)
%             fprintf('error whilst copying _argo to %s\n', genericMappedName);
%             % now return to the previous dir
%             cd(currentDir);
%             return
%         end % if(~mvStat)
%         fprintf('using %s as generic file during argo comparison\n', argoMappedName);
%     else % if(exist(argoMappedName, 'file'))
%         % does not exist so the generic is likely the _argo data
%         % NOTE: it could be the generic or could be the _ctd but let's be
%         % brave
%         fprintf('using existing generic file during argo comparison\n');
%     end % if(exist(argoMappedName, 'file'))
% [/CC20250918] 

    update_salinity_mapping( flt_dir, flt_name, lo_system_configuration );
    set_calseries( flt_dir, flt_name, lo_system_configuration );
    calculate_piecewisefit( flt_dir, flt_name, lo_system_configuration );
%[CC20250618/]
    %plot_diagnostics_ow_CSIRO( flt_dir, flt_name, lo_system_configuration, goHeadless );
    plot_diagnostics_ow( flt_dir, flt_name, lo_system_configuration,'pltFileType',pltFileType,'appendRef','_argo','goHeadless',goHeadless);
%[CC20250618/]

%[CC20250618/]
%     % backup the _argo mapped data and keep generic as _argo
%     mvStat = copyfile(genericMappedName, argoMappedName);
%     % if a move error happens go back
%     if(~mvStat)
%         fprintf('error whilst copying to %s\n', argoMappedName);
%         % now return to the previous dir
%         cd(currentDir);
%         return
%     end % if(~mvStat)
%     fprintf('generic file saved as %s during argo comparison\n', argoMappedName);
    fprintf('mapped file saved as %s during argo comparison\n', argoMappedName);

    %[CC20250618/]    

end % wmoid

% now return to the previous dir
fprintf('All Done!\n');
cd(currentDir);
return

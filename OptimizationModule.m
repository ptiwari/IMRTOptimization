function varargout = OptimizationModule(command, varargin)
%"IMRTPGui" GUI
%   Create a GUI to calculate IM structures.
%
%   JRA 4/30/04
%
%Usage:
%   Have a plan open in CERR and type IMRTPGui at Matlab prompt.
%
% Last modified:
%  JJW 07/05/06: added field sigma_100; changed names for QIB DoseTerm
%  APA 10/16/06: updates to workflow. See CVS log for details.
%
% Copyright 2010, Joseph O. Deasy, on behalf of the CERR development team.
%
% This file is part of The Computational Environment for Radiotherapy Research (CERR).
%
% CERR development has been led by:  Aditya Apte, Divya Khullar, James Alaly, and Joseph O. Deasy.
%
% CERR has been financially supported by the US National Institutes of Health under multiple grants.
%
% CERR is distributed under the terms of the Lesser GNU Public License.
%
%     This version of CERR is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
% CERR is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with CERR.  If not, see <http://www.gnu.org/licenses/>.

%Globals.
global planC stateS
indexS = planC{end};

%Use a static window size, by pixels.  Do not allow resizing.
screenSize = get(0,'ScreenSize');
y = 450;
x = 620; %800+263  %936 for half

hFig = findobj('Tag', 'CERR_OptimizeGui');
units = 'pixels';
switch upper(command)
    case 'START'
        hFig = stateS.handle.optimzeMenuFig;
        ud = get(hFig, 'userdata');
        
        for i=1:length(ud.optimization)
            val = str2num(ud.optimization(i).weight.String);
            if(strcmp(ud.optimization(i).weight.String,''))
                msgbox('Weight is not specified.', 'Error','error','modal');
                return;
            end
            switch(ud.optimization(i).type.Value)
                case 1
                    if(strcmp(ud.optimization(i).dose.String,'') )
                        msgbox('Dose is not specified for the Min Dose objective', 'Error','error','modal');
                        return;
                    end
                case 2
                    
                    if(strcmp(ud.optimization(i).dose.String,''))
                        msgbox('Dose is not specified for the Max Dose objective', 'Error','error','modal');
                        return;
                    end
                case 3
                    
                    if(strcmp(ud.optimization(i).dose.String,''))
                        msgbox('Dose is not specified for the Min Dose objective', 'Error','error','modal');
                        return;
                    end
                    
                    if(strcmp(ud.optimization(i).volume.String,''))
                        msgbox('Volume is not specified for the Min Dose objective', 'Error','error','modal');
                        return;
                    end
                case 4
                    
                    if(strcmp(ud.optimization(i).dose.String,''))
                        msgbox('Dose is not specified for the Prescription Dose objective', 'Error','error','modal');
                        return;
                    end
                case 5
                    
                    if(strcmp(ud.optimization(i).a.String,''))
                        msgbox('a is not specified for the gEUD objective', 'Error','error','modal');
                        return;
                    end
            end
            
        end
        try
            set(ud.startButton,'String','Running Optimization','Enable','off');
            drawnow
            
            s = ud.solver.String(ud.solver.Value);
            currDir = which('OptimizationModule.m');
            oneUp = fileparts(currDir);
            twoUp = fileparts(oneUp);
            if ispc
                userdir= getenv('USERPROFILE'); 
            else
                userdir= getenv('HOME');
            end
            if ismac
                ud.mFile = sprintf('%s/IMRT.mod',userdir);
                ud.dFile = sprintf('%s/IMRT.dat',userdir);
                ud.rFile = sprintf('%s/IMRT.run',userdir);
                ud.inf = sprintf('%s/inf',userdir);
                ud.result = sprintf('%s/result',userdir);
                twoUp = strcat(twoUp,'/IMRTOptimization/platforms');
                amplDir = strcat(twoUp,'/osx');
                solverDir = strcat(twoUp,'/osx/');
                cmd = sprintf('%s/ampl <%s\n',amplDir,ud.rFile);   
            elseif isunix
               ud.mFile = sprintf('%s/IMRT.mod',userdir);
               ud.dFile = sprintf('%s/IMRT.dat',userdir);
               ud.rFile = sprintf('%s/IMRT.run',userdir);
               ud.inf = sprintf('%s/inf',userdir);
               ud.result = sprintf('%s/result',userdir);
               twoUp = strcat(twoUp,'/IMRTOptimization/platforms');
               amplDir = strcat(twoUp,'/linux');
               solverDir = strcat(twoUp,'/linux/');
               cmd = sprintf('%s/ampl <%s\n',amplDir,ud.rFile);
            elseif ispc
                ud.mFile = sprintf('%s\\IMRT.mod',userdir);
                ud.dFile = sprintf('%s\\IMRT.dat',userdir);
                ud.rFile = sprintf('%s\\IMRT.run',userdir);
                ud.inf = sprintf('%s\\inf',userdir);
                ud.result = sprintf('%s\\result',userdir);
                twoUp = strcat(twoUp,'\IMRTOptimization\platforms');
                amplDir = strcat(twoUp,'\pc');
                solverDir = strcat(twoUp,'\pc\');
                cmd = sprintf('%s\ampl <%s\n',amplDir,ud.rFile);
            else
                disp('Platform not supported')
            end
            if(strfind(s{:},'knitro'))
                solverDir = strcat(solverDir,'knitro');
            else
                solverDir = strcat(solverDir,s{:});
            end
            generateModel(ud);
            generateData(ud);
            genRunFile(solverDir,s{:},ud);
            catchexec = false;
            [status,cmdout] = system(cmd);
            msgbox('Optimization Completed','Information','modal');
            set(ud.startButton,'String','Start Optimization','Enable','on');
            fprintf('%s',cmdout);
        catch
            msgbox('Could not run optimization. Make sure the dose is computed for the structures.','Error','modal');
            set(ud.startButton,'String','Start Optimization','Enable','on');
            catchexec = true;
        end
        if (~catchexec)
            saveSol(ud);
        end
        
        
end
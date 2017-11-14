function varargout = optimizeGui(command, varargin)
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
x = 650; %800+263  %936 for half

hFig = findobj('Tag', 'CERRIMRTPMenu');
 units = 'pixels';
switch upper(command)
    case 'INIT'
        if ~isempty(hFig)
            delete(hFig);
        end
        screenSize = get(0,'ScreenSize');

        dx = floor((x-30)/2);
        hFig = figure('Name','Optimize', 'units', 'pixels', 'position',[(screenSize(3)-x)/2 (screenSize(4)-y)/2 x y], 'MenuBar', 'none', 'NumberTitle', 'off', 'resize', 'off', 'Tag', 'CERRIMRTPMenu');
        stateS.handle.optimzeMenuFig = hFig;
        %Create structure pulldown menu.
        [assocScansV, relStructNumV] = getStructureAssociatedScan(1:length(planC{indexS.structures}), planC);
        structsInScanS = planC{indexS.structures}(assocScansV==1);
        strList = {structsInScanS.structureName};
        stateS.optimizeYVal = 90;
        typeList = {'Min Dose','Max Dose', 'Dose Volume','Presc Dose','gEUD'};
        uicontrol(hFig, 'style', 'pushbutton', 'units', units, 'position', [300 y-400 100 20], 'string', 'Add Organ', 'horizontalAlignment', 'center', 'callback', 'optimizeGui(''ADDGOAL'');');
        uicontrol(hFig, 'style', 'frame', 'units', units, 'position', [10 y-350 620 300]);
        ud.sliderH = uicontrol(hFig, 'style', 'slider', 'units', units, 'position', [620 y-350 15 300],'min',7,'max',max(7+1,length(planC{indexS.structures})),'value',max(7+1,length(planC{indexS.structures})));

        uicontrol(hFig, 'style', 'text', 'units', units, 'position', [20 y-40 50 15], 'string', 'Organ', 'horizontalAlignment', 'center');
        uicontrol(hFig, 'style', 'text', 'units', units, 'position', [130 y-40 50 15], 'string', 'Type', 'horizontalAlignment', 'center');
        uicontrol(hFig, 'style', 'text', 'units', units, 'position', [220 y-40 50 15], 'string', 'Weight', 'horizontalAlignment', 'center');
        uicontrol(hFig, 'style', 'text', 'units', units, 'position', [280 y-40 80 15], 'string', 'Dose(Gy)', 'horizontalAlignment', 'center');
        uicontrol(hFig, 'style', 'text', 'units', units, 'position', [380 y-40 80 15], 'string', 'Volume(%)', 'horizontalAlignment', 'center');
        uicontrol(hFig, 'style', 'text', 'units', units, 'position', [470 y-40 30 15], 'string', 'a', 'horizontalAlignment', 'left');
        uicontrol(hFig, 'style', 'text', 'units', units, 'position',[490 y-40 75 15] , 'string', 'Constraint', 'horizontalAlignment', 'center');
        uicontrol(hFig, 'style', 'text', 'units', units, 'position',[550 y-40 80 15] , 'string', 'Del', 'horizontalAlignment', 'center');
        
        ud.optimization(1).organ =      uicontrol(hFig, 'style', 'popupmenu', 'units', units, 'position', [10 y-90 100 30], 'string', strList, 'value', 1, 'horizontalAlignment', 'center');
        ud.optimization(1).type =       uicontrol(hFig, 'style', 'popupmenu', 'units', units,'UserData',1, 'position', [110 y-90 100 30], 'string', typeList, 'value', 1, 'horizontalAlignment', 'center','callback', 'optimizeGui(''REFRESH'');');
        ud.optimization(1).weight =       uicontrol(hFig, 'style', 'edit', 'units', units, 'position', [220 y-80 50 20], 'horizontalAlignment', 'center');
        ud.optimization(1).dose =     uicontrol(hFig, 'style', 'edit', 'units', units, 'position', [290 y-80 80 20], 'horizontalAlignment', 'center');
        ud.optimization(1).volume = uicontrol(hFig, 'style', 'edit', 'units', units, 'position',[390 y-80 50 20] , 'horizontalAlignment', 'center');
        ud.optimization(1).a = uicontrol(hFig, 'style', 'edit', 'units', units, 'position',[460 y-80 30 20] , 'horizontalAlignment', 'center');
        ud.optimization(1).constraint = uicontrol(hFig, 'style', 'checkbox', 'units', units, 'position',[520 y-80 50 20] , 'horizontalAlignment', 'center');
        uicontrol(hFig, 'style', 'pushbutton', 'units', units, 'position', [570 y-80 30 18], 'string', '-', 'horizontalAlignment', 'center', 'callback', 'optimizeGui(''ADDGOAL'');');

        ud.startButton = uicontrol(hFig, 'style', 'pushbutton', 'units', units, 'position', [530 y-400 100 20], 'string', 'Start Optimization', 'horizontalAlignment', 'center','callback', 'OptimizationModule(''start'');');
        solverList = {'ipopt','knitro_Direct','knitro_CG','knitro_Active','knitro_SQP'};
        ud.solver =      uicontrol(hFig, 'style', 'popupmenu', 'units', units, 'position', [420 y-400 100 20], 'string', solverList, 'value', 1, 'horizontalAlignment', 'center');
        set(hFig, 'userdata', ud);
        
        set(ud.optimization(1).volume,'Enable','off');
        set(ud.optimization(1).a,'Enable','off');
    case 'ADDGOAL'
        hFig = stateS.handle.optimzeMenuFig;
        stateS.optimizeYVal = stateS.optimizeYVal + 30;
        [assocScansV, relStructNumV] = getStructureAssociatedScan(1:length(planC{indexS.structures}), planC);
        structsInScanS = planC{indexS.structures}(assocScansV==1);
        strList = {structsInScanS.structureName};
        typeList = {'Min Dose','Max Dose', 'Dose Volume','Presc Dose','gEUD'};
        ud = get(hFig, 'userdata');
        currPos = length(ud.optimization);
        ud.optimization(currPos+1).organ =      uicontrol(hFig, 'style', 'popupmenu', 'units', units, 'position', [10 y-stateS.optimizeYVal 100 30], 'string', strList, 'value', 1, 'horizontalAlignment', 'center');
        ud.optimization(currPos+1).type =       uicontrol(hFig, 'style', 'popupmenu', 'units', units,'UserData',currPos+1, 'position', [110 y-stateS.optimizeYVal 100 30], 'string', typeList, 'value', 1, 'horizontalAlignment', 'center','callback', 'optimizeGui(''REFRESH'');');
        ud.optimization(currPos+1).weight =       uicontrol(hFig, 'style', 'edit', 'units', units, 'position', [220 y-stateS.optimizeYVal+10 50 20], 'horizontalAlignment', 'center');
        ud.optimization(currPos+1).dose =     uicontrol(hFig, 'style', 'edit', 'units', units, 'position', [290 y-stateS.optimizeYVal+10 80 20], 'horizontalAlignment', 'center');
        ud.optimization(currPos+1).volume = uicontrol(hFig, 'style', 'edit', 'units', units, 'position',[390 y-stateS.optimizeYVal+10 50 20] , 'horizontalAlignment', 'center');
        ud.optimization(currPos+1).a = uicontrol(hFig, 'style', 'edit', 'units', units, 'position',[460 y-stateS.optimizeYVal+10 30 20] , 'horizontalAlignment', 'center');
        ud.optimization(currPos+1).constraint = uicontrol(hFig, 'style', 'checkbox', 'units', units, 'position',[520 y-stateS.optimizeYVal+10 50 20] , 'horizontalAlignment', 'center');
        uicontrol(hFig, 'style', 'pushbutton', 'units', units, 'position', [570 y-stateS.optimizeYVal+10 30 18], 'string', '-', 'horizontalAlignment', 'center', 'callback', 'optimizeGui(''ADDGOAL'');');
        
        set(ud.optimization(currPos+1).volume,'Enable','off');
        set(ud.optimization(currPos+1).a,'Enable','off');
        
        set(hFig, 'userdata', ud);
    case 'REFRESH'
        ud = get(hFig, 'userdata');
        h = gco;
        currPos = h.UserData;
        switch(ud.optimization(currPos).type.Value)
            case 1
                set(ud.optimization(currPos).volume,'Enable','off','String','');
                set(ud.optimization(currPos).a,'Enable','off','String','');
                
                set(ud.optimization(currPos).dose,'Enable','on'); 
                set(ud.optimization(currPos).constraint,'Enable','on');   
            case 2
                set(ud.optimization(currPos).volume,'Enable','off','String','');
                set(ud.optimization(currPos).a,'Enable','off','String','');
                
                set(ud.optimization(currPos).dose,'Enable','on'); 
                set(ud.optimization(currPos).constraint,'Enable','on');
            case 3
                set(ud.optimization(currPos).a,'Enable','off','String','');
                set(ud.optimization(currPos).constraint,'Enable','off','String','');   
                
                set(ud.optimization(currPos).dose,'Enable','on'); 
                set(ud.optimization(currPos).volume,'Enable','on'); 
            case 4
                set(ud.optimization(currPos).a,'Enable','off','String','');
                set(ud.optimization(currPos).constraint,'Enable','off','String','');  
                set(ud.optimization(currPos).volume,'Enable','off','String','');
                
                set(ud.optimization(currPos).dose,'Enable','on'); 
            case 5
                set(ud.optimization(currPos).dose,'Enable','off','String',''); 
                set(ud.optimization(currPos).volume,'Enable','off','String',''); 
                set(ud.optimization(currPos).constraint,'Enable','off','String','');
                
                set(ud.optimization(currPos).a,'Enable','on'); 
        end
end
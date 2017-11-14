function generateData(ud)
global planC;
valArray = [];
strc = {};
stcIndex = [];
indexS = planC{end};
for i=1:length(planC{indexS.structures})
    strc{i} = planC{indexS.structures}(i).structureName;
end
for i=1:length(ud.optimization)
    valCell = ud.optimization(i).organ.String(ud.optimization(i).organ.Value);
    valArray(end+1) = i;
    stcIndex(end+1) = find(strcmp(strc,valCell{1}));
end
IMNumber = size(planC{indexS.IM},2); 
sampleRates = planC{indexS.IM}(IMNumber).IMDosimetry.beams(1,1).beamlets(1,1).sampleRate;
i=1;
for struc = stcIndex
    allVoxelC{i} = getVoxelV(struc, sampleRates); 
    i=i+1;
end

influenceM = getGlobalInfluenceM(planC{indexS.IM}(IMNumber).IMDosimetry, stcIndex);
fidDat = fopen(ud.inf,'w');
[r,c,v] = find(influenceM);
data_dump = [r,c,v];
clear r c v;
data_dump = data_dump';
fprintf( fidDat,'%d %d %f\n', data_dump );
clear data_dump;
fclose(fidDat);


fidDat = fopen(ud.dFile,'w');

numbeamlet = size(influenceM,2);
fprintf(fidDat,'param numbeamlet := %d;\n',numbeamlet);
fprintf(fidDat,'param numOrgans := %d;\n',length(ud.optimization));
fprintf(fidDat,'set organs  = ');    
fprintf(fidDat,'%d ',1:length(ud.optimization)); 
fprintf(fidDat,';\n');

% fprintf(fidDat,'param organs := ');
% fprintf(fidDat,'%d ',valArray);
% fprintf(fidDat,';\n');
% valArray = {};
% for i=1:length(ud.optimization)  
%     valCell = ud.optimization(i).type.String(ud.optimization(i).type.Value);
%     valArray{i} = valCell{:};
% end
% fprintf(fidDat,'param type :=\n');
% for i = 1:length(organs)
%     fprintf(fidDat,'%s %s ',organs{i},valArray{i});
% end
% fprintf(fidDat,';\n');


numEle = 0;
for i=1:length(ud.optimization)  
    if(~strcmp(ud.optimization(i).dose.String,'') )
        if numEle==0
            fprintf(fidDat,'param dose := ');
        end
        valCell = str2num(ud.optimization(i).dose.String);
        fprintf(fidDat,'%d %f ',i,valCell);
        numEle = numEle + 1;
    end
end

if(numEle>0)
    fprintf(fidDat,';\n');
    fprintf(fidDat,'param numDose := %d;\n',numEle);
end
numEle = 0;
for i=1:length(ud.optimization)  
    if(~strcmp(ud.optimization(i).weight.String,'') )
        if numEle==0
            fprintf(fidDat,'param weight :=');
        end
        valCell= str2num(ud.optimization(i).weight.String);
        fprintf(fidDat,'%d %f ',i,valCell);
        numEle = numEle+1;
    end
end
if numEle >0
    fprintf(fidDat,';\n');
end

numEle = 0;
for i=1:length(ud.optimization)  
    if(~strcmp(ud.optimization(i).volume.String,'') )
        if numEle==0
            fprintf(fidDat,'param volume :=');
        end
        valCell = str2num(ud.optimization(i).volume.String);
        fprintf(fidDat,'%d %f ',i,valCell);
        numEle = numEle+1;
    end
end

if(numEle>0)
    fprintf(fidDat,';\n');
    fprintf(fidDat,'param numVol := %d;\n',numEle);
end

numEle=0;
for i=1:length(ud.optimization)  
    if(~strcmp(ud.optimization(i).a.String,'') )
        if numEle==0
            fprintf(fidDat,'param a :=');
        end
        valCell = str2num(ud.optimization(i).a.String);
        fprintf(fidDat,'%d %f ',i,valCell);
        numEle = numEle+1;
    end
end
if(numEle>0)
    fprintf(fidDat,';\n');
    fprintf(fidDat,'param numA := %d;\n',numEle);   
end

for i = 1:length(ud.optimization)
    fprintf(fidDat,'set V[%d] := ',i);
    fprintf(fidDat,'%d ',allVoxelC{i});
    fprintf(fidDat,';\n');
end

fprintf(fidDat,'param: Indices: influenceM := include inf;\n');   

fclose(fidDat);
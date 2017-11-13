function saveSol()
% Save step 4 solution
% 10/24/12 Yao

global planC
indexS = planC{end};
IMNumber = size(planC{indexS.IM},2);

fid = fopen('result');
w = fscanf(fid,'%f ');

IM = planC{indexS.IM}(IMNumber).IMDosimetry;
found = false;
for i=1:length(planC{indexS.structures})
    strc = lower(planC{indexS.structures}(i).structureName);
    if(strcmp(strc,'skin'))
        found = true;
        break;
    end
end
if ~found
  msgbox('No skin structure found. The optimizer could not perform final dose computation. Please create the skin structure.','Information');  
  return;
end
Skin = i;
dose3DM = getIMDose(IM,w, Skin);
dose2CERR(dose3DM,[],'OptimizedDose','CERR test','Test PB distribution.','UniformCT',[],'no', IM.assocScanUID);

fclose(fid);

function generateModel(ud)
% Generate step1 model file for AMPL


fidModel = fopen(ud.mFile,'w');


fprintf(fidModel,'param numOrgans;\n');
fprintf(fidModel,'param numDose;\n');
fprintf(fidModel,'param numA;\n');
fprintf(fidModel,'param numVol;\n');
fprintf(fidModel,'set organs ;\n');
fprintf(fidModel,'param dose{organs};\n');
fprintf(fidModel,'param weight{organs};\n');
fprintf(fidModel,'param volume{organs};\n');
fprintf(fidModel,'param a{organs};\n');
fprintf(fidModel,'set Indices dimen 2;\n');
fprintf(fidModel,'param influenceM {Indices};\n');
fprintf(fidModel,'param numbeamlet;\n');
fprintf(fidModel,'var w {1..numbeamlet} >= 0;\n');
fprintf(fidModel,'set V {organs};\n');

fprintf(fidModel,'minimize F:');
for i=1:length(ud.optimization)
    if(~ud.optimization(i).constraint.Value )
        switch(ud.optimization(i).type.Value)
            case 1
                fprintf(fidModel,'weight[%d]* (1/card(V[%d])* sum{j in V[%d]} (min( sum{(j,k) in Indices} influenceM[j,k]*w[k]-dose[%d],0)^2))',i,i,i,i);         
            case 2
                fprintf(fidModel,'weight[%d]* (1/card(V[%d])*sum{j in V[%d]} (max( sum{(j,k) in Indices} influenceM[j,k]*w[k]-dose[%d],0)^2))',i,i,i,i);
            case 3
                fprintf(fidModel,'weight[%d]* ((1/card(V[%d])* sum{j in V[%d]} (sum{(j,k) in Indices} (influenceM[j,k]*w[k])^20))^(1/20)) +  (1/card(V[%d])* sum{j in V[%d]}( sum{(j,k) in Indices} influenceM[j,k]*w[k]))',i,i,i,i,i);
            case 4
                fprintf(fidModel,'weight[%d]* (1/card(V[%d])*sum{j in V[%d]} ( sum{(j,k) in Indices} influenceM[j,k]*w[k]-dose[%d])^2)',i,i,i,i);
            case 5
                fprintf(fidModel,'weight[%d]* (1/card(V[%d])* (sum{j in V[%d]} (sum{(j,k) in Indices} (influenceM[j,k]*w[k])^a[%d]))^(1/a[%d]))',i,i,i,i,i);
        end
        if(i ~= length(ud.optimization) && ~ud.optimization(i+1).constraint.Value)
            fprintf(fidModel,' +');
        end
    end
    
end
fprintf(fidModel,';\n');
for i=1:length(ud.optimization)
    
    if(ud.optimization(i).constraint.Value)
        fprintf(fidModel,'subject to cons%d {j in V[%d]}:',i,i);
        switch(ud.optimization(i).type.Value)
            case 1
                fprintf(fidModel,'(sum{(j,k) in Indices} influenceM[j,k]*w[k])>= dose[%d];\n',i);         
            case 2
                fprintf(fidModel,'(sum{(j,k) in Indices} influenceM[j,k]*w[k]) <=dose[%d];\n',i);
            
        end
    end
  
end

fclose(fidModel);



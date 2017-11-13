function genRunFile(solver,selectedSolver)
% Generate step1 run file for AMPL
% 10/23/12 Yao

fidRun = fopen('imrt.run','w');
fprintf(fidRun,'option solver ''%s'';\n',solver);
if(contains(solver,'knitro'))
     if (strcmp(selectedSolver,'knitro_Direct'))
        fprintf(fidRun,'option knitro_options "alg=1"; \n'); 
     elseif(strcmp(selectedSolver,'knitro_CG'))
        fprintf(fidRun,'option knitro_options "alg=2"; \n'); 
     elseif(strcmp(selectedSolver,'knitro_Active'))
        fprintf(fidRun,'option knitro_options "alg=3"; \n'); 
     elseif(strcmp(selectedSolver,'knitro_SQP'))
         fprintf(fidRun,'option knitro_options "alg=4"; \n'); 
     end

end

fprintf(fidRun,'model imrt.mod;\n');
fprintf(fidRun,'data imrt.dat;\n');

fprintf(fidRun,'let {k in 1..numbeamlet}w[k] := 1;\n');

fprintf(fidRun,'solve;\n');
fprintf(fidRun,'printf {k in 1..numbeamlet}: \"%%f \",w[k] >result;\n');
fclose(fidRun);

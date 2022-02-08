clear
clc
fileName = 'outputderv.txt';
fID = fopen(fileName, 'r');
x = textscan(fID, '%s');
s = 1;
for i = 1:100
    if strcmp(x{1,1}{i,1}, 'CXtot') == 1 && s == 1
        CX_basename = x{1,1}{i+2,1};
        CY_basename = x{1,1}{i+2+9,1};
        CZ_basename = x{1,1}{i+2+15,1};
        
        Cl_basename = x{1,1}{i+2+3,1};       
        Cm_basename = x{1,1}{i+2+12,1};
        Cn_basename = x{1,1}{i+2+18,1};
        
        CL_basename = x{1,1}{i+2+24,1};
        CD_basename = x{1,1}{i+2+27,1};
        
        s = 0;
    end
    
end

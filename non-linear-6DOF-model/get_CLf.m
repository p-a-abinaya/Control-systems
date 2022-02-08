function CL_q = get_CLf(alpha, elevator, CL, alphaq, elevatorq)
[al, el] = meshgrid(alpha, elevator);
qData = griddata(al, el, CL', alphaq, elevatorq, 'cubic');
CL_q = qData;

function Cm_q = get_Cm(alpha, elevator, Cm, alphaq, elevatorq)
[al, el] = meshgrid(alpha, elevator);
qData = griddata(al, el, Cm', alphaq, elevatorq, 'cubic');
Cm_q = qData;
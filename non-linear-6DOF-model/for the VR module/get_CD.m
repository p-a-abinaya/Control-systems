function CD_q = get_CD(alpha, elevator, CD, alphaq, elevatorq)
[al, el] = meshgrid(alpha, elevator);
qData = griddata(al, el, CD', alphaq, elevatorq, 'cubic');
CD_q = qData;
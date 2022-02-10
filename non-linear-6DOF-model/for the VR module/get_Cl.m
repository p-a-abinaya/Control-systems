function Cl_q = get_Cl(beta, rudder, aileron, Cl, beta_q, rudder_q, aileron_q)
[be, ru, ai] = meshgrid(beta, rudder, aileron);
Cl_q = griddata(be, ru, ai, pagetranspose(Cl), beta_q, rudder_q, aileron_q, "natural");
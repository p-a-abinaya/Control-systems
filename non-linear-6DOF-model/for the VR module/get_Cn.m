function Cn_q = get_Cn(beta, rudder, aileron, Cn, beta_q, rudder_q, aileron_q)
[be, ru, ai] = meshgrid(beta, rudder, aileron);
Cn_q = griddata(be, ru, ai, pagetranspose(Cn), beta_q, rudder_q, aileron_q, "natural");
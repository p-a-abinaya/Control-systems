function CY_q = get_CY(beta, rudder, aileron, CY, beta_q, rudder_q, aileron_q)
[be, ru, ai] = meshgrid(beta, rudder, aileron);
CY_q = griddata(be, ru, ai, pagetranspose(CY), beta_q, rudder_q, aileron_q, "natural");
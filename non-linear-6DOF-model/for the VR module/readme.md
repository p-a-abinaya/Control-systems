# Running the Simulation
## Steps 
	1. The RunFirstLateralModel.m and RunFirstLongitudinalModel.m has the codes to for extracting force and moment coefficients
	2. The NonLin6DOFModel.m is the function that takes in present state variables and control signals as inputs and then gives us state derivatives as output. The RunSecond_initCode.m has the code to give initial conditions and saturation limits for the control surfaces. 
	3. The avl geometry and mass files and the avl .exe should be present in the same directory as the codes. 
	4. the get_CLf, get_CD, get_Cl, get_Cm, get_Cn and get_CY script files are functions to interpolate the force and moment coefficients from the available data. 
	
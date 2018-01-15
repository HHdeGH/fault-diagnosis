classdef g014g < model
    
    methods
        function this = g014g()
            this.name = 'g014g';
            this.description = 'Fixed-wing UAV model, revized, according to uav-modeling, with no extra \dot{x} terms. Used in paper 2. Converting some scalar equations to vectors. With added sumbodule information';
            
            %% Equation list
            % legend:
            % dot - differential relation
            % int - integral term
            % trig - trigonometric term
            % ni - general non-invertible term
            % inp - input variable
            % out - output variable % NOT SUPPORTED
            % msr - measured variable
            % sub - subsystem where the equation belongs
            
            %% Variable tally
            
            % Unknown Variables
            % Should appear as var(c), NOT as msr or inp
            % dot_north, dot_east, dot_down, north, east, down
            % dot_phi, dot_theta, dot_psi, phi, theta, psi
            % dot_u, dot_v, dot_w, u, v, w
            % dot_p, dot_q, dot_r, p, q, r
            % c_0, c_1, c_2, Ji_X
            % V_i, chi, gamma, V_g
            % F_x, F_y, F_z, T_x, T_y, T_z
            % u_r, v_r, w_r, V_a, alpha, beta, u_w, v_w, w_w
            % m, m_nom, p_cm_x, p_cm_y, p_cm_z, J_nom_0, J_0, D_J
            % F_g_x, F_g_y, F_g_z, g
            % F_a_x, F_a_y, F_a_z, F_D, F_Y, F_Z, dx_CL, dy_CL, dz_CL
            % T_atot_x, T_atot_y, T_atot_z
            % q_bar, rho
            % C_D, C_Y, C_L, C_l, C_m, C_n
            % delta_a, delta_e, delta_t, delta_r
            % F_t_x, C_t, n_prop, F_t_y, F_t_z, T_t_x, T_t_y, T_t_z
            % dx_prop, dy_prop, dz_prop, T_ttot_x, T_ttot_y, T_ttot_z
            % Jar, C_p, P_prop, dot_n_prop
            % P_mot, E_i, I_i, V_mot, I_mot, P_elec, V_bat
            % h, z, lat, lon, lat_0, lon_0, z_0
            % T, P, P_t, 
            % T_0, P_0, h_0
            % w_n, w_e
            
            % Known/measured variables
            % Should appear in sensor equations OR fixed constraints,
            % should appear as msr or inp
            % m_nom, J_nom_0
            % p_CL_x, p_CL_y, p_CL_z
            % g_0
            % delta_am, delta_em, delta_tm, delta_rm
            % p_prop_x, p_prop_y, p_prop_z
            % lat_0_m, lon_0_m, z_0_m
            % T_0_m, P_0_m, h_0_m
            % a_m_x, a_m_y, a_m_z, p_m, q_m, r_m
            % phi_m, theta_m, psi_m
            % lat_m, lon_m, z_m, V_g_m, chi_m
            % P_m, T_m, P_t_m
            % alpha_m, beta_m
            % V_mot_m, I_mot_m, n_prop_m
            
            % Constants, parameters
            % Shall appear nowhere
            % S, b, c
            % CD_*, CL_*, CY_*, Cl_*, Cm_*, Cn_*
            % D, J_mot, J_prop, R_m, R_1, R_bat, R_s, I_0,
            % R_M, R_N, r_0
            % L_0, M_0, R_star
            
            %% Kinematic Equations
            
            % Position derivatives
            kin = [...
                {'dot_north ni phi ni theta ni psi ni u ni v ni w sub kinematics'};...
                {'dot_east ni phi ni theta ni psi ni u ni v ni w sub kinematics'};...
                {'dot_down ni phi ni theta ni psi ni u ni v ni w sub kinematics'};...
                ];
            
            der = [...
                {'int dot_north dot north sub kinematics'};...
                {'int dot_east dot east sub kinematics'};...
                {'int dot_down dot down sub kinematics'};
                ];
            
            % Euler angle derivatives
            kin = [kin;...
                {'dot_phi ni phi ni theta p ni q ni r sub kinematics'};...
                {'dot_theta ni phi q ni r sub kinematics'};...
                {'dot_psi ni phi ni theta ni q r sub kinematics'};...
                ];
            
            der = [der;...
                {'int dot_phi dot phi sub kinematics'};...
                {'int dot_theta dot theta sub kinematics'};...
                {'int dot_psi dot psi sub kinematics'};...
                ];
            
            % Angular Velocity
            kin = [kin;...
                {'C_0 ni p ni q ni r ni J sub kinematics'};...
                {'C_1 ni p ni q ni r ni J sub kinematics'};...
                {'C_2 ni p ni q ni r ni J sub kinematics'};...
                {'dot_p ni Ji ni T_x ni T_y ni T_z ni C_0 ni C_1 ni C_2 sub kinematics'};...
                {'dot_q ni Ji ni T_x ni T_y ni T_z ni C_0 ni C_1 ni C_2 sub kinematics'};...
                {'dot_r ni Ji ni T_x ni T_y ni T_z ni C_0 ni C_1 ni C_2 sub kinematics'};...
                ];
            
            der = [der;...
                {'int dot_p dot p sub kinematics'};...
                {'int dot_q dot q sub kinematics'};...
                {'int dot_r dot r sub kinematics'};...
                ];
            
            % Linear Velocity
            kin = [kin;...
                {'V_i ni u ni v ni w sub kinematics'};...
                %%
                {'chi ni u ni v ni w ni phi ni theta ni psi sub kinematics'};... % ni needed here to keep the system semi-explicit DAE
                {'gamma ni u ni v ni w ni phi ni theta ni psi V_i sub kinematics'};...
                %%
                {'V_g V_i gamma sub kinematics'};... % Is a "ni" in front of V_i reasonable? - I choose to let it as is
                {'dot_u ni v ni w ni r ni q F_x ni m sub kinematics'};...
                {'dot_v ni u ni w ni p r F_y ni m sub kinematics'};...
                {'dot_w ni u ni v ni p q F_z ni m sub kinematics'};...
                ];
            
            der = [der;...
                {'int dot_u dot u sub kinematics'};...
                {'int dot_v dot v sub kinematics'};...
                {'int dot_w dot w sub kinematics'};...
                ];
            
            % Air data
            kin = [kin;...
                {'u_r u u_w sub airdata'};...
                {'v_r v v_w sub airdata'};...
                {'w_r w w_w sub airdata'};...
                {'alpha w_r u_r sub airdata'};...
                {'beta v_r V_a sub airdata'};...
                {'V_a ni u_r ni v_r ni w_r sub airdata'};...
                ];
            
            % Mass Distribution
            kin = [kin;...
                {'m sub mass'};... % Known nominal mass
                {'p_cm sub mass'};...
                {'J sub mass'};... known inertia component
                {'Ji ni J sub mass'};...
                ];
            
            %% Dynamic Equations
            dyn = [];
            
            dyn = [dyn;...
                {'F_x F_g_x F_a_x F_t_x sub dynamics'};...
                {'F_y F_g_y F_a_y F_t_y sub dynamics'};...
                {'F_z F_g_z F_a_z F_t_z sub dynamics'};...
                {'T_x T_atot_x T_ttot_x sub dynamics'};...
                {'T_y T_atot_y T_ttot_y sub dynamics'};...
                {'T_z T_atot_z T_ttot_z sub dynamics'};...
                ];
            
            % Gravity
            dyn = [dyn;...
                {'F_g_x theta ni m ni g sub gravity'};...
                {'F_g_y phi ni theta ni m ni g sub gravity'};...
                {'F_g_z phi theta m g sub gravity'};...
                ];
            
            % Aerodynamics
            dyn = [dyn;...
                {'F_a_x ni alpha ni beta F_D ni F_Y ni F_L sub aerodynamics'};... 
                {'F_a_y ni beta ni F_D F_Y sub aerodynamics'};...
                {'F_a_z ni alpha ni beta ni F_D ni F_Y F_L sub aerodynamics'};... 
                {'dp_CL p_cm p_cl sub aerodynamics'};...
                {'T_atot_x T_a_x ni dp_CL ni F_a_y ni F_a_z sub aerodynamics'};... 
                {'T_atot_y T_a_y ni dp_CL ni F_a_x ni F_a_z sub aerodynamics'};...
                {'T_atot_z T_a_z ni dp_CL ni F_a_x ni F_a_y sub aerodynamics'};...
                {'q_bar rho V_a sub aerodynamics'};...
                {' F_D ni q_bar C_D sub aerodynamics'};...
                {' F_Y ni q_bar C_Y sub aerodynamics'};...
                {' F_L ni q_bar C_L sub aerodynamics'};...
                {' C_D ni V_a ni alpha ni q ni delta_e sub aerodynamics'};...
                {' C_Y ni V_a ni beta ni p ni r ni delta_a ni delta_r sub aerodynamics'};...
                {' C_L ni V_a ni alpha ni ni q ni delta_e sub aerodynamics'};...
                {' T_a_x ni q_bar C_l sub aerodynamics'};...
                {' T_a_y ni q_bar C_m sub aerodynamics'};...
                {' T_a_z ni q_bar C_n sub aerodynamics'};...
                {' C_l ni V_a ni beta ni p ni r ni delta_a ni delta_r sub aerodynamics'};...
                {' C_m ni V_a ni alpha ni q ni delta_e sub aerodynamics'};...
                {' C_n ni V_a ni beta ni p ni r ni delta_a ni delta_r sub aerodynamics'};...
                ];
            
            % Propeller
            dyn = [dyn;...
                {'fault F_t_x C_t ni rho ni n_prop sub propeller'};... % Using propeller model
                {' F_t_y sub propeller'};...
                {' F_t_z sub propeller'};...
                {'T_t_x P_prop ni w_prop sub propeller'};...
                {' T_t_y sub propeller'};...
                {' T_t_z sub propeller'};...
                {'dp_prop p_cm p_prop sub propeller'};...
                {'T_ttot_x T_t_x ni dp_prop ni F_t_x ni F_t_z sub propeller'};...
                {'T_ttot_y T_t_y ni dp_prop ni F_t_x ni F_t_z sub propeller'};...
                {'T_ttot_z T_t_z ni dp_prop ni F_t_x ni F_t_y sub propeller'};...
                {'n_prop w_prop sub propeller'};...
                {'Jar V_a n_prop sub propeller'};...
                {'fault C_t ni Jar sub propeller'};...
                {'fault P_prop C_p ni rho ni n_prop sub propeller'};...
                {'fault C_p ni Jar sub propeller'};...
                ];
            
            der = [der;...
                {'int dot_n_prop dot n_prop sub propeller'};...
                ];
            
            % Motor
            dyn = [dyn;...
                {' dot_n_prop P_mot P_prop ni n_prop sub motor'};...
                {'fault n_prop n_mot sub motor'};...
                {'fault n_mot E_i sub motor'};...
                {'fault E_i V_mot I_mot sub motor'};...
                {'P_mot ni E_i ni I_i sub motor'};...
                {'fault I_i I_mot E_i sub motor'};...
                {'P_elec ni V_mot ni I_mot sub motor'};...
                {'fault V_mot V_bat I_mot ni delta_t sub motor'};...
                ];
            
            %% Other models
            
            mod = [];
            
            mod = [mod;...
                {'north z lat lat_0 sub earth'};... % Earth model
                {'east z lon lon_0 sub earth'};...
                {'down z z_0 sub earth'};... % NED altitude offset from geometric altitude
                {'h ni z sub earth'};... % geopotential altitude
                {'z ni h sub earth'};...
                {'T T_0 ni h ni h_0 sub athmosphere'};... % Temperature gradient
                {'P P_0 ni T_0 ni T sub athmosphere'};... % Pressure gradient
                {'h ni T_0 ni P ni P_0 h_0 sub athmosphere'};... % Barometric altitude calcuation
                {'rho P T sub athmosphere'};... % density gradient
                {'P_t P rho V_a sub athmosphere'};... % dynamic pressure
                {'u_w ni phi ni theta ni psi ni w_n ni w_e sub athmosphere'};... %Assumption ww = 0; % Wind Model
                {'v_w ni phi ni theta ni psi ni w_n ni w_e sub athmosphere'};... %Assumption ww = 0; % Wind Model
                {'w_w ni phi ni theta ni psi ni w_n ni w_e sub athmosphere'};... %Assumption ww = 0; % Wind Model
                % Add wind model V_w, theta_w equations?
                ];
            
            %% Sensory equations
            
            msr = [];
            
            msr = [msr;...
                {'fault msr a_m_x F_x ni m ni g theta sub sensors'};... % Acceleration
                {'fault msr a_m_y F_y ni m ni g phi ni theta sub sensors'};...
                {'fault msr a_m_z F_z ni m ni g phi theta sub sensors'};...
                {'fault msr p_m p sub sensors'};... % Angular velocity
                {'fault msr q_m q sub sensors'};...
                {'fault msr r_m r sub sensors'};...
                {'fault msr phi_m phi sub sensors'};... % Euler angles
                {'fault msr theta_m theta sub sensors'};...
                {'fault msr psi_m psi sub sensors'};...
                {'fault msr lat_0_gps lat_0 sub sensors'};... % GPS measurements
                {'fault msr lon_0_gps lon_0 sub sensors'};...
                {'fault msr lat_gps lat sub sensors'};...
                {'fault msr lon_gps lon sub sensors'};...
                {'fault msr z_gps z sub sensors'};...
                {'fault msr V_g_gps V_g sub sensors'};...
                {'fault msr chi_gps chi sub sensors'};...
                {'msr T_0_m T_0 sub initializations'};... % Initialization temperature
                {'msr z_0_m z_0 sub initializations'};... % Initialization altitude
                {'z_0 h_0 sub initializations'};...
                {'fault msr P_bar P sub sensors'};... % Barometer reading
                {'fault msr T_m T sub sensors'};... % Therometer reading
                {'fault msr P_t_m P_t sub sensors'};... % Pitot reading
                {'fault msr alpha_m alpha sub sensors'};.... % AoA reading
                {'fault msr beta_m beta sub sensors'};... % AoS reading
                {'fault msr V_mot_m V_mot sub sensors'};... % Battery voltage measurement
                {'fault msr I_mot_m I_mot sub sensors'};... % Battery current measurement
                {'fault msr n_prop_m n_prop sub sensors'};... % Motor rps measurement
                {'fault delta_a inp delta_a_inp sub actuators'};...
                {'fault delta_e inp delta_e_inp sub actuators'};...
                {'fault delta_t inp delta_t_inp sub actuators'};...
                {'fault delta_r inp delta_r_inp sub actuators'};...
                {'p_prop sub constants'};...
                {'p_cl sub constants'};...
                {'g sub constants'};... % Taking static gravity for now
                ];
            
            
            %% Summing up
            this.constraints = [...
                {kin},{'k'};...
                {dyn},{'f'};...
                {der},{'d'};...
                {mod},{'m'};...
                {msr},{'s'};...
                ];
            
            %% Specifying node coordinates if available
            this.coordinates = [];
            
        end
        
    end
    
end
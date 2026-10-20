$TITLE HW5 - Mixed Integer Program for Reservoir and Irrigation Design (Chapter 7, Problem 1)

* ==============================================================================
* Problem Statement:
* A farmer plans to develop water for irrigation using two potential sources:
* 1. High Dam (Capacity = 700 ac-ft, Capital Cost = $10,000/yr) OR Low Dam (Capacity = 300 ac-ft, Capital Cost = $6,000/yr)
* 2. Lower River Pump (Capacity = 2.2 ac-ft/day, Capital Cost = $8,000/yr, Operating Cost = $20/ac-ft)
*
* Groundwater accretion between reservoir and pump = 2.0 ac-ft/day.
* Revenue = $300/acre/year.
* Seasons: Season 1 (6 months = 182.5 days), Season 2 (6 months = 182.5 days).
* ==============================================================================

SETS
    t /1, 2/ ;

PARAMETERS
    Q(t)       Seasonal inflow to reservoir (ac-ft)
               / 1 600, 2 200 /
    d(t)       Seasonal irrigation demand (ac-ft per acre)
               / 1 1.0, 2 3.0 /
    GW(t)      Seasonal groundwater accretion (ac-ft)
               / 1 365, 2 365 /
    MaxPump(t) Maximum seasonal pump capacity (ac-ft)
               / 1 401.5, 2 401.5 / ;

VARIABLES
    Z          Total annual net benefit ($ per year)
    A          Irrigated farm area (acres)
    S(t)       End-of-season reservoir storage (ac-ft)
    R(t)       Reservoir release for irrigation (ac-ft)
    P(t)       Water pumped from lower river diversion for irrigation (ac-ft)
    SP(t)      Excess spill from reservoir down river (ac-ft) ;

BINARY VARIABLES
    I_high     1 if high dam is constructed; 0 otherwise
    I_low      1 if low dam is constructed; 0 otherwise
    I_p        1 if pump station is constructed; 0 otherwise ;

POSITIVE VARIABLES A, S, R, P, SP ;

EQUATIONS
    obj             Objective Function: Maximize Net Benefit
    dam_select      Mutual exclusivity of dam construction
    mass_bal(t)     Seasonal mass balance in the reservoir
    storage_cap(t)  Reservoir storage capacity limit
    demand(t)       Seasonal crop water demand requirements
    pump_cap(t)     Pump operating capacity limit
    river_avail(t)  Available water at lower diversion for pumping ;

* Objective Function ($)
obj..
    Z =E= 300*A - 10000*I_high - 6000*I_low - 8000*I_p - 20*(P('1') + P('2')) ;

* Dam Construction Constraint (At most one dam size)
dam_select..
    I_high + I_low =L= 1 ;

* Reservoir Mass Balance Equations (S2 is carryover storage for S0)
mass_bal(t)..
    S(t) =E= S(t--1) + Q(t) - R(t) - SP(t) ;

* Reservoir Capacity Constraints
storage_cap(t)..
    S(t) =L= 700*I_high + 300*I_low ;

* Irrigation Water Demand Constraints
demand(t)..
    R(t) + P(t) =G= d(t)*A ;

* Pumping Capacity Constraints
pump_cap(t)..
    P(t) =L= MaxPump(t)*I_p ;

* River Water Availability Constraints for Lower Diversion
river_avail(t)..
    P(t) =L= SP(t) + GW(t) ;

* Model Definition and Solve
MODEL Reservoir_Irrigation_MIP / ALL / ;
SOLVE Reservoir_Irrigation_MIP USING MIP MAXIMIZING Z ;

* Display Key Results
DISPLAY Z.l, A.l, I_high.l, I_low.l, I_p.l, S.l, R.l, P.l, SP.l ;
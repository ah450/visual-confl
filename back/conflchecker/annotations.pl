:- module(annotations, [print_critical_pairs/1, print_cp/1]).


%% prints a single critical pair
print_cp(CPO):-
    copy_term(CPO, CP),
    CP = cp(S1, S2, R1, R2, Overlap, CAS),
    numbervars(CP, 0, _E),
    S1 = state(S1CHRConstraints, S1BIConstroaints, S1Globals),
    S2 = state(S2CHRConstraints, S2BIConstroaints, S2Globals),
    R1 =  rule(R1repr, KH1, RH1, G1, B1),
    R2 =  rule(R2repr, KH2, RH2, G2, B2),
    write_term('Critical ancestor state', []), nl, write_term(CAS, [numbervars(true)]), nl,
    write_term('state 1',[]), nl, write_term(S1, [numbervars(true)]), nl,
    write_term('state 2', []), nl, write_term(S2, [numbervars(true)]), nl,
    write_term('rule 1', []), nl, write_term(R1, [numbervars(true)]), nl,
    write_term('rule 2', []), nl, write_term(R2, [numbervars(true)]), nl,
    write_term('Overlapping constraints', []), nl, write_term(Overlap, [numbervars(true)]), nl.

cp_helper([]).

cp_helper([H|T]):-
    write_term('===============================================================================', []),nl,
    print_cp(H),
    write_term('===============================================================================', []),nl,    
    cp_helper(T).

    

%% prints a list of critical pairs
print_critical_pairs(CPS):-
    write_term('----------------------------------------------------------------------------------', []),nl,
    write_term('Critical pairs', []),nl,
    cp_helper(CPS),
    write_term('----------------------------------------------------------------------------------', []),nl.

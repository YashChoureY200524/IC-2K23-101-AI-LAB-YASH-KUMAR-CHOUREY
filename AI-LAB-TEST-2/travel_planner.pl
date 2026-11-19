:- dynamic best_route/4.
:- dynamic avoid_city/1.
:- dynamic blocked_edge/2.

% Knowledge base: edge(From, To, Distance_km, Time_hours, Cost_Rs)
edge(city_a, city_b, 100, 2, 250).
edge(city_b, city_f, 250, 4, 600).
edge(city_a, city_c, 120, 2, 400).
edge(city_c, city_f, 200, 3, 700).
edge(city_a, city_d, 160, 1, 600).
edge(city_d, city_f, 180, 2, 800).
edge(city_a, city_e, 110, 4, 450).
edge(city_e, city_f, 150, 4, 500).
edge(city_b, city_c, 80, 2, 150).
edge(city_c, city_d, 70, 1, 200).
edge(city_d, city_e, 90, 2, 250).
edge(city_b, city_e, 130, 3, 300).

% Bidirectional connectivity
connected(X, Y, D, T, C) :- edge(X, Y, D, T, C).
connected(X, Y, D, T, C) :- edge(Y, X, D, T, C).

% Valid step check
valid_step(X, Y, D, T, C) :-
    connected(X, Y, D, T, C),
    \+ avoid_city(Y),
    \+ blocked_edge(X, Y),
    \+ blocked_edge(Y, X).

% Cycle prevention
has_visited(X, [X|_]) :- !.
has_visited(X, [_|Tail]) :- has_visited(X, Tail).

% Path search (DFS)
find_path(Dest, Dest, Visited, Visited, 0, 0, 0).
find_path(Curr, Dest, Visited, FullPath, TotalD, TotalT, TotalC) :-
    valid_step(Curr, Next, D, T, C),
    \+ has_visited(Next, Visited),
    find_path(Next, Dest, [Next|Visited], FullPath, SubD, SubT, SubC),
    TotalD is D + SubD,
    TotalT is T + SubT,
    TotalC is C + SubC.

reverse_path([], Acc, Acc).
reverse_path([H|T], Acc, Result) :-
    reverse_path(T, [H|Acc], Result).

% Decision rules
is_better(cheapest, _, _, C, _, _, BestC) :- C < BestC.
is_better(cheapest, _, T, C, _, BestT, BestC) :- C =:= BestC, T < BestT.

is_better(fastest, _, T, _, _, BestT, _) :- T < BestT.
is_better(fastest, _, T, C, _, BestT, BestC) :- T =:= BestT, C < BestC.

is_better(shortest, D, _, _, BestD, _, _) :- D < BestD.
is_better(shortest, D, T, _, BestD, BestT, _) :- D =:= BestD, T < BestT.

% Global optimum search via failure-driven loop
init_best :-
    retractall(best_route(_, _, _, _)),
    assertz(best_route([], 9999, 9999, 9999)).

search_all(Source, Dest, Pref) :-
    find_path(Source, Dest, [Source], RevPath, D, T, C),
    best_route(_, BestD, BestT, BestC),
    is_better(Pref, D, T, C, BestD, BestT, BestC),
    retractall(best_route(_, _, _, _)),
    reverse_path(RevPath, [], ForwardPath),
    assertz(best_route(ForwardPath, D, T, C)),
    fail.
search_all(_, _, _).

plan_travel(Source, Dest, Pref) :-
    init_best,
    search_all(Source, Dest, Pref),
    best_route(Path, D, T, C),
    Path \= [],
    display_result(Source, Dest, Pref, Path, D, T, C),
    !.
plan_travel(Source, Dest, _) :-
    format('~nStatus: No valid route found between ~w and ~w.~n', [Source, Dest]).

% Output formatting
city_name(city_a, 'City A').
city_name(city_b, 'City B').
city_name(city_c, 'City C').
city_name(city_d, 'City D').
city_name(city_e, 'City E').
city_name(city_f, 'City F').

pref_label(cheapest, 'Cheapest Route').
pref_label(fastest, 'Fastest Route').
pref_label(shortest, 'Shortest Route').

print_route([]) :- nl.
print_route([H]) :-
    ( city_name(H, Name) -> write(Name) ; write(H) ),
    nl, !.
print_route([H|T]) :-
    ( city_name(H, Name) -> write(Name) ; write(H) ),
    write(' -> '),
    print_route(T).

display_reason(cheapest) :-
    write('This route has the lowest total cost among the available routes.').
display_reason(fastest) :-
    write('This route has the lowest travel time among the available routes.').
display_reason(shortest) :-
    write('This route has the shortest distance among the available routes.').

display_result(Source, Dest, Pref, Path, D, T, C) :-
    nl,
    write('=================================================='), nl,
    write('           INTELLIGENT TRAVEL PLANNER             '), nl,
    write('=================================================='), nl,
    ( city_name(Source, SName) -> true ; SName = Source ),
    ( city_name(Dest, DName) -> true ; DName = Dest ),
    ( pref_label(Pref, PLabel) -> true ; PLabel = Pref ),
    format('Source: ~w~n', [SName]),
    format('Destination: ~w~n', [DName]),
    format('Preference: ~w~n', [PLabel]),
    write('Recommended Route: '), print_route(Path),
    format('Total Cost: Rs. ~w~n', [C]),
    format('Estimated Travel Time: ~w hours~n', [T]),
    format('Total Distance: ~w km~n', [D]),
    write('Reason: '), display_reason(Pref), nl,
    write('=================================================='), nl.

% Additional challenges
plan_travel_avoid(Source, Dest, Pref, AvoidCity) :-
    assertz(avoid_city(AvoidCity)),
    ( city_name(AvoidCity, AName) -> true ; AName = AvoidCity ),
    format('~n--> Route planning while avoiding: ~w~n', [AName]),
    plan_travel(Source, Dest, Pref),
    retractall(avoid_city(AvoidCity)),
    !.
plan_travel_avoid(_, _, _, AvoidCity) :-
    retractall(avoid_city(AvoidCity)),
    fail.

plan_travel_block(Source, Dest, Pref, City1, City2) :-
    assertz(blocked_edge(City1, City2)),
    ( city_name(City1, N1) -> true ; N1 = City1 ),
    ( city_name(City2, N2) -> true ; N2 = City2 ),
    format('~n--> Connection blocked between ~w and ~w~n', [N1, N2]),
    plan_travel(Source, Dest, Pref),
    retractall(blocked_edge(City1, City2)),
    !.
plan_travel_block(_, _, _, City1, City2) :-
    retractall(blocked_edge(City1, City2)),
    fail.

compare_cheapest_fastest(Source, Dest) :-
    nl,
    write('=================================================='), nl,
    write('      ROUTE COMPARISON: CHEAPEST vs FASTEST       '), nl,
    write('=================================================='), nl,
    plan_travel(Source, Dest, cheapest),
    best_route(_, _, CT, CC),
    plan_travel(Source, Dest, fastest),
    best_route(_, _, FT, FC),
    TimeSaved is CT - FT,
    CostDiff is FC - CC,
    nl,
    write('--- TRADE-OFF ANALYSIS ---'), nl,
    format('Fastest route saves: ~w hours of travel time.~n', [TimeSaved]),
    format('Cheapest route saves: Rs. ~w in travel budget.~n', [CostDiff]),
    write('Decision Rule: Choose Fastest if time is critical; choose Cheapest for budget travel.'), nl,
    write('=================================================='), nl.

show_all_routes(Source, Dest) :-
    nl,
    write('=================================================='), nl,
    write('         ALL AVAILABLE CANDIDATE ROUTES           '), nl,
    write('=================================================='), nl,
    find_path(Source, Dest, [Source], RevPath, D, T, C),
    reverse_path(RevPath, [], ForwardPath),
    write('Route: '), print_route(ForwardPath),
    format('       Distance: ~w km | Time: ~w hrs | Cost: Rs. ~w~n', [D, T, C]),
    fail.
show_all_routes(_, _) :-
    write('=================================================='), nl.

% Quick test shortcuts
test1 :- plan_travel(city_a, city_f, cheapest).
test2 :- plan_travel(city_a, city_f, fastest).
test3 :- plan_travel(city_a, city_f, shortest).

run_all_tests :-
    test1,
    test2,
    test3,
    plan_travel_avoid(city_a, city_f, cheapest, city_b),
    plan_travel_block(city_a, city_f, cheapest, city_a, city_b),
    compare_cheapest_fastest(city_a, city_f).

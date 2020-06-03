:-include(game).

solve(Problem, Solution) :-
    % unify
    Problem = [Tops, Rights, Boxes, Solutions, sokoban(Sokoban)],
    % clean up and add clauses to db
    abolish_all_tables,
    retractall(top(_,_)),
    findall(_, (member(P, Tops), assert(P)), _),
    retractall(right(_,_)),
    findall(_, ( member(P, Rights), assert(P) ), _),
    retractall(solution(_)),
    findall(_, ( member(P, Solutions), assert(P) ), _),
    retractall(initial_state(_,_)),
    findall(Box, member(box(Box), Boxes), BoxLocs),
    assert(initial_state(sokoban, state(Sokoban, BoxLocs))),
    % solve
    solve_problem(Solution).

mark_visited_state(state(Sokoban, Boxes)) :- assert(visited_state(Sokoban, Boxes)).

check_visited_state(state(Sokoban, Boxes)) :- \+ visited_state(Sokoban, Boxes).

solve_problem(Solution) :-
    initial_state(sokoban, St),
    retractall(visited_state(_, _)),
    solve_problem(sokoban, Solution, St),
    !.

%1. Check if current state is a terminal state
%- if so, we are done, just return the move sequence
solve_problem(sokoban, [], St) :- final_state(sokoban, St), !.
%2. If not:
solve_problem(sokoban, Solution, St) :-
    % Check if we weren't in the same state before
    check_visited_state(St),
    mark_visited_state(St),
    %- Pick a box & direction to move, ensure move valid
    movement(St, push(Box, Dir), MovesToDo),
    %- compute next state
    update(St, push(Box, Dir), NewState),
    %- do the same recursively on the next state
    neib(P, Box, Dir),
    append(MovesToDo, [move(P, Dir)|M], Solution),
    solve_problem(sokoban, M, NewState),
    !.

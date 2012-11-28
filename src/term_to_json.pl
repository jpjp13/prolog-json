/** <module> Term-to-JSON conversion.
 *
 *  Converts a Prolog term into a JSON object atom.
 */

:- module(_,
    [
        parse_object//1
    ]).

:- include(json(include/common)).

parse_object(json([])) -->
    !,
    ['{'],
    ['}'].
parse_object(json(Members)) -->
    ['{'],
    parse_members(Members),
    ['}'].

parse_members([Pair]) -->
    !,
    parse_pair(Pair).
parse_members([Pair|Pairs]) -->
    parse_pair(Pair),
    [','],
    parse_members(Pairs).

parse_pair(Key-Value) -->
    parse_key(Key),
    [':'],
    parse_value(Value).

parse_key(Key) -->
    parse_atom(Key).

parse_value(Value) -->
    { looks_like_list(Value) }, % Must precede atom() check!
    !,
    parse_array(Value).
parse_value(json(Value)) -->
    !,
    parse_object(json(Value)).
parse_value(+Value) -->
    !,
    parse_symbol(Value).
parse_value(Value) -->
    { core:atom(Value) },
    !,
    parse_atom(Value).
parse_value(Value) -->
    { core:float(Value) },
    !,
    parse_float(Value).
parse_value(Value) -->
    { core:integer(Value) },
    !,
    parse_integer(Value).

looks_like_list([]).
looks_like_list([_|_]).

parse_atom(Value) -->
    ['"'],
    { core:atom_chars(Value, Chars) },
    Chars,
    ['"'].

parse_float(Value) -->
    { json_to_term:chars_number(Chars, Value) },
    Chars.

parse_integer(Value) -->
    { json_to_term:chars_number(Chars, Value) },
    Chars.

parse_array([]) -->
    !,
    ['['],
    [']'].
parse_array(Values) -->
    ['['],
    parse_array_values(Values),
    [']'].

parse_array_values([Value]) -->
    !,
    parse_value(Value).
parse_array_values([Value|Values]) -->
    parse_value(Value),
    [','],
    parse_array_values(Values).

parse_symbol(true)  --> !, [t,r,u,e].
parse_symbol(false) --> !, [f,a,l,s,e].
parse_symbol(null)  --> !, [n,u,l,l].
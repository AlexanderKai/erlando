%%%-------------------------------------------------------------------
%%% @author Chen Slepher <slepheric@gmail.com>
%%% @copyright (C) 2017, Chen Slepher
%%% @doc
%%%
%%% @end
%%% Created : 19 June 2017 by Chen Slepher <slepheric@gmail.com>
%%%-------------------------------------------------------------------
-module(reader_t).

-compile({parse_transform, do}).
-compile({no_auto_import, [get/1, put/2]}).

-include("op.hrl").

-behaviour(type).
-behaviour(functor).
-behaviour(applicative).
-behaviour(monad).
-behaviour(monad_trans).
-behaviour(monad_fail).
-behaviour(monad_reader).
-behaviour(monad_state).
-behaviour(alternative).
-behaviour(monad_plus).
-behaviour(monad_runner).

-export_type([reader_t/3]).

-export([type/0]).

-export([new/1, reader_t/1, run_reader_t/1]).
% impl of functor
-export([fmap/2, '<$'/2]).
% impl of applicative
-export([pure/1, '<*>'/2, lift_a2/3, '*>'/2, '<*'/2]).
-export([pure/2]).
% impl of monad
-export(['>>='/2, '>>'/2, return/1]).
-export([return/2]).
% impl of monad_trans
-export([lift/1]).
% impl of monad fail
-export([fail/1]).
-export([fail/2]).
% impl of monad reader
-export([ask/0, reader/1, local/2]).
-export([ask/1, reader/2]).
% impl of monad state
-export([get/0, put/1, state/1]).
-export([get/1, put/2, state/2]).
% impl of alternative.
-export([empty/0, '<|>'/2]).
-export([empty/1]).
% impl of monad_plus.
-export([mzero/0, mplus/2]).
-export([mzero/1]).
% impl of monad_runner.
-export([run_nargs/0, run_m/2]).
% reader related functions
-export([run/2, map/2, with/2]).

-opaque reader_t(R, M, A) :: {reader_t, inner_t(R, M, A)}.
-type inner_t(R, M, A) :: fun( (R) -> monad:monadic(M, A)).

-type t(M) :: {reader_t, M}.

type() ->
    type:default_type(?MODULE).

-spec new(M) -> t(M) when M :: monad:monad().
new(M) ->
    {?MODULE, M}.

-spec reader_t(inner_t(R, M, A)) -> reader_t(R, M, A).
reader_t(Inner) ->
    {?MODULE, Inner}.

-spec run_reader_t(reader_t(R, M, A)) -> inner_t(R, M, A).
run_reader_t({?MODULE, Inner}) ->
    Inner;
run_reader_t({undetermined, _} = U) ->
    run_reader_t(undetermined:run(U, ?MODULE));
run_reader_t(Other) ->
    exit({invalid_reader_t, Other}).

-spec fmap(fun((A) -> B), reader_t(R, M, A)) -> reader_t(R, M, B).
fmap(F, RTA) ->
    map(
      fun(FA) ->
              F /'<$>'/ FA
      end, RTA).

'<$'(B, FA) ->
    functor:'default_<$'(B, FA, ?MODULE).

-spec pure(A) -> reader_t(_R, _M, A).
pure(A) ->
    reader_t(fun (_) -> applicative:pure(A) end).

pure(A, IM) ->
    reader_t(fun (_) -> applicative:pure(A, IM) end).

-spec '<*>'(reader_t(R, M, fun((A) -> B)), reader_t(R, M, A)) -> reader_t(R, M, B).
'<*>'(RTAB, RTA) ->
    reader_t(
      fun(R) ->
              (run(RTAB, R) /'<*>'/ run(RTA, R))
      end).

-spec lift_a2(fun((A, B) -> C), reader_t(R, M, A), reader_t(R, M, B)) -> reader_t(R, M, C).
lift_a2(F, RTA, RTB) ->
    applicative:default_lift_a2(F, RTA, RTB, ?MODULE).

-spec '*>'(reader_t(R, M, _A), reader_t(R, M, B)) -> reader_t(R, M, B).
'*>'(RTA, RTB) ->
    applicative:'default_*>'(RTA, RTB, ?MODULE).

-spec '<*'(reader_t(R, M, A), reader_t(R, M, _B)) -> reader_t(R, M, A).
'<*'(RTA, RTB) ->
    applicative:'default_<*'(RTA, RTB, ?MODULE).

-spec '>>='(reader_t(R, M, A), fun( (A) -> reader_t(R, M, B) )) -> reader_t(R, M, B).
'>>='(RTA, KRTB) ->
    reader_t(
      fun(R) ->
              do([monad || 
                     A <- run(RTA, R),
                     run(KRTB(A), R)
               ])
      end).

-spec '>>'(reader_t(R, M, _A), reader_t(R, M, B)) -> reader_t(R, M, B).
'>>'(RTA, RTB) ->
    monad:'default_>>'(RTA, RTB, ?MODULE).

-spec return(A) -> reader_t(_R, _M, A).
return(A) ->
    return(A, applicative).

return(A, IM) ->
    monad:default_return(A, {?MODULE, IM}).

-spec lift(monad:monadic(M, A)) -> reader_t(_R, M, A).
lift(X) ->
    reader_t(fun(_) -> X end).

-spec fail(any()) -> reader_t(_R, _M, _A).
fail(E) ->
    fail(E, monad_fail).

-spec fail(any(), t(M)) -> reader_t(_R, M, _A).
fail(E, IM) ->
    reader_t(fun (_) -> monad_fail:fail(E, IM) end).

-spec ask() -> reader_t(R, _M, R).
ask() ->
    ask(monad).

ask(IM) ->
    reader_t(fun(R) -> monad:return(R, IM) end).

-spec local(fun( (R) -> R), reader_t(R, M, A)) -> reader_t(R, M, A).
local(F, RA) ->
    with(F, RA).

-spec reader(fun( (R) -> A)) -> reader_t(R, _M, A).
reader(F) ->
    reader(F, monad).

reader(F, IM) ->
    reader_t(fun(R) -> monad:return(F(R), IM) end).

get() ->
    get(monad_state).

get(IM) ->
    lift(monad_state:get(IM)).

put(S) ->
    put(S, monad_state).

put(S, IM) ->
    lift(monad_state:put(S, IM)).

state(F) ->
    state(F, monad_state).

state(F, IM) ->
    lift(monad_state:state(F, IM)).

empty() ->
    empty(alternative).

empty(IM) ->
    lift(alternative:empty(IM)).

'<|>'(RTA, RTB) ->
    reader_t(
      fun(R) ->
              alternative:'<|>'(run(RTA, R), run(RTB, R))
      end).

mzero() ->
    mzero(monad_plus).

-spec mzero() -> reader_t(_R, _M, _A).
mzero(IM) ->
    lift(monad_plus:mzero(IM)).

-spec mplus(reader_t(R, M, A), reader_t(R, M, A)) -> reader_t(R, M, A).
mplus(RTA, RTB) ->
    reader_t(
      fun(R) ->
              monad_plus:mplus(run(RTA, R), run(RTB, R))
      end).

run_nargs() ->
    1.

run_m(MR, [R]) ->
    run(MR, R).

-spec run(reader_t(R, M, A), R) -> monad:monadic(M, A).
run(MR, R) ->
    (run_reader_t(MR))(R).

-spec map(fun((monad:monadic(M, R)) -> monad:monadic(N, R)), reader_t(R, M, A)) -> reader_t(R, N, A).
map(F, MR) ->
    reader_t(fun(R) -> F(run(MR, R)) end).
    
-spec with(fun((NR) -> R), reader_t(NR, M, A)) -> reader_t(R, M, A).
with(F, MR) ->
    reader_t(fun(R) -> run(MR, F(R)) end).

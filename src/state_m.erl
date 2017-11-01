%%%-------------------------------------------------------------------
%%% @author Chen Slepher <slepheric@gmail.com>
%%% @copyright (C) 2017, Chen Slepher
%%% @doc
%%%
%%% @end
%%% Created : 16 Oct 2017 by Chen Slepher <slepheric@gmail.com>
%%%-------------------------------------------------------------------
-module(state_m).

-compile({parse_transform, monad_t_transform}).

-behaviour(functor).
-behaviour(applicative).
-behaviour(monad).
-behaviour(monad_state).

-transform({state_t, false, [fmap/2, '<$'/2, '<*>'/2, lift_a2/3, '*>'/2, '<*'/2, '>>='/2, '>>'/2]}).
-transform({state_t, true,  [pure/1, return/1, get/0, put/1, state/1]}).
-transform({state_t, false, true, [eval/2, exec/2, run/2]}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================

%%%-------------------------------------------------------------------
%%% @author Chen Slepher <slepheric@gmail.com>
%%% @copyright (C) 2017, Chen Slepher
%%% @doc
%%%
%%% @end
%%% Created :  1 Sep 2017 by Chen Slepher <slepheric@gmail.com>
%%%-------------------------------------------------------------------
-module(overload_op_example).

-compile({parse_transform, overload_op}).
-overloads(['>>=', '>>']).
%% API
-export([test/0]).

%%%===================================================================
%%% API
%%%===================================================================

%% is infixr and outputs 5
test() ->
    1 /'>>='/ 2 /'>>'/ 3.

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
'>>='(A, B) ->
    A * B.

'>>'(A, B) ->
    A + B.
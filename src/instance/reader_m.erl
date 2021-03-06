%%%-------------------------------------------------------------------
%%% @author Chen Slepher <slepheric@gmail.com>
%%% @copyright (C) 2017, Chen Slepher
%%% @doc
%%%
%%% @end
%%% Created : 16 Oct 2017 by Chen Slepher <slepheric@gmail.com>
%%%-------------------------------------------------------------------
-module(reader_m).

-erlando_type({?MODULE, []}).

-include("gen_fun.hrl").

-define(READER, {reader_t, identity}).

-behaviour(functor).
-behaviour(applicative).
-behaviour(monad).
-behaviour(monad_reader).
-behaviour(monad_fail).

-gen_fun(#{remote => reader_t, inner_type => identity,
             behaviours => [functor, applicative, monad, monad_reader]}).

-gen_fun(#{remote => monad_fail_instance, inner_type => identity,
           behaviours => [monad_fail]}).

-gen_fun(#{remote => reader_t, args => identity, extra_call => {identity, run}, 
             functions => [run/2]}).

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

